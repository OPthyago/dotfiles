# Evaluating/Deploying Self-Hosted Task Managers with MCP + AI Agent Control

Use when a user wants a self-hosted Trello/Jira-like board on a NAS/homelab that an AI agent can control via MCP.

## Recommendation tiers
1. **Plane** (github.com/makeplane/plane) — primary pick. Linear/Jira-like UI: kanban, cycles (sprints), modules, labels, milestones. Docker self-hosted (Django + PostgreSQL + Redis — medium weight). Official MCP server: `pip install plane-mcp-server` or run via `uvx plane-mcp-server stdio`. Config needs `PLANE_API_KEY`, `PLANE_WORKSPACE_SLUG`, `PLANE_BASE_URL`.
2. **Kan** — lighter, Node-based, more literally Trello-like UI. Official MCP server runnable via `npx -y @kan/mcp`. Good fallback for constrained NAS hardware.
3. Considered/rejected alternatives: Redmine (dated UI, heavy), OpenProject (heavy/enterprise but has the most mature native Google Calendar/iCal sync of the group), Taiga (scrum-focused), Youtrack, Focalboard, Waka.

## Known limitation: Google Calendar
Neither Plane nor Kan natively syncs with Google Calendar. Workarounds, in increasing effort:
- Run a separate Google Calendar MCP server alongside the task-manager's MCP server; have the agent query both and cross-reference schedules in-context (no real sync, just joint reasoning).
- Build an n8n or Make automation to bridge Plane/Kan and Google Calendar for true bidirectional sync.
- Or choose OpenProject if native calendar export/sync is a hard requirement, accepting the heavier footprint.

## Meta-pattern
Once the chosen tool is live, track its own remaining setup work (docker deploy, MCP config, calendar MCP, sync scripts) as an Epic/tickets inside the tool itself — a natural self-bootstrapping workflow.
