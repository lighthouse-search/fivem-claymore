-- Target and pickup Claymore item. TODO: This is broken until placement API is integrated.
exports.ox_target:addGlobalOption({
    name = 'claymore_pickup',
    label = 'Pick-up Claymore',
    icon = 'fa-regular fa-hand',
    onSelect = function(data)
        local entity = data.entity;
        local state = Entity(entity).state
        local claymore_id = state.claymore_id
        
        lib.callback.await('hades_claymore:pickup', false, claymore_id)
    end,
    canInteract = function(entity, distance, coords, name)
        local state = Entity(entity).state;
        local claymore_id = state.claymore_id;
        if (claymore_id == nil) then
            return false
        end

        local allowed = lib.callback.await('hades_claymore:can_action', false, claymore_id, "pickup");
        return allowed == true
    end
});

exports.ox_target:addGlobalOption({
    name = 'claymore_defuse',
    label = 'Defuse Claymore',
    icon = 'fa-solid fa-bomb',
    onSelect = function(data)
        local entity = data.entity;
        local state = Entity(entity).state
        local claymore_id = state.claymore_id
        
        defuse(claymore_id, entity);
    end,
    canInteract = function(entity, distance, coords, name)
        local state = Entity(entity).state;
        local claymore_id = state.claymore_id;
        if (claymore_id == nil) then
            return false
        end

        local allowed = lib.callback.await('hades_claymore:can_action', false, claymore_id, "defuse");
        return allowed == true
    end
});

exports.ox_target:addGlobalOption({
    name = 'claymore_admin',
    label = 'Admin',
    icon = 'fa-solid fa-user-shield',
    onSelect = function(data)
        local entity = data.entity;
        local state = Entity(entity).state
        local claymore_id = state.claymore_id

        local claymore = lib.callback.await('hades_claymore:claymore_get', false, claymore_id);
        if not claymore then
            lib.notify({ description = 'Claymore ID not found.', type = 'error' });
            return;
        end

        local input = lib.inputDialog("Claymore "..claymore_id, {
            {type = 'checkbox', label = 'Enabled', checked = state.enabled },
            {type = 'input', label = 'player_id', required = false, default = claymore.player_id },
            {type = 'number', label = 'Entity (netID)', required = false, disabled = true, default = claymore.entity },
            {type = 'input', label = 'Coordinates', description = 'x, y, z', required = false, default = string.format("%.2f, %.2f, %.2f", claymore.x, claymore.y, claymore.z) },
            {type = 'input', label = 'Permissions', default = state.permissions },
        })

        local claymore = lib.callback.await('hades_claymore:admin:claymore_update', false, claymore_id, {
            enabled = input[1],
            player_id = input[2],
            coordinates = parse_coordinates(input[4]),
            permissions = input[5]
        });
    end,
    canInteract = function(entity, distance, coords, name)
        local state = Entity(entity).state;
        local claymore_id = state.claymore_id;
        if (claymore_id == nil) then
            return false
        end

        local allowed = lib.callback.await('hades_claymore:can_action', false, claymore_id, "admin");
        return allowed == true
    end
});

-- Create netEvent handle to respect explosions called from server.
RegisterNetEvent('fivem:createExplosion')
AddEventHandler('fivem:createExplosion', function(x, y, z, explosion_type, damage_scale, is_audible, is_invisible, camera_shake)
    AddExplosion(x, y, z, explosion_type, damage_scale, is_audible, is_invisible, camera_shake)
end)

Citizen.CreateThread(function()
    local last_update = nil;
    while true do
        Citizen.Wait(0) -- Wait a small amount of time to prevent excessive resource usage

        local playerPed = PlayerPedId();
        local sprinting = IsPedSprinting(playerPed);

        -- Check if sprinting state has changed before pestering server.
        if sprinting ~= last_update then
            last_update = sprinting;
            TriggerServerEvent('hades_claymore:sprinting_state', sprinting);
        end
    end
end)