-- File description: Anti-exploit validation checks.

-- Check if user is within reasonable distance of placement coordinates (e.g. we don't want someone placing a camera half way across the map).
function is_reasonable_coordinates(player_id, targetCoords, buffer)
    -- Requesting player's coordinates.
    local playerPed = GetPlayerPed(player_id);
    -- Target player/ground coordinates.
    local coords = GetEntityCoords(playerPed);

    local playerCoords = vector3(coords.x, coords.y, coords.z);
    lib.print.info(playerCoords);
    lib.print.info(targetCoords);

    local distance = #(playerCoords - targetCoords);
    lib.print.info("Distance: " .. distance .. " Buffer: " .. buffer);
    if (distance <= buffer) then
        lib.print.info("TRUE!");
        return true;
    else
        return false;
    end
end