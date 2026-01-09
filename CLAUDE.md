# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Track Generator Extended is an OpenPlanet plugin for Trackmania 2020 that automatically generates random tracks in the map editor. The plugin uses weighted random selection to chain compatible track blocks together.

**Language:** AngelScript (`.as` files)
**Platform:** OpenPlanet (Trackmania plugin framework)
**Optional Dependencies:** MLHook (item skins), Camera

## Build & Run

No compilation needed - AngelScript is interpreted at runtime. Place in the OpenPlanet plugins folder:
- Windows: `%USERPROFILE%\OpenplanetNext\Plugins\`
- Plugin loads automatically when Trackmania starts with OpenPlanet

## Architecture

### File Responsibilities

| File | Purpose |
|------|---------|
| `menu.as` | UI rendering, settings declarations, plugin entry point |
| `RandomTrack.as` | `TrackGenerator` class - orchestrates track generation loop |
| `TrackSection.as` | Represents a placed block in the track chain, calculates next block weights |
| `Block.as` | Block definition class, `Connections`/`Directions`/`Tags` enums |
| `BlockChoice.as` | Weight calculation and random block selection logic |
| `loadBlockData.as` | Loads block definitions from `BlockData.json` |
| `BlockData.json` | JSON database of all blocks with properties |

### Track Generation Flow

1. `TrackGenerator.Start()` initializes with a start block
2. Loop: `TrackSection` calculates weights → `ChooseNextBlock()` selects next → attempt placement
3. If placement fails, weight is reduced; if total weight too low, undo and try different path
4. Continue until finish block is successfully placed

### Block Connection System

Blocks connect via `Connections` enum values. A block's `endConnector` must match the next block's `startConnector`. Connectors define road type (Tech, Dirt, Ice) and orientation (Flat, SlopeUp, TiltLeft).

### Weight System

Block selection uses weighted random choice with:
- Base weights from `BlockData.json`
- Setting multipliers (surface preferences, feature weights)
- Dynamic weights based on track state (checkpoint distance, track length)
- Weights zeroed for invalid placements, reduced on failed attempts

## Coding Conventions

### AngelScript Syntax

- Handles (references): `Block@ thisBlock`
- Null checks: `if (obj is null)` or `if (!(obj is null))`
- Casting: `cast<Type>(value)`
- Arrays: `array<Type>` with `InsertLast`, `Find`, `Length`
- Coroutines: `yield()` and `startnew(CoroutineFunc(...))`

### Naming

- Classes/Enums/Functions: PascalCase
- Variables: camelCase
- Settings: PascalCase with `[Setting]` attribute

## Adding Settings

When adding a new setting, you MUST do TWO things:

1. **Declare the setting** at file scope with `[Setting]` attribute:
```angelscript
[Setting category="General" name="My Feature" description="Enable my feature"]
bool MyFeatureSetting = false;
```

2. **Render in UI** in `RenderInterface()` function in `menu.as`:
```angelscript
MyFeatureSetting = UI::Checkbox('##MyFeatureSetting', MyFeatureSetting);
UI::SameLine();
UI::TextWrapped('My Feature - description of what it does.');
```

UI input types: `UI::Checkbox()` for bool, `UI::InputInt()` for int, `UI::InputFloat()` for float, `UI::BeginCombo()`/`UI::Selectable()` for enums.

## Adding New Blocks

1. Add block definition to `BlockData.json` with: `NameID`, `startConnector`, `endConnector`, `endPosition`, `Direction`, `tags`, `length`
2. If new connection type needed, add to `Connections` enum in `Block.as`
3. If new tag needed, add to `Tags` enum and weight logic in `BlockChoice.as`

## Debugging

Debug flags in code:
- `debugStepMode` - step through generation with T key
- `debugLastBlock` - debug block with G key
- `debugPrint` - verbose console output
