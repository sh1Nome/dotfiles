FROM docker.io/sbx/codex:latest AS build
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-tomlkit \
    && rm -rf /var/lib/apt/lists/* \
    && install -d /out/usr/local/share/codex-personal/python \
    && cp -R /usr/lib/python3/dist-packages/tomlkit /out/usr/local/share/codex-personal/python/
FROM scratch
COPY --from=build /out/ /
COPY files/codex-personal/ /usr/local/share/codex-personal/
