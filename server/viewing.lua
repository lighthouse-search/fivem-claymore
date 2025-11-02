-- File description: Contains server callbacks when client requests to view a Claymore.

function request_view(player_id, camera_id)
    -- Check if user is authorised to Claymore.
    can_claymore(player_id, camera_id, "view");

    -- Get camera information.
    local camera = camera_get(camera_id);
    -- Check if camera was found.
    if camera == nil then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = "Camera not found." });
        return;
    end

    -- TriggerClientEvent('ox_lib:notify', player_id, { type = 'success', title = 'Claymore Success', description = "Camera found!" });

    -- Spawn camera thread based on camera type.
    if camera.type == "person" then
        TriggerClientEvent('hades_claymore:view_person', player_id, GetPlayerPed(camera.entity), camera.x, camera.y, camera.z);
    elseif camera.type == "ground" then
        TriggerClientEvent('hades_claymore:view_ground', player_id, camera.x, camera.y, camera.z);
    else
        error("Unknown view type: " .. tostring(camera.type));
    end
end

lib.callback.register('hades_claymore:camera_list', function(source, start, limit)
    -- Check if user is authorised to Claymore.
    can_claymore(source, nil, "view");

    -- List camera information.
    local cameras = camera_list(start, limit);

    return cameras
end)