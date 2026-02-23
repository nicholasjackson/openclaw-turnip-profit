# 🔮 Turnip Prophet

Animal Crossing: New Horizons turnip price predictor using the game's actual algorithm.

An [OpenClaw](https://openclaw.ai) agent skill that predicts turnip prices and tells you when to sell for maximum bells 💰

[![ClawHub](https://img.shields.io/badge/ClawHub-turnip--prophet-blue)](https://clawhub.com/skills/turnip-prophet)
[![GitHub](https://img.shields.io/badge/GitHub-openclaw--turnip--profit-black)](https://github.com/nicholasjackson/openclaw-turnip-profit)

## What It Does

Predicts ACNH turnip prices based on:
- Your Sunday buy price (90-110 bells)
- Any known sell prices from this week
- Previous week's pattern (if known)

Returns probability distributions across all 4 price patterns:
- **Fluctuating**: Up-down waves
- **Large Spike**: Massive spike (400-600 bells)
- **Decreasing**: Falling all week
- **Small Spike**: Moderate bump (150-200)

## Features

- Uses the actual game algorithm (not guesswork)
- Generates visual chart of price ranges
- Opinionated recommendations (not just data dumps)
- Persistent weekly memory tracking
- More data = better predictions

## How It Works

Python implementation of the ACNH turnip price algorithm + chart generation via GNU Plot.

The skill maintains a `memory/turnip-week.json` file to track:
- Current week's buy price
- Known sell prices (12 slots: Mon-Sat AM/PM)
- Previous week's pattern

As you report new prices, predictions get more accurate.

## Requirements

- Python 3
- gnuplot (for charts)
- jq (for cron reminders - optional)

## Usage

For OpenClaw users: install via ClawHub

```bash
clawhub install turnip-prophet
```

Or manual installation:

```bash
git clone https://github.com/nicholasjackson/turnip-prophet.git ~/.openclaw/workspace/skills/turnip-prophet
```

Then just ask your agent about turnip prices:
- "What are my turnip predictions?"
- "Should I sell turnips today?"
- "Turnip forecast for this week"

### Daily Reminders (Optional)

The skill can send automatic reminders via Telegram:
- **Sunday 8am**: Check Daisy Mae's price
- **Mon-Sat noon + 8pm**: Check Nook's Cranny prices
- **Saturday 9:45pm**: Final warning before turnips rot

On first use, the agent will offer to set this up automatically. Or manually add to crontab:

```bash
(crontab -l 2>/dev/null; cat <<'EOF'
# Turnip Prophet reminders
0 8 * * 0 /usr/local/bin/openclaw gateway call --skill turnip-prophet --handler cron --params '{"event":"sunday-daisy"}' 2>&1 | logger -t openclaw-cron
0 12 * * 1-6 /usr/local/bin/openclaw gateway call --skill turnip-prophet --handler cron --params '{"event":"daily-check"}' 2>&1 | logger -t openclaw-cron
0 20 * * 1-6 /usr/local/bin/openclaw gateway call --skill turnip-prophet --handler cron --params '{"event":"daily-check"}' 2>&1 | logger -t openclaw-cron
45 21 * * 6 /usr/local/bin/openclaw gateway call --skill turnip-prophet --handler cron --params '{"event":"saturday-final"}' 2>&1 | logger -t openclaw-cron
EOF
) | crontab -
```

Adjust times for your timezone.

## Example

```
User: I bought turnips for 96 bells, Monday AM is 84
Agent: [generates chart showing price ranges]

Pattern odds:
📉 Decreasing: 45.2% 😬
📈 Large Spike: 32.1% 🤞
📊 Fluctuating: 22.7%

My take: One price drop doesn't tell us much yet. Check Monday PM — if it drops again, we're probably heading into a decreasing week. If it spikes, could be the start of a large spike pattern. 🎰
```

## Files

- `SKILL.md` - OpenClaw skill definition
- `scripts/turnip_predict.py` - Core prediction algorithm
- `scripts/generate_chart.sh` - Chart generation wrapper
- `memory/turnip-week.json` - Persistent weekly data (created on first use)

## Credits

Based on the reverse-engineered ACNH turnip price algorithm from the game's code.

## License

MIT
