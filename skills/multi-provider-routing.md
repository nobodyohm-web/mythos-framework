# Multi-Provider Routing — Free / Alternative AI Backends

> Run Claude Code against any compatible backend (OpenRouter, DeepSeek, Ollama, Gemini, SiliconFlow, …) via the `claude-code-router` proxy. Mythos integrates as a thin status/helper layer; **never** flips routing silently.

## Why
- **Cost** — DeepSeek and SiliconFlow run order-of-magnitude cheaper than Anthropic API for heavy refactor sessions.
- **Local** — Ollama lets you run offline / air-gapped against models like Qwen-Coder-32B or Llama-3.3-70B.
- **Failover** — Keep working when the Anthropic API is rate-limited.
- **Mixed routing** — Cheap models for boilerplate, premium for reviews.

## Upstream

[`musistudio/claude-code-router`](https://github.com/musistudio/claude-code-router) — MIT, 26k★. Proxy that exposes Anthropic's wire protocol and translates to any backend.

## Install

```bash
npm install -g @anthropic-ai/claude-code
npm install -g @musistudio/claude-code-router
```

Mythos provides `bin/mythos-route install` as a guided wrapper (it does **not** install for you — it tells you what to run and verifies).

## Configure

Edit `~/.claude-code-router/config.json`:

```json
{
  "Providers": [
    {
      "name": "openrouter",
      "api_base_url": "https://openrouter.ai/api/v1/chat/completions",
      "api_key": "sk-or-v1-...",
      "models": ["anthropic/claude-3.5-sonnet", "deepseek/deepseek-chat"]
    },
    {
      "name": "ollama",
      "api_base_url": "http://localhost:11434/v1/chat/completions",
      "api_key": "ollama",
      "models": ["qwen2.5-coder:32b"]
    }
  ],
  "Router": {
    "default":     "openrouter,anthropic/claude-3.5-sonnet",
    "background":  "ollama,qwen2.5-coder:32b",
    "think":       "openrouter,anthropic/claude-3.5-sonnet",
    "longContext": "openrouter,google/gemini-2.0-flash"
  }
}
```

The Router intent-keys are upstream's. `background` = boilerplate, `think` = reasoning, `longContext` = >32k tokens.

## Activate

```bash
ccr start                       # starts the proxy on 127.0.0.1:3456
eval "$(ccr activate)"          # sets ANTHROPIC_BASE_URL in current shell
claude                          # Claude Code now routes through the proxy
```

Deactivate with `unset ANTHROPIC_BASE_URL` or open a new shell.

## Mythos integration

```bash
bin/mythos-route status      # detect ccr binary, current ANTHROPIC_BASE_URL, default provider
bin/mythos-route providers   # list provider names from ~/.claude-code-router/config.json
bin/mythos-route install     # print install instructions, do NOT execute
bin/mythos-route enable      # print the activation line — user pastes it
bin/mythos-route disable     # print the deactivation line
```

`mythos-route` is **read-only and additive** — it never `eval`s into your shell, never modifies `~/.zshrc`, never installs npm packages. You stay in control.

## Trust & safety

- **Your API keys are sent to the provider you configure.** Verify `api_base_url` is the real endpoint before pasting a key.
- **Local Ollama** is the safest privacy posture — no key leaves your machine.
- **OAuth-based proxies** (some 3rd-party "free Claude" projects) re-use your Anthropic OAuth token — read their source before trusting.
- Mythos hooks (`prompt-injection-guard`, `hallucination-guard`) work identically through the proxy — they operate on tool I/O, not the model endpoint.

## When NOT to route

- Production deployments — stay on first-party Anthropic API for SLA + safety guarantees.
- Anything involving customer data — most third-party proxies log requests.
- Security audits — keep `security-auditor` subagent on Anthropic for OWASP/CVE recall accuracy.

## Cross-references
- [[terse-mode]] — combine with cheaper routing for max savings
- [[parallel-execution]] — fan out cheap-model subagents on `[P]` tasks; keep judges on premium
