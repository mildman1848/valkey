# Licensing

Valkey is suitable for this image template because the upstream project and Alpine package use permissive licensing.

Verified package signal for Alpine 3.24:

```text
valkey 9.0.4-r0 license=BSD-3-Clause AND BSD-2-Clause AND MIT
```

The image must retain license notices and should expose the license through OCI labels:

```text
org.opencontainers.image.licenses=BSD-3-Clause AND BSD-2-Clause AND MIT
```

## Redis comparison

Redis 7.2 and older were BSD-3-Clause. Current Redis 8.x packages are not equivalent:

```text
redis 8.x license=AGPL-3.0-only OR SSPL-1.0
```

For this image family, Valkey is the recommended modern Redis-protocol-compatible target.
