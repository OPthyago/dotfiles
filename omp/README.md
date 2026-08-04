# Oh My Pi (OMP) — Configurações do Agente

Arquivos de configuração do agente OMP (`~/.omp/agent/`).

## Conteúdo

- **`config.yml`**: Configuração das roles de modelo (`default`, `smol`, `tiny`, `slow`, `designer`, `advisor`), temas e comportamento.
- **`models.yml`**: Provedores locais e customizados (integração com `llama-cpp` no `http://127.0.0.1:1235/v1` e `lm-studio` no `http://127.0.0.1:1234/v1`).

## Instalação

```bash
mkdir -p ~/.omp/agent
cp omp/config.yml omp/models.yml ~/.omp/agent/
```
