# opencode free farm — one Fly app = one fresh free bucket (IP + deviceId)
FROM node:20-slim

# opencode CLI + llm-proxy plugin
RUN npm install -g opencode@1.18.16 || npm install -g opencode
RUN npm install -g opencode-llm-proxy

# fresh deviceId per boot (ephemeral dir, wiped in entrypoint)
ENV OPENCODE_CONFIG_DIR=/tmp/opencode-config
ENV OPENCODE_LLM_PROXY_HOST=0.0.0.0
ENV OPENCODE_LLM_PROXY_PORT=4010
ENV OPENCODE_LLM_PROXY_TOKEN=change-me
ENV OPENCODE_LLM_PROXY_MAX_CONCURRENT_REQUESTS=4
ENV OPENCODE_LLM_PROXY_MAX_QUEUED_REQUESTS=16

WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 4010
CMD ["/app/entrypoint.sh"]
