# JSON Crack for Railway.
# Upstream publishes no Docker image, so this builds the static web app from the
# v5.0.0 release (pinned to its commit) and serves it with nginx. Base images are
# pinned by version and digest.

# ---- Build: Next.js static export of apps/www ----
FROM node:24.22.3-alpine@sha256:116b800c3754b440ee0aa3ed2f20f5bf3d99a554bfd9adeea09ea8017f6e85f5 AS build

ARG JSONCRACK_VERSION=v5.0.0
ARG JSONCRACK_COMMIT=e99288b4eff060dcd53428f2a3a5c2f28eecffa6
# Build-time settings of the app (Next.js bakes NEXT_PUBLIC_* into the bundle).
# Set them as service variables on Railway and redeploy to change them.
ARG NEXT_PUBLIC_NODE_LIMIT=800
ARG NEXT_PUBLIC_DISABLE_EXTERNAL_MODE=true

ENV NEXT_TELEMETRY_DISABLED=1 \
    NODE_OPTIONS=--max-old-space-size=3072 \
    CI=1

RUN npm install -g pnpm@10.20.0

# Source of the pinned release commit (content at a commit SHA never changes).
WORKDIR /src
RUN node -e 'fetch(process.argv[1]).then(r=>{if(!r.ok)throw new Error("HTTP "+r.status);return r.arrayBuffer()}).then(b=>require("fs").writeFileSync("/tmp/src.tgz",Buffer.from(b)))' \
      "https://codeload.github.com/AykutSarac/jsoncrack.com/tar.gz/${JSONCRACK_COMMIT}" && \
    tar -xzf /tmp/src.tgz --strip-components=1 && \
    rm /tmp/src.tgz && \
    test -f apps/www/package.json

# Only the web app and the workspace package it uses (jsoncrack-react).
RUN pnpm install --frozen-lockfile --filter "www..."

RUN printf 'NEXT_PUBLIC_NODE_LIMIT=%s\nNEXT_PUBLIC_DISABLE_EXTERNAL_MODE=%s\nNEXT_TELEMETRY_DISABLED=1\n' \
      "${NEXT_PUBLIC_NODE_LIMIT}" "${NEXT_PUBLIC_DISABLE_EXTERNAL_MODE}" > apps/www/.env.production.local && \
    pnpm --filter "www..." run build && \
    test -f apps/www/out/editor.html

# ---- Serve: nginx (unprivileged) on Railway's PORT ----
FROM nginxinc/nginx-unprivileged:1.30.6-alpine@sha256:f5116ed4606f3eb015dd4a8e28cb9b351476dc0ad4bc6e9f93b19cec130cdf03

COPY --from=build /src/apps/www/out /usr/share/nginx/html
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
COPY nginx/robots.txt /usr/share/nginx/html/robots.txt

# nginx's entrypoint renders the template with PORT; Railway sets PORT too.
ENV PORT=8080
EXPOSE 8080
