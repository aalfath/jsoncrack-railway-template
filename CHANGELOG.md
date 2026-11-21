# Changelog

Breaking changes come first in each entry.

## v5.0.0-1 (2026-11-21)

No breaking changes. No app or image change; nothing to redeploy.

- README: the Deploy on Railway button now links to the published template code `json-crack` (it pointed at `jsoncrack`, which doesn't exist).

## v5.0.0 (2026-11-21)

First release of the template.

- JSON Crack v5.0.0, built from the release commit `e99288b4eff060dcd53428f2a3a5c2f28eecffa6` (upstream publishes no Docker image).
- Build on `node:24.22.3-alpine@sha256:116b800c…`, serve with `nginxinc/nginx-unprivileged:1.30.6-alpine@sha256:f5116ed4…`.
- The build turns off browser source maps and caps Next.js at 2 build workers (it ran out of memory on hosts with many CPUs).
- nginx listens on Railway's `PORT` with 2 workers, serves clean URLs and `/healthz`, and `/robots.txt` disallows indexing. Upstream's `CNAME` and sitemaps are removed.
- Upstream's banner and pop-up are off by default (`NEXT_PUBLIC_DISABLE_EXTERNAL_MODE=true`); `NEXT_PUBLIC_NODE_LIMIT` defaults to `800`.
