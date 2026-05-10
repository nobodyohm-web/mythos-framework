# Risk Rules — Mythos Guardrails

> Imported by `CLAUDE.md` via `@Risk.md`. These rules apply to **every** session.

---

## Code Risk

| Rule | Enforcement |
|------|-------------|
| Never commit `.env`, `.env.*`, secrets, credentials, `*.pem`, `*.key` | `permissions.deny` + `git-guardian.sh` |
| Never `git push --force` (or `-f`) to `main` / `master` | `permissions.deny` + `git-guardian.sh` |
| Never `--no-verify` to skip git hooks | `git-guardian.sh` blocks; CLAUDE.md rule #5 |
| Never `rm -rf /`, `rm -rf ~`, `rm -rf $HOME` | `permissions.deny` + `git-guardian.sh` |
| Never amend a published commit | CLAUDE.md OPERATING MODE |
| Never disable a failing test as a "fix" | `debug-detective.md` Anti-Patterns |

## Confidence Risk

- **<70 confidence** → explain WHY and what would raise it. Do not ship.
- **Two consecutive <70** → suggest `/evolve`.
- Log every significant action's confidence to `tasks/confidence-log.md`.

## Trading Risk (when applicable)

| Rule | Detail |
|------|--------|
| Max risk per trade | 1% of account equity |
| Max concurrent positions | 5 |
| Max daily loss | 3% of account equity → halt for the day |
| Stop-loss before entry | Mandatory; no naked entries |
| No averaging down | Add only to winners (above entry, with trail) |
| News/earnings exposure | No new positions within 24h of scheduled catalyst unless the play *is* the catalyst |

Personal overrides go in `Risk.local.md` (gitignored).

## Operational Risk

- Test hooks behaviorally with crafted stdin before wiring (see `tasks/lessons.md` 2026-05-10).
- Validate every JSON config with `python3 -c "import json; json.load(open(P))"` before commit.
- Self-test (`hooks/test-mythos.sh`) must be green before any `/evolve` commit.
- CLAUDE.md ≤ 200 lines, hard cap.
