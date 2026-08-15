-- Bulldoze behavior -- Project Zomboid 42.20.2

local RADIUS = 1.5
local CONE_COSINE = math.cos(math.rad(45))
local SCAN_INTERVAL_MS = 100
local nextScanAt = {}

local function onPlayerUpdate(player)
    if isClient() or not player or player:isDead() then return end
    if not CREATINE_BulldozeTraitType or not player:hasTrait(CREATINE_BulldozeTraitType) then return end
    if not player:isRunning() then return end

    local now = getTimestampMs()
    if now < (nextScanAt[player] or 0) then return end
    nextScanAt[player] = now + SCAN_INTERVAL_MS

    local cell = getCell()
    if not cell then return end
    local facing = player:getForwardDirection()
    local px, py, pz = player:getX(), player:getY(), player:getZ()
    local minX = math.floor(px - RADIUS)
    local maxX = math.floor(px + RADIUS)
    local minY = math.floor(py - RADIUS)
    local maxY = math.floor(py + RADIUS)
    local level = math.floor(pz)

    for x = minX, maxX do
        for y = minY, maxY do
            local square = cell:getGridSquare(x, y, level)
            local movingObjects = square and square:getMovingObjects()
            if movingObjects then
                for i = 0, movingObjects:size() - 1 do
                    local zombie = movingObjects:get(i)
                    if instanceof(zombie, "IsoZombie") and not zombie:isDead() then
                        local dx = zombie:getX() - px
                        local dy = zombie:getY() - py
                        local distanceSquared = dx * dx + dy * dy
                        if distanceSquared > 0 and distanceSquared <= RADIUS * RADIUS then
                            local distance = math.sqrt(distanceSquared)
                            local dot = facing.x * (dx / distance) + facing.y * (dy / distance)
                            if dot >= CONE_COSINE then zombie:Kill(player) end
                        end
                    end
                end
            end
        end
    end
end

Events.OnPlayerUpdate.Add(onPlayerUpdate)
