---
name: aidlc
description: Use for AI-DLC (AI-Driven Development Life Cycle) — the adaptive, phased software development workflow (Inception → Construction → Operations) from awslabs/aidlc-workflows. Load when the user asks to build/implement/design a feature or system end-to-end, requests requirements/user-stories/application-design artifacts, or explicitly mentions AI-DLC/AIDLC.
---

# AI-DLC (AI-Driven Development Life Cycle)

Vendored from https://github.com/awslabs/aidlc-workflows (`aidlc-rules/`, VERSION `1.0.1`). This is the
project-agnostic, user-level install: it applies to every omp session, not just this repo.

AI-DLC is an adaptive three-phase workflow (Inception → Construction → Operations) that scales its own
depth to the request: trivial fixes stay light, complex/high-risk work gets full requirements, user
stories, design, and NFR treatment. It produces its artifacts under `aidlc-docs/` in the target project
(`aidlc-state.md`, `audit.md`, requirements, stories, design docs, etc.) and an audit trail of every
decision and user response.

## How to use this skill

1. Read the full workflow rules first: `skill://aidlc/aws-aidlc-rules/core-workflow.md`. This is the
   entry point — it defines the phases, stage gating logic (ALWAYS/CONDITIONAL), and mandatory rule-detail
   loading.
2. Follow its "MANDATORY: Rule Details Loading" section: resolve rule-detail files under
   `skill://aidlc/aws-aidlc-rule-details/<path>` (e.g.
   `skill://aidlc/aws-aidlc-rule-details/common/process-overview.md`,
   `skill://aidlc/aws-aidlc-rule-details/inception/workspace-detection.md`), unless the current project
   already has its own copy at one of the project-local paths core-workflow.md lists (in which case that
   copy wins).
3. Load the mandatory common rules at workflow start exactly as core-workflow.md instructs
   (`process-overview.md`, `session-continuity.md`, `content-validation.md`, `question-format-guide.md`,
   `welcome-message.md`).
4. Scan `skill://aidlc/aws-aidlc-rule-details/extensions/` for `*.opt-in.md` files and offer them during
   Requirements Analysis; only load the matching full `*.md` rules file if the user opts in.
5. Execute phases/stages per core-workflow.md's own gating rules — do not re-derive them here.

## Directory map

```
skill://aidlc/
├── VERSION                             # upstream release version (1.0.1)
├── aws-aidlc-rules/
│   └── core-workflow.md                # the workflow itself — READ THIS FIRST
└── aws-aidlc-rule-details/
    ├── common/                         # process, session continuity, validation, terminology, etc.
    ├── inception/                      # workspace detection, requirements, stories, design, planning
    ├── construction/                   # functional/NFR/infra design, code-gen, build-and-test
    ├── operations/                     # operations.md
    └── extensions/                     # opt-in extensions: security, resiliency, property-based testing
```

## Notes

- This skill overrides project-local `.aidlc-rule-details/`, `.kiro/aws-aidlc-rule-details/`, etc. only
  as a *fallback source* — if the project already has one of those, core-workflow.md's own precedence
  (project copy first) applies; this skill just guarantees a copy always exists even in projects that
  never ran the AI-assisted setup.
- To update: re-sync `aidlc-rules/` from https://github.com/awslabs/aidlc-workflows (main branch) into
  this skill directory and re-check the VERSION file and the "MANDATORY: Rule Details Loading" path patch
  in `aws-aidlc-rules/core-workflow.md`.
- Explicit invocation: `/skill:aidlc` if slash-command skills are enabled.
