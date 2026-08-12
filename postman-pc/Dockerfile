# Cloud PC with Postman tooling — SSH in, drive with AI
FROM node:20-slim

# newman = classic Postman CLI runner (pure node, always works)
# postman-cli = official new CLI (may have pkg bug; newman is the reliable one)
RUN npm install -g newman
RUN npm install -g postman-cli || true

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# basic tools for building stuff
RUN apt-get update -qq && apt-get install -y -qq curl jq git > /dev/null 2>&1 || true

EXPOSE 4010
CMD ["/entrypoint.sh"]
