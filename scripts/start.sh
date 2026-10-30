#!/bin/bash
set -euo pipefail

: "${EULA:=FALSE}"
: "${JAVA_MIN_RAM:=1G}"
: "${JAVA_MAX_RAM:=4G}"

if [[ "$EULA" != "TRUE" ]]; then
  echo "Minecraft EULA not accepted. Review it, then start with EULA=TRUE if you agree." >&2
  exit 1
fi

for ram_setting in "$JAVA_MIN_RAM" "$JAVA_MAX_RAM"; do
  if [[ ! "$ram_setting" =~ ^[1-9][0-9]*[KMG]$ ]]; then
    echo "Invalid heap size '$ram_setting'; use a value such as 1G, 1024M, or 512K." >&2
    exit 1
  fi
done

if [[ ! -s /opt/minecraft/server.jar ]]; then
  echo "Minecraft server JAR is missing or empty: /opt/minecraft/server.jar" >&2
  exit 1
fi

printf 'eula=true\n' > /data/eula.txt
exec java "-Xms${JAVA_MIN_RAM}" "-Xmx${JAVA_MAX_RAM}" \
  -jar /opt/minecraft/server.jar nogui
