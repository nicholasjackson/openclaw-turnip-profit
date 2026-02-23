#!/bin/bash
# Generate turnip price chart image
# Usage: generate_chart.sh <buy> <known_json> <mins_json> <maxs_json> <output_path>
BUY="$1"
KNOWN="$2"
MINS="$3"
MAXS="$4"
OUTPUT="${5:-/tmp/turnip-chart.png}"

CHART_HTML="/home/nicj/.openclaw/workspace/skills/turnip-prophet/scripts/chart.html"
KNOWN_ENC=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$KNOWN'))")
MINS_ENC=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$MINS'))")
MAXS_ENC=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$MAXS'))")

URL="file://${CHART_HTML}?buy=${BUY}&known=${KNOWN_ENC}&mins=${MINS_ENC}&maxs=${MAXS_ENC}"

NODE_PATH=$(npm root -g) node -e "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({
    executablePath: '/home/nicj/.cache/ms-playwright/chromium-1208/chrome-linux/chrome',
    args: ['--no-sandbox']
  });
  const page = await browser.newPage({ viewport: { width: 840, height: 440 } });
  await page.goto(process.argv[1]);
  await page.waitForFunction(() => window.__chartReady === true);
  await page.waitForTimeout(500);
  await page.locator('canvas').screenshot({ path: process.argv[2] });
  await browser.close();
  console.log('done: ' + process.argv[2]);
})();
" "$URL" "$OUTPUT"
