#BUILD THE RCON-CLI PACKAGE
FROM golang:1.27.1-alpine AS rcon-cli_builder

ARG RCON_VERSION="0.10.3"
ARG RCON_TGZ_SHA1SUM=33ee8077e66bea6ee097db4d9c923b5ed390d583

WORKDIR /build

# install rcon
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

ENV CGO_ENABLED=0
RUN wget -q https://github.com/gorcon/rcon-cli/archive/refs/tags/v${RCON_VERSION}.tar.gz -O rcon.tar.gz \
    && echo "${RCON_TGZ_SHA1SUM}" rcon.tar.gz | sha1sum -c - \
    && tar -xzvf rcon.tar.gz \
    && rm rcon.tar.gz \
    && mv rcon-cli-${RCON_VERSION}/* ./ \
    && rm -rf rcon-cli-${RCON_VERSION} \
    && go build -v ./cmd/gorcon

#BUILD THE SERVER IMAGE
FROM ghcr.io/rake-pro/steamcmd-base:latest

# The base ships as USER steam; apt needs root. gettext-base is the only extra
# package: envsubst renders the settings template. procps (pgrep for the
# HEALTHCHECK), curl, ca-certificates and gosu already come from the base, and
# its package lists are stripped, so apt-get update has to run first.
USER root
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
      gettext-base \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY --from=rcon-cli_builder /build/gorcon /usr/bin/rcon-cli

LABEL name="rakepro/project-zomboid-server"

# HOME is pinned because the image boots as root: without it the root phase
# would get /root and the Steam library/workshop trees would move.
# PUID/PGID are defaulted to the base image's steam UID/GID so a deployment
# that does not set them keeps working instead of failing the boot.
ENV HOME=/home/steam \
    INSTALL_DIR=/project-zomboid \
    CONFIG_DIR=/project-zomboid-config \
    STEAMAPPID=380870 \
    PUID=1000 \
    PGID=1000 \
    ADMIN_USERNAME=admin \
    ADMIN_PASSWORD=admin \
    DEFAULT_PORT=16261 \
    UDP_PORT=16262 \
    RCON_PORT=27015 \
    SERVER_NAME=pzserver \
    STEAM_VAC=true \
    USE_STEAM=true \
    GENERATE_SETTINGS=true

COPY --chown=steam:steam ./scripts /home/steam/server/

RUN find /home/steam/server -type f -name "*.sh" -exec sed -i 's/\r$//' {} \; \
 && chmod +x /home/steam/server/*.sh \
 && mkdir -p /project-zomboid /project-zomboid-config

WORKDIR /home/steam/server

HEALTHCHECK --start-period=5m \
            CMD pgrep "ProjectZomboid" > /dev/null || exit 1

# Boot as root only long enough for init.sh to remap/chown the data dirs; it
# then drops to the steam user with gosu before the server starts.
USER root

ENTRYPOINT ["/home/steam/server/init.sh"]
