-- Target Computer Craft 1.5
-- Use `label set miner`

-- Chest at left of turtle for fuel
-- Chest above turtle for torches
-- Chest below turtle to deposit items

FUEL_SLOT = 1
TORCH_SLOT = 2
TUNNEL_LENGTH = 80
TUNNEL_NUMBER = 25
TORCH_DISTANCE = 13

local function mineForward()
    if turtle.detect() then
        turtle.dig()
    end
    if turtle.forward() == false then
        repeat
            turtle.dig()
            sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
        until turtle.forward() == true
    end
    if turtle.detectUp() then
        turtle.digUp()
    end
end

-- Leave 1 torch at all times
local function availableTorches()
    space = turtle.getItemSpace(TORCH_SLOT)
    return 63 - space
end

-- Place behind so it doesn't get mined
local function placeTorch()
    turtle.turnLeft()
    turtle.turnLeft()
    turtle.select(TORCH_SLOT)
    turtle.place()
    turtle.turnRight()
    turtle.turnRight()
end

local function reload()
    -- Load fuel from left chest
    turtle.select(FUEL_SLOT)
    turtle.turnLeft()
    turtle.suck()
    turtle.turnRight()
    -- Load torches from chest above
    turtle.select(TORCH_SLOT)
    turtle.suckUp()
    -- Unload items into chest below
    for i = 3, 16 do
        turtle.select(i)
        turtle.dropDown()
    end
end

-- Leave 1 fuel at all times
local function refuel()
    turtle.select(FUEL_SLOT)
    space = turtle.getItemSpace(FUEL_SLOT)
    turtle.refuel(63 - space)
end

local function distanceToBase(xdistance, tunnel)
    return xdistance + tunnel * 3
end

local function allSlotsUsed()
    for i = 3, 16 do
        space = turtle.getItemSpace(i)
        if space == 64 then
            return false
        end
    end
    return true
end

local function returnToBaseAndReload(xdistance, tunnel, reverse, continue)
    -- Ensure facing in reverse
    if not reverse then
        turtle.turnRight()
        turtle.turnRight()
    end
    -- Return to base
    for i = 1, xdistance do
        mineForward()
    end
    turtle.turnRight()
    if tunnel ~= 0 then
        for i = 1, (tunnel * 3) - 1 do
            mineForward()
        end
        turtle.forward()
    end
    -- Restore orientation
    turtle.turnRight()

    if continue then
        print("Reloading")
        while (turtle.getFuelLevel() - distanceToBase(xdistance, tunnel) <= 0) or (availableTorches() <= 1) do
            reload()
            refuel()
        end
        -- Trace back path to mine
        turtle.turnRight()
        for i = 1, tunnel * 3 do
            turtle.forward()
        end
        turtle.turnLeft()
        for i = 1, xdistance do
            turtle.forward()
        end
        -- Restore direction
        if reverse then
            turtle.turnRight()
            turtle.turnRight()
        end
    else
        reload()
    end
end


local function run()
    local xdistance = 0
    local tunnel = 0
    local reverse = false
    local torchTracker = 0
    while(1) do

        if ((turtle.getFuelLevel() - distanceToBase(xdistance, tunnel)) <= 3) or (availableTorches() < 1) or allSlotsUsed() then
            returnToBaseAndReload(xdistance, tunnel, reverse, true)
        end

        if reverse == false and xdistance == TUNNEL_LENGTH then
            turtle.turnRight()
            for i = 1, 3 do
                mineForward()
            end
            turtle.turnRight()
            tunnel = tunnel + 1
            reverse = true
        elseif reverse == true and xdistance == 0 then
            turtle.turnLeft()
            for i = 1, 3 do
                mineForward()
            end
            turtle.turnLeft()
            tunnel = tunnel + 1
            reverse = false
        else
            mineForward()
            if reverse then
                xdistance = xdistance - 1
            else
                xdistance = xdistance + 1
            end

            if torchTracker >= TORCH_DISTANCE then
                placeTorch()
                torchTracker = 0
            else
                torchTracker = torchTracker + 1
            end
        end

        if tunnel == (TUNNEL_NUMBER - 1) then
            if (xdistance == TUNNEL_LENGTH and (not reverse)) or (xdistance == 0 and reverse) then
                returnToBaseAndReload(xdistance, tunnel, reverse, false)
                print("Finished")
                break
            end
        end
    end
end

run()
