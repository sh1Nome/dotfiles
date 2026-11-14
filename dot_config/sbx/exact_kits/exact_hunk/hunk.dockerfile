FROM docker.io/sbx/codex:latest AS build
USER root
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl jq \
    && rm -rf /var/lib/apt/lists/*
RUN set -eu; \
    curl -fsSL https://api.github.com/repos/modem-dev/hunk/releases/latest -o /tmp/release.json; \
    tag="$(jq -er '.tag_name' /tmp/release.json)"; \
    curl -fsSL "https://github.com/modem-dev/hunk/archive/refs/tags/$tag.tar.gz" -o /tmp/source.tar.gz; \
    mkdir -p /tmp/hunk /out/usr/local/share/hunk /out/usr/local/bin; \
    tar -xzf /tmp/source.tar.gz --strip-components=1 -C /tmp/hunk; \
    HUNK_VERSION="$tag" HUNK_INSTALL_DIR=/out/usr/local/share/hunk HUNK_NO_MODIFY_PATH=1 sh /tmp/hunk/install.sh; \
    ln -s /usr/local/share/hunk/hunk /out/usr/local/bin/hunk
FROM scratch
COPY --from=build /out/ /
COPY files/hunk/config.toml /usr/local/share/hunk/default-config.toml
COPY files/hunk/extensions/threads.js /usr/local/share/hunk/extensions/threads.js
