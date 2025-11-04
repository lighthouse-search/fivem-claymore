-- File description: Server-side callbacks for Claymore actions.

-- Allow the client to ask server if user can defuse/pick up Claymore.
lib.callback.register('hades_claymore:can_action', function(source, claymore_id, action_type)
    print("Claymore id "..claymore_id)
    return can_action(source, claymore_id, action_type, false)
end)

-- Allow the client to ask server if user can defuse/pick up Claymore.
lib.callback.register('hades_claymore:pickup', function(source, claymore_id)
    print("Claymore id "..claymore_id)
    return request_pickup(source, claymore_id)
end)

lib.callback.register('hades_claymore:request_placement', function(source)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    return request_placement(source, playerCoords, false)
end)

-- Allow the client to ask server if user can defuse/pick up Claymore.
lib.callback.register('hades_claymore:defuse', function(source, claymore_id, successful)
    print("Claymore id "..claymore_id)
    if (not successful) then
        local claymore = claymore_get(claymore_id);
        local defuse_attempts = Entity(NetworkGetEntityFromNetworkId(claymore.entity)).state.defuse_attempts;
        if defuse_attempts == nil then
            defuse_attempts = 0;
        end;
        defuse_attempts+=1;
        Entity(NetworkGetEntityFromNetworkId(claymore.entity)).state:set('defuse_attempts', defuse_attempts, true);
        
        if defuse_attempts >= GetConfig().defuse.max_attempts then
            claymore_explode(claymore_id); 
        end
    elseif successful then
        request_defuse(source, claymore_id);
    end;
end)