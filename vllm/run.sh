#!/usr/bin/env bash
# Wrapper do vLLM server. Usado pelo systemd user unit vllm.service.
set -euo pipefail

VENV_DIR="/home/thyagoop/.local/share/vllm"
source "$VENV_DIR/.venv/bin/activate"

MODEL="${MODEL:-/home/thyagoop/.lmstudio/models/unsloth/Qwen3.8-27B-NVFP4}"
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-1235}"
MAX_MODEL_LEN="${MAX_MODEL_LEN:-131072}"
GPU_MEM_UTIL="${GPU_MEM_UTIL:-0.93}"
MAX_NUM_SEQS="${MAX_NUM_SEQS:-4}"
# MTP custa ~0.85 GB de peso + estado por seq. Com 131k de contexto nao cabe.
ENABLE_MTP="${ENABLE_MTP:-0}"
NUM_SPEC_TOKENS="${NUM_SPEC_TOKENS:-2}"
# FlashInfer JIT nao compila para sm120 (exige nvcc CUDA >= 12.9; host tem 12.8).
# Com kv-cache fp8 + head_dim 256 os candidatos sao FLASHINFER e TRITON_ATTN -> TRITON.
ATTN_BACKEND="${ATTN_BACKEND:-TRITON_ATTN}"
export VLLM_USE_FLASHINFER_SAMPLER="${VLLM_USE_FLASHINFER_SAMPLER:-0}"
export PYTORCH_CUDA_ALLOC_CONF="${PYTORCH_CUDA_ALLOC_CONF:-expandable_segments:True}"
export VLLM_SKIP_P2P_CHECK="${VLLM_SKIP_P2P_CHECK:-1}"

SERVED_NAME="${SERVED_NAME:-qwen3.8-27b}"
# CUDA graphs custam ~0.5-1 GiB de VRAM mas aceleram decode. 0 = --enforce-eager.
CUDA_GRAPHS="${CUDA_GRAPHS:-1}"
CHAT_TEMPLATE="${CHAT_TEMPLATE:-/home/thyagoop/.local/share/vllm/qwen38-omp.jinja}"

ARGS=(
  --host "$HOST"
  --port "$PORT"
  --served-model-name "$SERVED_NAME"
  --attention-backend "$ATTN_BACKEND"
  --max-model-len "$MAX_MODEL_LEN"
  --enable-prefix-caching
  --kv-cache-dtype fp8
  --gpu-memory-utilization "$GPU_MEM_UTIL"
  --max-num-seqs "$MAX_NUM_SEQS"
  --reasoning-parser qwen3
  # OMP sempre envia tools -> sem isso todo request volta 400.
  # Template do Qwen3.8 usa tool call XML (<tool_call><function=..><parameter=..>),
  # que e o Qwen3EngineToolParser = qwen3_xml (hermes e JSON, formato errado).
  --enable-auto-tool-choice
  --tool-call-parser qwen3_xml
  # Template = copia do checkpoint + 2 linhas: aceita tambem message.reasoning,
  # porque o OMP replica o thinking do historico nessa chave (o original le
  # so message.reasoning_content e descartaria o raciocinio dos passos anteriores).
  --chat-template "$CHAT_TEMPLATE"
)

[[ "$CUDA_GRAPHS" == "1" ]] || ARGS+=(--enforce-eager)

if [[ "$ENABLE_MTP" == "1" ]]; then
  ARGS+=(--speculative-config "{\"method\":\"mtp\",\"num_speculative_tokens\":$NUM_SPEC_TOKENS}")
fi

exec vllm serve "$MODEL" "${ARGS[@]}"
