
local function CREATINE_AddEmptySportsBottle(character)
    local inventory = character:getInventory()
    if not inventory then return end

    local bottle = inventory:AddItem("Base.Sportsbottle")
    if not bottle then return end

    local fluidContainer = bottle:getFluidContainer()
    if fluidContainer then
        fluidContainer:Empty()
    end
end

function CREATINE_OnEat(item, character, percentage)
    if not item or not character then return end

    local fullType = item:getFullType()

    if fullType ~= "CREATINE.Creatine"
            and fullType ~= "CREATINE.CreatineSmoothie" then
        return
    end

    if C_Master_RecordDose then
        C_Master_RecordDose(character)
    end

    -- Return an empty Sports Bottle after drinking the entire smoothie.
    if fullType == "CREATINE.CreatineSmoothie"
            and percentage >= 0.999 then
        CREATINE_AddEmptySportsBottle(character)
    end
end