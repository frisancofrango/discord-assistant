# opencode free farm — one Fly app = one fresh free bucket (IP + deviceId)
FROM node:20-slim

# opencode CLI (npm package is opencode-ai)
RUN npm install -g opencode-ai || npm install -g opencode-ai@latest

# llm-proxy plugin installed LOCALLY so we can reference by absolute path
WORKDIR /app
RUN npm install opencode-llm-proxy

# fresh deviceId per boot (ephemeral dir, wiped in entrypoint)
ENV OPENCODE_CONFIG_DIR=/tmp/opencode-config
ENV OPENCODE_LLM_PROXY_HOST=0.0.0.0
ENV OPENCODE_LLM_PROXY_PORT=4010
ENV OPENCODE_LLM_PROXY_TOKEN=change-me
ENV OPENCODE_LLM_PROXY_MAX_CONCURRENT_REQUESTS=4
ENV OPENCODE_LLM_PROXY_MAX_QUEUED_REQUESTS=16

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 4010
CMD ["/app/entrypoint.sh"]
