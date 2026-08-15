-- Second Wind behavior -- Project Zomboid 42.20.2

local COOLDOWN_HOURS = 24 * 7
local TRIGGER_HEALTH = 20
local PROTECTION_TICKS = 30
local KILL_RADIUS = 3

local speech = {
    "SECOND WIND!",
    "NOT YET!",
    "I WILL NOT DIE HERE!"
}

local function hasSecondWind(player)
    return CREATINE_SecondWindTraitType
        and player:hasTrait(CREATINE_SecondWindTraitType)
end

local function killNearbyZombies(player)
    local cell = getCell()
    if not cell then return end

    local zombies = cell:getZombieList()
    local px = player:getX()
    local py = player:getY()
    local pz = player:getZ()
    local radiusSquared = KILL_RADIUS * KILL_RADIUS

    for i = 0, zombies:size() - 1 do
        local zombie = zombies:get(i)

        if zombie
                and not zombie:isDead()
                and zombie:getZ() == pz then

            local dx = zombie:getX() - px
            local dy = zombie:getY() - py

            if dx * dx + dy * dy <= radiusSquared then
                zombie:Kill(player)
            end
        end
    end
end

local function activate(player, cancelPendingHit)
    local data = player:getModData()
    local body = player:getBodyDamage()

    if cancelPendingHit then
        player:setAvoidDamage(true)
    end

    -- Completely restores health and clears bodily injuries.
    body:RestoreToFullHealth()

    if not player:isGodMod() then
        player:setGodMod(true)
        data.CREATINE_SecondWindSetGodMode = true
    end

    data.CREATINE_SecondWindProtectionTicks = PROTECTION_TICKS
    data.CREATINE_SecondWindReadyAt =
        getGameTime():getWorldAgeHours() + COOLDOWN_HOURS

    killNearbyZombies(player)
    player:Say(speech[ZombRand(#speech) + 1])
end

local function onPlayerGetDamage(player, damageType, damageAmount)
    if isClient()
            or not player
            or player:isDead()
            or not hasSecondWind(player) then
        return
    end

    local data = player:getModData()
    local currentHour = getGameTime():getWorldAgeHours()

    if currentHour < (data.CREATINE_SecondWindReadyAt or 0) then
        return
    end

    local health = player:getBodyDamage():getOverallBodyHealth()
    local damage = tonumber(damageAmount) or 0
    local projectedHealth = health - damage
    local cancelPendingHit = damageType == "WEAPONHIT"

    if health <= TRIGGER_HEALTH
            or projectedHealth <= TRIGGER_HEALTH then
        activate(player, cancelPendingHit)
    end
end

local function onPlayerUpdate(player)
    if isClient() or not player then return end

    local data = player:getModData()
    local ticks = data.CREATINE_SecondWindProtectionTicks

    if ticks then
        ticks = ticks - 1

        if ticks <= 0 then
            if data.CREATINE_SecondWindSetGodMode then
                player:setGodMod(false)
            end

            data.CREATINE_SecondWindSetGodMode = nil
            data.CREATINE_SecondWindProtectionTicks = nil
        else
            data.CREATINE_SecondWindProtectionTicks = ticks
        end
    end

    -- Catch gradual damage that may be applied before its event is processed.
    if player:isDead() or not hasSecondWind(player) then
        return
    end

    local currentHour = getGameTime():getWorldAgeHours()

    if currentHour < (data.CREATINE_SecondWindReadyAt or 0) then
        return
    end

    if player:getBodyDamage():getOverallBodyHealth()
            <= TRIGGER_HEALTH then
        activate(player, false)
    end
end

Events.OnPlayerGetDamage.Add(onPlayerGetDamage)
Events.OnPlayerUpdate.Add(onPlayerUpdate)
