# /assimilate — HOST ENVIRONMENT ADAPTATION

**WARNING: YOU HAVE BEEN INJECTED INTO A NEW REPOSITORY.**
Your primary objective is no longer to evolve the Mythos framework itself, but to become an absolute master of this specific **Host Environment** (e.g., a Trading system like Kairos, a Web App, a Compiler).

---

## 🧬 SYMBIOTIC ASSIMILATION LOOP

### PHASE 1: HOST DNA SCAN
Run bash commands to scan the entire repository.
- What are the main languages and frameworks? (Check `package.json`, `Cargo.toml`, `requirements.txt`, etc.)
- What is the architecture?
- **What is the ultimate purpose of this software?** 

### PHASE 1.5: LOCAL COMPUTE PROBE (Ollama)
Run `bin/mythos-ollama status` to detect whether the host has local compute available.

- **If Ollama is installed + endpoint reachable**: capture the model list (`bin/mythos-ollama models`) and add a "Local fleet available" line to the assimilation summary. Note which installed models meet the ≥64k context floor (use `bin/mythos-ollama recommend` for guidance). This enables free parallel grunt-work via `bin/mythos-fleet dispatch --ollama` for boilerplate, refactor passes, and summarization during Phase 5 metamorphosis.
- **If Ollama is missing**: add an install hint to the summary (`bin/mythos-ollama install` prints the commands — DO NOT auto-execute). The user decides whether installing local compute is worth it for this host.
- **If Ollama is installed but endpoint unreachable**: add a "start daemon: `ollama serve`" hint.

This phase is **strictly advisory** — it NEVER installs, NEVER pulls models, NEVER modifies the user's shell. It maps local-compute capability so the agent can plan with full awareness. See `skills/ollama-integration.md` for when Ollama workers are appropriate.

### PHASE 2: DOMAIN SOTA RESEARCH
Once you know what this software does (e.g., "High-frequency crypto trading bot in Python"), you must research how to make it the absolute best in the world.
Run `bin/mythos-research --fetch` for:
1. `"site:github.com state of the art [Host Domain] architecture"`
2. `"arXiv [Host Domain] advanced algorithms 2025 2026"`
3. `"best CLI tools and MCP servers for [Host Domain] development"`

### PHASE 3: CUSTOM SKILL GENERATION
Write a new skill file: `skills/host-domain.md`.
- Document exactly how you must behave to write code for this host.
- List the specific architectural patterns to enforce.
- Define what constitutes a "Critical Error" in this specific domain (e.g., for a trading bot: "Risk calculation error"; for a web app: "XSS vulnerability").

### PHASE 4: TOOL ACQUISITION
If your Phase 2 research discovered external CLIs, APIs, or MCP servers that would make developing this host easier:
1. Install them via `npm`, `pip`, `brew`, or `cargo`.
2. Configure them in `.claude/settings.json` if they are MCP servers.

### PHASE 5: THE METAMORPHOSIS
Run `/deepaudit` to find all the pre-existing flaws in the host repository using your newly acquired SOTA knowledge.
Write the results to `tasks/host-upgrade-plan.md`.

Output your final summary:
```
🦠 ASSIMILATION COMPLETE 🦠
- Host Identity: [What is this project?]
- SOTA Domain Knowledge Acquired: [List of patterns]
- New Tools Acquired: [List of MCPs/CLIs]
- Local Compute: [from Phase 1.5 — Ollama present/missing + models if any]
- The host is ready for evolution. Run the tasks in `host-upgrade-plan.md`.
```
