---
name: turnip-prophet
description: Predict Animal Crossing New Horizons turnip prices using the game's exact algorithm. Use when a user asks about turnip prices, ACNH turnips, stalk market, turnip predictions, when to sell turnips, or bell profit from turnips.
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
