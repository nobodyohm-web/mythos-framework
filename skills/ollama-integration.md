# Ollama Integration — Native Anthropic Compatibility for Local Workers

> Load this skill when working with local Ollama, planning fleet workers that should run free, or when `/assimilate` reports Ollama present on the host.

## Why Ollama is a force-multiplier for Mythos

- **Truly free.** Runs on your hardware. No API spend.
- **Private.** No prompt, no code, no auth leaves the machine.
- **Parallel.** A single GPU or M-series Mac can serve multiple `claude -p` workers concurrently.
- **Native Anthropic API.** Since **Ollama v0.14 (January 2026)**, the daemon exposes a Messages-API-compatible endpoint at `http://localhost:11434`. **No `ccr` proxy required.**

## The clean integration path (v0.14+)

```bash
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_API_KEY=""
export ANTHROPIC_BASE_URL=http://localhost:11434
claude --model qwen3.6:latest
```

That's it. `claude` now speaks to your local daemon. No proxy, no translation layer, no extra port.

Confirm: `bin/mythos-ollama status` → `native anthropic: yes`.

For Ollama < 0.14, fall back to the `ccr` path documented in [[multi-provider-routing]].

## When to use Ollama workers (and when NOT to)

| Task type | Use Ollama? | Why |
|---|---|---|
| Boilerplate (docstrings, getters, format conversions) | ✅ yes | Pattern-matching is well within local-model quality. |
| Refactor passes with characterization tests covering them | ✅ yes | Tests are the safety net; model quality matters less. |
| Test scaffolding from existing code | ✅ yes | Mechanical work. |
| Summarization / one-shot translations | ✅ yes | I/O-bound, quality acceptable. |
| Architecture, ADR drafting, multi-component design | ❌ no | Keep on Anthropic — non-trivial reasoning. |
| Security audits (OWASP, CVE recall) | ❌ no | Recall quality on safety-critical recall is materially lower locally. |
| Bug localization in unfamiliar code | ❌ no | Long-horizon reasoning + tool orchestration. |
| Anything customer-facing or shipping to prod | ❌ no | Quality bar requires first-party Anthropic. |

**[D]** This split mirrors the v5.5 fleet philosophy: orchestrator on Anthropic for judgment, workers on cheap/local for grunt-work. Empirically validated by the 2026 SWE-bench gap between Claude Opus and open-weight 70B-class models.

## Model requirements

Claude Code requires **≥64k context tokens**. Models that meet this on Ollama 2026:

| Model | Context | Size | Good for |
|---|---|---|---|
| `qwen3.6:latest` | 128k | ~24GB | Code, long ctx — top pick |
| `qwen3.5` | 128k | ~14GB | Smaller fallback |
| `glm-5` | 128k | ~22GB | General + code |
| `kimi-k2.5:cloud` | 200k | cloud-routed | Highest quality, paid via Ollama cloud |

Small models (`qwen3:8b`, `llama3:7b`, `phi-3-mini`) **do not** reliably meet 64k. Useful for ad-hoc, not for fleet workers.

Pull a model: `ollama pull qwen3.6:latest` (large download — user-controlled).

`bin/mythos-ollama recommend` surfaces the current list.

## Fleet integration

```bash
# Worker on local Ollama (free, private, read-only by default)
bin/mythos-fleet dispatch --ollama --model qwen3.6:latest "Add JSDoc to src/auth.ts"

# Multiple workers in parallel — each gets its own subprocess
id1=$(bin/mythos-fleet dispatch --ollama --model qwen3.6:latest "Add JSDoc to src/auth.ts" --allow-tools Read,Edit --budget 0)
id2=$(bin/mythos-fleet dispatch --ollama --model qwen3.6:latest "Add JSDoc to src/db.ts"   --allow-tools Read,Edit --budget 0)

bin/mythos-fleet status
bin/mythos-fleet collect --id "$id1" --wait
```

The `--ollama` flag sets `ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN` for that worker only — your main session keeps using Anthropic.

If Ollama endpoint is not reachable, the dispatch exits **4** without spawning. Same exit code as `--provider` for `ccr` — symmetric safety contract.

## During /assimilate

`/assimilate` Phase 1.5 (Local Compute Probe) automatically runs `bin/mythos-ollama status`:

- **If Ollama installed + reachable:** the assimilation summary includes a "Local fleet available" hint and surfaces `recommend`'s output.
- **If Ollama missing:** the summary includes a `bin/mythos-ollama install` hint. The agent NEVER auto-runs the installer — that's a user decision.

This stays advisory: assimilation is a scan + plan, not an environment-mutating action.

## Privacy posture

- All inference local. No prompt or response leaves your machine.
- Auth token is the literal string `ollama` — a placeholder, not a secret.
- `bin/mythos-ollama enable` only prints env vars; you decide whether to export them.
- Mythos hooks (`prompt-injection-guard`, `hallucination-guard`) work identically over the local Anthropic-compatible endpoint — they operate on tool I/O, not the model URL.

## Safety contract (encoded in CLI)

`bin/mythos-ollama` **never**:
- runs `brew install`, `curl | sh`, or any installer
- runs `ollama pull <model>` (large downloads — user-controlled)
- `eval`s into your shell
- modifies `~/.zshrc`, `~/.bashrc`, or any rc file
- writes secrets

Same contract as `bin/mythos-route`. Print, you paste, you execute.

## Cross-references
- [[multi-provider-routing]] — `ccr` path for providers other than Ollama, or Ollama < 0.14.
- [[free-claude-code-assessment]] — why "free claude code" projects don't replace Claude, but Ollama can serve as worker-tier.
- [[parallel-execution]] — when fan-out across local workers is worth the orchestration cost.
- [[terse-mode]] — combine with Ollama workers for the cheapest possible iteration loop.
