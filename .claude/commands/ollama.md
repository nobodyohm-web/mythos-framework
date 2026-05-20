# /ollama — Local Ollama Status & Fleet Integration

Thin wrapper around `bin/mythos-ollama`. Read-only / advisory — never installs, never pulls models, never modifies your shell.

## What it does

| Subcommand | Action |
|---|---|
| `/ollama` (no args) | Equivalent to `bin/mythos-ollama status` |
| `/ollama status` | Detect binary, endpoint, version, model count |
| `/ollama models` | List installed models with size |
| `/ollama install` | Print install commands (does NOT execute) |
| `/ollama enable` | Print env vars to paste into your shell |
| `/ollama disable` | Print env vars to unset |
| `/ollama pull <model>` | Print `ollama pull` command (does NOT execute) |
| `/ollama recommend` | Suggest code-capable models with ≥64k context |
| `/ollama probe` | Reachability check, exit 0/1 |

## When to use

- **At session start in a new host** — see if local compute is available before planning fleet workers.
- **After `/assimilate`** — Phase 1.5 already runs status; this lets you drill deeper.
- **Before `/fleet dispatch --ollama`** — confirm endpoint is up and model is loaded.

## Workflow examples

```bash
/ollama status
# → see if ollama is installed and the endpoint is reachable

/ollama models
# → list local models, pick one that meets >=64k context

# If a model is missing:
/ollama pull qwen3.6:latest
# → prints `ollama pull qwen3.6:latest` for you to run

# Activate routing for this shell:
/ollama enable
# → prints export lines; paste into your shell

# Dispatch fleet work to local Ollama:
bin/mythos-fleet dispatch --ollama --model qwen3.6:latest \
  "Add JSDoc to src/auth.ts" --allow-tools Read,Edit --budget 0
```

## Safety contract

`bin/mythos-ollama` (and therefore `/ollama`) **never**:
- runs `brew install`, `curl | sh`, or any installer
- runs `ollama pull <model>` (large downloads stay user-controlled)
- `eval`s into your shell
- modifies `~/.zshrc`, `~/.bashrc`, or any rc file

You see the command. You decide. You run it.

## Quality reminder

Ollama workers are for **boilerplate, refactor passes, summarization**. Keep architecture, security audits, and long-horizon planning on first-party Anthropic. See `skills/ollama-integration.md` for the full split.

## Cross-references

- `skills/ollama-integration.md` — full skill: when to use, model picks, safety
- `skills/multi-provider-routing.md` — `ccr` path for non-Ollama providers
- `skills/free-claude-code-assessment.md` — honest verdict on routing proxies
- `.claude/commands/fleet.md` — dispatch + collect workflow
