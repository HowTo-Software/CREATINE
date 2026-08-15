-- Registers ingredients without redefining and resetting vanilla item scripts.

local RECIPE = "CREATINE.CreatineSmoothie"

local ingredients = {
    "Strewberrie",
    "Apple",
    "Banana",
    "Cherry",
    "DriedApricots",
    "Grapefruit",
    "Grapes",
    "Lemon",
    "Lime",
    "Mango",
    "Orange",
    "Peach",
    "Pear",
    "Pineapple",
    "Watermelon",
    "WatermelonSliced",
    "WatermelonSmashed",
    "BerryBlack",
    "BerryBlue",
    "BerryGeneric1",
    "BerryGeneric2",
    "BerryGeneric3",
    "BerryGeneric4",
    "BerryGeneric5",
    "Rosehips",
    "BeautyBerry",
    "HollyBerry",
    "WinterBerry",
    "CannedFruitCocktailOpen",
    "CannedPeachesOpen",
    "CannedPineappleOpen",
    "CannedFruitBeverageOpen",
    "Spinach",
    "Kale",
    "Avocado",
    "Carrots",
    "Cucumber",
    "GingerRoot",
    "SugarBeet",
    "Pumpkin",
    "PumpkinSliced",
    "PumpkinSmashed",
    "SweetPotato",
    "Zucchini",
    "CannedMilkOpen",
    "Yoghurt",
    "OatsRaw",
    "PeanutButter",
    "Butter",
    "Lard",
    "Chocolate",
    "Honey",
    "Sugar",
    "SugarBrown",
    "SugarCubes",
    "SugarPacket",
    "MapleSyrup",
    "CocoaPowder",
    "Peanuts",
    "SunflowerSeeds",
    "FlaxSeed",
    "ChocolateChips",
    "Egg",
    "WildEggs",
    "TurkeyEgg",
    "Bacon",
    "BaconRashers",
    "BaconBits",
    "Ham",
    "HamSlice",
    "Baloney",
    "BaloneySlice",
    "Pepperoni",
    "Salami",
    "SalamiSlice",
    "Sausage",
    "MeatPatty",
    "MincedMeat",
    "ChickenWings",
    "Chicken",
    "ChickenFillet",
    "TurkeyLegs",
    "TurkeyFillet",
    "TurkeyWings",
    "MuttonChop",
    "PorkChop",
    "Pork",
    "Venison",
    "Beef",
    "Steak",
    "Hotdog_single",
}

local function addIngredient(recipe, fullType, use)
    local scriptItem = ScriptManager.instance:getItem(fullType)
    if not scriptItem then
        print("[CREATINE] Ingredient not found: " .. fullType)
        return
    end

    local itemName = scriptItem:getName()
    recipe:getItemsList():put(itemName, ItemRecipe.new(itemName, "Base", use))
end

local function registerIngredients()
    local recipe = ScriptManager.instance:getEvolvedRecipe(RECIPE)
    if not recipe then
        print("[CREATINE] Evolved recipe not found: " .. RECIPE)
        return
    end

    for _, itemName in ipairs(ingredients) do
        addIngredient(recipe, "Base." .. itemName, 4)
    end

    addIngredient(recipe, "Base.BerryPoisonIvy", 5)
end

Events.OnGameBoot.Add(registerIngredients)
