-- CREATINE_ContextDebug.lua
-- Temporary diagnostic file: media/lua/client/CREATINE_ContextDebug.lua

local PREFIX = "[CREATINE CONTEXT DEBUG] "

local function log(message)
    print(PREFIX .. tostring(message))
end

local function attempt(label, callback)
    local success, result = pcall(callback)

    if not success then
        log(label .. " ERROR: " .. tostring(result))
        return nil
    end

    log(label .. " = " .. tostring(result))
    return result
end

local function dumpItem(fullType)
    log("----------------------------------------")
    log("CHECKING ITEM: " .. fullType)

    local scriptItem = attempt("Script item", function()
        return ScriptManager.instance:getItem(fullType)
    end)

    if not scriptItem then
        log("ITEM IS MISSING: " .. fullType)
        return
    end

    attempt("Full name", function()
        return scriptItem:getFullName()
    end)

    attempt("EvolvedRecipe property", function()
        return scriptItem:getEvolvedRecipe()
    end)

    attempt("Item type", function()
        return scriptItem:getType()
    end)
end

local function dumpEvolvedRecipes()
    log("========================================")
    log("DUMPING EVERY REGISTERED EVOLVED RECIPE")

    local recipes = attempt("getAllEvolvedRecipes()", function()
        return ScriptManager.instance:getAllEvolvedRecipes()
    end)

    if not recipes then
        return
    end

    local count = attempt("Recipe count", function()
        return recipes:size()
    end)

    if not count then
        return
    end

    for index = 0, count - 1 do
        local recipe = recipes:get(index)

        local name = attempt(
            "Recipe[" .. index .. "] name",
            function()
                return recipe:getName()
            end
        )

        if name and string.find(
                string.lower(tostring(name)),
                "creatine",
                1,
                true
        ) then
            log("FOUND CREATINE RECIPE AT INDEX " .. index)

            attempt("Recipe base item", function()
                return recipe:getBaseItem()
            end)

            attempt("Recipe result item", function()
                return recipe:getResultItem()
            end)

            attempt("Recipe maximum ingredients", function()
                return recipe:getMaxItems()
            end)
        end
    end

    log("FINISHED RECIPE DUMP")
    log("========================================")
end

local function dumpCreatineState()
    log("STARTING COMPLETE STATE CHECK")

    dumpEvolvedRecipes()

    dumpItem("Base.Sportsbottle")
    dumpItem("Base.Apple")
    dumpItem("Base.Banana")
    dumpItem("Base.PeanutButter")
    dumpItem("CREATINE.Creatine")
    dumpItem("CREATINE.CreatineSmoothie")

    dumpItem("JunkiezMoreSupplements.JunkiezProteinPowder")
    dumpItem("JunkiezMoreSupplements.JunkiezPreworkout")
    dumpItem("JunkiezMoreSupplements.JunkiezMassGainer")
    dumpItem("JunkiezMoreSupplements.JunkiezFatBurner")

    log("COMPLETE STATE CHECK FINISHED")
end

local function unwrapItem(entry)
    if not entry then
        return nil
    end

    local success, isInventoryItem = pcall(function()
        return instanceof(entry, "InventoryItem")
    end)

    if success and isInventoryItem then
        return entry
    end

    if type(entry) == "table" then
        if entry.items and entry.items[1] then
            return entry.items[1]
        end

        if entry.item then
            return entry.item
        end
    end

    return nil
end

local function dumpContextOptions(context)
    if not context or not context.options then
        log("Context contains no options table")
        return
    end

    log("CONTEXT OPTIONS:")

    for index, option in ipairs(context.options) do
        log(
            "  OPTION "
            .. tostring(index)
            .. ": "
            .. tostring(option and option.name)
        )
    end
end

local function onFillInventoryContextMenu(playerIndex, context, items)
    log("########################################")
    log("INVENTORY CONTEXT MENU EVENT FIRED")
    log("Player index: " .. tostring(playerIndex))
    log("Selected entry count: " .. tostring(items and #items or 0))

    if items then
        for index, entry in ipairs(items) do
            local item = unwrapItem(entry)

            if item then
                local fullType = attempt(
                    "Selected item " .. index,
                    function()
                        return item:getFullType()
                    end
                )

                if fullType then
                    attempt(
                        fullType .. " runtime fluid amount",
                        function()
                            local container = item:getFluidContainer()

                            if not container then
                                return "NO FLUID CONTAINER"
                            end

                            return container:getAmount()
                        end
                    )
                end
            else
                log(
                    "Could not unwrap selected entry "
                    .. tostring(index)
                )
            end
        end
    end

    dumpContextOptions(context)
    log("########################################")
end

log("DEBUGGER FILE LOADED")

-- Scripts and items already exist when client Lua is loaded, so run immediately.
dumpCreatineState()

Events.OnGameStart.Add(function()
    log("OnGameStart fired")
    dumpCreatineState()
end)

Events.OnFillInventoryObjectContextMenu.Add(
    onFillInventoryContextMenu
)