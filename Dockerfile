# syntax=docker/dockerfile:1

# This repo does NOT build go-healthz from source. It repackages the official
# upstream release binary (https://github.com/bdwyertech/go-healthz) into a
# GlueOps container image. Renovate keeps the version below in sync with
# upstream releases and opens a PR whenever a new one ships.
#
# renovate: datasource=github-releases depName=bdwyertech/go-healthz
ARG GITHUB_TAG=v0.4.11

# --- STAGE 1: download + verify the upstream release binary ---
FROM alpine:3.21 AS fetch

ARG GITHUB_TAG
ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache ca-certificates curl tar

WORKDIR /work

# Download the upstream archive for the target platform plus the published
# checksums, verify the archive against checksums.txt, then extract the binary.
RUN set -eux; \
    base="https://github.com/bdwyertech/go-healthz/releases/download/${GITHUB_TAG}"; \
    file="go-healthz_${TARGETOS}_${TARGETARCH}.tar.gz"; \
    curl -fsSLO "${base}/${file}"; \
    curl -fsSLO "${base}/checksums.txt"; \
    grep " ${file}\$" checksums.txt | sha256sum -c -; \
    tar -xzf "${file}"; \
    chmod +x go-healthz

# --- STAGE 2: minimal runtime image ---
FROM debian:bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /etc/go-healthz \
 && groupadd -g 65532 nonroot \
 && useradd -u 65532 -g 65532 -M -s /usr/sbin/nologin nonroot \
 && chown nonroot:nonroot /etc/go-healthz

COPY --from=fetch /work/go-healthz /usr/bin/go-healthz

# Run as a non-root user (UID/GID 65532). This needs no Kubernetes changes as
# long as the configured bind port is >= 1024 (privileged ports still require
# root or the NET_BIND_SERVICE capability). The UID matches the common
# "nonroot" convention, so it also satisfies `runAsNonRoot: true` if set.
USER 65532:65532

# A config is expected to be mounted at /etc/go-healthz/config.yml at runtime.
ENTRYPOINT ["/usr/bin/go-healthz", "--config", "/etc/go-healthz/config.yml"]
