#!/bin/bash
# fresh deviceId per boot ??? wipe config dir, regenerate
rm -rf $OPENCODE_CONFIG_DIR
mkdir -p $OPENCODE_CONFIG_DIR

cat > $OPENCODE_CONFIG_DIR/opencode.json <<EOF
{"\$schema":"https://opencode.ai","model":"opencode/mimo-v2.5-free"}
EOF

echo "[boot] versions:"
echo "  opencode:  $(opencode --version 2>&1 | head -1)"
echo "  newman:    $(newman --version 2>&1 | head -1)"
echo "  postman:   $(postman --version 2>&1 | head -1 || echo unavailable)"
echo "  code-server: $(code-server --version 2>&1 | head -1 || echo unavailable)"
echo "[boot] proxy  -> https://<app>.fly.dev/v1 (Bearer token)"
echo "[boot] IDE    -> https://<app>.fly.dev/ide/ (password from PASSWORD)"
echo "[boot] SSH    -> flyctl ssh console --app <app>"

# start the opencode free proxy in background
node /app/server.js &
PROXY_PID=$!
echo "[boot] proxy pid $PROXY_PID on :4010"

# start VS Code IDE in foreground (keeps machine alive)
exec code-server --bind-addr 0.0.0.0:$CODE_SERVER_PORT --auth password --password "$PASSWORD" --prefix /ide --disable-telemetry
