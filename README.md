# HELIOS Time & Weather

Global time & weather management system for FiveM with a built-in NUI admin dashboard.

## Features

- Server-authoritative time & weather synced to all players
- Automatic weather transitions based on configurable weighted probability matrix
- Hour-based weather modifiers (fog at night, sun at midday, etc.)
- Admin dashboard (NUI) — open with `/time`
- Freeze time, adjust speed (0.1x – 5x), set exact time or weather
- Access control via identifiers, ESX groups, or QBCore groups
- Resource exports for other scripts

## Installation

1. Place `HELIOS-timeweather` in your `resources` folder.
2. Add `ensure HELIOS-timeweather` to your `server.cfg`.

## Configuration

All settings are in `config.lua`:

| Setting | Default | Description |
|---|---|---|
| `Config.TimeSpeed` | `2` | Minutes advanced per real second (higher = faster) |
| `Config.StartTime` | June 15, 2025 08:00 | Initial date/time when the server starts |
| `Config.SyncInterval` | `10` | Seconds between sync broadcasts |
| `Config.WeatherChangeIntervalMin` | `45` | Minimum in-game minutes between weather changes |
| `Config.WeatherTransitions` | — | Weighted transition matrix for 15 weather types |
| `Config.WeatherHourModifiers` | — | Per-hour multipliers that influence weather probabilities |
| `Config.Access` | disabled | Access control (identifiers, ESX groups, QBCore groups) |

## Usage

- `/time` — Opens the admin dashboard (requires access)
- Admin dashboard allows you to freeze time, adjust speed, set time/weather, and see current state

## Exports

### Server Exports

```lua
exports['HELIOS-timeweather']:GetClock()
-- Returns: { year, month, day, hour, minute }

exports['HELIOS-timeweather']:GetWeather()
-- Returns: current weather type string

exports['HELIOS-timeweather']:SetWeather('RAIN')
-- Sets the global weather, returns true/false

exports['HELIOS-timeweather']:SetClockTime(14, 30)
-- Sets the server clock to 14:30
```

### Client Exports

```lua
exports['HELIOS-timeweather']:GetWeather()
-- Returns: current weather type string on this client
```

## Dependencies

- **FXServer** (cerulean) with **Lua 5.4**
- **gta5** runtime
- Optional: `es_extended` or `qb-core` for group-based access control

## Support

- [Tebex Store](https://helios-dev.tebex.io)
- [Support Discord](https://discord.gg/bpk2z3RHVQ)
- [Partnered Hosting](https://heliosnode.nl)
