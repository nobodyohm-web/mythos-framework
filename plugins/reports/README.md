# Reports — L5 Distribution Layer

## Purpose
Generate structured daily summaries, trade journals, and performance reviews.

## Report Types

### Daily Summary
- Market conditions recap
- Trades executed (entries, exits, P&L)
- Open positions status
- Key news and catalysts for tomorrow
- Lessons learned today

### Trade Journal
- Chronological log of all trades
- Entry/exit prices, position sizes, R-multiples
- Setup type (breakout, pullback, mean-reversion)
- Emotional state notes (optional)
- Screenshot/chart references

### Performance Review (Weekly/Monthly)
- Win rate, profit factor, average R-multiple
- Best and worst trades analysis
- Strategy-specific performance (which playbook works best?)
- Risk management compliance
- Goal tracking and adjustments

## Report Format
All reports are generated as Markdown files in this directory:
```
reports/
├── daily/
│   ├── 2026-05-10.md
│   └── ...
├── journals/
│   ├── trade-log.md
│   └── ...
└── reviews/
    ├── week-19-2026.md
    └── ...
```

## Output Template — Daily Summary
```markdown
# 📊 Daily Summary — [DATE]

## Market Conditions
- [bull/bear/range] | VIX: XX | S&P: $X,XXX (±X.X%)

## Trades Today
| # | Ticker | Type | Entry | Exit | P&L | R-Multiple |
|---|--------|------|-------|------|-----|-----------|
| 1 | XXX    | BRK  | $XX   | $XX  | +$X | +X.XR     |

## Open Positions
| Ticker | Entry | Current | Stop | Target | Unrealized |
|--------|-------|---------|------|--------|-----------|

## Tomorrow's Watch
- [ ] [catalyst/event 1]
- [ ] [catalyst/event 2]

## Lessons
- [anything learned today]
```
