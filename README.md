# project-zomboid-server

Project Zomboid dedicated server (SteamCMD-based, with `gorcon` rcon-cli and
env-driven server config / spawn LUA generation).

```
ghcr.io/rake-pro/project-zomboid-server
```

## Run

```
docker run -d --name pz \
  -p 16261:16261/udp -p 16262:16262/udp -p 27015:27015/tcp \
  -e SERVER_NAME=pzserver \
  -e ADMIN_PASSWORD=change-me \
  -e RCON_PASSWORD=change-me \
  -e MAX_PLAYERS=16 \
  -v /path/to/data:/project-zomboid \
  -v /path/to/config:/project-zomboid-config \
  ghcr.io/rake-pro/project-zomboid-server:latest
```

On first boot the server installs via SteamCMD and generates
`<SERVER_NAME>.ini` plus the spawn LUA from the environment. Set
`APPLY_ENV_TO_EXISTING=true` to re-apply env to an existing config, or
`FORCE_REGENERATE_CONFIG=true` to rewrite it.

## Configuration

Configuration is entirely environment-driven; the full list (with defaults)
lives in `scripts/compile-settings.sh`. Common ones:

| Variable | Default | Purpose |
| --- | --- | --- |
| `SERVER_NAME` | `pzserver` | Server/config name. |
| `ADMIN_USERNAME` / `ADMIN_PASSWORD` | `admin` | In-game admin account. |
| `PASSWORD` | (empty) | Join password (empty = open). |
| `MAX_PLAYERS` | `32` | Player cap. |
| `PVP` | `true` | Enable PvP. |
| `PUBLIC` / `PUBLIC_NAME` | `false` | List on the public server browser. |
| `MODS` / `WORKSHOP_ITEMS` | (empty) | Semicolon-separated mod IDs / Steam Workshop item IDs. |
| `MAP` | `Muldraugh, KY` | Map load order. |
| `RCON_PORT` / `RCON_PASSWORD` | `27015` / (empty) | RCON endpoint (set a password to enable). |
| `APPLY_ENV_TO_EXISTING` / `FORCE_REGENERATE_CONFIG` | `false` | Reapply / regenerate config on boot. |

## Ports

| Port | Use |
| --- | --- |
| `16261/udp` | Game (default port). |
| `16262/udp` | Player/direct connection port. |
| `27015/tcp` | RCON (when `RCON_PASSWORD` is set). |

## Volumes

| Path | Use |
| --- | --- |
| `/project-zomboid` | Game install + world saves (persist this). |
| `/project-zomboid-config` | Server config (`Server/<SERVER_NAME>.ini`, spawn LUA). |
