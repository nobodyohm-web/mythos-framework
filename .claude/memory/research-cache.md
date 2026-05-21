
---

## 2026-05-21 — Claude Code New Features (Jan–May 2026)

Source: https://code.claude.com/docs/en/changelog (verified via WebFetch, v2.1.108–v2.1.146)
Consumer: Mythos framework gap analysis

### Hook events Mythos is NOT using (as of CLAUDE.md v6.0)
- UserPromptSubmit (can block), UserPromptExpansion, PostToolBatch, PermissionRequest, PermissionDenied
- FileChanged, ConfigChange, CwdChanged, InstructionsLoaded
- WorktreeCreate, WorktreeRemove, PostCompact, StopFailure
- Elicitation, ElicitationResult, Notification, TaskCreated, TaskCompleted, TeammateIdle

### Hook features Mythos is NOT using
- type: "mcp_tool" hooks (v2.1.118)
- type: "http" hooks
- args: string[] exec form (no shell, v2.1.139)
- terminalSequence output field (desktop notifs, v2.1.141)
- continueOnBlock on PostToolUse (v2.1.141)
- effort.level input field in hook JSON
- background_tasks / session_crons in Stop/SubagentStop input
- asyncRewake (background hooks that wake on exit 2)

### Plugin system (not used by Mythos at all)
- Full plugin manifest with hooks, agents, skills, mcpServers, lspServers
- Plugin marketplace, dependency enforcement, --plugin-url
- Plugins can ship themes

### New env vars relevant to Mythos fleet/headless
- CLAUDE_CODE_SESSION_ID — passed to Bash subprocess (v2.1.132)
- CLAUDE_EFFORT — current effort in Bash subprocess (v2.1.145)
- CLAUDE_CODE_SUBAGENT_MODEL — forwarded to child processes (v2.1.146)
- CLAUDE_CODE_STOP_HOOK_BLOCK_CAP — override 8-block cap (v2.1.126)

### CLI flags relevant to Mythos fleet
- claude agents --json — list sessions as JSON for scripting (v2.1.145)
- claude agents --add-dir / --settings / --mcp-config / --model / --effort (v2.1.142)
- claude agents --cwd <path> (v2.1.141)
- --fallback-model (v2.1.120)
- --agent <name> case-insensitive (v2.1.145)

### MCP additions
- type: "mcp_tool" hooks calling connected servers
- MCP elicitation (servers request structured user input mid-task)
- alwaysLoad: true skips ToolSearch deferral
- workspace is reserved server name
- MCP stdio receives CLAUDE_PROJECT_DIR

### Effort/model
- /effort xhigh level for Opus 4.7 (v2.1.111)
- CLAUDE_CODE_EFFORT_LEVEL env var override

