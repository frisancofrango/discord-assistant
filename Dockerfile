# opencode free farm — one Fly app = one fresh free bucket (IP + deviceId)
FROM node:20-slim

# opencode CLI (npm package is opencode-ai)
RUN npm install -g opencode-ai || npm install -g opencode-ai@latest

WORKDIR /app

# fresh deviceId per boot (ephemeral dir, wiped in entrypoint)
ENV OPENCODE_CONFIG_DIR=/tmp/opencode-config
ENV OPENCODE_LLM_PROXY_PORT=4010
ENV OPENCODE_LLM_PROXY_TOKEN=change-me
ENV MODEL=opencode/mimo-v2.5-free

COPY server.js /app/server.js
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 4010
CMD ["/app/entrypoint.sh"]
