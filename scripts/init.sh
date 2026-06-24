#!/bin/bash
# shellcheck source=scripts/functions.sh
source "/home/steam/server/functions.sh"

# These directories are commonly PVC-backed. On a fresh deploy or after a wipe,
# they can be empty and/or missing.
mkdir -p /project-zomboid /project-zomboid-config/Server

# ------------------------------------------------------------------
# Steam Workshop requires a valid Steam library tree for staging/install
# ------------------------------------------------------------------
mkdir -p \
    /home/steam/.steam/steamapps/workshop/content \
    /home/steam/.steam/steamapps/workshop/downloads \
    /home/steam/Steam/steamapps/workshop/content \
    /home/steam/Steam/steamapps/workshop/downloads

chown -R steam:steam /home/steam/.steam /home/steam/Steam || true
# ------------------------------------------------------------------

LogAction "Set file permissions"

# if the user has not defined a PUID and PGID, throw an error and exit
if [ -z "${PUID}" ] || [ -z "${PGID}" ]; then
    LogError "PUID and PGID not set. Please set these in the environment variables."
    exit 1
else
    usermod -o -u "${PUID}" steam
    groupmod -o -g "${PGID}" steam
fi

chown -R steam:steam /project-zomboid /project-zomboid-config /home/steam/ || true

# Install/update the dedicated server into /project-zomboid (even if it is an empty volume).
install

if [ ! -x "/project-zomboid/start-server.sh" ]; then
    LogErr "Install finished but /project-zomboid/start-server.sh is still missing. Contents of /project-zomboid:"
    ls -la /project-zomboid || true
    exit 1
fi

# Fail fast with a helpful message if the dedicated server did not populate correctly.
if [ ! -x "/project-zomboid/start-server.sh" ]; then
    LogError "Dedicated server install did not produce /project-zomboid/start-server.sh"
    LogError "Contents of /project-zomboid:"
    ls -la /project-zomboid || true
    exit 1
fi

# shellcheck disable=SC2317
term_handler() {
    if ! shutdown_server; then
        # Does not save
        kill -SIGTERM "$(pidof ProjectZomboid64)"
    fi
    tail --pid="$killpid" -f 2>/dev/null
}

trap 'term_handler' SIGTERM

# Check config for warnings
check_admin_password

# Start the server
./start.sh &

# Process ID of su
killpid="$!"
wait "$killpid"
