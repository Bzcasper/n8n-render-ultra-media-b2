#!/bin/sh
set -e

echo "🚀 n8n Ultra Media + Backblaze B2 (v2.10.3)"

# Auto-update yt-dlp every start
yt-dlp -U || true

# Auto-configure rclone B2 remote
if [ -n "$BACKBLAZE_KEY_ID" ] && [ -n "$BACKBLAZE_APP_KEY" ]; then
  echo "✅ Setting up rclone B2 remote..."
  rclone config create b2 b2 account "$BACKBLAZE_KEY_ID" key "$BACKBLAZE_APP_KEY" --non-interactive || true
fi

export TZ=${GENERIC_TIMEZONE:-America/Los_Angeles}
echo "✅ All tools ready: ffmpeg, yt-dlp+aria2, rclone, b2 CLI, OCR, exiftool, Chromium, Python venv"
exec /usr/local/bin/docker-entrypoint.sh "$@"
