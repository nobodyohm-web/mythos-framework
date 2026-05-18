# Lessons Learned

> Append new lessons under `### YYYY-MM-DD — Short title`. Keep each lesson load-bearing — generic advice doesn't belong here.

### 2026-05-18 — Externalize state across agents; isolate context per agent
**Mistake (pre-evolution):** Mythos relied on subagents returning a single summary string for cross-agent handoff, which loses raw evidence and recreates context drift the parallel design was supposed to avoid.
**Root cause:** No durable, structured handoff mechanism between agents — only the Task tool's return value.
**Rule:** Use `bin/mythos-blackboard` for any cross-agent work that must preserve evidence. One topic per workstream, always tag the entry with an Epistemic Tier (`--tier=E|D|C|S`). Pattern matches InfiAgent / blackboard architecture.

### 2026-05-18 — Detect loops at the hook layer, not in the model
**Mistake (latent):** Repeated identical Bash commands (a classic agent failure mode) were only caught by the operator's eyes.
**Root cause:** No PostToolUse hook tracking command frequency.
**Rule:** `hooks/agent-guard.sh` keeps a 20-entry ring buffer of Bash commands. ≥3 repeats of the same command emits an `[AGENT-GUARD]` warning into the next model turn. Threshold tunable via `MYTHOS_LOOP_THRESHOLD`. When the warning fires, stop and re-plan — do not retry blindly.

### 2026-05-18 — `jq -c` without `-n` waits on stdin
**Mistake:** `mythos-blackboard write` silently created an empty file because `jq -c --arg ... '{...}' >> tmp` (no `-n`) waited on stdin and consumed nothing.
**Root cause:** Forgot the `-n` (null-input) flag for jq's create-from-scratch idiom.
**Rule:** When using jq purely to construct JSON from `--arg`/`--argjson` (no input filter), ALWAYS use `jq -nc` (or `-n` family). Repro the bug in test before claiming write success.

### 2026-05-18 — `jq -Rs . <<<` adds a trailing newline; don't grep with it
**Mistake:** `agent-guard.sh` couldn't count command repeats because the escaped match string ended in `\n`, which `grep` can't match within a single line.
**Root cause:** `jq -Rs . <<<"$x"` reads `$x` + the herestring's appended newline.
**Rule:** For per-line matching in JSONL ring buffers, prefer `jq` over `grep` (`jq -r --arg c "$CMD" 'select(.cmd == $c) | .ts' | wc -l`). If using grep, strip newlines via `printf '%s'` instead of `<<<`.

### 2026-05-18 — Auto-bootstrap CLI deps via project `.venv`
**Mistake:** A fresh shell of `bin/mythos-research` errored on missing `duckduckgo_search`/`bs4`.
**Root cause:** Hard import at top with no fallback; macOS Homebrew Python rejects user installs (PEP-668).
**Rule:** Project Python CLIs check for deps with `importlib.util.find_spec`. If missing and a project `.venv` exists, `os.execv` themselves under `.venv/bin/python3`. Same pattern reused for any future Python CLI.

### 2026-05-18 — Use the renamed `ddgs` package; keep legacy import as fallback
**Mistake:** `duckduckgo_search` is deprecated and was returning empty results from this network.
**Root cause:** Upstream renamed the package to `ddgs`; legacy still installs but is rate-limited.
**Rule:** `bin/mythos-research v2` tries `from ddgs import DDGS` first, falls back to `duckduckgo_search`. If results are empty, retries once with `safesearch=off`.
