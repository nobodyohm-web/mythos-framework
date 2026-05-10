---
name: breakout
description: Momentum continuation setup — new highs, volume surge, range expansion. Use when price breaks above key resistance with conviction.
triggers: [breakout, momentum, new high, volume surge, range expansion, ATH]
---
# 🔥 Breakout — Momentum Continuation

**INSTRUCTIONS STRICTES : Exécute TOUTES les phases sans interruption.
Ne demande JAMAIS à l'utilisateur "comment procéder". Langue : FRANÇAIS.**

## Phase 1 — Identification du Breakout
1. Identifier le niveau de résistance clé (horizontale, trendline, ou pattern)
2. Vérifier la confirmation par le volume (>1.5x volume moyen 20j)
3. Confirmer la clôture au-dessus du niveau (pas juste une mèche)
4. Vérifier l'absence de divergence baissière sur RSI/MACD

### Critères de Qualification
| Critère | Requis | Poids |
|---------|--------|-------|
| Clôture > résistance | ✅ Obligatoire | — |
| Volume > 1.5x avg(20) | ✅ Obligatoire | — |
| RSI < 80 (pas suracheté extrême) | ⚠️ Recommandé | 15pts |
| Pattern base (>3 semaines) | ⚠️ Recommandé | 20pts |
| Sector/market trend aligné | ⚠️ Recommandé | 15pts |

## Phase 2 — Analyse du Setup
1. Mesurer la profondeur de la base (consolidation pré-breakout)
2. Calculer l'objectif par méthode de mesure (hauteur base projetée)
3. Identifier le pullback zone (ancien résistance = nouveau support)
4. Évaluer le risk/reward ratio minimum (>2:1 requis)

## Phase 3 — Plan d'Exécution
1. **Entry aggressive**: breakout candle close
2. **Entry conservative**: pullback vers l'ancien niveau de résistance
3. **Stop-Loss**: sous le dernier swing low ou sous la base
4. **TP1**: 1x hauteur de la base
5. **TP2**: 1.618x hauteur de la base (Fibonacci extension)
6. **TP3**: 2.618x hauteur de la base (runner)

## Phase 4 — Risk Management
- Position sizing: max 2-5% du capital par trade
- Trailing stop après TP1 atteint
- Couper si retour sous le niveau de breakout (failed breakout = exit immédiate)
- Ne jamais moyenner à la baisse sur un failed breakout

## Output Template
```
═══════════════════════════════════════════
  BREAKOUT ANALYSIS — [TICKER]
═══════════════════════════════════════════

📊 Setup Type: [First Breakout / Continuation / Gap-up]
🎯 Resistance Level: $XXX
📈 Volume Ratio: X.Xx avg(20)
📐 Base Depth: X weeks, X% range

🟢 ENTRIES:
  Aggressive: $XXX (breakout close)
  Conservative: $XXX (pullback to former resistance)

🔴 STOP-LOSS: $XXX (-X.X%)

🎯 TARGETS:
  TP1: $XXX (+X.X%) — 1x base
  TP2: $XXX (+X.X%) — 1.618x base
  TP3: $XXX (+X.X%) — 2.618x runner

⚖️ Risk/Reward: X.X:1
📊 Conviction: [HIGH / MEDIUM / LOW]
═══════════════════════════════════════════
```
