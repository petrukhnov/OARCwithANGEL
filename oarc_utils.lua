-- oarc_utils.lua
-- Nov 2016
-- 
-- My general purpose utility functions for factorio
-- Also contains some constants and gui styles


--------------------------------------------------------------------------------
-- Useful constants
--------------------------------------------------------------------------------
CHUNK_SIZE = 32
MAX_FORCES = 64
TICKS_PER_SECOND = 60
TICKS_PER_MINUTE = TICKS_PER_SECOND * 60
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- GUI Label Styles
--------------------------------------------------------------------------------
my_fixed_width_style = {
    minimal_width = 450,
    maximal_width = 450
}
my_label_style = {
    minimal_width = 450,
    maximal_width = 450,
    maximal_height = 10,
    font_color = {r=1,g=1,b=1}
}
my_note_style = {
    minimal_width = 450,
    maximal_height = 10,
    font = "default-small-semibold",
    font_color = {r=1,g=0.5,b=0.5}
}
my_warning_style = {
    minimal_width = 450,
    maximal_width = 450,
    maximal_height = 10,
    font_color = {r=1,g=0.1,b=0.1}
}
my_spacer_style = {
    minimal_width = 450,
    maximal_width = 450,
    minimal_height = 20,
    maximal_height = 20,
    font_color = {r=0,g=0,b=0}
}
my_small_button_style = {
    font = "default-small-semibold"
}
my_color_red = {r=1,g=0.1,b=0.1}


--------------------------------------------------------------------------------
-- General Helper Functions
--------------------------------------------------------------------------------

-- Print debug only to me while testing.
function DebugPrint(msg)

end

-- Prints flying text.
-- Color is optional
function FlyingText(msg, pos, color) 
    local surface = game.surfaces["nauvis"]
    if color == nil then
        surface.create_entity({ name = "flying-text", position = pos, text = msg })
    else
        surface.create_entity({ name = "flying-text", position = pos, text = msg, color = color })
    end
end

-- Broadcast messages to all connected players
function SendBroadcastMsg(msg)
    for name,player in pairs(game.connected_players) do
        player.print(msg)
    end
end

-- Useful for displaying game time in mins:secs format
function formattime(ticks)
  local seconds = ticks / 60
  local minutes = math.floor((seconds)/60)
  local seconds = math.floor(seconds - 60*minutes)
  return string.format("%dm:%02ds", minutes, seconds)
end

-- Simple function to get total number of items in table
function TableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- Chart area for a force
function ChartArea(force, position, chunkDist)
    force.chart(game.surfaces["nauvis"],
        {{position.x-(CHUNK_SIZE*chunkDist),
        position.y-(CHUNK_SIZE*chunkDist)},
        {position.x+(CHUNK_SIZE*chunkDist),
        position.y+(CHUNK_SIZE*chunkDist)}})
end

-- Check if given position is in area bounding box
function CheckIfInArea(point, area)
    if ((point.x >= area.left_top.x) and (point.x <= area.right_bottom.x)) then
        if ((point.y >= area.left_top.y) and (point.y <= area.right_bottom.y)) then
            return true
        end
    end
    return false
end

-- Ceasefire
-- All forces are always neutral
function SetCeaseFireBetweenAllForces()
    for name,team in pairs(game.forces) do
        if name ~= "neutral" and name ~= "enemy" then
            for x,y in pairs(game.forces) do
                if x ~= "neutral" and x ~= "enemy" then
                    team.set_cease_fire(x,true)
                end
            end
        end
    end
end

-- Undecorator
function RemoveDecorationsArea(surface, area)
    for _, entity in pairs(surface.find_entities_filtered{area = area, type="decorative"}) do
        entity.destroy()
    end
end

-- Remove fish
function RemoveFish(surface, area)
    for _, entity in pairs(surface.find_entities_filtered{area = area, type="fish"}) do
        entity.destroy()
    end
end

-- Apply a style option to a GUI
function ApplyStyle (guiIn, styleIn)
    for k,v in pairs(styleIn) do
        guiIn.style[k]=v
    end 
end

-- Get a random 1 or -1
function RandomNegPos()
    if (math.random(0,1) == 1) then
        return 1
    else
        return -1
    end
end

-- Create a random direction vector to look in
function GetRandomVector()
    local randVec = {x=0,y=0}   
    while ((randVec.x == 0) and (randVec.y == 0)) do
        randVec.x = math.random(-3,3)
        randVec.y = math.random(-3,3)
    end
    DebugPrint("direction: x=" .. randVec.x .. ", y=" .. randVec.y)
    return randVec
end

-- Check for ungenerated chunks around a specific chunk
-- +/- chunkDist in x and y directions
function IsChunkAreaUngenerated(chunkPos, chunkDist)
    for x=-chunkDist, chunkDist do
        for y=-chunkDist, chunkDist do
            local checkPos = {x=chunkPos.x+x,
                             y=chunkPos.y+y}
            if (game.surfaces["nauvis"].is_chunk_generated(checkPos)) then
                return false
            end
        end
    end
    return true
end

-- Clear out enemies around an area with a certain distance
function ClearNearbyEnemies(player, safeDist)
    local safeArea = {left_top=
                    {x=player.position.x-safeDist,
                     y=player.position.y-safeDist},
                  right_bottom=
                    {x=player.position.x+safeDist,
                     y=player.position.y+safeDist}}

    for _, entity in pairs(player.surface.find_entities_filtered{area = safeArea, force = "enemy"}) do
        entity.destroy()
    end
end

-- Function to find coordinates of ungenerated map area in a given direction
-- starting from the center of the map
function FindMapEdge(directionVec)
    local position = {x=0,y=0}
    local chunkPos = {x=0,y=0}

    -- Keep checking chunks in the direction of the vector
    while(true) do
            
        -- Set some absolute limits.
        if ((math.abs(chunkPos.x) > 1000) or (math.abs(chunkPos.y) > 1000)) then
            break
        
        -- If chunk is already generated, keep looking
        elseif (game.surfaces["nauvis"].is_chunk_generated(chunkPos)) then
            chunkPos.x = chunkPos.x + directionVec.x
            chunkPos.y = chunkPos.y + directionVec.y
        
        -- Found a possible ungenerated area
        else
            
            chunkPos.x = chunkPos.x + directionVec.x
            chunkPos.y = chunkPos.y + directionVec.y

            -- Check there are no generated chunks in a 10x10 area.
            if IsChunkAreaUngenerated(chunkPos, 5) then
                position.x = (chunkPos.x*CHUNK_SIZE) + (CHUNK_SIZE/2)
                position.y = (chunkPos.y*CHUNK_SIZE) + (CHUNK_SIZE/2)
                break
            end
        end
    end

    DebugPrint("spawn: x=" .. position.x .. ", y=" .. position.y)
    return position
end

-- Find random coordinates within a given distance away
-- maxTries is the recursion limit basically.
function FindUngeneratedCoordinates(minDistChunks, maxDistChunks)
    local position = {x=0,y=0}
    local chunkPos = {x=0,y=0}

    local maxTries = 100
    local tryCounter = 0

    local minDistSqr = minDistChunks^2
    local maxDistSqr = maxDistChunks^2

    while(true) do
        chunkPos.x = math.random(0,maxDistChunks) * RandomNegPos()
        chunkPos.y = math.random(0,maxDistChunks) * RandomNegPos()

        local distSqrd = chunkPos.x^2 + chunkPos.y^2

        -- Enforce a max number of tries
        tryCounter = tryCounter + 1
        if (tryCounter > maxTries) then
            DebugPrint("FindUngeneratedCoordinates - Max Tries Hit!")
            break
 
        -- Check that the distance is within the min,max specified
        elseif ((distSqrd < minDistSqr) or (distSqrd > maxDistSqr)) then
            -- Keep searching!
        
        -- Check there are no generated chunks in a 10x10 area.
        elseif IsChunkAreaUngenerated(chunkPos, 5) then
            position.x = (chunkPos.x*CHUNK_SIZE) + (CHUNK_SIZE/2)
            position.y = (chunkPos.y*CHUNK_SIZE) + (CHUNK_SIZE/2)
            break -- SUCCESS
        end       
    end

    DebugPrint("spawn: x=" .. position.x .. ", y=" .. position.y)
    return position
end

-- Enforce a circle of land, also adds trees in a ring around the area.
function CreateCropCircle(surface, centerPos, chunkArea, tileRadius)

    local tileRadSqr = tileRadius^2

    local dirtTiles = {}
    for i=chunkArea.left_top.x,chunkArea.right_bottom.x,1 do
        for j=chunkArea.left_top.y,chunkArea.right_bottom.y,1 do

            -- This ( X^2 + Y^2 ) is used to calculate if something
            -- is inside a circle area.
            local distVar = math.floor((centerPos.x - i)^2 + (centerPos.y - j)^2)

            -- Fill in all unexpected water in a circle
            if (distVar < tileRadSqr) then
                if (surface.get_tile(i,j).collides_with("water-tile") or ENABLE_SPAWN_FORCE_GRASS) then
                    table.insert(dirtTiles, {name = "grass", position ={i,j}})
                end
            end

            -- Create a circle of trees around the spawn point.
            if ((distVar < tileRadSqr-200) and 
                (distVar > tileRadSqr-300)) then
                surface.create_entity({name="tree-01", amount=1, position={i, j}})
            end
        end
    end

    surface.set_tiles(dirtTiles)
end

-- COPIED FROM jvmguy!
-- Enforce a square of land, with a tree border
-- this is equivalent to the CreateCropCircle code
function CreateCropOctagon(surface, centerPos, chunkArea, tileRadius)

    local dirtTiles = {}
    for i=chunkArea.left_top.x,chunkArea.right_bottom.x,1 do
        for j=chunkArea.left_top.y,chunkArea.right_bottom.y,1 do

            local distVar1 = math.floor(math.max(math.abs(centerPos.x - i), math.abs(centerPos.y - j)))
            local distVar2 = math.floor(math.abs(centerPos.x - i) + math.abs(centerPos.y - j))
            local distVar = math.max(distVar1, distVar2 * 0.707);

            -- Fill in all unexpected water in a circle
            if (distVar < tileRadius+2) then
                if (surface.get_tile(i,j).collides_with("water-tile") or ENABLE_SPAWN_FORCE_GRASS) then
                    table.insert(dirtTiles, {name = "grass", position ={i,j}})
                end
            end

            -- Create a tree ring
            if ((distVar < tileRadius) and 
                (distVar > tileRadius-2)) then
                surface.create_entity({name="tree-01", amount=1, position={i, j}})
            end
        end
    end    
    surface.set_tiles(dirtTiles)
end

-- Create a horizontal line of water
function CreateWaterStrip(surface, leftPos, length)
    local waterTiles = {}
    for i=0,length,1 do
        table.insert(waterTiles, {name = "water", position={leftPos.x+i,leftPos.y}})
    end
    surface.set_tiles(waterTiles)
end 

-- Get an area given a position and distance.
-- Square length = 2x distance
function GetAreaAroundPos(pos, dist)

    return {left_top=
                    {x=pos.x-dist,
                     y=pos.y-dist},
            right_bottom=
                    {x=pos.x+dist,
                     y=pos.y+dist}}
end

-- Removes the entity type from the area given
function RemoveInArea(surface, area, type)
    for key, entity in pairs(surface.find_entities_filtered({area=area, type= type})) do
        entity.destroy()
    end
end

-- Removes the entity type from the area given
-- Only if it is within given distance from given position.
function RemoveInCircle(surface, area, type, pos, dist)
    for key, entity in pairs(surface.find_entities_filtered({area=area, type= type})) do
        if ((pos.x - entity.position.x)^2 + (pos.y - entity.position.y)^2 < dist^2) then
            entity.destroy()
        end
    end
end

-- Convenient way to remove aliens, just provide an area
function RemoveAliensInArea(surface, area)
    for _, entity in pairs(surface.find_entities_filtered{area = area, force = "enemy"}) do
        entity.destroy()
    end
end

-- Make an area safer
-- Reduction factor divides the enemy spawns by that number. 2 = half, 3 = third, etc...
-- Also removes all big and huge worms in that area
function ReduceAliensInArea(surface, area, reductionFactor)
    for _, entity in pairs(surface.find_entities_filtered{area = area, force = "enemy"}) do
        if (math.random(0,reductionFactor) > 0) then
            entity.destroy()
        end
    end

    -- Remove all big and huge worms
    for _, entity in pairs(surface.find_entities_filtered{area = area, name = "medium-worm-turret"}) do
            entity.destroy()
    end
    for _, entity in pairs(surface.find_entities_filtered{area = area, name = "big-worm-turret"}) do
            entity.destroy()
    end
end

-- Add Long Reach to Character
function GivePlayerLongReach(player)

end

-- This creates a random silo position, stored to global.siloPosition
-- It uses the config setting SILO_CHUNK_DISTANCE and spawns the silo somewhere
-- on a circle edge with radius using that distance.
function SetRandomSiloPosition()
    if (global.siloPosition == nil) then
        -- Get an X,Y on a circle far away.
        distX = math.random(0,SILO_CHUNK_DISTANCE_X)
        distY = RandomNegPos() * math.floor(math.sqrt(SILO_CHUNK_DISTANCE_X^2 - distX^2))
        distX = RandomNegPos() * distX

        -- Set those values.
        local siloX = distX*CHUNK_SIZE + CHUNK_SIZE/2
        local siloY = distY*CHUNK_SIZE + CHUNK_SIZE/2
        global.siloPosition = {x = siloX, y = siloY}
    end
end

-- Sets the global.siloPosition var to the set in the config file
function SetFixedSiloPosition()
    if (global.siloPosition == nil) then
        global.siloPosition = SILO_POSITION
    end
end

-- Transfer Items Between Inventory
-- Returns the number of items that were successfully transferred.
-- Returns -1 if item not available.
-- Returns -2 if can't place item into destInv (ERROR)
function TransferItems(srcInv, destEntity, itemStack)
    -- Check if item is in srcInv
    if (srcInv.get_item_count(itemStack.name) == 0) then
        return -1
    end

    -- Check if can insert into destInv
    if (not destEntity.can_insert(itemStack)) then
        return -2
    end
    
    -- Insert items
    local itemsRemoved = srcInv.remove(itemStack)
    itemStack.count = itemsRemoved
    return destEntity.insert(itemStack)
end

-- Attempts to transfer at least some of one type of item from an array of items.
-- Use this to try transferring several items in order
-- It returns once it successfully inserts at least some of one type.
function TransferItemMultipleTypes(srcInv, destEntity, itemNameArray, itemCount)
    local ret = 0
    for _,itemName in pairs(itemNameArray) do
        ret = TransferItems(srcInv, destEntity, {name=itemName, count=itemCount})
        if (ret > 0) then
            return ret -- Return the value succesfully transferred
        end
    end
    return ret -- Return the last error code
end


-- Generate the basic starter resource around a given location.
function GenerateStartingResources(surface, pos)
 
    local startAmount = START_AMOUNT        
    local startSize = START_RESOURCE_SIZE
    
    local coalPos = {x=pos.x+START_RESOURCE_POS_X, y=pos.y+START_RESOURCE_POS_Y}
    local ore1Pos = SetOreStartPos(coalPos)
    local ore2Pos = SetOreStartPos(ore1Pos)
    local ore3Pos = SetOreStartPos(ore2Pos)
    local ore4Pos = SetOreStartPos(ore3Pos)
    local ore5Pos = SetOreStartPos(ore4Pos)
    local ore6Pos = SetOreStartPos(ore5Pos)
    

    GenerateSingleResourceCircle("coal", coalPos, startAmount, startSize, surface)
    GenerateSingleResourceCircle("angels-ore1", ore1Pos, startAmount, startSize, surface)
    GenerateSingleResourceCircle("angels-ore2", ore2Pos, startAmount, startSize, surface)
    GenerateSingleResourceCircle("angels-ore3", ore3Pos, startAmount, startSize, surface)
    GenerateSingleResourceCircle("angels-ore4", ore4Pos, startAmount, startSize, surface)
    GenerateSingleResourceCircle("angels-ore5", ore5Pos, startAmount, startSize, surface)
    GenerateSingleResourceCircle("angels-ore6", ore6Pos, startAmount, startSize, surface)
    

end


function SetOreStartPos(prevPos)
    return {x=prevPos.x, y=prevPos.y+11}
end


function GenerateSingleResourceCircle(oreName, orePos, startAmount, startSize, surface)
    
    local midPoint = math.floor(startSize/2)
    for y=0, startSize do
        for x=0, startSize do
            if (((x-midPoint)^2 + (y-midPoint)^2 < midPoint^2) or not ENABLE_RESOURCE_SHAPE_CIRCLE) then
                surface.create_entity({name=oreName, amount=startAmount,
                    position={orePos.x+x, orePos.y+y}})
            end
        end
    end
end


-- Create the spawn areas.
-- This should be run inside the chunk generate event and be given a list of all
-- unique spawn points.
-- This clears enemies in the immediate area, creates a slightly safe area around it,
-- And spawns the basic resources as well
function CreateSpawnAreas(surface, chunkArea, spawnPointTable)
    for name,spawnPos in pairs(spawnPointTable) do

        -- Create a bunch of useful area and position variables
        local landArea = GetAreaAroundPos(spawnPos, ENFORCE_LAND_AREA_TILE_DIST+CHUNK_SIZE)
        local safeArea = GetAreaAroundPos(spawnPos, SAFE_AREA_TILE_DIST)
        local warningArea = GetAreaAroundPos(spawnPos, WARNING_AREA_TILE_DIST)
        local chunkAreaCenter = {x=chunkArea.left_top.x+(CHUNK_SIZE/2),
                                         y=chunkArea.left_top.y+(CHUNK_SIZE/2)}
        local spawnPosOffset = {x=spawnPos.x+ENFORCE_LAND_AREA_TILE_DIST,
                                         y=spawnPos.y+ENFORCE_LAND_AREA_TILE_DIST}

        -- Make chunks near a spawn safe by removing enemies
        if CheckIfInArea(chunkAreaCenter,safeArea) then
            RemoveAliensInArea(surface, chunkArea)
        
        -- Create a warning area with reduced enemies
        elseif CheckIfInArea(chunkAreaCenter,warningArea) then
            ReduceAliensInArea(surface, chunkArea, WARN_AREA_REDUCTION_RATIO)
        end

        -- If the chunk is within the main land area, then clear trees/resources
        -- and create the land spawn areas (guaranteed land with a circle of trees)
        if CheckIfInArea(chunkAreaCenter,landArea) then

            -- Remove trees/resources inside the spawn area
            RemoveInCircle(surface, chunkArea, "tree", spawnPos, ENFORCE_LAND_AREA_TILE_DIST+5)
            RemoveInCircle(surface, chunkArea, "resource", spawnPos, ENFORCE_LAND_AREA_TILE_DIST+5)

            CreateCropCircle(surface, spawnPos, chunkArea, ENFORCE_LAND_AREA_TILE_DIST)
            CreateCropOctagon(surface, spawnPos, chunkArea, ENFORCE_LAND_AREA_TILE_DIST)
        end

        -- Provide starting resources
        -- This is run on the bottom, right chunk of the spawn area which should be
        -- generated last, so it should work everytime.
        if CheckIfInArea(spawnPosOffset,chunkArea) then
            CreateWaterStrip(surface,
                            {x=spawnPos.x+WATER_SPAWN_OFFSET_X, y=spawnPos.y+WATER_SPAWN_OFFSET_Y},
                            WATER_SPAWN_LENGTH)
            GenerateStartingResources(surface, spawnPos)
        end
    end
end

--------------------------------------------------------------------------------
-- EVENT SPECIFIC FUNCTIONS
--------------------------------------------------------------------------------

-- Display messages to a user everytime they join
function PlayerJoinedMessages(event)
    local player = game.players[event.player_index]
    player.print(global.welcome_msg)
    player.print(GAME_MODE_MSG)
    player.print(MODULES_ENABLED)
end

-- Remove decor to save on file size
function UndecorateOnChunkGenerate(event)
    local surface = event.surface
    local chunkArea = event.area
    RemoveDecorationsArea(surface, chunkArea)
    RemoveFish(surface, chunkArea)
end

-- General purpose event function for removing a particular recipe
function RemoveRecipe(event, recipeName)
    local recipes = event.research.force.recipes
    if recipes[recipeName] then
        recipes[recipeName].enabled = false
    end
end

