#!/bin/bash
echo "[boot] newman: $(newman --version 2>&1 | head -1)"
echo "[boot] postman-cli: $(postman --version 2>&1 | head -1 || echo unavailable)"
echo "[boot] cloud PC ready ??? SSH: flyctl ssh console --app postman-pc"
echo "[boot] run collections: newman run collection.json -e env.json"
exec tail -f /dev/null
