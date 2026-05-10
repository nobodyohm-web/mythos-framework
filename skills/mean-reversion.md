---
name: mean-reversion
description: Fade extremes and reversal logic — counter-trend entries when price deviates significantly from equilibrium. Use for oversold bounces and overbought fades.
triggers: [mean reversion, fade, reversal, oversold, overbought, RSI extreme, Bollinger squeeze, deviation]
---
# 🔄 Mean Reversion — Fade & Reversal Logic

**INSTRUCTIONS STRICTES : Exécute TOUTES les phases sans interruption.
Ne demande JAMAIS à l'utilisateur "comment procéder". Langue : FRANÇAIS.**

## Phase 1 — Détection de l'Extrême
1. Identifier la déviation par rapport à la moyenne (Bollinger Bands, Keltner, Z-score)
2. Vérifier les conditions d'oversold/overbought:
   - RSI < 30 (oversold) ou RSI > 70 (overbought)
   - Prix hors Bollinger Band (2σ ou 3σ)
   - Z-score > 2.0 ou < -2.0 par rapport à la moyenne 20j
3. Confirmer l'absence de tendance directionnelle forte (ADX < 25 idéal)
4. Vérifier que ce n'est PAS un breakout légitime (volume + trend alignment)

### Critères de Qualification
| Critère | Requis | Poids |
|---------|--------|-------|
| RSI extrême (<30 ou >70) | ✅ Obligatoire | — |
| Prix hors Bollinger 2σ | ✅ Obligatoire | — |
| Pas de tendance forte (ADX<25) | ⚠️ Recommandé | 20pts |
| Volume en baisse à l'extrême | ⚠️ Recommandé | 15pts |
| Divergence RSI/MACD | ⚠️ Recommandé | 25pts |
| Support/résistance historique proche | ⚠️ Recommandé | 15pts |

> ⚠️ **ATTENTION** : Le mean reversion est la stratégie la PLUS dangereuse.
> Un extrême peut devenir encore plus extrême. Ne JAMAIS fade un trend fort.

## Phase 2 — Confirmation de Retournement
**NE PAS entrer sur l'extrême seul.** Attendre au moins 1 signal de confirmation :
1. **Bougie de retournement** (hammer, engulfing, doji star)
2. **RSI divergence** confirmée (prix fait nouveau extrême, RSI ne confirme pas)
3. **Retour dans les Bollinger Bands** (première clôture inside)
4. **Volume de capitulation** suivi de volume décroissant

## Phase 3 — Calcul de la Zone de Retour
1. Identifier la "juste valeur" (fair value) = EMA 20 ou VWAP
2. Calculer les niveaux de retour partiels :
   - Retour 50% vers la moyenne = TP1
   - Retour 100% vers la moyenne = TP2
   - Overshooting de l'autre côté = TP3 (optionnel, rare)
3. Placer le stop sous/au-dessus de l'extrême récent

## Phase 4 — Plan d'Exécution

### Long (Oversold Bounce)
1. **Entry**: première clôture inside Bollinger + signal de retournement
2. **Stop-Loss**: sous le plus bas récent (-1 ATR de marge)
3. **TP1**: milieu des Bandes (EMA 20)
4. **TP2**: bande opposée

### Short (Overbought Fade)
1. **Entry**: première clôture inside Bollinger + signal de retournement
2. **Stop-Loss**: au-dessus du plus haut récent (+1 ATR de marge)
3. **TP1**: milieu des Bandes (EMA 20)
4. **TP2**: bande opposée

## Phase 5 — Risk Management STRICT
- Position sizing: max **2%** du capital (plus risqué que trend-following)
- **JAMAIS** de moyenne à la baisse / dollar-cost averaging sur un MR trade
- Couper IMMÉDIATEMENT si le prix fait un nouveau extrême au-delà du stop
- Timeframe: ces trades sont SHORT-TERM (1-5 jours typiquement)
- Ratio minimum: 2:1 R/R ou skip le trade

## Output Template
```
═══════════════════════════════════════════
  MEAN REVERSION ANALYSIS — [TICKER]
═══════════════════════════════════════════

📊 Direction: [LONG (oversold bounce) / SHORT (overbought fade)]
📐 Deviation: [Z-score: X.X | RSI: XX | Bollinger: Xσ]
🔍 Fair Value (Mean): $XXX (EMA 20 / VWAP)

📊 Reversal Signal: [Engulfing / Hammer / RSI Div / None yet]
⚠️ Trend Strength (ADX): XX — [RANGE-BOUND ✅ / TRENDING ❌]

🟢 ENTRY: $XXX (first close inside bands + signal)
🔴 STOP-LOSS: $XXX (-X.X%) — beyond the extreme

🎯 TARGETS:
  TP1: $XXX (+X.X%) — 50% return to mean
  TP2: $XXX (+X.X%) — 100% return to mean (EMA 20)

⚖️ Risk/Reward: X.X:1
📊 Conviction: [HIGH / MEDIUM / LOW]
⏰ Expected Duration: X-X days
⚠️ Danger Level: [MODERATE / HIGH / EXTREME]
═══════════════════════════════════════════
```
