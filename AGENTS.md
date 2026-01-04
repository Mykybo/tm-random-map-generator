# AGENTS.md - Track Generator Extended

## Project Overview

Track Generator Extended is an OpenPlanet plugin for Trackmania 2020 that automatically generates random tracks in the map editor. The plugin uses weighted random selection to chain compatible track blocks together, creating playable tracks with checkpoints and a finish.

## Language & Framework

- **Language:** AngelScript (`.as` files)
- **Platform:** OpenPlanet (Trackmania plugin framework)
- **Optional Dependency:** MLHook (for item skin functionality)

## Project Structure

| File | Purpose |
|------|---------|
| `info.toml` | Plugin metadata (name, version, author, dependencies) |
| `menu.as` | UI rendering, settings, and plugin entry point |
| `RandomTrack.as` | Main `TrackGenerator` class - orchestrates track generation |
| `TrackSection.as` | Represents a single placed block in the track chain |
| `Block.as` | Block definition class, enums for connections (`Connections`), directions (`Directions`), tags (`Tags`), and surfaces |
| `BlockChoice.as` | Weight calculation and random block selection logic |
| `loadBlockData.as` | Loads block definitions from `BlockData.json` |
| `BlockData.json` | JSON database of all available blocks with their properties |
| `dataTracker.as` | Performance tracking and yield management during generation |
| `ItemSkins.as` | Optional MLHook integration for applying skins to placed items |

## Core Concepts

### Block Connections
Blocks connect via `Connections` enum values. A block's `endConnector` must match the next block's `startConnector` for valid placement. Connectors define road type (Tech, Dirt, Ice, etc.) and orientation (Flat, SlopeUp, TiltLeft, etc.).

### Weight System
Block selection uses weighted random choice:
- Base weights from `BlockData.json`
- Multipliers from settings (surface preferences, feature weights)
- Dynamic weights based on track state (checkpoint distance, track length, jump length)
- Weights are zeroed for invalid placements and reduced on failed attempts

### Track Generation Flow
1. `TrackGenerator.Start()` initializes with a start block
2. Loop: `TrackSection` calculates weights → `ChooseNextBlock()` selects next → attempt placement
3. If placement fails, weight is reduced; if total weight too low, undo and try different path
4. Continue until finish block is successfully placed

### Tags System
Blocks have `Tags` that affect weight calculation:
- `Checkpoint`, `Finish` - waypoint types
- `JumpContinue`, `DropJumpStart` - jump mechanics
- `CarStadium`, `CarSnow`, `CarRally`, `CarDesert` - car switchers
- Surface tags for weight multipliers

## Coding Conventions

### Naming
- Classes: PascalCase (`TrackSection`, `TrackGenerator`)
- Enums: PascalCase (`Connections`, `Directions`, `Tags`)
- Functions: PascalCase (`GetWeights`, `ChooseNextBlock`)
- Variables: camelCase (`nextPosition`, `blockIndex`)
- Settings: PascalCase with `[Setting]` attribute

### AngelScript Specifics
- Use `@` for handles (references): `Block@ thisBlock`
- Null checks: `if (obj is null)` or `if (!(obj is null))`
- Cast with `cast<Type>(value)`
- Arrays: `array<Type>` with methods like `InsertLast`, `Find`, `Length`
- Coroutines via `yield()` and `startnew(CoroutineFunc(...))`

### API Usage
- `CGameEditorPluginMap` - map editor plugin interface
- `CGameCtnEditorFree` - free editor access
- `GetApp()` - get application instance
- `UI::ShowNotification()` - user notifications

## Settings

Settings are defined in `menu.as` with `[Setting]` attributes:
```angelscript
[Setting category="General" name="Average track length" min=0]
uint FinishDistance = 70;
```

Key setting categories:
- **General:** Track length, checkpoint distance, error handling, special modes
  - **Wood Only Mode:** When enabled, generates tracks using only wood (snow road) blocks with snow road start blocks, excludes car gates and random boosters, and places a reactor down effect after the start and each checkpoint.
  - **Chaotic Wood Connections:** When enabled, allows wood blocks to connect in any orientation (flat to slope, tilt to flat, etc.) for wild track layouts.
- **Surface:** Weights for each road/platform surface type
- **Features:** Weights for turns, slopes, loops, etc.
- **Color:** Block color weights

## Debugging

Debug modes controlled by global flags:
- `debugStepMode` - step through generation with T key
- `debugLastBlock` - debug block with G key
- `debugPrint` - verbose console output

## Adding New Blocks

1. Add block definition to `BlockData.json` with:
   - `NameID` - game block/macroblock name
   - `startConnector`, `endConnector` - connection types
   - `endPosition` - relative end position (int3)
   - `Direction` - rotation change
   - `tags` - array of tag indices
   - `length` - approximate block length

2. If new connection type needed, add to `Connections` enum in `Block.as`

3. If new tag needed, add to `Tags` enum and weight logic in `BlockChoice.as`

## Build & Run

This is an OpenPlanet plugin - place in the OpenPlanet plugins folder:
- Windows: `%USERPROFILE%\OpenplanetNext\Plugins\`
- The plugin loads automatically when Trackmania starts

No compilation needed - AngelScript is interpreted at runtime.
