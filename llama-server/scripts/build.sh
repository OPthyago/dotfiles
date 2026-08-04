#!/usr/bin/env bash
# Build llama.cpp com CUDA para RTX 5090 (sm_120). Idempotente.
set -euo pipefail
cd "$(dirname "$0")"

# CUDA toolkit 12.8 no PATH para o cmake achar o nvcc
export PATH="/usr/local/cuda-12.8/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

JOBS="$(nproc)"
BUILD_DIR="build"

cmake -B "$BUILD_DIR" -S . \
  -DCMAKE_BUILD_TYPE=Release \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES=120 \
  -DGGML_NATIVE=ON \
  -DLLAMA_CURL=ON

cmake --build "$BUILD_DIR" --config Release -j "$JOBS"
cmake --install "$BUILD_DIR" --prefix "$HOME/.local"

echo "OK: binários em ~/.local/bin"
