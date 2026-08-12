#!/bin/bash
# fresh deviceId per boot ??? wipe config dir, regenerate
rm -rf $OPENCODE_CONFIG_DIR
mkdir -p $OPENCODE_CONFIG_DIR

# opencode config: free model + llm-proxy plugin loaded by ABSOLUTE PATH
cat > $OPENCODE_CONFIG_DIR/opencode.json <<EOF
{
  "\$schema": "https://opencode.ai",
  "model": "opencode/mimo-v2.5-free",
  "plugin": ["/app/node_modules/opencode-llm-proxy/dist/llm-proxy.js"]
}
EOF

echo "[boot] OPENCODE_CONFIG_DIR=$OPENCODE_CONFIG_DIR"
ls -la $OPENCODE_CONFIG_DIR
ls -la /app/node_modules/opencode-llm-proxy/dist/ 2>&1 | head -5

# run opencode headless server on internal port 4000 (llm-proxy listens on 4010 externally)
exec opencode serve --hostname 0.0.0.0 --port 4000
