ARG UBUNTU_VERSION=26.04
FROM ubuntu:${UBUNTU_VERSION}

ARG MINECRAFT_VERSION_URL=https://fill-data.papermc.io/v1/objects/416b7d105b1d0192df4afa4b29d2800d9dbeda092a82fbc5b511248a54adde15/paper-26.3-227.jar

ENV JAVA_MIN_RAM=1G \
    JAVA_MAX_RAM=4G \
    EULA=FALSE

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        openjdk-25-jre-headless \
        wget \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/installation.sh /usr/local/bin/install-minecraft
COPY scripts/start.sh /usr/local/bin/start-minecraft
RUN chmod 0755 /usr/local/bin/install-minecraft /usr/local/bin/start-minecraft \
    && MINECRAFT_VERSION_URL="${MINECRAFT_VERSION_URL}" \
       SERVER_JAR_PATH=/opt/minecraft/server.jar \
       /usr/local/bin/install-minecraft \
    && groupadd --system minecraft \
    && useradd --system --gid minecraft --home-dir /data --no-create-home minecraft \
    && mkdir -p /data \
    && chown minecraft:minecraft /data

USER minecraft
WORKDIR /data
VOLUME ["/data"]

EXPOSE 25565/tcp

ENTRYPOINT ["/usr/local/bin/start-minecraft"]
