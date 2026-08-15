require "Items/ProceduralDistributions"

local distributions = {
    "ArmyStorageMedical",
    "GymLockers",
    "KitchenDryFood",
    "PharmacyCosmetics",
    "MedicalStorageOutfit",
}

local function containsPair(items, fullType)
    for i = 1, #items, 2 do
        if items[i] == fullType then return true end
    end
    return false
end

local function addCreatineToDistributions()
    for _, distributionName in ipairs(distributions) do
        local distribution = ProceduralDistributions.list[distributionName]

        if distribution and distribution.items then
            if not containsPair(distribution.items, "CREATINE.Creatine") then
                table.insert(distribution.items, "CREATINE.Creatine")
                table.insert(distribution.items, 1.0)
            end
        else
            print("[CREATINE] Missing procedural distribution: "
                .. distributionName)
        end
    end
end

Events.OnPreDistributionMerge.Add(addCreatineToDistributions)
