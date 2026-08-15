-- Adds cross-mod evolved-recipe entries without replacing Junkiez item scripts.

local powders = {
    "JunkiezProteinPowder",
    "JunkiezPreworkout",
    "JunkiezMassGainer",
    "JunkiezFatBurner",
}

local recipes = {
    "Base.JunkiezShake",
    "Base.JunkiezBlendedShake",
    "CREATINE.CreatineSmoothie",
}

local function registerCompatibility()
    for _, recipeType in ipairs(recipes) do
        local recipe = ScriptManager.instance:getEvolvedRecipe(recipeType)
        if recipe then
            for _, itemName in ipairs(powders) do
                local fullType = "JunkiezMoreSupplements." .. itemName
                local scriptItem = ScriptManager.instance:getItem(fullType)
                if scriptItem then
                    recipe:getItemsList():put(
                        itemName,
                        ItemRecipe.new(itemName, "JunkiezMoreSupplements", 5)
                    )
                end
            end
        else
            print("[CREATINE Junkiez Compat] Recipe not found: " .. recipeType)
        end
    end

    local creatine = ScriptManager.instance:getItem("CREATINE.Creatine")
    if not creatine then return end

    for _, recipeType in ipairs({
        "Base.JunkiezShake",
        "Base.JunkiezBlendedShake",
    }) do
        local recipe = ScriptManager.instance:getEvolvedRecipe(recipeType)
        if recipe then
            recipe:getItemsList():put(
                creatine:getName(),
                ItemRecipe.new(creatine:getName(), "CREATINE", 5)
            )
        end
    end
end

Events.OnGameBoot.Add(registerCompatibility)
