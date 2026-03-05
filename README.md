# n8n Ultra Media + Backblaze B2 (Render Free Tier)

Full-featured n8n with ffmpeg, yt-dlp+aria2, rclone, OCR, ImageMagick, Python venv, Chromium, and Backblaze B2 integration.

## Deploy (2 minutes)
1. Create repo → add these 5 files
2. Render Dashboard → New → Blueprint → connect repo
3. Replace `YOUR_KEY_ID_HERE` / `YOUR_APP_KEY_HERE` in render.yaml (or add as env vars)
4. Deploy

## Test Commands (Execute Command node)
```bash
ffmpeg -version
yt-dlp --version
rclone ls b2:your-bucket-name
b2 version
tesseract --version
