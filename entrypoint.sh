#!/bin/sh
set -e

echo "🚀 n8n Ultra Media + Backblaze B2 (v2.10.3)"

# Auto-update yt-dlp (with fallback if rate-limited)
echo "Updating yt-dlp..."
yt-dlp -U || echo "yt-dlp update skipped (rate limit or network issue) - using built version"

# Auto-configure rclone B2 remote if keys provided
if [ -n "$BACKBLAZE_KEY_ID" ] && [ -n "$BACKBLAZE_APP_KEY" ]; then
  echo "✅ Setting up rclone B2 remote..."
  rclone config create b2 b2 account "$BACKBLAZE_KEY_ID" key "$BACKBLAZE_APP_KEY" --non-interactive || echo "rclone config already exists or failed"
fi

export TZ=${GENERIC_TIMEZONE:-America/Los_Angeles}

echo "✅ All tools ready: ffmpeg, yt-dlp+aria2, rclone, b2 CLI, OCR, exiftool, Chromium, Python venv"

# Exec the ACTUAL n8n entrypoint/binary (this is what was missing)
exec n8n start
