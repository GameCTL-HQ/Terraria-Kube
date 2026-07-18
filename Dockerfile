# GameCTL vanilla Terraria dedicated server image — built from scratch so
# GameCTL controls exactly what runs.
#
# Sources: only Debian's official base and Re-Logic's official dedicated
# server zip (terraria.org — freely downloadable). The Linux server binary is
# self-contained (bundled mono), so no runtime deps beyond glibc.
#
# TERRARIA_VERSION is the compact form used in the zip name (1.4.5.6 -> 1456).
# CI resolves the newest one from terraria.org's download page.
FROM debian:12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl unzip tini \
    && rm -rf /var/lib/apt/lists/*

ARG TERRARIA_VERSION
ENV TERRARIA_VERSION=${TERRARIA_VERSION}

RUN test -n "${TERRARIA_VERSION}" || (echo "TERRARIA_VERSION build-arg is required (see CI)" >&2; exit 1) \
    && curl -fsSL "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${TERRARIA_VERSION}.zip" -o /tmp/ts.zip \
    && unzip -q /tmp/ts.zip -d /tmp/ts \
    && mkdir -p /opt/terraria \
    && cp -a "/tmp/ts/${TERRARIA_VERSION}/Linux/." /opt/terraria/ \
    && chmod +x /opt/terraria/TerrariaServer.bin.x86_64* \
    && rm -rf /tmp/ts /tmp/ts.zip

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

# Direct connect on 7777/tcp. World data lives wherever -world points —
# GameCTL mounts /root/.local/share/Terraria/Worlds.
EXPOSE 7777/tcp
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint"]
