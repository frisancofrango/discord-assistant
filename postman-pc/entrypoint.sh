#!/bin/bash
echo "[boot] versions:"
echo "  newman:    $(newman --version 2>&1 | head -1)"
echo "  postman:   $(postman --version 2>&1 | head -1 || echo unavailable)"
echo "  code-server: $(code-server --version 2>&1 | head -1 || echo unavailable)"
echo "  opencode:  $(opencode --version 2>&1 | head -1)"
echo "[boot] IDE: https://<app>.fly.dev  (password from PASSWORD env)"
echo "[boot] SSH: flyctl ssh console --app <app>"
echo "[boot] postman: newman run collection.json -e env.json"

# start code-server (VS Code in browser) ??? blocking, keeps machine alive
exec code-server --bind-addr 0.0.0.0:8080 --auth password --password "$PASSWORD" --disable-telemetry
