# Lessons Learned — Agentic Autonomy

> This file is updated automatically after every user correction.
> Claude Code must review this file at session start and apply all patterns.
> Fed by: L3 Self-Improvement Loop (Rule #3) + L4 Journal Analyzer subagent.

---

## Format
Each lesson follows this structure:
```
### [DATE] — [SHORT TITLE]
**Mistake:** What went wrong
**Root Cause:** Why it happened
**Rule:** What to do instead (permanently)
```

---

<!-- Lessons will be appended below this line -->

### 2026-05-10 — Wiring is not enforcement until the file exists
**Mistake:** v3.2 settings.json wired 14 hooks (`bash hooks/X.sh ... || true`), but the `hooks/` directory was absent in this checkout. Every hook silently no-op'd thanks to `|| true`. The system *looked* fully evolved (patterns.json said "all green") but had zero runtime enforcement.
**Root Cause:** Conflated configuration with implementation. A self-test that only checked settings.json structure (not file existence on disk) cannot detect missing implementations referenced by that config. The `|| true` fallback hid the failure.
**Rule:** Every config reference must be paired with a presence check in `test-mythos.sh`. For hooks specifically: `[ -f hooks/X.sh ] && [ -x hooks/X.sh ]` for every script the settings.json file mentions. Never use `|| true` to swallow "file not found" — only to swallow "non-zero exit from a working file".

### 2026-05-10 — Hook activation can block your own meta-tooling
**Mistake:** Right after wiring git-guardian, ran a Bash command containing literal strings like `cat /home/x/.env` and `rm -rf /` (as JSON test payloads). The PreToolUse hook saw those substrings in the outer command and blocked execution.
**Root Cause:** git-guardian inspects `.tool_input.command` from the harness, which is the FULL outer command — it cannot tell test heredocs from real commands. Substring detection is correct enforcement; it just doesn't distinguish authoring context from runtime.
**Rule:** Embed hook behavior tests **inside `hooks/test-mythos.sh`** (which calls `bash hooks/X.sh` directly with crafted stdin), not as ad-hoc Bash one-liners from the agent. The self-test is invoked by the harness as `bash hooks/test-mythos.sh` — that outer string contains no dangerous substrings, so the hook stays out of its own way.

### 2026-05-10 — Substring matching is too coarse for command guards
**Mistake:** v3.3 git-guardian first pass flagged `git commit -m "...removed rm -rf / shortcut..."` as a destructive command. The dangerous pattern was inside a quoted argument (commit-message body), not the actual invocation. Result: legitimate commits were blocked.
**Root Cause:** Used substring `grep -Eq` against the entire command line. A command guard must distinguish *invocations* from *string literals embedded in arguments*. Without doing real shell parsing, anchoring on shell-segment boundaries is the minimum viable heuristic.
**Rule:** Anchor every guard pattern with `^` after splitting the command on shell separators (`;`, `&&`, `||`, `|`, newline) AND replacing quoted strings with a placeholder first. Each segment's leading invocation is what gets matched. Three regression tests now live in `test-mythos.sh`:
  1. `git commit -m "...dangerous string..."` → MUST allow (quoted content).
  2. `echo hi && rm -rf /` → MUST block (real chained invocation).
  3. `echo "git push --force main"` → MUST allow (string content).

### 2026-05-10 — CLAUDE.md is a budget, not a wishlist
**Mistake:** Initial CLAUDE.md was 268 lines including ascii diagrams, prose identity statements, and French verification blocks. Anthropic explicitly warns this causes Claude to ignore rules buried in noise.
**Root Cause:** Mistook comprehensiveness for clarity. Added everything that "felt useful" rather than only what changed Claude's behavior.
**Rule:** For every line in CLAUDE.md, ask "would removing this cause Claude to make a mistake?" If no → cut. Cap at 200 lines. Use `@imports` for detail; lazy-load via skills.

### 2026-05-10 — Hooks beat prompts for invariants
**Mistake:** Relying on CLAUDE.md instructions like "never commit secrets" — these are advisory and depend on model adherence.
**Root Cause:** Confused advisory text with deterministic enforcement.
**Rule:** Anything that MUST happen every time → hook. Anything that's situational → CLAUDE.md or skill. Defense-in-depth: layer both for critical invariants (e.g. force-push to main is denied in `permissions.deny` AND blocked by `git-guardian.sh`).

### 2026-05-10 — Test hooks with crafted stdin
**Mistake:** Past evolutions wrote hooks but never validated behavior end-to-end.
**Root Cause:** Assumed bash syntax check = working hook.
**Rule:** For every hook with branching logic, verify with `echo '{...}' | bash hooks/foo.sh; echo "exit=$?"`. Confirm both block-path (exit 2) and allow-path (exit 0). Bake these into `test-mythos.sh` over time.

### 2026-05-10 — Keep Bash(*) wildcard in permissions.allow
**Mistake:** /evolve replaced `Bash(*)` with 45 scoped commands (git, npm, bun...). Every unlisted command triggered a permission prompt, breaking autonomous flow.
**Root Cause:** Research said "wildcards defeat the safety classifier" — but the user explicitly wants ZERO permission prompts. The `deny` list already blocks dangerous operations (force-push, rm -rf /, secret reads).
**Rule:** ALWAYS keep `Bash(*)` in permissions.allow. Use `deny` list for security, NOT scoped allow. The deny list is the guardrail, not the allow list.

### 2026-05-10 — Subagents must live at .claude/agents/ to be discoverable
**Mistake:** v3.0–v3.1 stored subagent specs at `subagents/<name>.md`. Claude Code's Task tool only auto-discovers `.claude/agents/<name>.md` (project) and `~/.claude/agents/<name>.md` (user). The flat `subagents/` files were documentation only.
**Root Cause:** Confused "we wrote a subagent spec" with "the harness can invoke it". The schema was fine; the path was wrong.
**Rule:** Canonical subagent location is `.claude/agents/<name>.md`. Keep `subagents/` only as human reference. Frontmatter MUST include `name`, `description`, `tools` (comma-separated), `model`. The `description` is what triggers automatic delegation — write it as "when to use" in third person.

### 2026-05-10 — Hook output should use the official JSON contract when possible
**Mistake:** smart-router emitted plain-text `[ROUTER] Task type: ...` to stdout. The harness still surfaced it, but the cleanest path is the documented `{"hookSpecificOutput":{"hookEventName":"...","additionalContext":"..."}}` shape.
**Root Cause:** Took the path of least resistance instead of reading the hook spec.
**Rule:** When a hook injects context, prefer the JSON contract via `jq`. Fall back to plain stdout only if `jq` is missing. This keeps integration with future Claude Code versions stable.

### 2026-05-10 — Wire the full hook lifecycle, not just the obvious events
**Mistake:** v3.1 wired only SessionStart/End, UserPromptSubmit, PreToolUse, PostToolUse, Stop. Missed PreCompact (state lost on /compact), SubagentStop (no subagent observability), Notification (no surface for permission events).
**Root Cause:** Built reactively for the events I'd already used; didn't audit the complete event list in the docs.
**Rule:** When adding observability, check every event in `code.claude.com/docs/en/hooks` and decide explicitly: wire it, log it, or document why not.

### 2026-05-10 — Capture pre-compact state, don't lose it
**Mistake:** When `/compact` ran mid-session, transient context (current task, branch, last lesson) was rebuilt from scratch. Wasted tokens re-deriving what was already known.
**Root Cause:** Treated /compact as "free" cleanup; ignored that it discards working memory.
**Rule:** PreCompact hook persists a small markdown snapshot (`precompact-snapshot.md`) that the post-compact session can read in one Read call. Cheap insurance.

