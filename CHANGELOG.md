# Changelog

## 9.0.4-mldm1

- Initial Mildman1848 Valkey image based on `ghcr.io/linuxserver/baseimage-alpine:3.24`.
- Uses Alpine `valkey` package `9.0.4-r0`.
- Adds s6-overlay service supervision.
- Adds `/config` persistence.
- Adds optional `FILE__VALKEY_PASSWORD` support.
- Adds local smoke test for health, auth, wrong-password rejection, `abc` process user, and secret leak checks.
