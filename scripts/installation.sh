#!/bin/bash
set -euo pipefail

: "${MINECRAFT_VERSION_URL:?Set MINECRAFT_VERSION_URL to the Paper server download URL}"
: "${SERVER_JAR_PATH:?Set SERVER_JAR_PATH to the destination for the server JAR}"

mkdir -p "$(dirname "$SERVER_JAR_PATH")"
wget --https-only --output-document="$SERVER_JAR_PATH" "$MINECRAFT_VERSION_URL"
test -s "$SERVER_JAR_PATH"
