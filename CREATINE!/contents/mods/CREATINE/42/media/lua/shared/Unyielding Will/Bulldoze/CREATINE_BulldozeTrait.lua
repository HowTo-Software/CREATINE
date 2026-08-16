-- Bulldoze behavior -- Project Zomboid 42.20 stable

local RADIUS = 1.5
local CONE_COSINE = math.cos(math.rad(45))

local function onPlayerUpdate(player)
    if isClient() or not player or player:isDead() then return end
    if not CREATINE_BulldozeTraitType or not player:hasTrait(CREATINE_BulldozeTraitType) then return end
    if not player:isRunning() then return end

    local cell = getCell()
    if not cell then return end
    local facing = player:getForwardDirection()
    local zombies = cell:getZombieList()
    local px, py, pz = player:getX(), player:getY(), player:getZ()

    for i = 0, zombies:size() - 1 do
        local zombie = zombies:get(i)
        if zombie and not zombie:isDead() and zombie:getZ() == pz then
            local dx = zombie:getX() - px
            local dy = zombie:getY() - py
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance > 0 and distance <= RADIUS then
                local dot = facing.x * (dx / distance) + facing.y * (dy / distance)
                if dot >= CONE_COSINE then zombie:Kill(player) end
            end
        end
    end
end

Events.OnPlayerUpdate.Add(onPlayerUpdate)
