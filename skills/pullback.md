---
name: pullback
description: Trend continuation entry — buying dips in established uptrends. Use when price retraces to support in a confirmed trend.
triggers: [pullback, dip, retracement, trend continuation, support bounce, buy the dip]
---
# 📈 Pullback — Trend Continuation Entry

**INSTRUCTIONS STRICTES : Exécute TOUTES les phases sans interruption.
Ne demande JAMAIS à l'utilisateur "comment procéder". Langue : FRANÇAIS.**

## Phase 1 — Confirmation du Trend
1. Vérifier la tendance primaire (EMA 50 > EMA 200, ou prix > EMA 50)
2. Identifier au moins 2 Higher Highs + 2 Higher Lows
3. Confirmer la force du trend (ADX > 25 si disponible)
4. Vérifier l'alignement multi-timeframe (weekly + daily)

### Critères de Qualification
| Critère | Requis | Poids |
|---------|--------|-------|
| Trend confirmé (HH/HL) | ✅ Obligatoire | — |
| Prix > EMA 50 daily | ✅ Obligatoire | — |
| Pullback vers zone de support | ✅ Obligatoire | — |
| Volume en baisse pendant le pullback | ⚠️ Recommandé | 20pts |
| RSI 40-60 (zone neutre) | ⚠️ Recommandé | 15pts |
| Fibonacci 38.2-61.8% retracement | ⚠️ Recommandé | 20pts |

## Phase 2 — Identification de la Zone d'Entrée
1. Tracer les niveaux Fibonacci du dernier swing (38.2%, 50%, 61.8%)
2. Identifier les supports horizontaux (anciens résistances, pivots)
3. Repérer les moyennes mobiles dynamiques (EMA 21, EMA 50)
4. Chercher la confluence de niveaux (Fib + horizontal + EMA = zone forte)

## Phase 3 — Signal d'Entrée
Attendre un signal de retournement dans la zone :
1. **Bullish engulfing** sur le support
2. **Hammer / morning star** sur le support
3. **RSI divergence haussière** (prix fait LL, RSI fait HL)
4. **Volume spike** au rebond (acheteurs reviennent)

## Phase 4 — Plan d'Exécution
1. **Entry**: signal de retournement confirmé dans la zone Fib 38.2-61.8%
2. **Stop-Loss**: sous le dernier swing low OU sous Fib 78.6%
3. **TP1**: re-test du dernier high (swing high précédent)
4. **TP2**: extension 127.2% du mouvement
5. **TP3**: extension 161.8% du mouvement

## Phase 5 — Risk Management
- Position sizing: max 3-5% du capital
- Invalider si prix casse sous EMA 50 daily (trend compromis)
- Trailing stop après TP1 (suivre EMA 21 ou canal)
- Ne JAMAIS acheter un pullback sans signal de retournement

## Output Template
```
═══════════════════════════════════════════
  PULLBACK ANALYSIS — [TICKER]
═══════════════════════════════════════════

📊 Trend Status: [STRONG / MODERATE / WEAKENING]
📐 Retracement Depth: XX.X% (Fib level)
🔍 Support Confluence: [EMA XX + Fib XX% + Horizontal $XXX]

📊 Reversal Signal: [Engulfing / Hammer / RSI Div / None yet]

🟢 ENTRY: $XXX (at confluence zone)
🔴 STOP-LOSS: $XXX (-X.X%) — below Fib 78.6%

🎯 TARGETS:
  TP1: $XXX (+X.X%) — previous high retest
  TP2: $XXX (+X.X%) — 127.2% extension
  TP3: $XXX (+X.X%) — 161.8% extension

⚖️ Risk/Reward: X.X:1
📊 Conviction: [HIGH / MEDIUM / LOW]
🔄 Status: [WAITING for signal / ACTIVE / INVALIDATED]
═══════════════════════════════════════════
```
