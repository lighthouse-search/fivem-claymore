-- File description: Contains server callbacks when client requests to place a Claymore.

-- Request placement of a Claymore.
function request_placement(player_id, coordinates)
    if GetConfig().feature_flags.placement == false then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = 'Claymore placement is currently disabled.' });
        return;
    end
    
    -- Check if user is authorised to Claymore.
    can_claymore(player_id, nil, "place");

    -- Check the player is within reasonable coordinates to place this camera. We don't want cheaters placing cameras half way across the map for friends (without freecam exploits).
    -- Check if the player is more than 10 units away from the placement coordinates.
    lib.print.info(coordinates);
    if not is_reasonable_coordinates(player_id, coordinates, 10) then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = 'Coordinates are not reasonable to place a Claymore camera.' });
        return;
    end

    -- Ensure player has a Claymore in their inventory.
    if (does_player_have_claymore_in_inventory(player_id) == false) then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = "You don't have a Claymore." });
        return;
    end

    -- TODO: We need to check the durability of Claymore isn't zero (the item still works).

    trigger_placement(false, player_id, coordinates, nil, true, nil);

    -- Great! We successfully created a Claymore entry, now we need to remove the Claymore item from user's inventory to prevent duplication.
    local success = exports.ox_inventory:RemoveItem(player_id, "claymore", 1);
    if (success ~= true) then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = 'Failed to remove Claymore item from inventory.' });
        return;
    end

    TriggerClientEvent('ox_lib:notify', player_id, {
        title = 'Claymore Ready!',
        description = "Claymore successfully placed!",
        type = 'success'
    });

    print(claymore_id)
end

function trigger_placement(admin, player_id, coordinates, permissions, enabled, obj)
    local modelHash = GetHashKey("ch_prop_ch_ld_bomb_01a")
    if obj == nil then
        obj = CreateObject(modelHash, coordinates.x, coordinates.y, coordinates.z - 1, true, false, true)
        local timeout = 0
        while not DoesEntityExist(obj) and timeout < 1000 do
            Wait(10)
            timeout = timeout + 1
        end
    end
    local netId = NetworkGetNetworkIdFromEntity(obj);

    if DoesEntityExist(obj) then
        -- Make the object a mission entity and freeze it so physics/explosions can't move it
        FreezeEntityPosition(obj, true)
    end

    TaskPlayAnim(GetPlayerPed(player_id), "mp_car_bomb", "car_bomb_mechanic", 8.0, -8.0, -1, 50, 0, false, false, false)

    -- Create Claymore camera entry is SQL database.
    local claymore_id = claymore_create(player_id, netId, coordinates.x, coordinates.y, coordinates.z);

    if (permissions == nil) then
        permissions = json.encode(default_permissions(claymore_id, player_id));
    end
    if (type(permissions) == "table") then
        permissions = json.encode(permissions);
    end
    
    -- if (type(permissions) == "string") then
    --     permissions = json.decode(permissions);
    -- end

    Entity(obj).state:set('claymore', "true", true);
    Entity(obj).state:set('claymore_id', claymore_id, true);
    Entity(obj).state:set('player_id', player_id, true);
    Entity(obj).state:set('permissions', permissions, true);
    Entity(obj).state:set('enabled', enabled or true, true);
    print("Claymore placed with player_id: " .. player_id);
end

-- Request removal of a Claymore.
function request_pickup(player_id, claymore_id)
    if GetConfig().feature_flags.pickup == false then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = 'Claymore pickup is currently disabled.' });
        return;
    end
    -- Check if user has permission to remove this Claymore.
    if (can_action(player_id, claymore_id, "pickup", false) == false) then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = "No permission." });
        return;
    end

    local claymore = claymore_get(claymore_id);
    if not is_reasonable_coordinates(player_id, vector3(claymore.x, claymore.y, claymore.z), GetConfig().pickup.max_range) then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = 'Too far away from Claymore.' });
        return;
    end

    claymore_remove(claymore_id, true);

    exports.ox_inventory:AddItem(player_id, "claymore", 1);
end

-- Request defusal of a Claymore.
function request_defuse(player_id, claymore_id)
    if GetConfig().feature_flags.defuse == false then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = 'Claymore defusal is currently disabled.' });
        return;
    end

    -- Check if user has permission to remove this Claymore.
    if (can_action(player_id, claymore_id, "defuse", false) == false) then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = "No permission." });
        return;
    end

    local claymore = claymore_get(claymore_id);
    if not is_reasonable_coordinates(player_id, vector3(claymore.x, claymore.y, claymore.z), GetConfig().defuse.max_range) then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = 'Too far away from Claymore.' });
        return;
    end
    
    claymore_remove(claymore_id, false);

    TriggerClientEvent('ox_lib:notify', player_id, {
        title = 'Claymore defused',
        description = 'Claymore has been successfully defused.',
        type = 'success'
    });
end

function clear_all(delete_spawned_entities)
    local claymores = claymore_list(nil, nil);

    MySQL.query.await('DELETE FROM `hades_claymore`');

    if delete_spawned_entities ~= false then
        for _, claymore in ipairs(claymores) do
            print("DELETE ENTITY "..claymore.entity);
            DeleteEntity(NetworkGetEntityFromNetworkId(claymore.entity))
        end
    end
end

AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
    if eventData.secondsRemaining == 60 then
        clear_all(true)
    end
end)