#!/bin/bash
# shellcheck source=scripts/functions.sh
source "/home/steam/server/functions.sh"

# Configure RCON settings
LogAction "Configuring RCON settings"
cat >/home/steam/server/rcon.yml  <<EOL
default:
  address: "127.0.0.1:${RCON_PORT}"
  password: "${RCON_PASSWORD}"
EOL

cd /project-zomboid || exit

# If the server files were wiped (e.g., PVC nuked) or this is a fresh install,
# make sure the dedicated server has been installed before trying to start it.
if [ ! -x "/project-zomboid/start-server.sh" ]; then
  LogWarn "/project-zomboid/start-server.sh is missing; running init to (re)install server files"
  # Reinstall the server into /project-zomboid (common when a PVC was wiped)
  install

  if [ ! -x "/project-zomboid/start-server.sh" ]; then
    LogError "Server install did not produce start-server.sh. Listing /project-zomboid for debugging:"
    ls -la /project-zomboid || true
    exit 1
  fi
fi

# if GENERATE_SETTINGS IS FALSE then we will not generate the settings
if [ "$GENERATE_SETTINGS" = "true" ]; then
  LogAction "Compiling settings"
  /home/steam/server/compile-settings.sh
elif [ "$GENERATE_SETTINGS" = "false" ]; then
  LogWarn "GENERATE_SETTINGS=false, not overwriting settings"
fi

LogAction "Starting server"
./start-server.sh \
    -cachedir="$CONFIG_DIR" \
    -adminusername "$ADMIN_USERNAME" \
    -adminpassword "$ADMIN_PASSWORD" \
    -port "$DEFAULT_PORT" \
    -servername "$SERVER_NAME" \
    -steamvac "$STEAM_VAC" "$USE_STEAM"
