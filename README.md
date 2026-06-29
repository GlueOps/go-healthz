# go-healthz

GlueOps container image for [`bdwyertech/go-healthz`](https://github.com/bdwyertech/go-healthz) — a simple bolt-on server health-check / readiness proxy.

This repository **does not contain or build the go-healthz source**. It is a thin packaging repo: the [`Dockerfile`](./Dockerfile) downloads the official upstream release binary, verifies it against the published `checksums.txt`, and bundles it into a minimal Debian image published to GHCR.

## Image

```
ghcr.io/glueops/go-healthz:<release-version>   # e.g. v0.1.0 (this repo's release-please version)
ghcr.io/glueops/go-healthz:latest
```

Images are built for `linux/amd64` and `linux/arm64`. The image is tagged with
this repo's release-please version — a single, consistent version scheme. The
actual upstream go-healthz version that's bundled is pinned by `ARG GITHUB_TAG`
in the [`Dockerfile`](./Dockerfile) (used only to fetch the right binary).

## Usage

A config file is expected at `/etc/go-healthz/config.yml`. Mount your own:

```bash
docker run --rm -p 8080:8080 \
  -v "$PWD/config.yml:/etc/go-healthz/config.yml:ro" \
  ghcr.io/glueops/go-healthz:latest
```

See the [upstream README](https://github.com/bdwyertech/go-healthz) for configuration options.

The container runs as a **non-root** user (UID/GID `65532`). No Kubernetes
changes are needed as long as your `bind:` port is `>= 1024` (privileged ports
still require root or the `NET_BIND_SERVICE` capability) and the mounted config
is readable by that user (a default ConfigMap mount, mode `0644`, is).

## How updates work

- The pinned upstream version lives in a single `ARG GITHUB_TAG=...` line in the [`Dockerfile`](./Dockerfile), annotated for Renovate (`datasource=github-releases depName=bdwyertech/go-healthz`).
- Renovate opens a PR whenever upstream cuts a new release; the PR build verifies the new binary downloads and passes checksum verification.
- [release-please](https://github.com/googleapis/release-please-action) manages this repo's version, changelog, and releases from Conventional Commits.
- When a release-please release is cut, the image is built and pushed to GHCR **tagged with that release version** (plus `latest`). One version scheme everywhere.
