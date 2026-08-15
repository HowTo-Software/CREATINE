-- CREATINE custom traits -- Project Zomboid 42.20 stable

local function registerTrait(resourceName, label, description, texturePath)
    local traitType = CharacterTrait.register(resourceName)
    local definition = CharacterTraitDefinition.getCharacterTraitDefinition(traitType)
    if not definition then
        definition = CharacterTraitDefinition.addCharacterTraitDefinition(
            traitType,
            label,
            0,
            description,
            false,
            false
        )
        local texture = getTexture(texturePath)
        if texture then definition:setTexture(texture) end
    end
    return traitType
end

local function registerCreatineTraits()
    CREATINE_SecondWindTraitType = registerTrait(
        "creatine:secondwind",
        "UI_trait_CreatineSecondWind",
        "UI_trait_CreatineSecondWindDesc",
        "media/textures/traits/Trait_SecondWind.png"
    )
    CREATINE_BulldozeTraitType = registerTrait(
        "creatine:bulldoze",
        "UI_trait_CreatineBulldoze",
        "UI_trait_CreatineBulldozeDesc",
        "media/textures/traits/Trait_Bulldoze.png"
    )
end

Events.OnGameBoot.Add(registerCreatineTraits)
