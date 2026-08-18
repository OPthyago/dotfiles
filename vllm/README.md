# vLLM — Qwen3.8-27B local (RTX 5090 32GB)

Servidor OpenAI-compatible em `127.0.0.1:1235`, usado como backend local do OMP
com **131072 tokens de contexto** e múltiplas sessões concorrentes.

Substitui o `llama-server/` deste repo (llama.cpp, aposentado: enfileirava requests
com `--parallel` baixo em vez de fazer batching contínuo).

## Arquivos

| Arquivo | Destino |
|---|---|
| `run.sh` | `~/.local/share/vllm/run.sh` |
| `qwen38-omp.jinja` | `~/.local/share/vllm/qwen38-omp.jinja` |
| `systemd/user/vllm.service` | `~/.config/systemd/user/vllm.service` |

O venv (`~/.local/share/vllm/.venv`) e o checkpoint não estão no repo.

## Instalação

```bash
# venv
uv venv --python 3.12 ~/.local/share/vllm/.venv
uv pip install --python ~/.local/share/vllm/.venv/bin/python vllm

# checkpoint (22 GB)
hf download unsloth/Qwen3.8-27B-NVFP4 \
  --local-dir ~/.lmstudio/models/unsloth/Qwen3.8-27B-NVFP4

# serviço
cp systemd/user/vllm.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now vllm
loginctl enable-linger "$USER"   # sobe no boot sem login gráfico
```

Probe de readiness: `curl -s localhost:1235/v1/models` (`/health` às vezes responde
vazio). Startup frio ~135 s (cache do `torch.compile`), quente ~45 s.

## Configuração travada e por quê

| Flag | Motivo |
|---|---|
| `--max-model-len 131072` | requisito; KV fp8 = 32 KiB/token porque o `qwen3_5` é híbrido (64 layers, só 16 full-attention) |
| `--gpu-memory-utilization 0.93` | 0.95 falha: a checagem é contra VRAM **livre** e o compositor/Brave come ~1,3 GiB |
| `ENABLE_MTP=0` | MTP (811 MB + estado/seq) não cabe junto com 131K |
| `--attention-backend TRITON_ATTN` | FlashInfer estoura `requires GPUs with sm75 or higher`: o JIT exige nvcc CUDA ≥ 12.9 e o host tem 12.8 |
| `--enable-auto-tool-choice` | sem isso **todo** request do OMP volta 400 (OMP manda 13 tools) |
| `--tool-call-parser qwen3_xml` | o template emite tool call XML (`<function=`/`<parameter=`), não JSON do hermes |
| `--chat-template qwen38-omp.jinja` | ver abaixo |
| `--kv-cache-dtype fp8` | dobra o pool de KV |
| `--max-num-seqs 4` | subagents do OMP em paralelo |

Sem CUDA graphs (`CUDA_GRAPHS=0` → `--enforce-eager`) o decode cai de ~48 para
~30 tok/s; o custo medido de VRAM foi só 0,06 GiB, então ficam ligados.

## `qwen38-omp.jinja`

Cópia do `chat_template.jinja` do checkpoint + **2 linhas**:

```jinja
        {%- elif message.reasoning is string %}
            {%- set reasoning_content = message.reasoning %}
```

O OMP replica o thinking do histórico em `message.reasoning`, mas o template original
só lê `message.reasoning_content` — sem o patch o raciocínio dos passos anteriores de
um loop de tools era descartado (`<think></think>` vazio).

Ao trocar de checkpoint, **re-derivar** este arquivo do template novo em vez de
reaproveitar este.

## Números medidos

| Concorrência | tok/s por request | agregado |
|---|---|---|
| 1 | 47.9 | 47.9 |
| 2 | 46 | 91.6 |
| 4 | 46-47 | 185.5 |

Contexto real validado com needle-in-haystack de 120.416 tokens (recuperado; prefill
~2.389 tok/s). VRAM em serviço ~29,7 GB de 32,6 GB. KV pool 5,7 GiB = 173.306 tokens.

## Thinking (ver `omp/models.yml`)

`omp --thinking off` desliga de verdade; `low`/`medium`/`high` mandam
`reasoning_effort` `low`/`medium`/`xhigh`. O template aceita **só** esses três —
`minimal` e `max` retornam 400, por isso o `reasoningEffortMap`.
