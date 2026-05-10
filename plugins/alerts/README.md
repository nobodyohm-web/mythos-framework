# Alerts — L5 Distribution Layer

## Purpose
Real-time notification system for price alerts, risk triggers, and system events.

## Alert Types

### Price Alerts
- Breakout detection (price crosses key resistance)
- Pullback entry zone reached
- Stop-loss proximity warning
- Target price reached (TP1, TP2, TP3)

### Risk Alerts
- Portfolio exposure exceeding limits
- Correlation spike between positions
- Drawdown threshold approaching
- VIX spike (fear index > threshold)

### System Alerts
- Typecheck failure after edit
- Test suite failure
- API key expiration warning
- Session timeout approaching

## Implementation Notes
This directory will contain alert configuration and scripts as the system evolves.
Alert delivery channels can include: terminal output, macOS notifications, webhooks.

## Configuration Template
```json
{
  "alerts": {
    "price": {
      "enabled": true,
      "channels": ["terminal", "notification"]
    },
    "risk": {
      "enabled": true,
      "channels": ["terminal", "notification"],
      "drawdownThreshold": 5.0
    },
    "system": {
      "enabled": true,
      "channels": ["terminal"]
    }
  }
}
```
