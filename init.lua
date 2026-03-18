-- Blood Moon Mod
-- Random blood moon nights with buffed mobs and increased spawning

local S = core.get_translator("bloodmoon")

-- =============================================================================
-- Configuration
-- =============================================================================

local BLOODMOON_CHANCE   = 3       -- 1 in N nights triggers blood moon
local DAMAGE_MULT        = 2.0     -- double damage
local SPEED_MULT         = 2.0     -- double speed

-- =============================================================================
-- State (persisted via mod storage)
-- =============================================================================

local storage = core.get_mod_storage()
local bloodmoon_active = storage:get_int("active") == 1
local last_night = false
local night_count = storage:get_int("night_count")

-- =============================================================================
-- Global API: other mods can check if blood moon is active
-- =============================================================================

bloodmoon = {}

function bloodmoon.is_active()
    return bloodmoon_active
end

function bloodmoon.get_damage_mult()
    return bloodmoon_active and DAMAGE_MULT or 1.0
end

function bloodmoon.get_speed_mult()
    return bloodmoon_active and SPEED_MULT or 1.0
end

-- =============================================================================
-- Sky effects
-- =============================================================================

local function set_bloodmoon_sky(player)
    player:set_sky({
        type = "regular",
        sky_color = {
            night_sky = "#330000",
            night_horizon = "#550505",
            fog_moon_tint = "#ff2200",
            fog_sun_tint = "#ff2200",
        },
        clouds = true,
    })
    player:set_moon({
        texture = "bloodmoon_moon.png",
        scale = 2.0,
    })
    player:set_stars({
        star_color = "#ff444430",
    })
end

local function reset_sky(player)
    player:set_sky({
        type = "regular",
        sky_color = {
            day_sky = "#61b5f5",
            day_horizon = "#90d3f6",
            dawn_sky = "#b4bafa",
            dawn_horizon = "#bac1f0",
            night_sky = "#006bff",
            night_horizon = "#4090ff",
            fog_sun_tint = "#f47d1d",
            fog_moon_tint = "#7f99cc",
        },
        clouds = true,
    })
    player:set_moon({
        texture = "",
        scale = 1,
    })
    player:set_stars({
        star_color = "#ebebff69",
    })
end

-- =============================================================================
-- Activate / Deactivate
-- =============================================================================

local function activate_bloodmoon()
    bloodmoon_active = true
    storage:set_int("active", 1)

    for _, player in ipairs(core.get_connected_players()) do
        set_bloodmoon_sky(player)
        core.chat_send_player(player:get_player_name(),
            core.colorize("#ff2200", "*** BLOOD MOON RISES ***"))
    end

    -- Play thunder sound
    for _, player in ipairs(core.get_connected_players()) do
        local pos = player:get_pos()
        if pos then
            core.sound_play("default_cool_lava", {
                pos = pos, gain = 1.5, max_hear_distance = 100,
            }, true)
        end
    end

    core.log("action", "[bloodmoon] Blood moon activated!")
end

local function deactivate_bloodmoon()
    if not bloodmoon_active then return end
    bloodmoon_active = false
    storage:set_int("active", 0)

    for _, player in ipairs(core.get_connected_players()) do
        reset_sky(player)
        core.chat_send_player(player:get_player_name(),
            core.colorize("#aaaaff", "The blood moon fades..."))
    end

    core.log("action", "[bloodmoon] Blood moon deactivated.")
end

-- =============================================================================
-- Day/night cycle detection
-- =============================================================================

local function check_night()
    local tod = core.get_timeofday()
    if not tod then return false end
    return tod < 0.23 or tod > 0.77
end
local first_step = true

core.register_globalstep(function(dtime)
    local is_night = check_night()

    -- First step: sync last_night so we don't false-trigger
    if first_step then
        first_step = false
        last_night = is_night
        -- Re-apply sky if blood moon was saved as active
        if bloodmoon_active and is_night then
            for _, player in ipairs(core.get_connected_players()) do
                set_bloodmoon_sky(player)
            end
        elseif not is_night then
            -- It's day now, clear stale blood moon
            bloodmoon_active = false
            storage:set_int("active", 0)
        end
        return
    end

    -- Detect transition to night
    if is_night and not last_night then
        night_count = night_count + 1
        storage:set_int("night_count", night_count)
        if math.random(1, BLOODMOON_CHANCE) == 1 then
            activate_bloodmoon()
        end
    end

    -- Detect transition to day
    if not is_night and last_night then
        deactivate_bloodmoon()
    end

    last_night = is_night

end)

-- =============================================================================
-- Player join/leave during blood moon
-- =============================================================================

core.register_on_joinplayer(function(player)
    if bloodmoon_active then
        set_bloodmoon_sky(player)
        core.chat_send_player(player:get_player_name(),
            core.colorize("#ff2200", "*** A BLOOD MOON IS ACTIVE ***"))
    end
end)

core.register_on_leaveplayer(function(player)
    reset_sky(player)
end)

core.log("action", "[bloodmoon] Loaded!")
