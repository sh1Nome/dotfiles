FROM docker.io/library/debian:trixie-slim AS build
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates cargo curl gcc jq libc6-dev libcurl4-openssl-dev libssl-dev make zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
RUN set -eu; \
    curl -fsSL 'https://api.github.com/repos/git/git/tags?per_page=100' -o /tmp/git-tags.json; \
    tag="$(jq -er '[.[].name | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))] | max_by(ltrimstr("v") | split(".") | map(tonumber))' /tmp/git-tags.json)"; \
    curl -fsSL "https://github.com/git/git/archive/refs/tags/$tag.tar.gz" -o /tmp/git.tar.gz; \
    mkdir -p /tmp/git; \
    tar -xzf /tmp/git.tar.gz --strip-components=1 -C /tmp/git; \
    cd /tmp/git; \
    make -j2 prefix=/usr/local NO_TCLTK=YesPlease NO_GETTEXT=YesPlease NO_EXPAT=YesPlease all; \
    make prefix=/usr/local NO_TCLTK=YesPlease NO_GETTEXT=YesPlease NO_EXPAT=YesPlease DESTDIR=/out install; \
    /out/usr/local/bin/git --version | grep -Fx "git version ${tag#v}"
FROM scratch
COPY --from=build /out/ /
