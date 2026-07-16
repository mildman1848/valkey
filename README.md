# Mildman1848 Valkey Docker Image

LinuxServer.io-style Valkey image with s6-overlay, `/config` persistence, optional `FILE__` secret support, and multiarch Buildx CI.

Valkey is a high-performance key/value datastore and the open-source fork used by modern stacks such as Immich as a Redis-protocol-compatible service. Menschen haben Redis kompliziert gemacht. Valkey macht es wieder langweiliger. Das ist ein Feature.

## Image metadata

| Field | Value |
|---|---|
| Upstream | <https://valkey.io/> |
| Source | <https://github.com/valkey-io/valkey> |
| Alpine package | `valkey` from Alpine main |
| Base image | `ghcr.io/linuxserver/baseimage-alpine:3.24` |
| Version | `9.0.4-mldm1` |
| License | `BSD-3-Clause AND BSD-2-Clause AND MIT` |
| Required platforms | `linux/amd64`, `linux/arm64` |

## Quick start

```bash
make build DOCKER='sudo docker'
make smoke DOCKER='sudo docker'
```

Run locally with generated password secret:

```bash
make secrets
make start DOCKER='sudo docker'
make logs DOCKER='sudo docker'
```

Connect:

```bash
VALKEY_PASSWORD="$(cat secrets/valkey_password.txt)"
sudo docker exec -it valkey-dev valkey-cli -a "$VALKEY_PASSWORD" --no-auth-warning ping
```

Expected:

```text
PONG
```

## Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `PUID` | `911` from LSIO base unless overridden | Runtime user id for `abc` |
| `PGID` | `911` from LSIO base unless overridden | Runtime group id for `abc` |
| `TZ` | unset | Timezone |
| `VALKEY_PASSWORD` | unset | Optional password. Prefer `FILE__VALKEY_PASSWORD`. |
| `FILE__VALKEY_PASSWORD` | unset | Path to a file containing the Valkey password. |
| `VALKEY_CONFIG` | `/config/valkey.conf` | Runtime config file path. |

## Persistent data

Mount `/config`. The default config stores RDB/AOF data under `/config`:

```yaml
volumes:
  - ./config:/config
```

## Immich note

Immich currently uses a service named `redis` with a Valkey image in its official Docker Compose example. If replacing Redis in an Immich stack, keep the service/DNS name `redis` unless you also change Immich's environment.

Example:

```yaml
redis:
  image: docker.io/valkey/valkey:9
  healthcheck:
    test: redis-cli ping || exit 1
  restart: always
```

For this custom image:

```yaml
redis:
  image: ghcr.io/mildman1848/valkey:9.0.4-mldm1
  restart: always
```

## Security notes

- Prefer `FILE__VALKEY_PASSWORD` over plain environment values.
- The password is written into `/config/valkey-auth.conf` with mode `0600` so it is not exposed in the process command line.
- Do not publish generated files from `config/` or `secrets/`.
- Smoke tests verify auth, wrong-password rejection, `abc` runtime user, branding, and no secret in logs.
- Trivy `DS-0002` is expected for LSIO-based images because `/init` must start as root; the final Valkey process drops to `abc` after LSIO initialization.

## Useful targets

```bash
make info
make lint
make build DOCKER='sudo docker'
make smoke DOCKER='sudo docker'
make scan DOCKER='sudo docker' TRIVY='sudo trivy'
make sbom DOCKER='sudo docker' SYFT='sudo syft'
make release-dry-run
```
