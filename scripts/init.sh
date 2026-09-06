#!/bin/bash
# PID 1 as root. Its only job is to make the data directories owned by the
# steam user, then hand the container over to start.sh unprivileged.
# shellcheck source=scripts/functions.sh
source "/home/steam/server/functions.sh"

LogAction "Set file permissions"

# remap_steam_user re-IDs the steam user to $PUID/$PGID (both defaulted in the
# Dockerfile), creates each directory if it is missing and chowns it. These are
# commonly PVC-backed and, until this image dropped privileges, were written as
# root, so the first boot after the upgrade re-owns them.
# The Steam library/workshop trees must exist for workshop staging/install.
remap_steam_user \
    "$INSTALL_DIR" \
    "$CONFIG_DIR" \
    "$CONFIG_DIR/Server" \
    /home/steam/.steam \
    /home/steam/Steam \
    /home/steam/.steam/steamapps/workshop/content \
    /home/steam/.steam/steamapps/workshop/downloads \
    /home/steam/Steam/steamapps/workshop/content \
    /home/steam/Steam/steamapps/workshop/downloads

# exec keeps start.sh as PID 1, so it is the process that receives SIGTERM and
# can run the RCON save/quit shutdown.
exec gosu steam /home/steam/server/start.sh
