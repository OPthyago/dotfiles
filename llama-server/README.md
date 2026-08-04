# llama.cpp — inferência local

Dois servidores llama.cpp em systemd user services, subindo no boot sem login.

| Porta | Serviço | Modelo | Uso |
|------:|---------|--------|-----|
| 1235 | `llama-server` | Qwen3.6-27B Q4_K_M | agentes (OMP), contexto de 256k |
| 1236 | `llama-fim` | Qwen2.5-Coder-3B Q4_K_M | autocomplete no nvim (minuet), FIM |

Servidores separados de propósito: com um só e `--parallel 1`, o autocomplete
enfileirava atrás das tarefas do agente (medido: 0,75s → 7,61s).

## Hardware alvo

RTX 5090 32 GB. O build usa `CMAKE_CUDA_ARCHITECTURES=120` (sm_120, Blackwell),
que exige **CUDA toolkit ≥ 12.8**.

## Instalação

```bash
# 1. CUDA toolkit 12.8
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update && sudo apt-get install -y cuda-toolkit-12-8

# 2. build (instala em ~/.local)
git clone https://github.com/ggml-org/llama.cpp ~/opt/llama.cpp
cp scripts/build.sh scripts/bench.sh ~/opt/llama.cpp/
cd ~/opt/llama.cpp && ./build.sh

# 3. configs
mkdir -p ~/.config/llama-server
cp *.env *.sh ~/.config/llama-server/
cp systemd/user/*.service ~/.config/systemd/user/

# 4. servicos
loginctl enable-linger "$USER"
systemctl --user daemon-reload
systemctl --user enable --now llama-server llama-fim

# 5. power limit persistente (opcional)
sudo cp systemd/system/nvidia-power-limit.service /etc/systemd/system/
sudo systemctl enable --now nvidia-power-limit
```

## Operação

```bash
systemctl --user status llama-server llama-fim
journalctl --user -u llama-server -f
curl -s http://127.0.0.1:1235/health
~/opt/llama.cpp/bench.sh          # benchmark pp/tg
```

Trocar modelo ou flags: editar o `.env` correspondente e
`systemctl --user restart llama-server` (ou `llama-fim`).

## Notas que custaram tempo

- **`LD_LIBRARY_PATH`**: o `cmake --install` com prefix em `~/.local` deixa o
  rpath vazio; sem `LD_LIBRARY_PATH=~/.local/lib` o binário não acha
  `libllama-server-impl.so`. Os wrappers `run*.sh` já exportam.
- **Aspas no `.env`**: `FLAGS=-ngl 99 ...` sem aspas faz o shell tentar executar
  `99` ao dar `source`. Sempre `FLAGS="..."`.
- **`CTX` vs `PARALLEL`**: a VRAM depende só de `CTX` (pool de KV);
  `PARALLEL` fatia esse pool. `CTX=262144 PARALLEL=2` = 128k por requisição.
- **FIM**: só o endpoint `/infill` respeita o suffix. O `/v1/completions` do
  llama.cpp ignora e vira continuação simples.
- **Contenção de GPU**: o LM Studio precisa estar sem modelo carregado, senão
  não sobra VRAM e o serviço morre com OOM no load.

## Medições (RTX 5090 @ 450 W, FA on, KV Q8_0)

| Métrica | Valor |
|---------|------:|
| pp512 (prompt processing) | 3256 t/s |
| tg128 (geração) | 71,7 t/s |
| prompt de 178k tokens | 3m26s (prefill cai pra ~864 t/s) |
| completion FIM (Coder-3B) | 0,10–0,20 s |
