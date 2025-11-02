function does_player_have_claymore_in_inventory(player_id)
    -- Get user's inventory
    local inventory = exports.ox_inventory:GetInventoryItems(player_id, false);
    -- Print user's inventory for debugging purposes.
    print(json.encode(inventory, {indent = true}));

    -- Check player has Claymore item.
    local has_Claymore = false;
    for slot, item in pairs(inventory) do
        -- local durability = item.durability or "N/A"
        -- print(string.format("Item: %s, Durability: %s", item.name, durability))
        print(item.name);
        if item.name == "claymore" then
            has_Claymore = true;
        end
    end

    return has_Claymore;
end

exports('does_player_have_claymore_in_inventory', does_player_have_claymore_in_inventory)