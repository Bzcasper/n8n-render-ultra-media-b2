FROM docker.n8n.io/n8nio/n8n:2.10.3

USER root

# 2026 APK FIX: Bootstrap apk-tools using wget (curl is missing in hardened image)
RUN wget -q -O /tmp/apk-tools.apk \
    https://dl-cdn.alpinelinux.org/alpine/v3.22/main/x86_64/apk-tools-2.14.8-r0.apk && \
    tar -xzf /tmp/apk-tools.apk -C / --strip-components=1 && \
    rm /tmp/apk-tools.apk && \
    apk update && apk upgrade --no-cache

# ALL MEDIA + STORAGE + HACK TOOLS (now apk works)
RUN apk add --no-cache \
    ffmpeg aria2 rclone exiftool mediainfo sox lame qpdf \
    poppler-utils tesseract-ocr imagemagick ghostscript \
    chromium chromium-chromedriver nss freetype harfbuzz ca-certificates \
    py3-pip curl jq git tzdata && \
    # yt-dlp with hash validation (secure download)
    wget -q -O /usr/local/bin/yt-dlp \
      https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp && \
    wget -q -O /tmp/SHA2-256SUMS \
      https://github.com/yt-dlp/yt-dlp/releases/latest/download/SHA2-256SUMS && \
    cd /usr/local/bin && \
    grep "yt-dlp$" /tmp/SHA2-256SUMS | sha256sum -c - && \
    chmod +x /usr/local/bin/yt-dlp && \
    rm /tmp/SHA2-256SUMS && \
    # Backblaze b2 CLI
    pip3 install --no-cache-dir b2

# Python venv (fixes Python runner + pandas/opencv)
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir pandas numpy pillow requests beautifulsoup4 yt_dlp opencv-python-headless

ENV PATH="/opt/venv/bin:$PATH" \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    NODE_OPTIONS="--max-old-space-size=4096"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER node
ENTRYPOINT ["/entrypoint.sh"]
