#!/usr/bin/env bash
# Wrapper do servidor FIM (autocomplete). Usado pelo systemd user unit llama-fim.
set -euo pipefail
export LD_LIBRARY_PATH="$HOME/.local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
ENV_FILE="$HOME/.config/llama-server/llama-fim.env"

# shellcheck source=/dev/null
source "$ENV_FILE"

exec "$HOME/.local/bin/llama-server" \
  --model "$MODEL" \
  --host "$HOST" \
  --port "$PORT" \
  --ctx-size "$CTX" \
  --parallel "$PARALLEL" \
  $FLAGS
