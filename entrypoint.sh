#!/bin/bash
# fresh deviceId per boot ??? wipe config dir, regenerate
rm -rf $OPENCODE_CONFIG_DIR
mkdir -p $OPENCODE_CONFIG_DIR

# opencode config: free model + llm-proxy plugin (starts :4010 server automatically)
cat > $OPENCODE_CONFIG_DIR/opencode.json <<EOF
{
  "\$schema": "https://opencode.ai",
  "model": "opencode/mimo-v2.5-free",
  "plugin": ["opencode-llm-proxy"]
}
EOF

echo "[boot] OPENCODE_CONFIG_DIR=$OPENCODE_CONFIG_DIR"
ls -la $OPENCODE_CONFIG_DIR

# run opencode headless server on internal port 4000 (proxy listens on 4010 externally)
exec opencode serve --hostname 0.0.0.0 --port 4000
