RegisterCommand("admin-claymore-place", function(source, args, rawCommand)
    local playerServerId = GetPlayerServerId(PlayerId());
    local playerPed = GetPlayerPed(PlayerId());
    -- Target player/ground coordinates.
    local coords = GetEntityCoords(playerPed);

    local player_id = playerServerId;
    local coordinates = string.format("%.2f, %.2f, %.2f", coords.x, coords.y, coords.z);
    local permissions = json.encode({ { player_id = playerServerId, permission = "pickup" }, { player_id = playerServerId, permission = "dont_explode" } });

    local input = lib.inputDialog('[Admin]: Place Claymore', {
        {type = 'number', label = 'player_id', required = true, default = player_id },
        {type = 'input', label = 'Coordinates', description = 'x, y, z', required = true, default = coordinates },
        {type = 'input', label = 'Permissions', required = true, default = permissions },
    });

    if not input then
        -- "Cancel" was pressed
        return
    end

    local coordsInput = input[2] or ""
    local parts = {}
    for part in string.gmatch(coordsInput, "([^,]+)") do
        part = part:gsub("^%s*(.-)%s*$", "%1")
        table.insert(parts, tonumber(part))
    end

    if #parts < 3 or not parts[1] or not parts[2] or not parts[3] then
        lib.notify({ description = 'Invalid coordinates. Use "x, y, z"', type = 'error' })
        return
    end

    local coordsVec = vector3(parts[1], parts[2], parts[3]);
    lib.callback.await('hades_claymore:admin:place', false, input[1], coordsVec, input[3]);

end, false) -- The 'false' indicates it's not restricted by ACE permissions automatically

RegisterCommand("admin-claymore-clear", function(source, args, rawCommand)
    local input = lib.inputDialog('[Admin]: Clear ALL Claymores?', {});

    if not input then
        -- "Cancel" was pressed
        return
    end

    lib.callback.await('hades_claymore:admin:clear_all', false);

end, false) -- The 'false' indicates it's not restricted by ACE permissions automatically