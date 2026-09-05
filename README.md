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

## Detailed sports car (Studio-only dependency)

`src/server/DetailedCarSpawner.server.lua` clones a pre-built car model from
`ReplicatedStorage.CarAssets.DetailedSportsCarTemplate` instead of building
one from primitive parts. That template is **not** part of this repo -- it's
AI-generated MeshPart content (via Roblox Studio's Assistant), and Roblox
doesn't allow scripts to assign mesh/texture asset IDs at runtime, so it has
to exist as a real instance placed in the Studio place file. This means:

- The template only exists in this project's own Studio place; it won't be
  present if you sync this repo into a fresh place.
- If you need to recreate it: generate a segmented mesh in Studio's
  Assistant (parts: body, windshield, 4 wheels, spoiler, exhaust pipes),
  flatten it into a plain Model at that same path, done.
