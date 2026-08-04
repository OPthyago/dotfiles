# AI-DLC (AI-Driven Development Life Cycle) Workflow Playbook

Use this when working on projects following the AI-DLC methodology (Inception → Construction → Operations), organized into Units of Work (U1, U2, ...).

## Core Rules
1. Artifacts (requirements, stories, design docs, state) live under `aidlc-docs/`. Check project-specific constraints — this folder may be required to stay fully untracked (never committed, never gitignored) if the user says so.
2. Break work into Units of Work; each unit gets its own scope, tests, and (if using Make) its own make targets appended to the shared root Makefile.
3. When the user wants to learn (not full automation): scaffold structure + failing tests with clear NotImplementedError placeholders, and let the user implement the logic. Wait for explicit user approval (e.g. "approved") before proceeding to the next Unit of Work.
4. Document real source schemas (e.g. from BigQuery, APIs) into aidlc-docs/inception/requirements/ before writing Pydantic/data models — verify actual column names/types rather than assuming a table is a lookup/dimension table just because of its name.
5. Track a running aidlc-state.md and audit.md style trail so units of work and decisions are traceable across sessions.

## Environment Pitfall Checklist (Python + Make projects)
- If `make install` (running `pip install -e ".[dev]"`) fails with 'pip: not found' (exit 127): pip isn't on PATH. Fixes to try, in order:
  - Use `python3 -m pip install -e ".[dev]"` in the Makefile instead of bare `pip`.
  - Ensure a venv is created/activated first (e.g. `python3 -m venv .venv && source .venv/bin/activate`).
  - As last resort, verify pip is installed system-wide.
- Prefer making the Makefile robust to missing global `pip` by always invoking `python3 -m pip`.
