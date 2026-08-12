# Cloud IDE PC — VS Code in browser + Postman tooling + opencode CLI
FROM node:20-slim

# ── Postman tooling ──
RUN npm install -g newman
RUN npm install -g postman-cli || true

# ── code-server (VS Code in browser) ──
RUN curl -fsSL https://code-server.dev/install.sh | sh || npm install -g code-server

# ── opencode CLI (free models, works from browser IDE) ──
RUN npm install -g opencode-ai || true

# ── tools for building stuff ──
RUN apt-get update -qq && apt-get install -y -qq curl jq git python3 > /dev/null 2>&1 || true

# ── runtime config ──
ENV PASSWORD=changeme
ENV CODE_SERVER_PORT=8080
ENV SHELL=/bin/bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
CMD ["/entrypoint.sh"]
