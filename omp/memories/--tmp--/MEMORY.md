# Long-Term Memory

## User Environment
- Linux machine, home dir `/home/thyagoop`. Uses LazyVim (`~/.config/nvim`) and OMP ("Oh My Pi", an agent/AI CLI tool) with config at `~/.omp/agent/` (contains agent.db, config.yml, models.yml, RULES.md, sessions/, memories/, skills/).
- Desktop environment uses Sway/wlroots with SwayNotificationCenter (swaync) for notifications.
- Speaks Portuguese; comfortable with technical English.
- Has a NAS at 192.168.0.11 (Synology-like), already running Paperless-ngx, accessed via SSH as user `bolseiro`.
- Runs local LM Studio server(s) serving qwen/qwen3.6-27b (and qwen2.5-coder-32b, nomic-embed-text) either on localhost or LAN at 192.168.0.92:1234.

## OMP (agent harness) facts
- Model roles: `completion(prompt, model="smol"|"slow"|"default")` routes to explicitly configured models (no dynamic mid-conversation switching). User's mapping: default=anthropic/claude-sonnet-5, smol=local LM Studio qwen3.6-27b, slow=anthropic/claude-opus-5.
- Other fixed-purpose roles exist in harness code: `tiny` (titles), `commit` (commit messages), `advisor`.
- To verify which model ran a turn: session system context declares `Model: provider/model-id` (ground truth). Also `/model` command, `omp models` CLI, TUI status bar, session transcripts.
- Provider base URLs overridable via env vars in `~/.omp/agent/.env`, pattern `<PROVIDER>_BASE_URL=<url>` (e.g. `LM_STUDIO_BASE_URL=http://192.168.0.92:1234/v1`). LM Studio provider is keyless by default.
- LM Studio per-model reasoning toggle: `~/.lmstudio/.internal/user-concrete-model-default-config/<model>.json` key `llm.prediction.reasoning.enableThinking` (bool, default false for qwen3.6-27b). Must also check OMP's `~/.omp/agent/config.yml` key `defaultThinkingLevel` — both model capability flag AND harness request parameter must be set for reasoning_content to actually appear.
- Policy stance (stated to user): no political/moral content filters; only refuses direct requests to build weapons/explosives intended to harm; cybersecurity research (exploits, reversing, malware, CTF, bug bounty, defensive hardening) is allowed; won't attack specific third-party systems without authorization.

## NAS access
- SSH: `ssh -i "$HOME/.ssh/nas_claude" -p 44 bolseiro@192.168.0.11`. No `~/.ssh/config` alias exists (colloquial name "nas-claude" is not configured) — must always use explicit command.
- Remote user `bolseiro` (uid=1026, groups=users,administrators) is NOT in docker group; `docker` not in default PATH; `sudo` requires a password (no NOPASSWD) — privileged docker commands need user-supplied sudo password or discovery of docker binary's full path.
- Known containers on NAS: claude-code, gemini-cli, antigravity-cli (goal: inspect and replicate setup elsewhere, called "omp").
- Sandbox tool's `ssh://` protocol only works for configured capability hosts/resolvable SSH config aliases; raw IP+port+key must go through bash `ssh` command otherwise.

## Self-hosted task management on NAS (for AI-agent control via MCP)
- Recommended: **Plane** (github.com/makeplane/plane) — Linear/Jira-like, Docker self-hosted (Django+PostgreSQL+Redis), has official `plane-mcp-server` (pip/uvx installable). Example MCP config uses env PLANE_API_KEY, PLANE_WORKSPACE_SLUG, PLANE_BASE_URL.
- Lighter fallback: **Kan** — Node-based, more literal Trello UI, official MCP server via `npx -y @kan/mcp`.
- Rejected/considered: Redmine (dated, heavy), OpenProject (heavy but best native Google Calendar/iCal sync), Taiga, Youtrack, Focalboard, Waka.
- Gap: neither Plane nor Kan has native Google Calendar sync. Workaround: run a separate Google Calendar MCP server in parallel and have the agent cross-reference both MCP sources; true bidirectional sync needs n8n/Make automation or falling back to OpenProject.
- Meta-plan: the Plane setup itself (deploy via docker, configure MCP, configure GCal MCP, build sync script) is intended to be tracked as an Epic/tickets inside Plane once operational.

## Paperless-ngx MCP
- Tool `mcp__paperless_query_documents` must be called through `write()` using `path='xd://mcp__paperless_query_documents'`, `content=<JSON string of query params>`, `i=<intent label>`. Passing a JS object/JSON.stringify as a second positional arg fails ("Protocol paths are not supported by write()").
- Query params: `{query, after, before, counts_only}`.
- Known issue (as of last session): Paperless API token returns 401 Invalid token — needs manual renewal by user before queries succeed.

## Hardware/vehicle notes
- Royal Enfield Meteor 350 (J-platform) uses OBD2/Euro5 ECU — does NOT use legacy blink-count fault codes; actual fault code needs OBD scanner. Chronic causes of crank-no-start + yellow injection light: (1) dielectric grease on relay pins under left cover turning into insulator from heat/vibration, (2) loose/corroded battery terminals causing voltage dip during cranking, (3) dirty/misaligned side-stand or lean-angle sensor. General lesson: always web-search model/generation-specific issues for modern OBD2 vehicles rather than trusting generic diagnostic tables.

## Linux desktop app freeze pattern
- On Sway/wlroots systems with swaync, apps (e.g. Cider) that emit DBus desktop notifications on events (like track change) can completely freeze if swaync's notification service is hung, because the DBus call blocks. Diagnose via app config/logs (~/.config/<app>) grepping for DBus timeout errors, test `org.freedesktop.Notifications.GetServerInformation` directly, then restart swaync and/or disable the app's notification feature.
