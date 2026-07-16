# syntax=docker/dockerfile:1.7
ARG LSIO_BASE_VERSION=3.24
FROM ghcr.io/linuxserver/baseimage-alpine:${LSIO_BASE_VERSION}

ARG LSIO_BASE_VERSION
ARG APP_VERSION=9.0.4
ARG IMAGE_REVISION=mldm1
ARG VERSION=9.0.4-mldm1
ARG BUILD_DATE
ARG VCS_REF

ENV APP_VERSION="${APP_VERSION}" \
    IMAGE_REVISION="${IMAGE_REVISION}" \
    VERSION="${VERSION}"

LABEL build_version="Mildman1848 version:- ${VERSION} Upstream:- ${APP_VERSION} Revision:- ${IMAGE_REVISION} Build-date:- ${BUILD_DATE}" \
      maintainer="Mildman1848" \
      org.opencontainers.image.title="valkey" \
      org.opencontainers.image.description="LinuxServer.io-style Valkey image with s6-overlay and /config persistence" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.source="https://github.com/mildman1848/valkey" \
      org.opencontainers.image.url="https://github.com/mildman1848/valkey" \
      org.opencontainers.image.documentation="https://github.com/mildman1848/valkey#readme" \
      org.opencontainers.image.licenses="BSD-3-Clause AND BSD-2-Clause AND MIT" \
      org.opencontainers.image.base.name="ghcr.io/linuxserver/baseimage-alpine:${LSIO_BASE_VERSION}"

RUN apk add --no-cache \
      valkey \
      valkey-cli \
      tzdata \
    && mkdir -p /defaults /config

COPY root/ /
COPY defaults/ /defaults/

RUN chmod +x \
      /usr/local/bin/file-env \
      /usr/local/bin/start-app \
      /usr/local/bin/healthcheck \
      /usr/local/bin/app-healthcheck \
      /etc/s6-overlay/s6-rc.d/init-branding/run \
      /etc/s6-overlay/s6-rc.d/init-app-config/run \
      /etc/s6-overlay/s6-rc.d/app/run \
    && chmod 0644 /defaults/valkey.conf

VOLUME ["/config"]
EXPOSE 6379
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 CMD ["/usr/local/bin/healthcheck"]
