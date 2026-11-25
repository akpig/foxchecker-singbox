# syntax=docker/dockerfile:1.7

FROM debian:bookworm-slim AS singbox-fetch
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gzip tar \
    && rm -rf /var/lib/apt/lists/*
ARG TARGETARCH
ARG SINGBOX_VERSION=1.13.14
ARG SINGBOX_AMD64_SHA256=f48703461a15476951ac4967cdad339d986f4b8096b4eb3ff0829a500502d697
RUN test "${TARGETARCH}" = "amd64" \
    && asset="sing-box-${SINGBOX_VERSION}-linux-amd64.tar.gz" \
    && curl -fsSL "https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_VERSION}/${asset}" -o /tmp/sing-box.tar.gz \
    && printf '%s  %s\n' "${SINGBOX_AMD64_SHA256}" /tmp/sing-box.tar.gz | sha256sum -c - \
    && tar -xzf /tmp/sing-box.tar.gz -C /tmp \
    && install -m 0755 "/tmp/sing-box-${SINGBOX_VERSION}-linux-amd64/sing-box" /usr/local/bin/sing-box \
    && install -m 0755 "/tmp/sing-box-${SINGBOX_VERSION}-linux-amd64/libcronet.so" /usr/local/lib/libcronet.so \
    && install -m 0644 "/tmp/sing-box-${SINGBOX_VERSION}-linux-amd64/LICENSE" /tmp/LICENSE \
    && /usr/local/bin/sing-box version
RUN --network=none --mount=type=bind,source=geoip,target=/geoip \
    set -eu; \
    digest="$(cat /geoip/current.sha512)"; \
    test "${#digest}" -eq 128; \
    case "$digest" in *[!0-9a-f]*) exit 1 ;; esac; \
    archive="/geoip/$digest.mmdb.gz"; \
    printf '%s  %s\n' "$digest" "$archive" | sha512sum -c -; \
    gzip -dc "$archive" > /tmp/country.mmdb

FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 65532 checker \
    && useradd --uid 65532 --gid 65532 --no-create-home --home-dir /tmp --shell /usr/sbin/nologin checker \
    && install -d -m 0700 -o 65532 -g 65532 /output
COPY --chmod=0755 foxchecker/foxchecker /usr/local/bin/foxchecker
RUN --network=none /usr/local/bin/foxchecker --version
COPY --from=singbox-fetch /usr/local/bin/sing-box /usr/local/bin/sing-box
COPY --from=singbox-fetch /usr/local/lib/libcronet.so /usr/local/lib/libcronet.so
COPY --from=singbox-fetch /tmp/LICENSE /licenses/sing-box/LICENSE
COPY --from=singbox-fetch /tmp/country.mmdb /usr/local/share/foxchecker/country.mmdb
COPY geoip/NOTICE /licenses/geoip/NOTICE
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV HOME=/tmp
USER 65532:65532
WORKDIR /output
ENTRYPOINT ["/usr/local/bin/foxchecker", "--engine", "sing-box"]
