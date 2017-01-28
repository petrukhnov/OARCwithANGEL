-- config.lua
-- Dec 2016
-- Configuration Options

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

WELCOME_MSG = "Welcome to 100+ mods server. "
GAME_MODE_MSG = "Enjoy your stay, and join us at discord."
MODULES_ENABLED = "Mods enabled: ALL."

WELCOME_MSG_TITLE = "OARC with Angel ores."
WELCOME_MSG1 = "Aliens not cleared for solo spawns."
WELCOME_MSG2 = "Please join the main forces, and help us to launch satelite."

OTHER_MSG1 = "Server will will not be reseted even after satelite launch."
OTHER_MSG2 = "Most probably it will stay for 3 month after 0.15 is out."


WELCOME_MSG3 = "Solo spawn will kill you in 95%. Join main forces!"
WELCOME_MSG4 = "Silo is randomly spawned 500 chunks away."
WELCOME_MSG5 = "discord: https://discord.gg/JC2Jk"
WELCOME_MSG6 = " " 


SPAWN_MSG1 = "Solo spawn will kill you in 95%. Join main forces!"
SPAWN_MSG2 = "If you managed to find good spot for solo, 9 friends could join you."
SPAWN_MSG3 = "Solo spawn will kill you in 95%. Join main forces!"

--------------------------------------------------------------------------------
-- Module Enables
-- These enables are not fully tested! For example, disable separate spawns
-- will probably break the frontier rocket silo mode
--------------------------------------------------------------------------------

-- Frontier style rocket silo mode
FRONTIER_ROCKET_SILO_MODE = true

-- Separate spawns
ENABLE_SEPARATE_SPAWNS = true

-- Enable Undecorator
ENABLE_UNDECORATOR = false

--------------------------------------------------------------------------------
-- Spawn Options
--------------------------------------------------------------------------------

---------------------------------------
-- Distance Options
---------------------------------------
-- Near Distance in chunks
NEAR_MIN_DIST = 25 --50
NEAR_MAX_DIST = 100 --125
                   --
-- Far Distance in chunks
FAR_MIN_DIST = 100 --50
FAR_MAX_DIST = 250 --125
                   --
---------------------------------------
-- Resource Options
---------------------------------------
WATER_SPAWN_OFFSET_X = -4
WATER_SPAWN_OFFSET_Y = -38
WATER_SPAWN_LENGTH = 8

-- Start resource amounts
START_AMOUNT = 1500

-- Start resource shape
-- If this is true, it will be a circle
-- If false, it will be a square
ENABLE_RESOURCE_SHAPE_CIRCLE = true

-- Start resource position and size
-- Position is relative to player starting location
START_RESOURCE_POS_X = -27
START_RESOURCE_POS_Y = -34
START_RESOURCE_SIZE = 12

-- Force the land area circle at the spawn to be fully grass
ENABLE_SPAWN_FORCE_GRASS = false

---------------------------------------
-- Safe Spawn Area Options
---------------------------------------

-- Safe area has no aliens
-- +/- this in x and y direction
SAFE_AREA_TILE_DIST = CHUNK_SIZE*12

-- Warning area has reduced aliens
-- +/- this in x and y direction
WARNING_AREA_TILE_DIST = CHUNK_SIZE*20

-- 1 : X (spawners alive : spawners destroyed) in this area
WARN_AREA_REDUCTION_RATIO = 15

-- Create a circle of land area for the spawn
ENFORCE_LAND_AREA_TILE_DIST = 55


---------------------------------------
-- Other Forces/Teams Options
---------------------------------------

-- I am not currently implementing other teams. It gets too complicated.
-- Enable if people can join their own teams
-- ENABLE_OTHER_TEAMS = false

-- Main force is what default players join
MAIN_FORCE = "main_force"

-- Enable if people can spawn at the main base
ENABLE_DEFAULT_SPAWN = true

-- Enable if people can allow others to join their base
ENABLE_SHARED_SPAWNS = true
MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN = 10


---------------------------------------
-- Special Action Cooldowns
---------------------------------------
RESPAWN_COOLDOWN_IN_MINUTES = 60
RESPAWN_COOLDOWN_TICKS = TICKS_PER_MINUTE * RESPAWN_COOLDOWN_IN_MINUTES

-- Require playes to be online for at least 5 minutes
-- Else their character is removed and their spawn point is freed up for use
MIN_ONLIME_TIME_IN_MINUTES = 5
MIN_ONLINE_TIME = TICKS_PER_MINUTE * MIN_ONLIME_TIME_IN_MINUTES


-- Allow players to choose another spawn in the first 10 minutes
-- This does not allow creating a new spawn point. Only joining other players.
-- SPAWN_CHANGE_GRACE_PERIOD_IN_MINUTES = 10
-- SPAWN_GRACE_TIME = TICKS_PER_MINUTE * SPAWN_CHANGE_GRACE_PERIOD_IN_MINUTES

--------------------------------------------------------------------------------
-- Frontier Rocket Silo Options
--------------------------------------------------------------------------------

SILO_CHUNK_DISTANCE_X = 500
SILO_DISTANCE_X = SILO_CHUNK_DISTANCE_X*CHUNK_SIZE + CHUNK_SIZE/2
SILO_DISTANCE_Y = 16

-- Should be in the middle of a chunk
SILO_POSITION = {x = SILO_DISTANCE_X, y = SILO_DISTANCE_Y}

-- If this is enabled, the static position is ignored.
ENABLE_RANDOM_SILO_POSITION = true

-------------------------------------------------------------------------------
-- DEBUG
--------------------------------------------------------------------------------

-- DEBUG prints for me
global.oarcDebugEnabled = false