#!/usr/bin/env bash
# GameCTL Terraria entrypoint — a thin passthrough. All server behavior comes
# from the args the Deployment passes (-world, -autocreate, -port, ...), which
# keeps this image drop-in compatible with GameCTL's terraria generator.
#
# TerrariaServer spawns a console input reader that NPEs without an attached
# stdin/tty, so run the container with stdin+tty (k8s: stdin: true, tty: true).
set -euo pipefail

# Default worlds dir (the path TerrariaServer uses on Linux; GameCTL mounts the
# volume here and passes absolute -world paths under it).
mkdir -p /root/.local/share/Terraria/Worlds

ver="${TERRARIA_VERSION:-unknown}"
echo "gamectl: starting Terraria dedicated server ${ver} — args: $*"
exec /opt/terraria/TerrariaServer.bin.x86_64 "$@"
