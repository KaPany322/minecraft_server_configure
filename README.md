# Paper Minecraft server container

This project builds a container image for a Paper Java Edition server. The server runs as an unprivileged `minecraft` user. The Paper JAR is stored in the image at `/opt/minecraft/server.jar`; the server configuration, plugins, and world data are stored under `/data`.

## Requirements

- Docker Engine with permission to build and run containers.
- Inbound TCP port 25565 allowed by the host firewall and, when hosted on Azure, the VM network security group.
- Agreement to the [Minecraft EULA](https://www.minecraft.net/eula) before starting the server.

## Build the image

Run these commands from this directory:

```sh
docker build -t minecraft:latest .
```

The Dockerfile defaults to Ubuntu 26.04, OpenJDK 25, and the Paper download URL defined in the file. To use another Paper build, pass its HTTPS URL and to use other Ubuntu version, pass its version:

```sh
docker build \
  --build-arg MINECRAFT_VERSION_URL="<https://example.invalid/paper.jar>" \
  #  --build-arg UBUNTU_VERSION="26.04"
  -t minecraft:latest .
```

The chosen Paper release must support the Java version installed in the Dockerfile. Only use server downloads from a source you trust.

## Run the server

After reviewing and accepting the EULA, start the server with a persistent named volume:

```sh
docker run -d -it \
  --name minecraft \
  --restart unless-stopped \
  --memory 5g \
  -p 25565:25565/tcp \
  -e EULA=TRUE \
  -e JAVA_MIN_RAM=1G \
  -e JAVA_MAX_RAM=4G \
  -v minecraft-data:/data \
  minecraft:latest
```

The default heap is 1 GiB minimum and 4 GiB maximum. Set the container memory limit above the maximum heap to leave room for the JVM and operating system. Heap values accept forms such as `1G`, `1024M`, or `512K`.

View logs and stop or restart the server with:

```sh
docker logs -f minecraft
docker stop minecraft
docker restart minecraft
```

To type commands in the Minecraft server console, attach to the container:

```sh
docker attach minecraft
```

Detach without stopping the server with **Ctrl+P**, then **Ctrl+Q**.

The `minecraft-data` volume retains the world and server configuration when the container is replaced. Back it up before changing server versions. Removing a container without `-v` keeps the named volume; deleting the volume removes its data.

## Install Paper plugins

Paper uses plugins, not Forge/Fabric mods. Download a plugin JAR only from a source you trust, and check that it supports your Paper and Minecraft versions. From the Docker host, set the real HTTPS download URL and install it into the persistent data volume:

```sh
PLUGIN_URL=<https://trusted-site.example/download/plugin.jar>

docker exec --user minecraft minecraft mkdir -p /data/plugins
docker exec --user minecraft minecraft wget \
  --https-only \
  --output-document=/data/plugins/<plugin_name>.jar \
  "$PLUGIN_URL"
docker restart minecraft
```

Replace the example URL and `plugin.jar` with the plugin's actual download URL and filename. Plugins load when the server starts. They run with broad access to the server, so install only plugins you trust.

## Mods

This image runs Paper, which does not load Forge, Fabric, or NeoForge mods. Mods that add blocks, items, or other game content require a server built with a compatible mod loader, and players generally need compatible mods installed in their clients. Switching an existing modded world to Paper can lose modded content. Keep a backup before changing server software.

If your server runs on Forge, Fabric or Neoforge, and you want to install mods run in console:
```sh
MOD_URL=<https://trusted-site.example/download/mod.jar>

docker exec --user minecraft minecraft mkdir -p /data/mods
docker exec --user minecraft minecraft wget \
  --https-only \
  --output-document=/data/mods/<mod_name>.jar \
  "$MOD_URL"
docker restart minecraft
```
## Network access

`EXPOSE 25565/tcp` documents the port in the image. The `-p` option publishes it on the Docker host. On Azure, also allow inbound TCP port 25565 in the VM's network security group. The container does not configure UFW or host firewall rules.
