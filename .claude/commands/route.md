# /route — Multi-Provider Routing

Load `skills/multi-provider-routing.md` and report the current state to the user.

## Workflow

1. Run `bin/mythos-route status` and show the output.
2. If `ccr` is not installed → suggest `bin/mythos-route install`.
3. If `ccr` is installed but `ANTHROPIC_BASE_URL` is unset → suggest `bin/mythos-route enable` (and remind that the user must paste the resulting `eval` line themselves).
4. If `ANTHROPIC_BASE_URL` points at the router → list available providers via `bin/mythos-route providers`.

## Constraints

- Do NOT `eval` activation lines into the user's shell.
- Do NOT modify `~/.zshrc`, `~/.bashrc`, or any rc file.
- Do NOT install npm packages.
- Do NOT write API keys.

The user is always the one who flips the switch.
