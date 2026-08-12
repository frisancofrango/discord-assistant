# ALL-IN-ONE: opencode free proxy (:4010) + VS Code IDE (:8080 /ide) + Postman CLI
FROM node:20-slim

# ── opencode CLI (npm package is opencode-ai) — powers the free proxy ──
RUN npm install -g opencode-ai || npm install -g opencode-ai@latest

# ── Postman tooling ──
RUN npm install -g newman
RUN npm install -g postman-cli || true

# ── code-server (VS Code in browser, under /ide) ──
RUN curl -fsSL https://code-server.dev/install.sh | sh || npm install -g code-server

# ── build tools for the IDE ──
RUN apt-get update -qq && apt-get install -y -qq curl jq git python3 > /dev/null 2>&1 || true

# ── fresh deviceId per boot (ephemeral dir, wiped in entrypoint) ──
ENV OPENCODE_CONFIG_DIR=/tmp/opencode-config
ENV OPENCODE_LLM_PROXY_PORT=4010
ENV OPENCODE_LLM_PROXY_TOKEN=change-me
ENV MODEL=opencode/mimo-v2.5-free
ENV PASSWORD=changeme
ENV CODE_SERVER_PORT=8080

WORKDIR /app
COPY server.js /app/server.js
COPY router.js /app/router.js
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 80 4010 8080
CMD ["/app/entrypoint.sh"]
