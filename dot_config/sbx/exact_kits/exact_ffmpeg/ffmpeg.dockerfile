FROM docker.io/sbx/codex:latest
USER root
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ffmpeg fonts-noto-cjk \
    && rm -rf /var/lib/apt/lists/*
COPY files/skills/create-short-video/ /usr/local/share/ffmpeg/skills/create-short-video/
