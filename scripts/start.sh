#!/bin/bash
# Runs as the steam user (init.sh execs into this through gosu) and is PID 1,
# so the SIGTERM trap and the server process both live here.
# shellcheck source=scripts/functions.sh
source "/home/steam/server/functions.sh"

# Configure RCON settings
LogAction "Configuring RCON settings"
cat >/home/steam/server/rcon.yml  <<EOL
default:
  address: "127.0.0.1:${RCON_PORT}"
  password: "${RCON_PASSWORD}"
EOL

# Install/update the dedicated server into $INSTALL_DIR (even if it is an empty
# volume, e.g. a fresh deploy or a wiped PVC). steamcmd_update retries
# internally and returns 1 instead of exiting, so a Steam-side failure still
# boots the last installed build.
if ! steamcmd_update "$STEAMAPPID" validate; then
  LogError "SteamCMD update did not complete; trying to start the last installed build"
fi

# Fail fast with a helpful message if the dedicated server did not populate.
if [ ! -x "$INSTALL_DIR/start-server.sh" ]; then
  LogError "Dedicated server install did not produce $INSTALL_DIR/start-server.sh"
  LogError "Contents of $INSTALL_DIR:"
  ls -la "$INSTALL_DIR" || true
  exit 1
fi

cd "$INSTALL_DIR" || exit

# if GENERATE_SETTINGS IS FALSE then we will not generate the settings
if [ "$GENERATE_SETTINGS" = "true" ]; then
  LogAction "Compiling settings"
  /home/steam/server/compile-settings.sh
elif [ "$GENERATE_SETTINGS" = "false" ]; then
  LogWarn "GENERATE_SETTINGS=false, not overwriting settings"
fi

# Check config for warnings
check_admin_password

# shellcheck disable=SC2317
term_handler() {
    if ! shutdown_server; then
        # Does not save
        kill -SIGTERM "$(pidof ProjectZomboid64)"
    fi
    tail --pid="$killpid" -f 2>/dev/null
}

trap 'term_handler' SIGTERM

LogAction "Starting server"
./start-server.sh \
    -cachedir="$CONFIG_DIR" \
    -adminusername "$ADMIN_USERNAME" \
    -adminpassword "$ADMIN_PASSWORD" \
    -port "$DEFAULT_PORT" \
    -servername "$SERVER_NAME" \
    -steamvac "$STEAM_VAC" "$USE_STEAM" &

# Process ID of the dedicated server launcher
killpid="$!"
wait "$killpid"
