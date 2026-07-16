#!/usr/bin/env bash
set -euo pipefail

image="${1:?Usage: smoke-test.sh IMAGE}"
name="valkey-smoke-$$"
tmpdir="$(mktemp -d)"
DOCKER_BIN="${DOCKER:-docker}"
password="valkey-change-me-$RANDOM-$$"

cleanup() {
  ${DOCKER_BIN} rm -f "$name" >/dev/null 2>&1 || true
  if command -v sudo >/dev/null 2>&1; then
    sudo rm -rf "$tmpdir" >/dev/null 2>&1 || rm -rf "$tmpdir" >/dev/null 2>&1 || true
  else
    rm -rf "$tmpdir" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

mkdir -p "$tmpdir/config"
printf '%s' "$password" > "$tmpdir/valkey_password"
chmod 600 "$tmpdir/valkey_password"

${DOCKER_BIN} run -d --name "$name" \
  -e PUID="$(id -u)" \
  -e PGID="$(id -g)" \
  -e FILE__VALKEY_PASSWORD=/run/secrets/valkey_password \
  -v "$tmpdir/config:/config" \
  -v "$tmpdir/valkey_password:/run/secrets/valkey_password:ro" \
  "$image"

for _ in {1..60}; do
  if ${DOCKER_BIN} exec "$name" /usr/local/bin/healthcheck >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

${DOCKER_BIN} exec "$name" /usr/local/bin/healthcheck | grep -qx 'PONG'
${DOCKER_BIN} exec "$name" valkey-cli -h 127.0.0.1 -p 6379 -a "$password" --no-auth-warning set smoke ok | grep -qx 'OK'
${DOCKER_BIN} exec "$name" valkey-cli -h 127.0.0.1 -p 6379 -a "$password" --no-auth-warning get smoke | grep -qx 'ok'

wrong_password_output="$(${DOCKER_BIN} exec "$name" valkey-cli -h 127.0.0.1 -p 6379 -a definitely-wrong-password --no-auth-warning ping 2>&1 || true)"
if grep -qx 'PONG' <<<"$wrong_password_output"; then
  echo 'ERROR: Valkey accepted a deliberately wrong password' >&2
  exit 1
fi

process_users="$(${DOCKER_BIN} exec "$name" sh -lc "ps aux | awk '\$11 ~ /valkey-server/ {print \$1}' | sort -u")"
if [[ -z "$process_users" ]]; then
  echo 'ERROR: no Valkey process found' >&2
  ${DOCKER_BIN} logs "$name" >&2 || true
  exit 1
fi
if grep -qx 'root' <<<"$process_users"; then
  echo 'ERROR: Valkey process is running as root' >&2
  exit 1
fi
abc_uid="$(${DOCKER_BIN} exec "$name" sh -lc 'id -u abc')"
if ! grep -Eq "^(abc|${abc_uid})$" <<<"$process_users"; then
  echo "ERROR: Valkey process did not run as abc; observed: $process_users, abc_uid=${abc_uid}" >&2
  exit 1
fi

if ${DOCKER_BIN} exec "$name" sh -lc "tr '\0' ' ' </proc/1/cmdline | grep -F '$password'" >/dev/null 2>&1; then
  echo 'ERROR: generated Valkey secret leaked into process command line' >&2
  exit 1
fi

logs="$(${DOCKER_BIN} logs "$name" 2>&1 || true)"
if grep -F "$password" <<<"$logs" >/dev/null; then
  echo 'ERROR: generated Valkey secret leaked into container logs' >&2
  exit 1
fi

if ! grep -F 'Brand: Mildman1848' <<<"$logs" >/dev/null; then
  echo 'ERROR: expected Mildman1848 branding not found in logs' >&2
  exit 1
fi
if grep -i 'milde' <<<"$logs" >/dev/null; then
  echo 'ERROR: forbidden private branding token found in logs' >&2
  exit 1
fi

echo 'Valkey smoke test passed: health, auth, wrong-password rejection, abc process user, no secret leak'
