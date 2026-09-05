# RobloxProject

A Roblox game built with [Rojo](https://rojo.space/), syncing Luau scripts from this repo into Roblox Studio.

## Structure

- `src/server` - server-side scripts (`ServerScriptService`)
- `src/client` - client-side scripts (`StarterPlayerScripts`)
- `src/shared` - modules shared between client and server (`ReplicatedStorage/Shared`)
- `default.project.json` - Rojo project configuration

## Getting started

1. Install [Rojo](https://rojo.space/docs/v7/getting-started/installation/) (CLI + the Roblox Studio plugin).
2. From this folder, run `rojo serve`.
3. In Roblox Studio, connect using the Rojo plugin to sync files in.
