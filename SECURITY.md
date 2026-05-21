# Security Policy

## Supported versions

Mythos releases security fixes for the latest minor version on `master`. Older minor versions are best-effort.

| Version | Supported |
|---------|-----------|
| 6.x     | ✅ |
| 5.x     | ⚠️ best-effort |
| < 5     | ❌ |

## Reporting a vulnerability

**Do not file a public issue for a security vulnerability.**

Email: report it through GitHub's [private vulnerability reporting](https://github.com/nobodyohm-web/mythos-framework/security/advisories/new) for this repo.

Please include:
- A description of the vulnerability.
- Steps to reproduce (a minimal proof-of-concept).
- The affected file(s), hook(s), or CLI(s).
- Your assessment of impact (RCE, secret leak, data corruption, etc.).
- Whether you've shared the finding with anyone else.

We will acknowledge within 72 hours and aim to ship a fix or mitigation within 7 days for high-severity issues.

## Threat model

Mythos ships defenses against three classes of risk:

### 1. Irreversible local operations
- `hooks/git-guardian.sh` blocks `git push --force` to main/master, `--no-verify` commits, `rm -rf /`, commits touching `.env*` or `*.pem`/`*.key`.
- Fleet workers run in `--bare` mode with `--no-session-persistence` and a mandatory `--max-budget-usd` cap.

### 2. Model hallucination
- `hooks/hallucination-guard.sh` (PreToolUse on Bash) warns when a command references a nonexistent path.
- `hooks/agent-guard.sh` (PostToolUse) detects command-repeat loops via a 20-entry ring buffer.

### 3. Untrusted content via tools
- `hooks/prompt-injection-guard.sh` (PostToolUse on Read, WebFetch) scans tool responses for injection patterns and emits a `[PROMPT-INJECTION-GUARD]` warning into the next turn.
- The marketplace HEAD-probes URLs before write and supports SHA-256 pinning to detect tampering between review and re-install.

## What Mythos does NOT protect

- **Supply chain.** If you `install`, you trust the bytes. We HEAD-probe and SHA-pin on request, but we do not vet third-party skill/agent *content*. Read every third-party file before installing.
- **MCP servers.** MCP integration is the user's responsibility. Mythos does not sandbox MCP tool calls.
- **Provider routing.** If you run with `claude-code-router` pointed at a third-party provider, your prompts and code transit that provider. We don't control their retention or logging.
- **Model jailbreaks.** Mythos's defenses are about the *agent loop*, not the model. A user who actively tries to jailbreak the agent can defeat the hooks by disabling them.

## Hardening recommendations

For high-stakes use:

1. Pin every third-party skill/agent's SHA-256 in `registry/skills.json` / `registry/agents.json` via `bin/mythos-skill refresh-sha`.
2. Run with `bin/mythos-fleet --allow-tools Read,Grep,Glob` for any worker you wouldn't trust to write files.
3. Set `MYTHOS_LOOP_THRESHOLD` low (e.g., `2`) in CI to catch repeat-loop failures fast.
4. Review `tasks/confidence-log.md` regularly. Two consecutive sub-70 confidence scores should trigger `/evolve`.
5. Never commit `.claude/state/` to a public repo — it can leak prompts, plans, and budget data.

## Past advisories

None at this time. Each future advisory will be linked here with CVE-ID (if assigned), affected versions, and the fix commit.
