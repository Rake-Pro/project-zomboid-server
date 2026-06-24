#!/bin/bash
# shellcheck source=scripts/functions.sh
set -euo pipefail

source "/home/steam/server/functions.sh"

config_file="/project-zomboid-config/Server/${SERVER_NAME}.ini"
config_dir="$(dirname "$config_file")"

mkdir -p "$config_dir"

# Only regen INI if:
# - it does not exist, OR
# - FORCE_REGENERATE_CONFIG=true, OR
# - APPLY_ENV_TO_EXISTING=true (useful when you change env in k8s and want it applied)
FORCE_REGENERATE_CONFIG="${FORCE_REGENERATE_CONFIG:-false}"
APPLY_ENV_TO_EXISTING="${APPLY_ENV_TO_EXISTING:-false}"

# Regen LUA if:
# - it does not exist, OR
# - FORCE_REGENERATE_LUA=true, OR
# - APPLY_ENV_TO_EXISTING=true
FORCE_REGENERATE_LUA="${FORCE_REGENERATE_LUA:-false}"

# Optional: wait for workshop content to exist before generating spawnregions.
# Set this in Helm values as an env var, e.g. WAIT_FOR_WORKSHOP_SECONDS: "30"
WAIT_FOR_WORKSHOP_SECONDS="${WAIT_FOR_WORKSHOP_SECONDS:-0}"

export PVP="${PVP:-true}"
export PAUSE_EMPTY="${PAUSE_EMPTY:-true}"
export GLOBAL_CHAT="${GLOBAL_CHAT:-true}"
export CHAT_STREAMS="${CHAT_STREAMS:-s,r,a,w,y,sh,f,all}"
export OPEN="${OPEN:-true}"
export SERVER_WELCOME_MESSAGE="${SERVER_WELCOME_MESSAGE:-Welcome to Project Zomboid Multiplayer!}"
export AUTO_CREATE_USER_IN_WHITE_LIST="${AUTO_CREATE_USER_IN_WHITE_LIST:-false}"
export DISPLAY_USER_NAME="${DISPLAY_USER_NAME:-true}"
export SHOW_FIRST_AND_LAST_NAME="${SHOW_FIRST_AND_LAST_NAME:-false}"
export SPAWN_POINT="${SPAWN_POINT:-0,0,0}"
export SAFETY_SYSTEM="${SAFETY_SYSTEM:-true}"
export SHOW_SAFETY="${SHOW_SAFETY:-true}"
export SAFETY_TOGGLE_TIMER="${SAFETY_TOGGLE_TIMER:-2}"
export SAFETY_COOLDOWN_TIMER="${SAFETY_COOLDOWN_TIMER:-3}"
export SPAWN_ITEMS="${SPAWN_ITEMS:-}"
export DEFAULT_PORT="${DEFAULT_PORT:-16261}"
export UDP_PORT="${UDP_PORT:-16262}"
export RESET_ID="${RESET_ID:-563979383}"

# IMPORTANT: These must be exported for envsubst to populate template.
export MODS="${MODS:-}"
export MAP="${MAP:-Muldraugh, KY}"
export WORKSHOP_ITEMS="${WORKSHOP_ITEMS:-}"

export DO_LUA_CHECKSUM="${DO_LUA_CHECKSUM:-true}"
export DENY_LOGIN_ON_OVERLOADED_SERVER="${DENY_LOGIN_ON_OVERLOADED_SERVER:-true}"
export PUBLIC="${PUBLIC:-false}"
export PUBLIC_NAME="${PUBLIC_NAME:-My PZ Server}"
export PUBLIC_DESCRIPTION="${PUBLIC_DESCRIPTION:-}"
export MAX_PLAYERS="${MAX_PLAYERS:-32}"
export PING_LIMIT="${PING_LIMIT:-400}"
export HOURS_FOR_LOOT_RESPAWN="${HOURS_FOR_LOOT_RESPAWN:-0}"
export MAX_ITEMS_FOR_LOOT_RESPAWN="${MAX_ITEMS_FOR_LOOT_RESPAWN:-4}"
export CONSTRUCTION_PREVENTS_LOOT_RESPAWN="${CONSTRUCTION_PREVENTS_LOOT_RESPAWN:-true}"
export DROP_OFF_WHITE_LIST_AFTER_DEATH="${DROP_OFF_WHITE_LIST_AFTER_DEATH:-false}"
export NO_FIRE="${NO_FIRE:-false}"
export ANNOUNCE_DEATH="${ANNOUNCE_DEATH:-false}"
export MINUTES_PER_PAGE="${MINUTES_PER_PAGE:-1.0}"
export SAVE_WORLD_EVERY_MINUTES="${SAVE_WORLD_EVERY_MINUTES:-0}"
export PLAYER_SAFEHOUSE="${PLAYER_SAFEHOUSE:-false}"
export ADMIN_SAFEHOUSE="${ADMIN_SAFEHOUSE:-false}"
export SAFEHOUSE_ALLOW_TRESPASS="${SAFEHOUSE_ALLOW_TRESPASS:-true}"
export SAFEHOUSE_ALLOW_FIRE="${SAFEHOUSE_ALLOW_FIRE:-true}"
export SAFEHOUSE_ALLOW_LOOT="${SAFEHOUSE_ALLOW_LOOT:-true}"
export SAFEHOUSE_ALLOW_RESPAWN="${SAFEHOUSE_ALLOW_RESPAWN:-false}"
export SAFEHOUSE_DAY_SURVIVED_TO_CLAIM="${SAFEHOUSE_DAY_SURVIVED_TO_CLAIM:-0}"
export SAFEHOUSE_REMOVAL_TIME="${SAFEHOUSE_REMOVAL_TIME:-144}"
export SAFEHOUSE_ALLOW_NON_RESIDENTIAL="${SAFEHOUSE_ALLOW_NON_RESIDENTIAL:-false}"
export ALLOW_DESTRUCTION_BY_SLEDGEHAMMER="${ALLOW_DESTRUCTION_BY_SLEDGEHAMMER:-true}"
export SLEDGEHAMMER_ONLY_IN_SAFEHOUSE="${SLEDGEHAMMER_ONLY_IN_SAFEHOUSE:-false}"
export KICK_FAST_PLAYERS="${KICK_FAST_PLAYERS:-false}"
export SERVER_PLAYER_ID="${SERVER_PLAYER_ID:-88635698}"
export RCON_PORT="${RCON_PORT:-27015}"
export RCON_PASSWORD="${RCON_PASSWORD:-}"
export DISCORD_ENABLE="${DISCORD_ENABLE:-false}"
export DISCORD_TOKEN="${DISCORD_TOKEN:-}"
export DISCORD_CHANNEL="${DISCORD_CHANNEL:-}"
export DISCORD_CHANNEL_ID="${DISCORD_CHANNEL_ID:-}"
export PASSWORD="${PASSWORD:-}"
export MAX_ACCOUNTS_PER_USER="${MAX_ACCOUNTS_PER_USER:-0}"
export ALLOW_COOP="${ALLOW_COOP:-true}"
export SLEEP_ALLOWED="${SLEEP_ALLOWED:-false}"
export SLEEP_NEEDED="${SLEEP_NEEDED:-false}"
export KNOCKED_DOWN_ALLOWED="${KNOCKED_DOWN_ALLOWED:-true}"
export SNEAK_MODE_HIDE_FROM_OTHER_PLAYERS="${SNEAK_MODE_HIDE_FROM_OTHER_PLAYERS:-true}"
export STEAM_SCOREBOARD="${STEAM_SCOREBOARD:-true}"
export STEAM_VAC="${STEAM_VAC:-true}"
export UPNP="${UPNP:-true}"
export VOICE_ENABLE="${VOICE_ENABLE:-true}"
export VOICE_MIN_DISTANCE="${VOICE_MIN_DISTANCE:-10.0}"
export VOICE_MAX_DISTANCE="${VOICE_MAX_DISTANCE:-100.0}"
export VOICE_3D="${VOICE_3D:-true}"
export SPEED_LIMIT="${SPEED_LIMIT:-70.0}"
export LOGIN_QUEUE_ENABLED="${LOGIN_QUEUE_ENABLED:-false}"
export LOGIN_QUEUE_CONNECT_TIMEOUT="${LOGIN_QUEUE_CONNECT_TIMEOUT:-60}"
export SERVER_BROWSER_ANNOUNCED_IP="${SERVER_BROWSER_ANNOUNCED_IP:-}"
export PLAYER_RESPAWN_WITH_SELF="${PLAYER_RESPAWN_WITH_SELF:-false}"
export PLAYER_RESPAWN_WITH_OTHER="${PLAYER_RESPAWN_WITH_OTHER:-false}"
export FAST_FORWARD_MULTIPLIER="${FAST_FORWARD_MULTIPLIER:-40.0}"
export DISABLE_SAFEHOUSE_WHEN_PLAYER_CONNECTED="${DISABLE_SAFEHOUSE_WHEN_PLAYER_CONNECTED:-false}"
export FACTION="${FACTION:-true}"
export FACTION_DAY_SURVIVED_TO_CREATE="${FACTION_DAY_SURVIVED_TO_CREATE:-0}"
export FACTION_PLAYERS_REQUIRED_FOR_TAG="${FACTION_PLAYERS_REQUIRED_FOR_TAG:-1}"
export DISABLE_RADIO_STAFF="${DISABLE_RADIO_STAFF:-false}"
export DISABLE_RADIO_ADMIN="${DISABLE_RADIO_ADMIN:-true}"
export DISABLE_RADIO_GM="${DISABLE_RADIO_GM:-true}"
export DISABLE_RADIO_OVERSEER="${DISABLE_RADIO_OVERSEER:-false}"
export DISABLE_RADIO_MODERATOR="${DISABLE_RADIO_MODERATOR:-false}"
export DISABLE_RADIO_INVISIBLE="${DISABLE_RADIO_INVISIBLE:-true}"
export CLIENT_COMMAND_FILTER="${CLIENT_COMMAND_FILTER:--vehicle.*;+vehicle.damageWindow;+vehicle.fixPart;+vehicle.installPart;+vehicle.uninstallPart}"
export CLIENT_ACTION_LOGS="${CLIENT_ACTION_LOGS:-ISEnterVehicle;ISExitVehicle;ISTakeEngineParts;}"
export PERK_LOGS="${PERK_LOGS:-true}"
export BLOOD_SPLAT_LIFESPAN_DAYS="${BLOOD_SPLAT_LIFESPAN_DAYS:-0}"
export ALLOW_NON_ASCII_USERNAME="${ALLOW_NON_ASCII_USERNAME:-false}"
export BAN_KICK_GLOBAL_SOUND="${BAN_KICK_GLOBAL_SOUND:-true}"
export REMOVE_PLAYER_CORPSES_ON_CORPSE_REMOVAL="${REMOVE_PLAYER_CORPSES_ON_CORPSE_REMOVAL:-false}"
export TRASH_DELETE_ALL="${TRASH_DELETE_ALL:-false}"
export PVP_MELEE_WHILE_HIT_REACTION="${PVP_MELEE_WHILE_HIT_REACTION:-false}"
export MOUSE_OVER_TO_SEE_DISPLAY_NAME="${MOUSE_OVER_TO_SEE_DISPLAY_NAME:-true}"
export HIDE_PLAYERS_BEHIND_YOU="${HIDE_PLAYERS_BEHIND_YOU:-true}"
export PVP_MELEE_DAMAGE_MODIFIER="${PVP_MELEE_DAMAGE_MODIFIER:-30.0}"
export PVP_FIREARM_DAMAGE_MODIFIER="${PVP_FIREARM_DAMAGE_MODIFIER:-50.0}"
export CAR_ENGINE_ATTRACTION_MODIFIER="${CAR_ENGINE_ATTRACTION_MODIFIER:-0.5}"
export PLAYER_BUMP_PLAYER="${PLAYER_BUMP_PLAYER:-false}"
export MAP_REMOTE_PLAYER_VISIBILITY="${MAP_REMOTE_PLAYER_VISIBILITY:-1}"
export BACKUPS_COUNT="${BACKUPS_COUNT:-5}"
export BACKUPS_ON_START="${BACKUPS_ON_START:-true}"
export BACKUPS_ON_VERSION_CHANGE="${BACKUPS_ON_VERSION_CHANGE:-true}"
export BACKUPS_PERIOD="${BACKUPS_PERIOD:-0}"

# NOTE: In the template these are "Disables anti-cheat protection..." so true == anti-cheat OFF for that type.
export ANTI_CHEAT_PROTECTION_TYPE1="${ANTI_CHEAT_PROTECTION_TYPE1:-false}"
export ANTI_CHEAT_PROTECTION_TYPE2="${ANTI_CHEAT_PROTECTION_TYPE2:-false}"
export ANTI_CHEAT_PROTECTION_TYPE3="${ANTI_CHEAT_PROTECTION_TYPE3:-false}"
export ANTI_CHEAT_PROTECTION_TYPE4="${ANTI_CHEAT_PROTECTION_TYPE4:-false}"
export ANTI_CHEAT_PROTECTION_TYPE5="${ANTI_CHEAT_PROTECTION_TYPE5:-false}"
export ANTI_CHEAT_PROTECTION_TYPE6="${ANTI_CHEAT_PROTECTION_TYPE6:-false}"
export ANTI_CHEAT_PROTECTION_TYPE7="${ANTI_CHEAT_PROTECTION_TYPE7:-false}"
export ANTI_CHEAT_PROTECTION_TYPE8="${ANTI_CHEAT_PROTECTION_TYPE8:-false}"
export ANTI_CHEAT_PROTECTION_TYPE9="${ANTI_CHEAT_PROTECTION_TYPE9:-false}"
export ANTI_CHEAT_PROTECTION_TYPE10="${ANTI_CHEAT_PROTECTION_TYPE10:-false}"
export ANTI_CHEAT_PROTECTION_TYPE11="${ANTI_CHEAT_PROTECTION_TYPE11:-false}"
export ANTI_CHEAT_PROTECTION_TYPE12="${ANTI_CHEAT_PROTECTION_TYPE12:-false}"
export ANTI_CHEAT_PROTECTION_TYPE13="${ANTI_CHEAT_PROTECTION_TYPE13:-false}"
export ANTI_CHEAT_PROTECTION_TYPE14="${ANTI_CHEAT_PROTECTION_TYPE14:-false}"
export ANTI_CHEAT_PROTECTION_TYPE15="${ANTI_CHEAT_PROTECTION_TYPE15:-false}"
export ANTI_CHEAT_PROTECTION_TYPE16="${ANTI_CHEAT_PROTECTION_TYPE16:-false}"
export ANTI_CHEAT_PROTECTION_TYPE17="${ANTI_CHEAT_PROTECTION_TYPE17:-false}"
export ANTI_CHEAT_PROTECTION_TYPE18="${ANTI_CHEAT_PROTECTION_TYPE18:-false}"
export ANTI_CHEAT_PROTECTION_TYPE19="${ANTI_CHEAT_PROTECTION_TYPE19:-false}"
export ANTI_CHEAT_PROTECTION_TYPE20="${ANTI_CHEAT_PROTECTION_TYPE20:-false}"
export ANTI_CHEAT_PROTECTION_TYPE21="${ANTI_CHEAT_PROTECTION_TYPE21:-false}"
export ANTI_CHEAT_PROTECTION_TYPE22="${ANTI_CHEAT_PROTECTION_TYPE22:-false}"
export ANTI_CHEAT_PROTECTION_TYPE23="${ANTI_CHEAT_PROTECTION_TYPE23:-false}"
export ANTI_CHEAT_PROTECTION_TYPE24="${ANTI_CHEAT_PROTECTION_TYPE24:-false}"

export ANTI_CHEAT_PROTECTION_TYPE2_THRESHOLD_MULTIPLIER="${ANTI_CHEAT_PROTECTION_TYPE2_THRESHOLD_MULTIPLIER:-3.0}"
export ANTI_CHEAT_PROTECTION_TYPE3_THRESHOLD_MULTIPLIER="${ANTI_CHEAT_PROTECTION_TYPE3_THRESHOLD_MULTIPLIER:-1.0}"
export ANTI_CHEAT_PROTECTION_TYPE4_THRESHOLD_MULTIPLIER="${ANTI_CHEAT_PROTECTION_TYPE4_THRESHOLD_MULTIPLIER:-1.0}"
export ANTI_CHEAT_PROTECTION_TYPE9_THRESHOLD_MULTIPLIER="${ANTI_CHEAT_PROTECTION_TYPE9_THRESHOLD_MULTIPLIER:-1.0}"
export ANTI_CHEAT_PROTECTION_TYPE15_THRESHOLD_MULTIPLIER="${ANTI_CHEAT_PROTECTION_TYPE15_THRESHOLD_MULTIPLIER:-1.0}"
export ANTI_CHEAT_PROTECTION_TYPE20_THRESHOLD_MULTIPLIER="${ANTI_CHEAT_PROTECTION_TYPE20_THRESHOLD_MULTIPLIER:-1.0}"
export ANTI_CHEAT_PROTECTION_TYPE22_THRESHOLD_MULTIPLIER="${ANTI_CHEAT_PROTECTION_TYPE22_THRESHOLD_MULTIPLIER:-1.0}"
export ANTI_CHEAT_PROTECTION_TYPE24_THRESHOLD_MULTIPLIER="${ANTI_CHEAT_PROTECTION_TYPE24_THRESHOLD_MULTIPLIER:-6.0}"

should_generate_ini="false"
if [ ! -f "$config_file" ]; then
  should_generate_ini="true"
elif [ "$FORCE_REGENERATE_CONFIG" = "true" ]; then
  should_generate_ini="true"
elif [ "$APPLY_ENV_TO_EXISTING" = "true" ]; then
  should_generate_ini="true"
fi

if [ "$should_generate_ini" = "true" ]; then
  echo "Generating server config: $config_file"
  envsubst < /home/steam/server/templates/settings.ini.template > "$config_file"
else
  echo "Using existing server config: $config_file"
fi

spawnpoints_file="${config_dir}/${SERVER_NAME}_spawnpoints.lua"
spawnregions_file="${config_dir}/${SERVER_NAME}_spawnregions.lua"

# Create server spawnpoints file if missing (do not overwrite by default)
if [ ! -f "$spawnpoints_file" ]; then
  cp /home/steam/server/templates/server_spawnpoints.lua.template "$spawnpoints_file"
fi

# Generate spawnregions from MAP env + on-disk maps, if needed/forced.
should_generate_lua="false"
if [ ! -f "$spawnregions_file" ]; then
  should_generate_lua="true"
elif [ "$FORCE_REGENERATE_LUA" = "true" ]; then
  should_generate_lua="true"
elif [ "$APPLY_ENV_TO_EXISTING" = "true" ]; then
  should_generate_lua="true"
fi

if [ "$should_generate_lua" = "true" ]; then
  echo "Generating server spawnregions: $spawnregions_file"
  echo "MAP env: $MAP"

  maps_root="/project-zomboid/media/maps"

  workshop_roots=()
  for base in /project-zomboid-config /project-zomboid /home/steam /root; do
    if [ -d "$base" ]; then
      while IFS= read -r d; do
        workshop_roots+=("$d")
      done < <(find "$base" -maxdepth 6 -type d -path "*/steamapps/workshop/content/108600" 2>/dev/null || true)
    fi
  done

  if [ "${#workshop_roots[@]}" -eq 0 ]; then
    echo "WARNING: no workshop content roots found (steamapps/workshop/content/108600). Workshop maps may be skipped." >&2
  else
    echo "Found workshop roots:"
    for r in "${workshop_roots[@]}"; do
      echo "  - $r"
    done
  fi

  tmp_index="$(mktemp)"
  trap 'rm -f "$tmp_index"' EXIT
  : > "$tmp_index"

  if [ "$WAIT_FOR_WORKSHOP_SECONDS" -gt 0 ] && [ "${#workshop_roots[@]}" -gt 0 ]; then
    echo "Waiting up to ${WAIT_FOR_WORKSHOP_SECONDS}s for workshop spawnpoints to appear..."
    end=$((SECONDS + WAIT_FOR_WORKSHOP_SECONDS))
    while [ $SECONDS -lt $end ]; do
      found_any="false"
      for r in "${workshop_roots[@]}"; do
        if find "$r" -type f -path "*/media/maps/*/spawnpoints.lua" -print -quit 2>/dev/null | grep -q .; then
          found_any="true"
          break
        fi
      done
      [ "$found_any" = "true" ] && break
      sleep 1
    done
  fi

  if [ "${#workshop_roots[@]}" -gt 0 ]; then
    for r in "${workshop_roots[@]}"; do
      find "$r" -type f -path "*/media/maps/*/spawnpoints.lua" 2>/dev/null \
        | awk -F'/media/maps/' '{print $2}' \
        | awk -F'/spawnpoints.lua' '{print $1}'
    done | sort -u > "$tmp_index"
  fi

  has_workshop_spawnpoints() {
    grep -Fxq "$1" "$tmp_index"
  }

  has_vanilla_spawnpoints() {
    [ -f "${maps_root}/$1/spawnpoints.lua" ]
  }

  IFS=';' read -r -a map_list <<< "${MAP}"

  {
    echo "function SpawnRegions()"
    echo "    return {"

    for raw in "${map_list[@]}"; do
      m="$(echo "$raw" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
      [ -z "$m" ] && continue

      if has_vanilla_spawnpoints "$m" || has_workshop_spawnpoints "$m"; then
        echo "        { name = \"${m}\", file = \"media/maps/${m}/spawnpoints.lua\" },"
      else
        echo "        -- Skipped (no spawnpoints.lua found): ${m}"
      fi
    done

    echo "        { name = \"${SERVER_NAME} (Server Spawn)\", serverfile = \"${SERVER_NAME}_spawnpoints.lua\" },"
    echo "    }"
    echo "end"
  } > "$spawnregions_file"
else
  echo "Using existing server spawnregions: $spawnregions_file"
fi
