---
name: turnip-prophet
description: Predict Animal Crossing New Horizons turnip prices using the game's exact algorithm. Use when a user asks about turnip prices, ACNH turnips, stalk market, turnip predictions, when to sell turnips, or bell profit from turnips.
repository: https://github.com/nicholasjackson/openclaw-turnip-profit
metadata:
  {
    "openclaw":
      {
        "requires": { "bins": ["python3", "gnuplot", "jq"] },
        "install":
          [
            {
              "id": "deps-debian",
              "kind": "shell",
              "label": "Install dependencies (Debian/Ubuntu)",
              "command": "sudo apt-get update && sudo apt-get install -y python3 gnuplot jq",
              "when": "debian"
            },
            {
              "id": "deps-macos",
              "kind": "shell",
              "label": "Install dependencies (macOS)",
              "command": "brew install gnuplot jq",
              "when": "darwin"
            }
          ]
      }
  }
---

# Turnip Prophet - Animal Crossing Turnip Price Predictor

Predicts Animal Crossing: New Horizons turnip prices using the game's actual algorithm.

## ⚠️ IMPORTANT: Always Read Memory First!

**Before doing ANYTHING**, read the weekly data file:
```
memory/turnip-week.json
```
This contains the buy price, previous pattern, and all known prices for the current week. **Do not ask the user for data you already have.** Only ask for new/missing prices.

When the user gives a new price, **update `memory/turnip-week.json` immediately** with the new value before running the prediction.

### Weekly Data Format (`memory/turnip-week.json`)
```json
{
  "week_start": "2026-02-15",
  "buy_price": 96,
  "previous_pattern": 1,
  "prices": [84, 81, 78, null, null, null, null, null, null, null, null, null],
  "labels": ["Mon AM", "Mon PM", "Tue AM", "Tue PM", "Wed AM", "Wed PM", "Thu AM", "Thu PM", "Fri AM", "Fri PM", "Sat AM", "Sat PM"]
}
```

On Sundays, create a fresh file with the new buy price and reset prices to all nulls.

## Triggers

Activate when user mentions:
- "turnip prices" or "turnip price"
- "ACNH turnips" or "Animal Crossing turnips"
- "stalk market"
- "turnip prophet" or "turnip prediction"
- "bell profit" with context of turnips
- Any question about when to sell turnips in Animal Crossing

## Cron Setup (Optional but Recommended)

### Auto-detect on first use
When triggered for the first time (or when `memory/turnip-week.json` doesn't exist), check if cron reminders are configured:

```bash
crontab -l 2>/dev/null | grep -q "turnip-prophet"
```

If NOT configured, send a message:
> "Want me to set up daily turnip price reminders? I can ping you:
> - Sunday 8am: Check Daisy Mae's price
> - Mon-Sat noon + 8pm: Check Nook's Cranny prices
> - Saturday 9:45pm: Last chance warning
> 
> I'll show you the exact cron entries before adding them. See the skill README for manual setup."

**Do NOT auto-modify crontab.** Instead, show the user the exact cron entries that would be added and ask them to review and confirm before proceeding.

### Manual Setup

**Requirements:**
1. Set `TURNIP_TELEGRAM_TARGET` environment variable to your Telegram user ID
2. Optionally set `OPENCLAW_BIN` if `openclaw` is not in your PATH

**Example cron entries:**

```bash
# Turnip Prophet - Sunday morning reminder (8 AM local time)
0 8 * * 0 TURNIP_TELEGRAM_TARGET=YOUR_TELEGRAM_ID $(which openclaw) gateway call --skill turnip-prophet --handler cron --params '{"event":"sunday-daisy"}' 2>&1 | logger -t openclaw-cron

# Turnip Prophet - Daily price check reminders (Mon-Sat, noon + 8 PM local time)
0 12 * * 1-6 TURNIP_TELEGRAM_TARGET=YOUR_TELEGRAM_ID $(which openclaw) gateway call --skill turnip-prophet --handler cron --params '{"event":"daily-check"}' 2>&1 | logger -t openclaw-cron
0 20 * * 1-6 TURNIP_TELEGRAM_TARGET=YOUR_TELEGRAM_ID $(which openclaw) gateway call --skill turnip-prophet --handler cron --params '{"event":"daily-check"}' 2>&1 | logger -t openclaw-cron

# Turnip Prophet - Saturday final warning (9:45 PM local time)
45 21 * * 6 TURNIP_TELEGRAM_TARGET=YOUR_TELEGRAM_ID $(which openclaw) gateway call --skill turnip-prophet --handler cron --params '{"event":"saturday-final"}' 2>&1 | logger -t openclaw-cron
```

**To install (replace YOUR_TELEGRAM_ID):**
```bash
# First, get your Telegram user ID from OpenClaw logs or ask your agent
# Then review these commands before running:

cat > /tmp/turnip-cron.txt <<'EOF'
# Turnip Prophet reminders
0 8 * * 0 TURNIP_TELEGRAM_TARGET=YOUR_TELEGRAM_ID $(which openclaw) gateway call --skill turnip-prophet --handler cron --params '{"event":"sunday-daisy"}' 2>&1 | logger -t openclaw-cron
0 12 * * 1-6 TURNIP_TELEGRAM_TARGET=YOUR_TELEGRAM_ID $(which openclaw) gateway call --skill turnip-prophet --handler cron --params '{"event":"daily-check"}' 2>&1 | logger -t openclaw-cron
0 20 * * 1-6 TURNIP_TELEGRAM_TARGET=YOUR_TELEGRAM_ID $(which openclaw) gateway call --skill turnip-prophet --handler cron --params '{"event":"daily-check"}' 2>&1 | logger -t openclaw-cron
45 21 * * 6 TURNIP_TELEGRAM_TARGET=YOUR_TELEGRAM_ID $(which openclaw) gateway call --skill turnip-prophet --handler cron --params '{"event":"saturday-final"}' 2>&1 | logger -t openclaw-cron
EOF

# Review the file, then install:
cat /tmp/turnip-cron.txt
(crontab -l 2>/dev/null; cat /tmp/turnip-cron.txt) | crontab -
```

### Cron Handler Logic

When `--handler cron` is called with an event:

**sunday-daisy:**
- Check if `memory/turnip-week.json` has a buy_price for the current week
- If missing: Send Telegram reminder "🔔 Sunday! Check Daisy Mae's turnip price (90-110 bells) and buy your turnips 🥬"
- If already set: Stay silent (user already reported it)

**daily-check:**
- Read `memory/turnip-week.json`
- Determine which price slot is missing (Mon AM/PM through Sat AM/PM)
- Send reminder: "🔔 Time to check Nook's Cranny turnip prices! Currently missing: [list slots]"
- If all prices already known for today: Stay silent

**saturday-final:**
- Read `memory/turnip-week.json`
- If any prices still unknown OR user hasn't sold: "⏰ FINAL CALL: Turnips expire at 10 PM! Sell now or they'll rot 🗑️"
- Include current prediction if data exists

After sending a reminder, DO NOT wait for a response in the cron handler — just send and exit.

## How It Works

The skill uses a Python implementation of the actual ACNH turnip price algorithm to predict future prices based on:
- Your Sunday buy price (90-110 bells)
- Any known sell prices from this week
- Previous week's pattern (if known)

There are 4 price patterns:
- **Pattern 0 (Fluctuating)**: High-low-high-low-high waves
- **Pattern 1 (Large Spike)**: Decreasing then massive spike (up to 6x)
- **Pattern 2 (Decreasing)**: Consistently declining (bad week)
- **Pattern 3 (Small Spike)**: Decreasing then moderate spike (up to 2x)

## Usage Instructions

When triggered:

1. **Read `memory/turnip-week.json`** — get all known data
2. **Update the file** if the user provided a new price
3. **Run the prediction** with all known data
4. **Generate a chart** and send it with the prediction summary

### Running the Prediction

```bash
echo '{"buy_price": 96, "prices": [84, 81, 78, null, null, null, null, null, null, null, null, null], "previous_pattern": 1}' | python3 scripts/turnip_predict.py
```

- `prices` array: [Mon AM, Mon PM, Tue AM, Tue PM, Wed AM, Wed PM, Thu AM, Thu PM, Fri AM, Fri PM, Sat AM, Sat PM]
- Use `null` for unknown prices

### Generating the Chart

After running the prediction, generate a chart image:

```bash
bash scripts/generate_chart.sh <buy_price> '<known_json>' '<mins_json>' '<maxs_json>' /tmp/turnip-chart.png
```

- `known_json`: array of 12 values, `null` for unknown (from `memory/turnip-week.json` prices)
- `mins_json`: array of 12 min values from the prediction output
- `maxs_json`: array of 12 max values from the prediction output
- All script paths are relative to the skill directory: `skills/turnip-prophet/`

Then send the chart image via the message tool with a caption containing the prediction summary.

**Always include the chart with every prediction update.**

## Presenting Results

Send the chart image via message tool, then reply with a conversational analysis. Don't be robotic — have a personality about it.

**Format:**
1. Chart image with brief caption (buy price, known prices)
2. Text reply with:
   - **Pattern odds** as a bullet list with emoji reactions (😬🤞🚀💀 etc.)
   - **Brief colour commentary** — what the data actually means in plain English
   - **"My take:"** — a specific, opinionated recommendation for what to do next (which price to check, when to sell, when to hold)

**Example:**
```
Pattern odds:
📉 Decreasing: 84.7% 😬
📈 Large Spike: 15.1% 🤞
📊 Small Spike: 0.1%

Not great. Three consecutive drops is strongly pointing to a decreasing week. But there's still a 15% chance of a large spike hiding — if it happens, it'd be Wed-Fri with prices up to 576 bells.

My take: Check the Tuesday PM price. If it drops again, this week is almost certainly a bust — sell and cut your losses. If it jumps up, the spike is on. 🎰
```

Be direct, be opinionated, skip patterns with 0% probability.

## Pattern Descriptions for Users

- **Fluctuating (0)**: Prices go up and down in waves — sell when above 120-130
- **Large Spike (1)**: Prices drop then SPIKE huge (400-600 bells) — wait for it!
- **Decreasing (2)**: Prices keep falling all week — sell ASAP to cut losses
- **Small Spike (3)**: Prices drop then small bump (150-200) — sell during the bump

## Error Handling

If the script fails or returns an error:
- Explain what went wrong in simple terms
- Ask user to double-check their input data
- Suggest they try again with corrected information

## Notes

- Predictions are probabilistic, not guaranteed
- The algorithm matches the actual game code
- More known prices = better predictions
- Sunday buy price is required
- Previous week's pattern helps but isn't required
