#!/bin/bash
# Project Zomboid specific helpers. The shared logging / steamcmd / user-remap
# helpers come from the steamcmd-base image.
# shellcheck source=/dev/null
source "/opt/scripts/functions.sh"

# rcon call
rcon-call() {
  local args="$1"
  rcon-cli -c /home/steam/server/rcon.yml "$args"
}

# Saves the server
# Returns 0 if it saves
# Returns 1 if it is not able to save
save_server() {
    local return_val=0
    if ! rcon-call save; then
        return_val=1
    fi
    return "$return_val"
}

# Saves then shutdowns the server
# Returns 0 if it is shutdown
# Returns 1 if it is not able to be shutdown
shutdown_server() {
    local return_val=0
    # Do not shutdown if not able to save
    if save_server; then
        if ! rcon-call "quit"; then
            return_val=1
        fi
    else
        return_val=1
    fi
    return "$return_val"
}

# Check if the admin password has been changed
check_admin_password() {
    if [ -z "${ADMIN_PASSWORD}" ] ||  [ "${ADMIN_PASSWORD}" == "admin" ] || [ "${ADMIN_PASSWORD}" == "CHANGEME" ]; then
        LogWarn "ADMIN_PASSWORD is not set or is insecure. Please set this in the environment variables."
    fi
}
