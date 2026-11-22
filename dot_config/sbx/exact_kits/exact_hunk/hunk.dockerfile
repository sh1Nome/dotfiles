FROM docker.io/library/debian:trixie-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*
RUN set -eu; \
    curl -fsSL https://hunk.dev/install.sh -o /tmp/hunk-install.sh; \
    HUNK_INSTALL_DIR=/out/usr/local/share/hunk HUNK_NO_MODIFY_PATH=1 HUNK_DISABLE_ANALYTICS=1 sh /tmp/hunk-install.sh; \
    mkdir -p /out/usr/local/bin; \
    ln -s /usr/local/share/hunk/hunk /out/usr/local/bin/hunk
FROM scratch
COPY --from=build /out/ /
COPY files/hunk/config.toml /usr/local/share/hunk/default-config.toml
COPY files/hunk/extensions/threads.js /usr/local/share/hunk/extensions/threads.js
