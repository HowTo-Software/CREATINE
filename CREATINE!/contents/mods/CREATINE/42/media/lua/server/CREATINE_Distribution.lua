require "Items/ProceduralDistributions"

local distributions = {
    "ArmyStorageMedical",
    "GymLockers",
    "KitchenDryFood",
    "PharmacyCosmetics",
    "MedicalStorageOutfit",
}

for _, distributionName in ipairs(distributions) do
    local distribution = ProceduralDistributions.list[distributionName]

    if distribution and distribution.items then
        table.insert(distribution.items, "CREATINE.Creatine")
        table.insert(distribution.items, 1.0)
    else
        print("[CREATINE] Missing procedural distribution: "
            .. distributionName)
    end
end