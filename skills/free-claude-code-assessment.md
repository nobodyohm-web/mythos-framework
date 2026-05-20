# Free Claude Code — Honest Assessment

> Load this skill when the user asks about "free claude code", free alternatives to Claude, NVIDIA NIM routing, OAuth proxies, or multi-agent fleets backed by cheap providers. Tier every claim. Do not flatter the projects.

## Bottom line

**"Free Claude Code" is a misnomer.** None of these projects give you free access to real Anthropic Claude models. They are all **routing proxies** that translate Claude Code's wire protocol into calls to other (sometimes free-tier) providers. The "free" depends entirely on whether the target provider has a free tier.

## Per-project tiers

| Project | Stars | License | Verdict | Tier |
|---|---|---|---|---|
| [`musistudio/claude-code-router`](https://github.com/musistudio/claude-code-router) | 26.4k | MIT | **The upstream.** Routes to OpenRouter, DeepSeek, Ollama, Gemini, SiliconFlow, Volcengine, Groq, ModelScope, DashScope, AIHubMix. Active. This is what Mythos integrates with. | **[E]** |
| [`Alishahryar1/free-claude-code`](https://github.com/Alishahryar1/free-claude-code) | 26.9k | MIT | Routing proxy to 10 providers (NVIDIA NIM, Kimi, Wafer, OpenRouter, DeepSeek, LM Studio, llama.cpp, Ollama, OpenCode Zen, Z.ai). Local Admin UI for key entry. README has zero rate-limit / reliability disclaimers — handle with care. Not "free Claude" — relabeled free-tier routing. | **[E]** misnamed, **[C]** quality |
| [`Rishurajgautam24/free-claude-code`](https://github.com/Rishurajgautam24/free-claude-code) | 230 | MIT | Lighter proxy: NIM (40 req/min free) + OpenRouter + LM Studio. Includes rolling-window throttle, 429 backoff, max 5 concurrent streams. Better-engineered than the larger 26.9k fork on rate-limit handling. | **[E]** |
| [`Andrewkeith83/free-claude-code`](https://github.com/Andrewkeith83/free-claude-code) | 83 | MIT | NIM-only proxy + bundled **Telegram bot for remote control**. Bot is a meaningful supply-chain risk vector — review before trusting. | **[E]** project shape, **[S]** trust |
| [`decolua/9router`](https://github.com/decolua/9router) | — | — | Claims "40+ providers, unlimited free, RTK -40% tokens". Strong marketing claims, low independent verification. Not integrated by Mythos. | **[C]** unverified |
| [`AmazingAng/auth2api`](https://github.com/AmazingAng/auth2api) | 457 | MIT | **OAuth-to-API proxy.** You log into YOUR Claude/ChatGPT account via browser, the proxy stores refresh tokens locally, exposes them as OpenAI-compatible endpoints. README explicitly warns OpenAI ToS doesn't permit relaying sessions. Use only for **your own** account, at **your own** risk. NOT a free-claude trick — it's a personal-access wrapper. | **[E]** function, **[D]** TOS grey |

## Are they "free"?

| Provider | Free tier reality |
|---|---|
| NVIDIA NIM | 1,000 inference credits on signup, up to 5,000 total, **40 req/min**. Devs on NVIDIA forum report exhausting it in 2-3 min during agentic workflows. **[E]** |
| Z.ai (GLM-4.7) | Free tier exists for some models on z.ai. Use is rate-limited and TOS-bound. **[C]** |
| OpenRouter | Has a few free models (`google/gemini-flash-1.5-8b:free`, etc.) — most require credits. **[E]** |
| DeepSeek | Cheap, **not free** (sub-cent per task). **[E]** |
| Ollama / LM Studio / llama.cpp | Truly free — runs locally on your hardware. No remote cost. Quality depends on model & GPU. **[E]** |
| Groq | Free tier with strict daily limits. **[E]** |

So "free" is real for **local** (Ollama) and **rate-limited cloud** (NIM, Groq, OpenRouter free models). Heavy agentic workloads hit the ceiling fast.

## Are they functional?

For **routing protocol**: yes. The wire-level translation works.
For **code quality**: **no, not as Claude**. Non-Anthropic models on the free tier (open-source 7B–70B) produce visibly worse code on:
- Architectural reasoning (multi-file design)
- Subtle bug localization
- Long-horizon planning
- Security audits

They're acceptable for:
- Boilerplate (docstrings, getters/setters, format conversions)
- One-shot file refactors
- Translation / summarization tasks
- Test scaffolding

**[D]** This is well-documented in the 2026 SWE-bench and HumanEval-Plus comparisons.

## Safety warnings

1. **OAuth proxies** (`auth2api` and forks that look similar): they hold your auth credentials in plaintext at `~/.auth2api/` or equivalent. If the proxy is malicious or compromised, the attacker gets your Claude session. **Audit before running.**
2. **Telegram-controlled proxies** (`Andrewkeith83/free-claude-code`): the bot is an external attack surface. Don't use.
3. **Local Admin UI** (`Alishahryar1/free-claude-code`): defaults to `127.0.0.1` but ensure it's not exposed on a LAN interface.
4. **Anthropic TOS:** routing Claude Code's traffic to non-Anthropic providers does NOT violate Anthropic's TOS — you're not using Anthropic. Routing your *own Anthropic auth* through a 3rd-party proxy (`auth2api` pattern) IS in TOS-grey territory.

## When this matters for Mythos

Use the cheap/free providers as **workers** for parallel grunt-work via `bin/mythos-fleet` and `bin/mythos-route`. Keep the **orchestrator** (main Claude Code session) on first-party Anthropic for reasoning, judgment, and integration. This is the only setup that preserves quality while cutting cost.

## Cross-references
- [[multi-provider-routing]] — how to set up the proxy that fleet workers use.
- [[parallel-execution]] — when fan-out is appropriate.
- [[terse-mode]] — combine with cheap workers for max savings.
