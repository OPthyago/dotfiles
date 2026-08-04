# Raw Memories

## 019fca95-b5e9-7000-93ee-f775c5b269e9
updated_at: 1785813261
Context: User has a NAS (accessible at 192.168.0.11, already running Paperless-ngx) and wants to self-host a Trello-like task/project management tool that an AI agent (Claude/assistant) can control via MCP.

Key recommendations given:
1. **Plane** (https://github.com/makeplane/plane) — recommended primary choice. Self-hosted via docker-compose, Linear/Jira-like UI, features: kanban boards, cycles (sprints), modules, labels, milestones. Has an official MCP server (`plane-mcp-server`, installable via `pip install plane-mcp-server` or `uvx`). Example MCP client config:
```json
{
  "mcpServers": {
    "plane": {
      "command": "uvx",
      "args": ["plane-mcp-server", "stdio"],
      "env": {
        "PLANE_API_KEY": "...",
        "PLANE_WORKSPACE_SLUG": "...",
        "PLANE_BASE_URL": "http://nas:8000"
      }
    }
  }
}
```
Stack: Django + PostgreSQL + Redis (medium weight).

2. **Kan** — lighter alternative, more literally Trello-like UI, Node-based, also has official MCP server, runnable via `npx -y @kan/mcp`. Good fallback if NAS resources are constrained.

3. Rejected/other options discussed: Redmine (mature but dated UI, heavy, low modern adoption), OpenProject (heavy, enterprise, better native Google Calendar/iCal sync than Plane/Kan), Taiga (agile/scrum focused), Youtrack, Focalboard, Waka.

4. **Google Calendar integration gap**: Neither Plane nor Kan has native Google Calendar sync. Workaround: run a separate Google Calendar MCP server in parallel; the AI agent queries both Plane (tasks) and Google Calendar (events) MCP servers simultaneously to cross-reference schedules, rather than relying on tool-native sync. For true bidirectional/visual calendar sync, would need n8n or Make automation bridging Plane and Google Calendar, or fall back to OpenProject which has more mature calendar export.

5. User's meta-joke: the very process of setting up Plane + MCP + Calendar sync on the NAS would itself become tracked as tickets inside Plane once operational (self-referential bootstrapping workflow: Epic 'Bootstrapping' with issues like Deploy Plane via Docker, Configure MCP server, Configure Google Calendar MCP, Create Plane↔GCal sync script).

## 019fca95-11f1-7000-9bb4-06c744c904d2
updated_at: 1785810224
Paperless MCP integration notes:
- Tool: mcp__paperless_query_documents accessed via xd:// protocol path.
- write() tool call format: must use path='xd://mcp__paperless_query_documents', content=<JSON string of query params>, i=<intent label>. Passing JSON.stringify(...) as second positional arg fails with 'Protocol paths are not supported by write()'.
- Query params seen: {query, after, before, counts_only}.
- Encountered blocking issue: Paperless server returns 401 Invalid token — the API token configured for the MCP server connection is invalid/expired and must be renewed by the user before queries can succeed.
- Unresolved: could not determine document count for 'shift solution' in 2026 due to auth failure.

## 019fca8c-6507-7000-9567-7e5df93e5c52
updated_at: 1785810186
Environment: local LM Studio serving qwen/qwen3.6-27b, accessed by an OMP agent harness (provider lm-studio, api openai-completions).

Key config locations:
- LM Studio per-model default config: ~/.lmstudio/.internal/user-concrete-model-default-config/qwen/qwen3.6-27b.json — contains 'llm.prediction.reasoning.enableThinking' (bool). Was false by default; set to true to enable chain-of-thought/reasoning output.
- OMP agent config: ~/.omp/agent/config.yml — contains 'defaultThinkingLevel' setting (e.g. 'high') controlling whether harness requests reasoning from model.
- OMP home dir: ~/.omp/ contains agent/ (agent.db, config.yml, models.yml, RULES.md, sessions/, memories/, skills/), logs/, run/, ssh-control/.

Debug workflow to verify reasoning/thinking is active on a local LM Studio model:
curl -s http://127.0.0.1:1234/v1/chat/completions -X POST -H 'Content-Type: application/json' -d '{"model":"qwen/qwen3.6-27b","messages":[...],"max_tokens":1024}' | jq '{content:.choices[0].message.content, reasoning_tokens:.usage.completion_tokens_details.reasoning_tokens, has_reasoning:(.choices[0].message.reasoning_content|length>0), finish:.choices[0].finish_reason}'
After enabling config and reloading model (lms load), reasoning_tokens > 0 and has_reasoning true confirms fix.

Policy stance clarified in conversation (user asked about censorship): assistant states no content/political/moral filters; only refuses direct instructions to build weapons/explosives intended to harm; cybersecurity research (exploits, reversing, malware analysis, CTF, bug bounty, defense/hardening) is allowed; won't attack specific third-party systems without authorization.

Pitfall: model capability (supports thinking) is separate from whether it's enabled — must check both the model's own config flag AND the harness's request parameters (defaultThinkingLevel) to actually get reasoning_content in output.

## 019fca70-74f1-7000-9db6-0c90221e15f5
updated_at: 1785808013
Royal Enfield Meteor 350 troubleshooting session:

Initial symptoms: motor cranks (gira) but won't start, yellow injection/MIL light on dashboard, fuel pump audible (works fine).

KEY FINDING (after web research) - Meteor 350 does NOT use blink-count fault codes like older bikes; it has OBD2/Euro5 ECU, light just stays on/blinks fast, actual code must be read via OBD scanner at dealership.

Top 3 known chronic causes on Meteor 350 (J-platform) for crank-no-start with yellow light:
1. Excess dielectric grease on relays under left side cover from factory — vibration/heat turns it into insulator on relay pins, causing intermittent ECU/ignition relay contact loss. Fix: remove relays, clean pins with contact cleaner spray, reseat firmly.
2. Loose/corroded battery terminals — ECU very sensitive to voltage drop during cranking; even slightly loose terminals cause voltage dip that cuts spark and triggers injection light. Fix: tighten battery terminal bolts firmly.
3. Side stand (pezinho) sensor or tip-over/lean angle sensor (under seat) dirty/misaligned — prevents ignition even while cranking. Fix: cycle side stand, clean sensor, ensure bike in neutral with clutch pulled during start.

User workaround steps to attempt starting without dealership: tighten battery terminals, clean grease off relay pins (left side cover), cycle ignition key 3x before cranking (let fuel pump prime), start in neutral with clutch pulled.

Process note: initial LLM response (qwen model) used generic/generic-sounding blink-code table that turned out to be inaccurate for this specific bike/ECU generation — always web-search for model-specific known issues rather than trusting generic diagnostic tables for modern OBD2 vehicles.

## 019fca65-527a-7000-b478-4c77bce555b1
updated_at: 1785807507
Issue: Cider music player froze/hung right after playing a track, requiring restart.

Diagnosis process:
- Checked running processes for Cider (pgrep)
- Searched for Cider config/log locations: ~/.config/Cider, ~/.config/sh.cider.genten
- Found log evidence: `notify_notification_show ... O tempo limite foi alcançado` (timeout) and MPRIS/Next calls also timing out

Root cause: SwayNotificationCenter (swaync) DBus notification service was stuck/hung. Cider tried to emit a native OS notification on track change/play, blocked on the DBus call, causing the whole app to freeze.

Fix applied:
1. Restarted swaync service: `systemctl --user restart swaync.service` (or equivalent)
2. Disabled Cider's playback notifications in config file `~/.config/sh.cider.genten/spa-config.yml` by setting `playbackNotifications: false`

Verification:
- `org.freedesktop.Notifications.GetServerInformation` DBus call responded normally again
- Cider's Next/skip track no longer froze
- MPRIS interface responded correctly and reported 'Playing' status

General pattern for future: On Linux systems using swaync (Sway/wlroots desktop), apps that emit desktop notifications via DBus can hang/freeze entirely if swaync's notification daemon is unresponsive. Diagnostic approach: check app config dirs (~/.config/<app>), grep logs for DBus timeout errors, test DBus notification service directly, and either restart the notification daemon or disable the app's notification feature as workaround.

## 019fc9e7-ddbf-7000-a0bd-ea94735c37e3
updated_at: 1785798990
NAS SSH connection details (for user thyago):
- Command: ssh -i "$HOME/.ssh/nas_claude" -p 44 bolseiro@192.168.0.11
- No ~/.ssh/config alias exists for 'nas-claude' — user calls it that colloquially but it's not a configured SSH host/alias; must use explicit ssh command with key/port/user/ip above.
- Remote user 'bolseiro': uid=1026, groups=users,administrators (not in docker group).
- 'docker' command not found in bolseiro's default PATH (sh: docker: command not found) — likely needs full path or is only accessible via sudo/root.
- sudo on NAS requires a password (no NOPASSWD entry) — commands like 'sudo docker ps' and 'sudo -n docker ps' both fail with 'sudo: a password is required'. Need user to supply the sudo password to run privileged docker commands, or find docker binary path directly.
- Known/expected containers on NAS: claude-code, gemini-cli, antigravity-cli — goal mentioned was to inspect these and replicate setup elsewhere (referred to as 'omp').
- General note: the sandbox environment tool supports ssh://<host>/<path> reads but only for configured capability hosts or resolvable OpenSSH config aliases; raw IP+port+key must be used via bash ssh command instead when no alias is set up.

## 019fc9d7-ac69-7000-822b-c3b644b6f160
updated_at: 1785798811
OMP (Oh My Pi) model role system:
- `completion(prompt, model="smol"|"slow"|"default")` explicitly routes to different underlying models per call; no automatic/dynamic model selection mid-conversation.
- Role mappings configured by user in this session (modelRoles config): default=anthropic/claude-sonnet-5, smol=local LM Studio Qwen3.6-27b (lm-studio/qwen/qwen3.6-27b), slow=anthropic/claude-opus-5. Initially smol was misconfigured to google-antigravity/gemini-3.1-flash-lite; user corrected config to point smol at their local LM Studio Qwen model.
- Other special-purpose roles exist in omp harness code (fixed purposes, not user-selectable per-task): `tiny` (session/memory titles), `commit` (commit messages), `advisor`, etc.
- The main conversational agent in a session always runs as modelRoles.default; it does not switch models itself mid-chat.
- To verify which model handled a turn: session system context block declares `Model: provider/model-id` explicitly (ground truth, not inference).
- Ways to inspect model routing in omp: `/model` command in-session (view/switch active model), TUI status bar/header, `omp models` CLI (lists all available models by provider), and session transcripts which record the concrete provider/modelId that executed each turn.
- Testing model calls: use `eval` tool with python `completion()` calls and print results; tool call statusEvents show op/model/tier/chars/duration for each completion call, useful for confirming actual routing.
- No other hub peer agents were active during this session (hub list returned empty); to test agent-to-agent messaging, need another session/subagent or spawn via `task`.

## 019fc9cd-5b9e-7000-a3da-529753899355
updated_at: 1785797779
User environment: Linux machine, home dir /home/thyagoop, uses LazyVim (~/.config/nvim) and also uses 'omp' (an agent/AI CLI tool) with config at ~/.omp/agent/.

Task: User wanted to point OMP's LM Studio provider to a remote/local-network LM Studio server at http://192.168.0.92:1234 instead of default localhost, but models weren't showing up.

Diagnosis steps:
1. Searched nvim config for AI/LM Studio references - found none (nvim was a red herring, actual target was OMP not nvim).
2. Located OMP provider docs internally (omp://providers.md) showing LM Studio default base URL is http://127.0.0.1:1234/v1, override via LM_STUDIO_BASE_URL env var.
3. Verified remote LM Studio server reachable: `curl -s -m 3 http://192.168.0.92:1234/v1/models` returned valid model list (qwen/qwen3.6-27b, qwen/qwen2.5-coder-32b, text-embedding-nomic-embed-text-v1.5).
4. Checked ~/.omp/agent/.env - didn't exist/was empty.

Fix applied:
`mkdir -p ~/.omp/agent && echo 'LM_STUDIO_BASE_URL=http://192.168.0.92:1234/v1' >> ~/.omp/agent/.env`

After this, restarting omp should surface models as lm-studio/qwen3.6-27b, lm-studio/qwen2.5-coder-32b, etc. LM Studio provider in OMP is keyless by default (no API key required for local/LAN instances).

Reusable pattern: OMP provider base URLs can be overridden via env vars in ~/.omp/agent/.env, following pattern <PROVIDER>_BASE_URL=<url>. Always verify server reachability with curl before assuming client-side config issue.
