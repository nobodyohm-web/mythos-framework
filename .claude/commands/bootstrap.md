# /bootstrap — Project Initialization Wizard

Detect the project type and scaffold a Mythos-grade Claude Code workspace inside it.

## Target
Project at `$ARGUMENTS` (default: current working directory).

## Phase 1 — DETECT

Inspect the target dir to classify the project:

```bash
ls -1 | head -50
test -f package.json && echo "node-or-bun"
test -f pyproject.toml -o -f requirements.txt && echo "python"
test -f Cargo.toml && echo "rust"
test -f go.mod && echo "go"
```

Identify:
- **Stack**: Node/Bun, Python, Rust, Go, mixed?
- **Framework hints**: React/Next/Vue, FastAPI/Flask, Axum/Actix?
- **Test runner**: vitest, jest, pytest, cargo test, go test?
- **Existing CI**: `.github/workflows/`?
- **Existing Claude config**: `CLAUDE.md`, `.claude/`?

## Phase 2 — PROPOSE

Output a **non-destructive** plan:
- What will be created (paths)
- What existing files will be MODIFIED (with diff preview)
- What existing files will be UNTOUCHED

If `CLAUDE.md` already exists → never overwrite. Suggest merging.

## Phase 3 — SCAFFOLD

Create the minimum:

1. `CLAUDE.md` (only if absent) — using the project-type-aware template:
   - Stack section pre-filled
   - Test command pre-filled (`bun test` / `pytest` / `cargo test`)
   - Lint command pre-filled
2. `.claude/settings.json` (only if absent) — with permission allowlist scoped to detected stack
3. `tasks/` directory with empty `lessons.md`, `confidence-log.md`, `todo.md`, `session-journal.md`
4. `.gitignore` additions (if needed): `.claude/memory/.context-guardian-*`, `.env`, `.env.*`

## Phase 4 — VERIFY

Run a quick smoke test:
- `cat CLAUDE.md | head -20`
- `python3 -c "import json; json.load(open('.claude/settings.json'))"`
- `git status` → confirm only intended files staged

## Phase 5 — REPORT

```
═══════════════════════════════════════════
  🚀 BOOTSTRAP COMPLETE
═══════════════════════════════════════════

📦 Detected stack: <stack>
🧪 Test command: <command>
🔧 Lint command: <command>

📁 Created:
  - <path>
  - <path>

📁 Untouched (already present):
  - <path>

▶️ Next steps:
  1. Review CLAUDE.md and tune for your repo
  2. Run /mythosrun "implement first feature"
═══════════════════════════════════════════
```

## Constraints
- **Never overwrite** existing CLAUDE.md, settings.json, or tasks files. Always offer a merge instead.
- **Never auto-commit** the scaffold; let the user review the diff first.
- **No npm install / pip install / cargo build** — bootstrap is config-only, not dependency installation.
