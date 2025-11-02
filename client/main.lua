-- Target and pickup Claymore item. TODO: This is broken until placement API is integrated.
exports.ox_target:addGlobalOption({
    name = 'Claymore_pickup',
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
    name = 'Claymore_defuse',
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
})

RegisterNetEvent('fivem:createExplosion')
AddEventHandler('fivem:createExplosion', function(x, y, z)
    AddExplosion(x, y, z, 2, 1.0, true, false, 1.0)
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