# Skill — MCP Orchestrator

> When to use which MCP tool, common workflows, and how to fail gracefully when a server is offline.

**Trigger when:** a task involves cross-directory file ops, persistent key-value memory, structured web fetching, sequential planning, or GitHub PR/issue operations.

**Skip when:** the task is local code edits in the working directory — built-in Read/Edit/Write/Bash are faster than going through MCP.

---

## Available MCP servers (configured in `.claude/settings.json` → `mcpServers`)

| Server | Tool prefix | Purpose | Needs env? |
|---|---|---|---|
| `filesystem` | `mcp__filesystem__*` | Read/write/glob across allowed dirs (incl. `~/Desktop`) | no |
| `memory` | `mcp__memory__*` | Persistent KV store across sessions (knowledge graph) | no |
| `sequential-thinking` | `mcp__sequential-thinking__*` | Multi-step reasoning scaffolding for planning | no |
| `fetch` | `mcp__fetch__*` | Structured web content fetching with markdown conversion | no |
| `github` | `mcp__github__*` | PRs, issues, repo search (only loaded if `GITHUB_TOKEN` set) | yes |

Run `/mcp` in Claude Code to see live status. Tools appear with prefix `mcp__<server>__<tool>`.

---

## Decision flow

```
need to read/write file in project root?     → built-in Read / Write / Edit
need to access ~/Desktop or sibling repo?     → mcp__filesystem__*
need to remember a fact across sessions?      → mcp__memory__create_entities
need to recall something from a past session? → mcp__memory__search_nodes
need to break down a complex problem?         → mcp__sequential-thinking__sequentialthinking
need a single web page's content as markdown? → mcp__fetch__fetch
need to list / read / comment a PR?           → gh CLI (faster) or mcp__github__*
```

---

## Common workflows

### Workflow A — cross-repo investigation
1. `mcp__filesystem__list_allowed_directories` → confirm scope
2. `mcp__filesystem__search_files` with pattern → find target
3. `mcp__filesystem__read_text_file` → read findings
4. Synthesize without copying everything into context

### Workflow B — persistent learning
1. After a non-trivial fix: `mcp__memory__create_entities` with `{name, entityType:"lesson", observations:[...]}`
2. Next session, on similar task: `mcp__memory__search_nodes` with the topic keywords
3. Apply the recalled lesson; update if it's evolved

### Workflow C — PR triage
1. `gh pr list --state open --json number,title,author` (faster than MCP for listing)
2. For depth: `mcp__github__get_pull_request_files` for the diff
3. `mcp__github__create_pull_request_comment` to leave review notes

### Workflow D — sequential planning
- Use `mcp__sequential-thinking__sequentialthinking` when:
  - The problem has unclear sub-structure
  - Hypotheses need to be revised mid-plan
  - You'd otherwise re-prompt yourself 3+ times
- Skip when the plan fits in your head (≤5 steps).

---

## Error handling

| Failure | Recovery |
|---|---|
| MCP server not running (`mcp__X__*` not in tool list) | Fall back to built-in equivalent; note the gap in `tasks/session-journal.md` |
| MCP tool returns error | Read error message; if "permission denied" → check `mcp__filesystem__list_allowed_directories`; if "rate limit" → backoff |
| Server starts but no tools register | Restart with `/mcp` reconnect; if persistent, log to `tasks/lessons.md` |
| GitHub MCP wants `GITHUB_TOKEN` you don't have | Use `gh` CLI instead (uses gh auth) |

---

## Anti-patterns

- ❌ Using `mcp__filesystem__*` for files in the project working directory (built-in is cheaper).
- ❌ Storing every conversation turn in `mcp__memory__` — only durable lessons.
- ❌ Wrapping every web fetch in `mcp__sequential-thinking__*` — tool, not crutch.
- ❌ Trusting an MCP tool's output without sanity-checking (same as any external tool).

---

## References
- Active server config: `.claude/settings.json` → `mcpServers`
- Live status: run `/mcp` in Claude Code
- Server docs: https://modelcontextprotocol.io/
