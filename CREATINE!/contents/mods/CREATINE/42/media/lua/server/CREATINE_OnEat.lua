
function CREATINE_OnEat(item, character, percentage)
    if not item or not character then return end

    if item:getFullType() ~= "CREATINE.Creatine" then
        return
    end

    if C_Master_RecordDose then
        C_Master_RecordDose(character)
    end

end
