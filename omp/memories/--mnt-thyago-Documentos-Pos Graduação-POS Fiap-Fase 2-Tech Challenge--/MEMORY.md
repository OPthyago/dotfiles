# Long-Term Memory

## Project: TECH-CHALLENGE-FASE-2 (FIAP Pós-Graduação, Fase 2)
- Location: /mnt/thyago/Documentos/Pos Graduação/POS Fiap/Fase 2/Tech Challenge/TECH-CHALLENGE-FASE-2
- Source requirement doc: '[IAST] - Tech Challenge - Fase 2.pdf'
- Methodology: AI-DLC (AI-Driven Development Life Cycle) — Inception → Construction → Operations, split into Units of Work (U1, U2...). User wants to learn, not have everything done automatically.
- Artifacts stored under aidlc-docs/ (aidlc-state.md, audit.md, requirements, stories, design docs).
- HARD CONSTRAINT: aidlc-docs/ must NEVER be committed and NEVER added to .gitignore — must remain fully untracked/invisible.

### Architecture Decisions
- Python data engineering project. Dependencies: Pydantic, PyArrow, Pytest, Hypothesis (declared in pyproject.toml).
- Makefile at repo root = npm-scripts equivalent (make install, make test-u1, etc.); each Unit of Work adds its own make targets.
- Explicitly decided NOT to use Airflow locally.

### Data Domain: INEP Alfabetização (literacy) pipeline
- Source: BigQuery public dataset `basedosdados.br_inep_avaliacao_alfabetizacao`.
- Bronze/Silver architecture. Schemas documented in aidlc-docs/inception/requirements/source-schemas.md:
  - uf: 15 cols, key sigla_uf
  - municipio: 15 cols, key id_municipio — IMPORTANT: this is aggregated evaluation data (same shape as uf), NOT a municipality name/UF lookup table. Cols: ano, id_municipio, serie, rede, taxa_alfabetizacao, media_portugues, proporcao_aluno_nivel_0..8.
  - meta_alfabetizacao_brasil: 11 cols, national
  - meta_alfabetizacao_uf: 12 cols, key sigla_uf
  - meta_alfabetizacao_municipio: 13 cols, key id_municipio
  - alunos (microdata, largest table): 12 cols — ano, id_municipio, id_escola, id_aluno, caderno, serie, rede, presenca, preenchimento_caderno, alfabetizado, proficiencia (FLOAT64, Saeb scale, cutoff=743pts), peso_aluno. Candidate source for simulated streaming producer (U5).
- Design implication: dataset has no municipality cadastro table; Silver layer (U6) needs external lookup `basedosdados.br_bd_diretorios_brasil.municipio` to normalize id_municipio → name/UF.

### Units of Work Status
- U1 (Bronze layer models): scaffolded with pyproject.toml + Makefile + intentionally failing tests (NotImplementedError placeholders, e.g. "implementação [...] é sua missão!") for user to implement as learning exercise. Next step: update Pydantic models with real schema fields discovered, get U1 approved, then implement.
- U2 (planned): Infra em Terraform — pending user approval of U1.

### Known Unresolved Issue
- `make install` runs `pip install -e ".[dev]"` and fails with `/bin/sh: 1: pip: not found` (exit 127) — pip not on PATH in user's Linux (Arch/Manjaro-like) shell. Likely fix: change Makefile to use `python3 -m pip`, or ensure venv is activated / pip installed. Still unresolved as of last session.

### Environment Notes
- Sessions have run on google-gemini-cli / gemini-3.1-pro; hit 429 RESOURCE_EXHAUSTED quota errors (individual quota, ~4h reset window) — may need to switch provider/model if recurs.

---

## OMP (oh-my-pi) System Knowledge

### Compaction
- compaction.strategy options: 'context-full', 'handoff', 'shake', 'snapcompact', 'off'.
- 'shake': inline local reduction (no summarization model call). Replaces eligible tool results / large fenced/XML blocks with recoverable `artifact://` references, using a protected recent-token window and minimum-savings threshold.
- Automatic shake triggers on threshold/idle, emits events with action:'shake'. If it can't reclaim enough to drop below recovery band, falls through to context-full summarization (avoids no-op loops); idle-triggered shake skips that fallback since idle timer rechecks usage.
- Manual `/shake` command is separate and MORE aggressive than automatic shake — targets all eligible history, not just the oldest part.
- Guidance: don't bother running /shake until context usage nears 70-80%+ or symptoms of saturation appear (comfortable margin below that, e.g. 52% usage ≈ 330K free of 1M).
- Relevant source files: packages/agent/src/compaction/{shake.ts, compaction-v2-streaming.ts, utils.ts, openai.ts}; packages/coding-agent/src/session/session-manager.ts.
- Default config: compaction.enabled=true, reserveTokens unset (defaults to max(16384, 15% of context window)), keepRecentTokens=20000, autoContinue=true.
- To explore OMP internal docs: use the grep tool with path='omp://' (e.g. omp://compaction.md, omp://tools/browser.md, omp://tools/debug.md, omp://lsp-config.md) — internal doc references, not filesystem paths.

### Extensions
- OMP auto-discovers custom extensions only if the extension directory has a package.json with an `omp.extensions` manifest field (e.g. `{"name":"model-router","omp":{"extensions":["./index.ts"]}}`). Without it, code isn't loaded and default model config is used.
- A custom 'model-router' extension (routes requests to a small classifier model to pick target model) was attempted at ~/.omp/agent/extensions/model-router/index.ts, then deemed not worth the added latency/cost and removed via `rm -rf ~/.omp/agent/extensions/model-router`.
- Preferred alternative for difficulty-based model routing: use OMP's built-in `defaultThinkingLevel: auto` setting instead of custom routing logic.
- User requested installing the Graphify skill (https://github.com/Graphify-Labs/graphify) for general OMP use — builds a local knowledge graph from codebase/docs/PDFs via /graphify. Installation was in progress, not confirmed complete.
