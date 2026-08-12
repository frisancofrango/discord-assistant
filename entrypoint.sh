#!/bin/bash
# fresh deviceId per boot ??? wipe config dir, regenerate
rm -rf $OPENCODE_CONFIG_DIR
mkdir -p $OPENCODE_CONFIG_DIR

# opencode config: free model
cat > $OPENCODE_CONFIG_DIR/opencode.json <<EOF
{
  "\$schema": "https://opencode.ai",
  "model": "opencode/mimo-v2.5-free"
}
EOF

echo "[boot] OPENCODE_CONFIG_DIR=$OPENCODE_CONFIG_DIR"
ls -la $OPENCODE_CONFIG_DIR

# self-contained OpenAI-compatible server wrapping `opencode run`
exec node /app/server.js
