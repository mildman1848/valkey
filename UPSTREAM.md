# Upstream

| Field | Value |
|---|---|
| Project | Valkey |
| Website | <https://valkey.io/> |
| Source | <https://github.com/valkey-io/valkey> |
| Alpine package | <https://pkgs.alpinelinux.org/packages?name=valkey> |
| License | BSD-3-Clause AND BSD-2-Clause AND MIT |
| Current packaged version | 9.0.4-r0 on Alpine 3.24 main |

This image uses the Alpine `valkey` package rather than compiling from source.

## License compatibility

Valkey remains under permissive BSD-family/MIT-compatible licensing in Alpine 3.24. That makes it suitable for this public image pattern.

Redis 8.x is intentionally not used here because current Redis licensing moved to AGPL/SSPL/RSAL-style options, which carry materially more compliance risk for a public image family.
