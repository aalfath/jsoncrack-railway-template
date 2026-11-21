[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/jsoncrack?utm_medium=integration&utm_source=button&utm_campaign=jsoncrack)

# JSON Crack on Railway

One-click [JSON Crack](https://github.com/AykutSarac/jsoncrack.com) on Railway, built from this repo. JSON Crack turns JSON, YAML, CSV and XML into interactive graphs, and can validate, format, convert, query (jq, JSONPath) and generate types or JSON Schema from your data.

**Version:** JSON Crack **v5.0.0** (release commit [`e99288b`](https://github.com/AykutSarac/jsoncrack.com/tree/e99288b4eff060dcd53428f2a3a5c2f28eecffa6)). Upstream publishes no Docker image, so the `Dockerfile` builds the static site from that pinned commit:

- build stage: `node:24.22.3-alpine@sha256:116b800c3754b440ee0aa3ed2f20f5bf3d99a554bfd9adeea09ea8017f6e85f5` with pnpm 10.20.0 and upstream's frozen lockfile;
- serve stage: `nginxinc/nginx-unprivileged:1.30.6-alpine@sha256:f5116ed4606f3eb015dd4a8e28cb9b351476dc0ad4bc6e9f93b19cec130cdf03`.

## What you get

| Service | Built from | What it does | Volume |
|---|---|---|---|
| **JSON Crack** (public) | this repo's `Dockerfile` | The JSON Crack web app (landing page, `/editor`, converters, type generators, docs) served by nginx on `PORT` behind Railway's HTTPS domain. Health check: `/healthz` | none needed |

JSON Crack runs entirely in the browser. Data you paste or open stays in the visitor's browser tab (session storage) and is never sent to the server, so the template has no database and no volume, and a redeploy or restart loses nothing.

What this repo adds to upstream:

- nginx listens on Railway's `PORT` (8080 by default), with clean URLs for every page of the static export (`/editor`, `/converter/json-to-yaml`, …), gzip, long caching for hashed assets, and `/healthz` for Railway's health check.
- `/robots.txt` keeps search engines out of your instance.
- The build turns off browser source maps and caps Next.js at 2 build workers, so it fits in a few GB of memory on any builder.
- Upstream's promotional banner and "self-hosted" pop-up are turned off (`NEXT_PUBLIC_DISABLE_EXTERNAL_MODE=true`).

## Variables

The deploy form asks for nothing.

- `PORT` = `8080`: nginx's port; the public domain targets it.

Optional build-time settings. Next.js bakes them into the site, so set them on the service and **redeploy** (a rebuild) to apply:

- `NEXT_PUBLIC_NODE_LIMIT` (default `800`): the largest graph, in nodes, the editor draws. Raise it for big files if your visitors' browsers cope.
- `NEXT_PUBLIC_DISABLE_EXTERNAL_MODE` (default `true`): set `false` to show upstream's banner and pop-up again.

## Good to know

- The site has no login. Anyone with the URL can use it, but nothing is stored or processed on the server.
- The editor's code panel loads the Monaco editor from `cdnjs.cloudflare.com`, so visitors' browsers need internet access (upstream behaviour).
- The first build takes a few minutes (Next.js static export); restarts take seconds.

## Updates

Railway sends everyone who deployed this template an "update available" notice when a change is merged to this repo's `main`. Each version is listed in [`CHANGELOG.md`](CHANGELOG.md), breaking changes first. To move to a new JSON Crack release we bump `JSONCRACK_VERSION`/`JSONCRACK_COMMIT` in the `Dockerfile`.

## Run it locally

```sh
docker build -t jsoncrack-railway .
docker run --rm -p 8080:8080 jsoncrack-railway
# open http://localhost:8080/editor
```

## Licence

JSON Crack is Apache-2.0 ([AykutSarac/jsoncrack.com](https://github.com/AykutSarac/jsoncrack.com/blob/main/LICENSE.md)). The wrapper files in this repo are MIT.
