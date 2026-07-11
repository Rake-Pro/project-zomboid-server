#BUILD THE RCON-CLI PACKAGE
FROM golang:1.25-alpine AS rcon-cli_builder

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
FROM cm2network/steamcmd:root

RUN apt-get update && apt-get -y upgrade && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    gettext-base \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=rcon-cli_builder /build/gorcon /usr/bin/rcon-cli

LABEL maintainer="greg@rake.pro" \
      name="rakepro/project-zomboid-server" \
      github="" \
      dockerhub=""

ENV HOME=/home/steam \
    CONFIG_DIR=/project-zomboid-config \
    ADMIN_USERNAME=admin \
    ADMIN_PASSWORD=admin \
    DEFAULT_PORT=16261 \
    UDP_PORT=16262 \
    RCON_PORT=27015 \
    SERVER_NAME=pzserver \
    STEAM_VAC=true \
    USE_STEAM=true \
    GENERATE_SETTINGS=true

COPY ./scripts /home/steam/server/

RUN find /home/steam/server -type f \( -name "*.sh" -o -name "*.scmd" \) -exec sed -i 's/\r$//' {} \; \
 && chmod +x /home/steam/server/*.sh \
 && mkdir -p /project-zomboid /project-zomboid-config

WORKDIR /home/steam/server

HEALTHCHECK --start-period=5m \
            CMD pgrep "ProjectZomboid" > /dev/null || exit 1

ENTRYPOINT ["/home/steam/server/init.sh"]