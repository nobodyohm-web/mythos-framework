# Claude Mythos — Autonomous Agentic Base

This repository is an **extremely powerful, autonomous agentic base** designed for rigorous, hallucination-free problem solving. It transforms the Claude Code CLI into an autonomous system capable of executing complex multi-file engineering tasks at Staff Engineer standards, without suffering from cognitive drift or confirmation bias.

## Core Design Principles

Built upon an unyielding epistemic foundation:
```
SEEK → FIND → VERIFY → KEEP WHAT SURVIVES
```

1. **Separate Judge from Builder**: The agent that writes the code is never the agent that reviews it.
2. **Epistemic Rigor**: Every claim is tracked on a tier system (Established, Derived, Conjectured, Speculative).
3. **Compound Intelligence**: Continuous self-improvement loop via `/evolve` and `/benchmark`.
4. **Self-Healing Infrastructure**: Deterministic git and context hooks protect against catastrophic failures (e.g., secret commits, context exhaustion, force-pushes).

## 🚀 Getting Started

### 1. Installation
Simply clone this repository into a new folder where you want to start your project.
```bash
git clone <this-repo> my-new-project
cd my-new-project
```

### 2. Initialization
Run Claude Code and invoke the bootstrap command to scaffold your environment:
```bash
claude
> /bootstrap
```

## 🧠 System Architecture

- **`CLAUDE.md`**: The Root Brain. Defines the system identity, operating mode, and knowledge matrix.
- **`Risk.md`**: Core guardrails (Code, Epistemic, Operational) that apply unconditionally to every session.
- **`.claude/settings.json`**: The infrastructure wiring, handling MCP routing, and hook triggers.
- **`.claude/commands/`**: Slash commands that drive the execution engines (`/mythosrun`, `/critique`, `/team`, `/evolve`).
- **`.claude/agents/`**: The specialized subagent roster (`planner`, `implementer`, `reviewer`, etc.).
- **`skills/`**: The knowledge base dynamically loaded when relevant.
- **`hooks/`**: Deterministic shell scripts providing defense-in-depth at every stage of the execution lifecycle.

## ⚖️ The Epistemic Defense System

This base is uniquely optimized against "Agentic Drift" and hallucinations:
- **`/critique`**: Spawns an adversarial judge to break assumptions and look for epistemic drift.
- **Auto-validation**: Hooks block completion until type-checks and tests pass.
- **Evidence-Based**: Implements a strict falsification workflow. If it isn't verified by a test, it's Conjectured.

Enjoy your hallucination-free, continuously-improving engineering partner.
