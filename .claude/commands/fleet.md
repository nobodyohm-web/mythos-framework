# /fleet — Multi-Worker Claude Code Orchestration

> Spawn parallel `claude -p` workers from the main session. Each worker is sandboxed (`--bare`, read-only by default, hard budget cap). Workers can optionally route through `claude-code-router` to cheap/free providers.

## When to use

Use **only** when the work is genuinely parallel and each worker's task is self-contained. Good fits:

- "Write JSDoc for every function in 20 files" → 1 worker per file.
- "Translate 12 README sections into English" → 1 worker per section.
- "Generate Pydantic models from these 8 OpenAPI specs" → 1 worker per spec.
- "Add docstrings + type hints to legacy module X" → 1 worker per submodule.

Do **NOT** use for tasks that need shared state, cross-file reasoning, or judgment. Those stay on the orchestrator (you, on Opus).

## Workflow

1. **Plan** — Break the work into independent subtasks. Write each into a single sentence.
2. **Dispatch** — One `mythos-fleet dispatch` call per subtask. Returns a worker id.
3. **Wait** — Workers run in the background. `mythos-fleet status` to monitor.
4. **Collect** — `mythos-fleet collect --id <id>` reads the worker's structured output (text + `total_cost_usd` + `session_id`).
5. **Review + integrate** — YOU review every worker's output. The fleet never auto-applies — workers can't push to git, can't merge, can't even write outside their cwd unless you `--allow-tools "Write,Edit"`.

## Example

```bash
# Three docstring jobs in parallel, all read-only by default
id1=$(bin/mythos-fleet dispatch "Add JSDoc to every export in src/auth.ts" --allow-tools "Read,Edit" --budget 0.30)
id2=$(bin/mythos-fleet dispatch "Add JSDoc to every export in src/db.ts"   --allow-tools "Read,Edit" --budget 0.30)
id3=$(bin/mythos-fleet dispatch "Add JSDoc to every export in src/api.ts"  --allow-tools "Read,Edit" --budget 0.30)

bin/mythos-fleet status

# When done:
bin/mythos-fleet collect --id "$id1" --wait
bin/mythos-fleet collect --id "$id2" --wait
bin/mythos-fleet collect --id "$id3" --wait

# Cleanup:
bin/mythos-fleet clear --all
```

## Routing workers to cheap providers

If `claude-code-router` is running (`bin/mythos-route status` confirms), pass `--provider <name>`:

```bash
bin/mythos-fleet dispatch "Generate getters/setters for src/models/user.go" \
  --provider openrouter --model deepseek/deepseek-chat \
  --allow-tools "Read,Edit" --budget 0.10
```

The worker's `ANTHROPIC_BASE_URL` is set to `http://127.0.0.1:3456`. If `ccr` isn't running, dispatch fails fast with exit 4 — never silently runs on first-party billing when you asked for routing.

## Safety contract (encoded in `bin/mythos-fleet`)

| Constraint | Enforced how |
|---|---|
| Workers can't persist sessions | `--no-session-persistence` always passed |
| Workers don't load hooks/MCP/CLAUDE.md | `--bare` always passed |
| Workers can't write/exec by default | `--allowedTools "Read,Grep,Glob"` |
| Budget cap is mandatory | `--max-budget-usd $1.00` default, never omitted |
| Routing requires running router | `ccr_running` HEAD check; exit 4 if not |
| Workers respect their `cwd` | `--add-dir` must be passed explicitly |

## Constraints — do not bypass

- Do NOT call `--allow-dangerously-skip-permissions` for workers.
- Do NOT pass the orchestrator's API key into a worker that's routed to a 3rd-party provider.
- Do NOT collect-and-auto-apply. Always review.

## Cross-references
- [[free-claude-code-assessment]] — honest verdict on "free claude code" projects
- [[multi-provider-routing]] — how to set up `ccr` for cheap workers
- [[parallel-execution]] — when fan-out is appropriate (vs. coupled tasks staying on main)
