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
- matplotlib (for charts)
- jq (for cron reminders - optional)

### Installation

**Python dependencies:**
```bash
pip3 install matplotlib
```

**jq (optional, for cron reminders):**

Debian/Ubuntu (requires sudo):
```bash
sudo apt-get update && sudo apt-get install -y jq
```

macOS:
```bash
brew install jq
```

**Note:** System package installs (`apt-get`, `brew`) may require elevated privileges. Review commands before running.

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

On first use, your agent will offer to set up automatic reminders:
- **Sunday 8am**: Check Daisy Mae's price
- **Mon-Sat noon + 8pm**: Check Nook's Cranny prices
- **Saturday 9:45pm**: Final warning before turnips rot

**Interactive Setup:**

Just say "yes" when prompted and the agent will:
1. Auto-detect your messaging channel (Telegram/WhatsApp/Discord/Signal)
2. Auto-detect your user ID from the current conversation
3. Generate cron entries configured for your setup
4. Show you exactly what will be installed
5. Provide commands for you to review and confirm

**What gets installed:**
- A config file at `memory/turnip-config.json` with your channel/user ID
- Four cron entries that only send reminders for missing data
- No hard-coded values, no manual editing required

Adjust times for your timezone by editing the cron schedule after installation.

## Privacy & Data

All data is stored **locally on your machine only**. No external calls, no cloud sync.

**Config file** (`memory/turnip-config.json`):
- Stores: channel name + your user ID (only if you enable reminders)
- Purpose: Cron reminders need this to send you messages
- Storage: Skill's local memory directory
- Removal: Delete the file or disable reminders anytime

**Price history** (`memory/turnip-week.json`):
- Stores: Turnip prices you report each week
- Purpose: Used to predict future prices
- Resets: Automatically each Sunday

**How to opt out:**
```bash
# Disable reminders (removes config)
rm ~/.openclaw/workspace/skills/turnip-prophet/memory/turnip-config.json

# Clear price history
rm ~/.openclaw/workspace/skills/turnip-prophet/memory/turnip-week.json
```

No data leaves your machine. No tracking, no external APIs, no cloud storage.

## Credentials & Automated Messaging

**The skill does not request or store API keys.**

However, **if you enable cron reminders**, you're authorizing:
- Automated messages sent **as you**, using your OpenClaw identity
- Use of your existing OpenClaw credentials (bot tokens, API keys)
- Scheduled execution of `openclaw gateway call message.send`

**Requirements for cron reminders:**
- OpenClaw must be running
- Your messaging channel (Telegram/WhatsApp/etc.) must be configured
- Your credentials must be valid

If you don't want automated messaging using your credentials, skip the cron setup. The core prediction feature works independently and requires no credentials.

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
