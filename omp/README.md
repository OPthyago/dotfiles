# Oh My Pi (OMP) — Configurações, Skills e Memória do Agente

Coleção completa de ativos e configurações do agente OMP (`~/.omp/agent/`).

## Estrutura

- **`config.yml`**: Configuração das roles de modelo (`default`, `smol`, `tiny`, `slow`, `designer`, `advisor`), temas e comportamento.
- **`models.yml`**: Provedores locais e customizados (integração com `llama-cpp` no `http://127.0.0.1:1235/v1` e `lm-studio` no `http://127.0.0.1:1234/v1`).
- **`RULES.md`**: Regras globais de conduta e atribuição do agente.
- **`.env`**: Variáveis de ambiente de suporte (`LM_STUDIO_BASE_URL`, etc.).
- **`skills/`**: Skills vendored/instaladas no agente (ex: `aidlc`).
- **`managed-skills/`**: Managed skills codificadas (ex: `graphify`).
- **`memories/`**: Memórias de longo prazo persistidas por workspace.

## Restauração / Sincronização

```bash
mkdir -p ~/.omp/agent
cp omp/config.yml omp/models.yml omp/RULES.md omp/.env ~/.omp/agent/
cp -r omp/skills omp/managed-skills omp/memories ~/.omp/agent/
```
