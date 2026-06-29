# go-healthz

GlueOps container image for [`bdwyertech/go-healthz`](https://github.com/bdwyertech/go-healthz) — a simple bolt-on server health-check / readiness proxy.

This repository **does not contain or build the go-healthz source**. It is a thin packaging repo: the [`Dockerfile`](./Dockerfile) downloads the official upstream release binary, verifies it against the published `checksums.txt`, and bundles it into a minimal Debian image published to GHCR.

## Image

```
ghcr.io/glueops/go-healthz:<upstream-version>   # e.g. v0.4.11
ghcr.io/glueops/go-healthz:latest
```

Images are built for `linux/amd64` and `linux/arm64`.

## Usage

A config file is expected at `/etc/go-healthz/config.yml`. Mount your own:

```bash
docker run --rm -p 8080:8080 \
  -v "$PWD/config.yml:/etc/go-healthz/config.yml:ro" \
  ghcr.io/glueops/go-healthz:latest
```

See the [upstream README](https://github.com/bdwyertech/go-healthz) for configuration options.

## How updates work

- The pinned upstream version lives in a single `ARG GITHUB_TAG=...` line in the [`Dockerfile`](./Dockerfile), annotated for Renovate (`datasource=github-releases depName=bdwyertech/go-healthz`).
- Renovate opens a PR whenever upstream cuts a new release. Merging it rebuilds and republishes the image tagged with the new upstream version.
- [release-please](https://github.com/googleapis/release-please-action) manages this repo's own changelog and releases from Conventional Commits.
