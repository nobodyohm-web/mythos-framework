# /evolve — MYTHOS AUTONOMOUS EVOLUTION ENGINE

You are now entering **FULL AUTONOMOUS EVOLUTION MODE**.

This is NOT a simple analysis. This is a **massive, multi-phase autonomous construction project** where you will deeply analyze, redesign, build, test, and deploy improvements to transform this Claude Code workspace into the most powerful agentic development environment possible.

You will work **autonomously for as long as needed**. Do NOT stop after one improvement. Do NOT ask for permission between phases. Execute the ENTIRE protocol below, end to end, without interruption.

Your goal: make this workspace **compound in intelligence** with every session. Build the infrastructure that makes Claude Code operate at Mythos-level autonomy.

---

## PHASE 1 — DEEP SYSTEM AUDIT (Read everything, understand everything)

Read and analyze ALL of these files. Do not skip any:

1. `CLAUDE.md` — Current identity, rules, architecture
2. `Risk.md` — Risk rules
3. `tasks/lessons.md` — All learned patterns (CRITICAL — these are past failures)
4. `tasks/confidence-log.md` — All confidence scores (calibration data)
5. `tasks/session-journal.md` — Session history
6. `tasks/todo.md` — Pending and completed tasks
7. `.claude/memory/patterns.json` — Serialized learning state
8. `.claude/settings.json` — Current hooks and permissions
9. ALL files in `skills/` — Current playbooks
10. ALL files in `subagents/` — Current specialist specs
11. ALL files in `hooks/` — Current guardrail scripts
12. ALL files in `.claude/commands/` — Current slash commands
13. ALL files in `plugins/` — Current distribution channels

After reading everything, write a `## SYSTEM AUDIT` section in `tasks/session-journal.md` with:
- Total files in system
- Total lines of configuration
- Gaps identified (what's missing vs what a Mythos-level system needs)
- Redundancies (what's duplicated or contradictory)
- Weakness map (where the system is most fragile)

---

## PHASE 2 — INTELLIGENCE AMPLIFICATION (Upgrade the brain)

### 2A — CLAUDE.md Deep Enhancement
Analyze the current CLAUDE.md and improve it:

1. **Tighten the rules** — Are there ambiguous rules? Make them precise and testable
2. **Add missing patterns** — Based on lessons.md, what rules should exist but don't?
3. **Optimize the structure** — Research says optimal CLAUDE.md is 60-200 lines. If over 200, refactor: move detailed instructions into skills/ and keep CLAUDE.md as a high-level control document
4. **Add project detection** — CLAUDE.md should adapt behavior based on what kind of project exists in the workspace (TypeScript? Python? Rust? Empty?)
5. **Strengthen meta-cognition** — Add thinking frameworks for complex decisions

### 2B — Confidence Calibration
Review all entries in `confidence-log.md`:
1. Were high-confidence predictions accurate?
2. Were low-confidence predictions justified?
3. Calculate calibration score
4. Adjust the confidence scoring guidelines in CLAUDE.md based on data

---

## PHASE 3 — AUTONOMOUS INFRASTRUCTURE BUILD (Build new capabilities)

### 3A — Create Advanced Hook System
Build these NEW hooks if they don't exist:

1. **`hooks/smart-router.sh`** — Intelligent prompt routing:
   - Detect if user input is a bug report → auto-trigger /heal logic
   - Detect if user input is a question → respond directly, don't plan
   - Detect if user input is a complex task → auto-trigger /mythosrun logic
   - Detect if user input is a code review request → auto-trigger review subagent

2. **`hooks/context-guardian.sh`** — Context window protection:
   - Estimate current context usage
   - Warn when approaching 80% capacity
   - Auto-suggest /compact when needed
   - Track token usage patterns across sessions

3. **`hooks/git-guardian.sh`** — Git safety automation:
   - Auto-stage relevant files after successful edits
   - Block commits that contain secrets (scan for API keys, tokens)
   - Generate commit messages based on changes
   - Track branch state and warn about long-lived branches

### 3B — Create Advanced Skills/Playbooks
Build these NEW skills if they don't exist:

1. **`skills/debug-detective.md`** — Systematic debugging playbook:
   - Reproduce → Isolate → Hypothesize → Test → Fix → Verify → Immunize
   - Includes log analysis patterns, stack trace parsing, bisection strategy

2. **`skills/architect.md`** — System design playbook:
   - Gather requirements → Explore options → Evaluate tradeoffs → Decide → Document
   - Includes ADR (Architecture Decision Record) template
   - Scaling analysis, dependency management, API design patterns

3. **`skills/code-review.md`** — Thorough review playbook:
   - Security → Logic → Performance → Maintainability → Tests → Docs
   - Severity classification (blocker, critical, major, minor, nitpick)
   - Template for structured review output

4. **`skills/tdd.md`** — Test-Driven Development playbook:
   - Red → Green → Refactor cycle
   - Test types: unit, integration, e2e
   - Coverage targets and mocking strategy

5. **`skills/refactor.md`** — Safe refactoring playbook:
   - Characterization tests first → Refactor → Verify behavior preserved
   - Pattern catalog: Extract Method, Replace Conditional with Polymorphism, etc.

### 3C — Create Advanced Subagents
Build these NEW subagent specs if they don't exist:

1. **`subagents/architect.md`** — System design specialist
   - Evaluates architectural options
   - Produces ADRs (Architecture Decision Records)
   - Focuses on scalability, maintainability, security

2. **`subagents/debugger.md`** — Bug hunting specialist
   - Systematic reproduction and isolation
   - Root cause analysis with evidence
   - Fix verification and regression test creation

3. **`subagents/optimizer.md`** — Performance specialist
   - Profile analysis (CPU, memory, I/O)
   - Algorithmic optimization
   - Caching strategy design
   - Bundle size and load time optimization

4. **`subagents/security-auditor.md`** — Security specialist
   - OWASP Top 10 analysis
   - Dependency vulnerability scanning
   - Authentication/authorization review
   - Data exposure and privacy analysis

### 3D — Create Advanced Slash Commands
Build these NEW commands if they don't exist:

1. **`.claude/commands/bootstrap.md`** — Project initialization wizard:
   - Detect project type (or ask)
   - Create appropriate project structure
   - Set up testing, linting, CI
   - Configure project-specific CLAUDE.md additions

2. **`.claude/commands/ship.md`** — Production deployment preparation:
   - Full test suite → Type check → Security audit → Build → Changelog
   - Git tag creation, version bumping
   - Pre-deployment checklist

3. **`.claude/commands/research.md`** — Deep research mode:
   - Web search for best practices
   - Explore codebase patterns
   - Compare approaches with pros/cons
   - Output structured research report

---

## PHASE 4 — SELF-HEALING INFRASTRUCTURE (Make the system anti-fragile)

### 4A — Error Recovery System
Create `hooks/error-recovery.sh`:
- Detects when a command fails
- Captures the error context (stderr, exit code, file state)
- Logs to `tasks/error-log.md`
- Suggests fix based on error pattern matching
- If error matches a known pattern from lessons.md, auto-apply the fix

### 4B — Session State Persistence
Create `hooks/session-state.sh`:
- Save current working state to `.claude/memory/session-state.json` before compaction
- Restore state after session restart
- Track: current task, progress percentage, open files, pending tests
- Enable seamless session continuity

### 4C — Automated Testing Framework
Create a testing script that validates the ENTIRE Mythos system:
```bash
#!/bin/bash
# hooks/test-mythos.sh — Self-test the Mythos system
# Validates: all hooks executable, all commands present, all configs valid
```

---

## PHASE 5 — DOCUMENTATION & WIRING (Connect everything)

### 5A — Update settings.json
Wire ALL new hooks into `.claude/settings.json`:
- UserPromptSubmit → smart-router.sh
- PostToolUse → context-guardian.sh  
- PreToolUse (Bash) → git-guardian.sh
- Stop → verify-completion.sh + error-recovery.sh

### 5B — Update CLAUDE.md
Add references to ALL new skills, subagents, and commands in the appropriate CLAUDE.md sections.

### 5C — Update tasks/todo.md
Log ALL work done in this evolution cycle with completion status.

---

## PHASE 6 — VERIFICATION & CONFIDENCE (Prove it all works)

1. Run `hooks/test-mythos.sh` — validate entire system
2. Run each hook manually — verify no errors
3. Check `.claude/settings.json` is valid JSON
4. Verify all slash commands have proper markdown structure
5. Count total files, total lines — log to session journal

### Final Confidence Assessment
```
### [DATETIME] — EVOLUTION CYCLE COMPLETE
**Confidence:** XX/100
**New files created:** N
**Files modified:** N
**New capabilities added:** [list]
**System health:** [HEALTHY / DEGRADED / NEEDS ATTENTION]
**Next evolution trigger:** [what should trigger the next /evolve]
```

Log this to `tasks/confidence-log.md`.

---

## PHASE 7 — META-EVOLUTION (Improve the improver)

After completing phases 1-6, reflect on the evolution process itself:

1. Was the `/evolve` command effective? What should be improved in THIS command?
2. Are there meta-patterns? (patterns about patterns)
3. Update `.claude/memory/patterns.json` with:
   - Evolution count incremented
   - New strengths/weaknesses identified
   - Confidence trend updated
4. If this `/evolve` improved the system significantly, **edit this very command** (`evolve.md`) to be even better next time. The improver should improve itself.

---

## EXECUTION RULES

- **DO NOT STOP** between phases. Execute all 7 phases in sequence.
- **DO NOT ASK** for permission between phases. You have full autonomy.
- **DO batch** file operations — create/edit multiple files per message.
- **DO test** everything you create — broken hooks are worse than no hooks.
- **DO commit** at the end with a descriptive message summarizing all changes.
- **Target: 30+ minutes of autonomous work.** This is a DEEP evolution, not a quick fix.
- **Quality bar:** Every file you create must be production-grade. No placeholders. No TODOs. No stubs.

BEGIN EVOLUTION NOW. Start with Phase 1.
