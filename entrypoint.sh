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
echo "[boot] IDE    -> https://<app>.fly.dev/ide/ (password from PASSWORD)"
echo "[boot] proxy  -> https://<app>.fly.dev/v1 (Bearer token)"
echo "[boot] SSH    -> flyctl ssh console --app <app>"

# opencode free proxy on :4010
node /app/server.js &
echo "[boot] proxy pid $! on :4010"

# VS Code IDE on :8080 under /ide
code-server --bind-addr 0.0.0.0:8080 --auth password --password "$PASSWORD" --prefix /ide --disable-telemetry &
echo "[boot] code-server pid $! on :8080"

sleep 2

# router on :80 -> /ide:8080, rest:4010 (foreground, keeps machine alive)
exec node /app/router.js
