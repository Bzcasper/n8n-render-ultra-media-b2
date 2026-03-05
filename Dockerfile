FROM docker.n8n.io/n8nio/n8n:2.10.3

USER root

# Bootstrap apk using static binary (this worked in your last build)
RUN wget -q -O /tmp/apk.static \
    https://gitlab.alpinelinux.org/api/v4/projects/5/packages/generic/v2.14.4/x86_64/apk.static && \
    chmod +x /tmp/apk.static && \
    /tmp/apk.static -X http://dl-cdn.alpinelinux.org/alpine/v3.22/main \
      -U --allow-untrusted --initdb add apk-tools && \
    rm /tmp/apk.static && \
    apk update && apk upgrade --no-cache

# Install runtime + build tools (build deps only for opencv compilation)
RUN apk add --no-cache \
    ffmpeg aria2 rclone exiftool mediainfo sox lame qpdf \
    poppler-utils tesseract-ocr imagemagick ghostscript \
    chromium chromium-chromedriver nss freetype harfbuzz ca-certificates \
    py3-pip curl jq git tzdata && \
    # Build deps for opencv-python-headless (added temporarily)
    apk add --no-cache --virtual .build-deps \
      build-base cmake linux-headers pkgconf python3-dev py3-numpy-dev && \
    # yt-dlp with hash validation
    wget -q -O /usr/local/bin/yt-dlp \
      https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp && \
    wget -q -O /tmp/SHA2-256SUMS \
      https://github.com/yt-dlp/yt-dlp/releases/latest/download/SHA2-256SUMS && \
    cd /usr/local/bin && \
    grep "yt-dlp$" /tmp/SHA2-256SUMS | sha256sum -c - && \
    chmod +x /usr/local/bin/yt-dlp && \
    rm /tmp/SHA2-256SUMS && \
    # b2 CLI with override
    pip3 install --no-cache-dir --break-system-packages b2

# Python venv + packages (opencv will now compile successfully)
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir pandas numpy pillow requests beautifulsoup4 yt_dlp opencv-python-headless && \
    # Clean up build deps after compilation (reduces image size ~200–400 MB)
    apk del .build-deps

ENV PATH="/opt/venv/bin:$PATH" \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    NODE_OPTIONS="--max-old-space-size=4096"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER node
ENTRYPOINT ["/entrypoint.sh"]
