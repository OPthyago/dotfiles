# Raw Memories

## 019fcab0-4ee7-7000-b417-3d459051b478
updated_at: 1785813254
Project: TECH-CHALLENGE-FASE-2 (Fiap Pos Graduação, Fase 2, Tech Challenge). Located at /mnt/thyago/Documentos/Pos Graduação/POS Fiap/Fase 2/Tech Challenge/TECH-CHALLENGE-FASE-2.

Workflow: Using AI-DLC (AI-Driven Development Life Cycle) skill - Inception → Construction → Operations phases. Artifacts stored under aidlc-docs/ (aidlc-state.md, audit.md, requirements, stories, design docs).

Environment issue: `make install` runs `pip install -e ".[dev]"` but fails with '/bin/sh: 1: pip: not found' (exit 127). System likely needs pip installed/available on PATH, or Makefile should use `python -m pip` or activate a venv first. Unresolved as of last session.

Data domain: INEP alfabetização (literacy) evaluation data pipeline (Bronze/Silver architecture implied), source: BigQuery public dataset `basedosdados.br_inep_avaliacao_alfabetizacao`.

Schemas documented in aidlc-docs/inception/requirements/source-schemas.md:
- uf: 15 columns, geo key sigla_uf
- municipio: 15 columns, geo key id_municipio — IMPORTANT: this is aggregated evaluation data (same structure as uf table), NOT a municipality registry/lookup (no name, no state info). Columns: ano, id_municipio, serie, rede, taxa_alfabetizacao, media_portugues, proporcao_aluno_nivel_0..8.
- meta_alfabetizacao_brasil: 11 columns, national level
- meta_alfabetizacao_uf: 12 columns, key sigla_uf
- meta_alfabetizacao_municipio: 13 columns, key id_municipio
- alunos (microdata, largest table): 12 columns — ano, id_municipio, id_escola, id_aluno, caderno, serie, rede, presenca, preenchimento_caderno, alfabetizado, proficiencia (FLOAT64, Saeb scale, cutoff=743pts), peso_aluno. Candidate table for simulated streaming producer (U5) — events of (id_aluno, proficiencia, alfabetizado) per município/escola.

Design implication: Since dataset has no municipality name/UF cadastro table, Silver layer (U6) will need external lookup, likely `basedosdados.br_bd_diretorios_brasil.municipio`, to normalize id_municipio → município name/UF.

Next steps identified but not yet done: update Pydantic models for U1 (bronze layer models) with real schema fields discovered above; get U1 stage approval; proceed to implementation.

## 019fca62-48e4-7000-b3fc-6f7bf8e1da1f
updated_at: 1785812252
OMP (oh-my-pi) compaction system facts:
- compaction.strategy config supports: 'context-full', 'handoff', 'shake', 'snapcompact', 'off'.
- 'shake' strategy: inline, local reduction without calling a summarization model. Replaces eligible tool results and large fenced/XML blocks with recoverable artifact:// references, using a protected recent-token window and minimum-savings threshold.
- Automatic shake (triggered by threshold/idle) emits auto-compaction events with action:'shake'. If shake can't reclaim enough context to get below recovery band, falls through to context-full summarization (prevents no-op shake loops); idle shake doesn't use that fallback since idle timer rechecks usage.
- Manual '/shake' command: separate, MORE aggressive than automatic shake — targets all eligible history, not just oldest part.
- Relevant source files: packages/agent/src/compaction/shake.ts, compaction-v2-streaming.ts, utils.ts, openai.ts; packages/coding-agent/src/session/session-manager.ts.
- Default config: compaction.enabled=true, reserveTokens unset (defaults to larger of 16384 or 15% of context window), keepRecentTokens=20000, autoContinue=true.
- Practical guidance given to user: don't bother running /shake until context usage nears 70-80%+ or symptoms of saturation appear; at 52% usage there's still comfortable margin (~330K tokens free out of 1M).
- Useful technique for exploring OMP internals: use grep tool with path='omp://' to search built-in documentation (e.g., omp://compaction.md, omp://tools/browser.md, omp://tools/debug.md, omp://lsp-config.md) — these are internal doc references accessible via the grep tool, not filesystem paths.

## 019fc9f8-59fa-7000-bc08-c3a21900cb91
updated_at: 1785811938
PROJECT CONTEXT:
- Repo: TECH-CHALLENGE-FASE-2 (FIAP Fase 2 pos-graduação tech challenge)
- Source requirements doc: '[IAST] - Tech Challenge - Fase 2.pdf'
- Methodology: AI-DLC (aidlc) workflow, split into Units of Work (U1, U2...), user wants to learn, not have everything done for them
- HARD CONSTRAINT: never commit aidlc-docs folder, never add to .gitignore either — must stay fully invisible/untracked

ARCHITECTURE DECISIONS:
- Python-based data engineering project
- Dependencies: Pydantic, PyArrow, Pytest, Hypothesis — declared in pyproject.toml
- Makefile at repo root acts as the npm-scripts equivalent (make install, make test-u1, etc.) — decided during Application Design phase
- Explicitly decided NOT to use Airflow locally
- Convention: each Unit of Work adds its own make targets to the shared root Makefile

U1 STATUS:
- Scaffolded with pyproject.toml + Makefile + failing tests (raise NotImplementedError with message like "implementação [...] é sua missão!") intentionally left for the user to implement as a learning exercise
- User needs to run `make install` then `make test-u1` to see failing tests, then implement

NEXT UNIT PLANNED: U2 - Infra em Terraform (pending user's 'approved' on U1 to proceed)

ISSUE ENCOUNTERED (unresolved at session end):
- `make install` runs `pip install -e ".[dev]"` but failed with `/bin/sh: 1: pip: not found` (Erro 127) — user's shell has no pip on PATH. Likely fix: use `python3 -m pip` in Makefile, or ensure venv is activated / pip is installed on the user's Linux system (Manjaro/Arch-like environment based on prompt).

ENVIRONMENT NOTES:
- Session run on google-gemini-cli / gemini-3.1-pro provider; hit 429 RESOURCE_EXHAUSTED quota errors mid-conversation (individual quota reached, ~4h reset window) — may need to switch provider/model or wait if this recurs.
- User's OS prompt shows Portuguese/Brazilian locale, path 'Documentos/Pos Graduação/POS Fiap/Fase 2/Tech Challenge/TECH-CHALLENGE-FASE-2'.

## 019fca0b-38b7-7000-8b13-27d880df3b5c
updated_at: 1785802662
- Attempted to build a 'model-router' OMP extension at ~/.omp/agent/extensions/model-router/index.ts that would route requests to a small classifier model to decide which target model to use. User deemed this not worth the effort (extra latency/cost of classifier call outweighs benefit) and had it removed via `rm -rf ~/.omp/agent/extensions/model-router`.
- Technical note: OMP only auto-discovers custom extensions if the extension directory contains a package.json with an `omp.extensions` manifest field (e.g. `{"name":"model-router","omp":{"extensions":["./index.ts"]}}`). Without this manifest, extension code is not loaded and the default model config is used instead.
- Alternative suggested for model routing/difficulty-based behavior: use OMP's built-in `defaultThinkingLevel: auto` setting instead of building custom routing logic.
- User also requested installing the Graphify skill (https://github.com/Graphify-Labs/graphify) for general OMP use (not just Claude) — a /graphify skill that builds a local knowledge graph from codebase/docs/PDFs; installation was in progress but not confirmed complete in this thread.
