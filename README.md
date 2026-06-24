# project-zomboid-server

Project Zomboid dedicated server image (steamcmd base + `gorcon` rcon-cli,
env-driven `settings.ini`/spawn LUA generation). Published to GitHub Container
Registry as `ghcr.io/rake-pro/project-zomboid-server`.

## CI

`.github/workflows/build.yml` builds and pushes on push to `main` (and builds,
without pushing, on PRs). It tags the linux/amd64 image:

- `ghcr.io/rake-pro/project-zomboid-server:sha-<short>` (immutable, pin this in GitOps)
- `ghcr.io/rake-pro/project-zomboid-server:latest`

Auth uses the built-in `GITHUB_TOKEN` (`packages: write`) - no registry secrets.

## Configuration

The server is configured entirely through environment variables consumed by
`scripts/compile-settings.sh` at startup (PVP, MAX_PLAYERS, MODS, WORKSHOP_ITEMS,
RCON_*, etc.). See that script for the full list and defaults.
