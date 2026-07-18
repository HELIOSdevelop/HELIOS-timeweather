Config = {}

Config.TimeSpeed = 2

Config.StartTime = {
    year   = 2025,
    month  = 6,
    day    = 15,
    hour   = 8,
    minute = 0,
}

Config.SyncInterval = 10
Config.WeatherChangeIntervalMin = 45

Config.WeatherTransitions = {
    EXTRASUNNY = { EXTRASUNNY = 40, CLEAR = 35, CLOUDS = 20, SMOG = 5 },
    CLEAR      = { CLEAR = 40, EXTRASUNNY = 15, CLOUDS = 30, SMOG = 10, FOGGY = 5 },
    CLOUDS     = { CLOUDS = 30, CLEAR = 20, SMOG = 20, OVERCAST = 15, FOGGY = 10, RAIN = 5 },
    SMOG       = { SMOG = 30, CLOUDS = 25, FOGGY = 20, CLEAR = 15, OVERCAST = 10 },
    FOGGY      = { FOGGY = 30, SMOG = 20, CLOUDS = 20, OVERCAST = 15, CLEAR = 15 },
    OVERCAST   = { OVERCAST = 25, RAIN = 30, CLOUDS = 20, FOGGY = 10, CLEAR = 10, THUNDER = 5 },
    RAIN       = { RAIN = 30, THUNDER = 25, OVERCAST = 20, CLOUDS = 10, CLEARING = 10, CLEAR = 5 },
    THUNDER    = { THUNDER = 25, RAIN = 30, OVERCAST = 15, CLEARING = 20, CLEAR = 10 },
    CLEARING   = { CLEARING = 20, CLOUDS = 25, CLEAR = 30, SMOG = 15, EXTRASUNNY = 10 },
    NEUTRAL    = { CLEAR = 40, CLOUDS = 30, SMOG = 20, FOGGY = 10 },
    SNOW       = { SNOW = 40, SNOWLIGHT = 25, BLIZZARD = 15, OVERCAST = 10, CLEARING = 10 },
    SNOWLIGHT  = { SNOWLIGHT = 30, SNOW = 30, BLIZZARD = 10, CLOUDS = 20, CLEARING = 10 },
    BLIZZARD   = { BLIZZARD = 20, SNOW = 35, SNOWLIGHT = 25, OVERCAST = 20 },
    XMAS       = { XMAS = 30, SNOW = 25, SNOWLIGHT = 20, BLIZZARD = 5, CLOUDS = 20 },
    HALLOWEEN  = { HALLOWEEN = 30, SMOG = 20, FOGGY = 25, CLOUDS = 15, THUNDER = 10 },
}

-- ── Access Control ─────────────────────────────────────────────────
-- Set disable = true to allow everyone.
-- If all lists are empty, everyone gets access.
-- If any list has entries, at least one configured check must pass.
Config.Access = {
    disable = true,

    -- Identifier-based access (steam, license, ip, etc.)
    identifiers = {
        -- 'steam:12345678',
    },

    -- ESX group access (requires es_extended)
    esx_groups = {
        -- 'admin',
        -- 'superadmin',
    },

    -- QBCore group access (requires qb-core)
    qb_groups = {
        -- 'admin',
        -- 'god',
    },
}

Config.WeatherHourModifiers = {
    [0]  = { FOGGY = 2.5, SMOG = 1.8 },
    [1]  = { FOGGY = 2.5, SMOG = 1.8 },
    [2]  = { FOGGY = 2.0, SMOG = 1.5 },
    [3]  = { FOGGY = 2.0 },
    [4]  = { FOGGY = 2.0 },
    [5]  = { FOGGY = 1.5, CLOUDS = 1.2 },
    [6]  = { FOGGY = 1.2, CLEAR = 1.3 },
    [7]  = { CLEAR = 1.3, EXTRASUNNY = 1.2 },
    [8]  = { EXTRASUNNY = 1.3, CLEAR = 1.2 },
    [9]  = { EXTRASUNNY = 1.3 },
    [10] = { EXTRASUNNY = 1.3 },
    [11] = { EXTRASUNNY = 1.5 },
    [12] = { EXTRASUNNY = 1.5, CLEAR = 1.2 },
    [13] = { EXTRASUNNY = 1.5, CLEAR = 1.2 },
    [14] = { EXTRASUNNY = 1.3, CLEAR = 1.2, THUNDER = 1.3 },
    [15] = { EXTRASUNNY = 1.2, THUNDER = 1.5 },
    [16] = { RAIN = 1.3, THUNDER = 1.5 },
    [17] = { RAIN = 1.3, CLOUDS = 1.2, FOGGY = 1.2 },
    [18] = { CLOUDS = 1.3, SMOG = 1.3, FOGGY = 1.5 },
    [19] = { SMOG = 1.5, FOGGY = 2.0 },
    [20] = { SMOG = 1.8, FOGGY = 2.0 },
    [21] = { SMOG = 2.0, FOGGY = 2.5 },
    [22] = { SMOG = 2.0, FOGGY = 2.5 },
    [23] = { FOGGY = 2.5, SMOG = 2.0 },
}
