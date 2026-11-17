FROM docker.io/sbx/codex:latest AS build
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends nodejs-24 \
    && install -D /usr/bin/node /out/usr/local/share/pstack/node/bin/node
FROM scratch
COPY --from=build /out/ /
ENV PATH=/usr/local/share/pstack/node/bin
