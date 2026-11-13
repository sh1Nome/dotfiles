FROM docker.io/sbx/codex:latest AS build
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl jq python3-tomlkit \
    && rm -rf /var/lib/apt/lists/*
RUN set -eu; \
    curl -fsSL https://api.github.com/repos/microsoft/tgrep/releases/latest -o /tmp/release.json; \
    tag="$(jq -er '.tag_name' /tmp/release.json)"; \
    curl -fsSL "https://github.com/microsoft/tgrep/archive/refs/tags/$tag.tar.gz" -o /tmp/source.tar.gz; \
    install -d /out/usr/local/share/tgrep /out/usr/local/bin /out/usr/local/share/codex-personal/python; \
    tar -xzf /tmp/source.tar.gz --strip-components=1 -C /out/usr/local/share/tgrep; \
    TGREP_VERSION="$tag" TGREP_INSTALL_DIR=/out/usr/local/bin bash /out/usr/local/share/tgrep/scripts/install.sh; \
    cp -R /usr/lib/python3/dist-packages/tomlkit /out/usr/local/share/codex-personal/python/
FROM scratch
COPY --from=build /out/ /
COPY files/codex-personal/ /usr/local/share/codex-personal/
