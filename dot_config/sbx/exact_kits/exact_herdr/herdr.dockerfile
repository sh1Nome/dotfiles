FROM docker.io/library/debian:trixie-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl
RUN set -eu; \
    curl -fsSL https://github.com/herdrdev/herdr/releases/latest/download/herdr-linux-x86_64 -o /herdr; \
    chmod 0755 /herdr
FROM scratch
COPY --from=build /herdr /usr/local/bin/herdr
