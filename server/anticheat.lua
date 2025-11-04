-- File description: Anti-exploit validation checks.

-- Check if user is within reasonable distance of placement coordinates (e.g. we don't want someone placing a camera half way across the map).
function is_reasonable_coordinates(player_id, targetCoords, buffer)
    -- Requesting player's coordinates.
    local playerPed = GetPlayerPed(player_id);
    -- Target player/ground coordinates.
    local coords = GetEntityCoords(playerPed);

    local playerCoords = vector3(coords.x, coords.y, coords.z);

    local distance = #(playerCoords - targetCoords);
    if (distance <= buffer) then
        return true;
    else
        return false;
    end
end

function does_player_have_claymore_in_inventory(player_id)
    -- Get user's inventory
    local inventory = exports.ox_inventory:GetInventoryItems(player_id, false);
    -- print(json.encode(inventory, {indent = true}));

    -- Check player has Claymore item.
    local has_Claymore = false;
    for slot, item in pairs(inventory) do
        -- local durability = item.durability or "N/A"
        -- print(string.format("Item: %s, Durability: %s", item.name, durability))
        -- print(item.name);
        if item.name == "claymore" then
            has_Claymore = true;
        end
    end

    return has_Claymore;
end

exports('does_player_have_claymore_in_inventory', does_player_have_claymore_in_inventory)