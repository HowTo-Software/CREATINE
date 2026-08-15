
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
end
