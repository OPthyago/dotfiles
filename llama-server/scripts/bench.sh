#!/usr/bin/env bash
# Benchmark pp (prompt processing, proxy de TTFT) e tg (geração/throughput)
# com o modelo configurado no env.
set -euo pipefail
export LD_LIBRARY_PATH="$HOME/.local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
ENV_FILE="$HOME/.config/llama-server/llama-server.env"
# shellcheck source=/dev/null
source "$ENV_FILE"
exec "$HOME/.local/bin/llama-bench" -m "$MODEL" -ngl 99 -fa on
