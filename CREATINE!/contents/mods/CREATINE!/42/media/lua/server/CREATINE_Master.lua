-- CREATINE loading and milestone system -- Project Zomboid 42.20.2

CREATINE_MilestoneSystem = CREATINE_MilestoneSystem or {}
CREATINE_MilestoneSystem.DAYS_TO_LOAD = 7
CREATINE_MilestoneSystem.Packs = {
    { name = "Bully",          weight = 85,  fitness = 5,  strength = 5 },
    { name = "Tactician",      weight = 95,  fitness = 6,  strength = 7 },
    { name = "Berserker",      weight = 110, fitness = 8,  strength = 9 },
    { name = "UnyieldingWill", weight = 130, fitness = 10, strength = 10 },
}

CREATINE_MilestoneSystem.SpeechGain = {
    Bully          = "I could punch holes in the wall!",
    Tactician      = "I can shoot the peter off a skeeter at a hundred meters.",
    Berserker      = "WHERE ARE THEY?",
    UnyieldingWill = "I pity them no longer.",
}
CREATINE_MilestoneSystem.SpeechLoss = "Feel... so... weak..."

local function bundles()
    return {
        Bully = {
            CharacterTrait.NUTRITIONIST,
            CharacterTrait.THICK_SKINNED,
            CharacterTrait.RESILIENT,
        },
        Tactician = {
            CharacterTrait.GRACEFUL,
            CharacterTrait.GYMNAST,
            CharacterTrait.HUNTER,
        },
        Berserker = {
            CharacterTrait.ADRENALINE_JUNKIE,
            CharacterTrait.ATHLETIC,
            CharacterTrait.AXEMAN,
        },
        UnyieldingWill = {
            CREATINE_SecondWindTraitType,
            CREATINE_BulldozeTraitType,
        },
    }
end

local function traitKey(traitType)
    return tostring(traitType)
end

local function dataFor(player)
    local root = player:getModData()
    root.CREATINE = root.CREATINE or {}
    local data = root.CREATINE
    data.DoseDays = data.DoseDays or {}
    data.ActiveMilestones = data.ActiveMilestones or {}
    data.GrantedTraits = data.GrantedTraits or {}
    return data
end

local function addBundleTrait(player, data, traitType)
    if not traitType or player:hasTrait(traitType) then return end
    player:getCharacterTraits():add(traitType)
    data.GrantedTraits[traitKey(traitType)] = true
end

local function activeMilestoneNeeds(data, traitType)
    local allBundles = bundles()
    for milestoneName in pairs(data.ActiveMilestones) do
        for _, neededType in ipairs(allBundles[milestoneName] or {}) do
            if neededType == traitType then return true end
        end
    end
    return false
end

local function removeBundleTrait(player, data, traitType)
    local key = traitKey(traitType)
    if not data.GrantedTraits[key] or activeMilestoneNeeds(data, traitType) then return end
    if player:hasTrait(traitType) then player:getCharacterTraits():remove(traitType) end
    data.GrantedTraits[key] = nil
end

local function suppressWeightTraits(player, data)
    if not data.CreatineLoaded then return end
    local traits = player:getCharacterTraits()
    if player:hasTrait(CharacterTrait.OBESE) then traits:remove(CharacterTrait.OBESE) end
    if player:hasTrait(CharacterTrait.OVERWEIGHT) then traits:remove(CharacterTrait.OVERWEIGHT) end
end

local function grantMilestone(player, data, milestoneName)
    if data.ActiveMilestones[milestoneName] then
        for _, traitType in ipairs(bundles()[milestoneName] or {}) do
            addBundleTrait(player, data, traitType)
        end
        return
    end
    data.ActiveMilestones[milestoneName] = true
    for _, traitType in ipairs(bundles()[milestoneName] or {}) do
        addBundleTrait(player, data, traitType)
    end
    local line = CREATINE_MilestoneSystem.SpeechGain[milestoneName]
    if line then player:Say(line) end
end

local function removeMilestone(player, data, milestoneName)
    if not data.ActiveMilestones[milestoneName] then return false end
    data.ActiveMilestones[milestoneName] = nil
    for _, traitType in ipairs(bundles()[milestoneName] or {}) do
        removeBundleTrait(player, data, traitType)
    end
    return true
end

function C_Master_EvaluateMilestones(player)
    if not player or player:isDead() then return end
    local data = dataFor(player)
    local nutrition = player:getNutrition()
    local weight = nutrition and nutrition:getWeight() or 0
    local fitness = player:getPerkLevel(Perks.Fitness)
    local strength = player:getPerkLevel(Perks.Strength)
    local lostAny = false

    data.CreatineWeight = weight
    data.CreatineRegularity = ((fitness + strength) / 20) * 100

    for _, pack in ipairs(CREATINE_MilestoneSystem.Packs) do
        local achieved = data.CreatineLoaded == true
            and weight >= pack.weight
            and fitness >= pack.fitness
            and strength >= pack.strength
        if achieved then
            grantMilestone(player, data, pack.name)
        elseif removeMilestone(player, data, pack.name) then
            lostAny = true
        end
    end

    suppressWeightTraits(player, data)
    if lostAny then player:Say(CREATINE_MilestoneSystem.SpeechLoss) end
end

function C_Master_RecordDose(player)
    if not player or player:isDead() then return end
    local data = dataFor(player)

    if data.DoseDayCount == nil then
        data.DoseDayCount = 0
        for _ in pairs(data.DoseDays) do
            data.DoseDayCount = data.DoseDayCount + 1
        end
    end

    -- Build 42 exposes world age in hours. Dividing by 24 produces a
    -- persistent world-day number independent of the sandbox day length.
    local day = tostring(math.floor(getGameTime():getWorldAgeHours() / 24))

    if not data.DoseDays[day] then
        data.DoseDays[day] = true
        data.DoseDayCount = data.DoseDayCount + 1
    end

    if data.DoseDayCount >= CREATINE_MilestoneSystem.DAYS_TO_LOAD then
        data.CreatineLoaded = true
    end

    C_Master_EvaluateMilestones(player)
end

local function evaluateAllPlayers()
    if isClient() then return end
    if isServer() then
        local players = getOnlinePlayers()
        for i = 0, players:size() - 1 do
            C_Master_EvaluateMilestones(players:get(i))
        end
    else
        local player = getPlayer()
        if player then C_Master_EvaluateMilestones(player) end
    end
end

Events.EveryTenMinutes.Add(evaluateAllPlayers)
