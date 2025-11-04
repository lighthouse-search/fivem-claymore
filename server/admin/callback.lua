-- File description: Server-side ADMIN callbacks for Claymore actions.

-- lib.callback.register('hades_claymore:config_get', function(source)
--     can_action(source, nil, "admin", true)
--     return GetConfig();
-- end);

lib.callback.register('hades_claymore:claymore_get', function(source, claymore_id)
    can_action(source, claymore_id, "admin", true)
    print("Claymore id "..claymore_id)
    return claymore_get(claymore_id)
end);

lib.callback.register('hades_claymore:admin:claymore_update', function(source, claymore_id, data)
    can_action(source, claymore_id, "admin", true)
    print("Claymore id "..claymore_id)
    claymore_update(claymore_id, data)
    TriggerClientEvent('ox_lib:notify', source, { type = 'success', title = 'Claymore Updated' });
end);

lib.callback.register('hades_claymore:admin:place', function(source, player_id, coordinates, permissions)
    can_action(source, nil, "admin", true);
    trigger_placement(true, player_id, coordinates, permissions, true, nil);
end);

lib.callback.register('hades_claymore:admin:clear_all', function(source, player_id, coordinates, permissions)
    can_action(source, nil, "admin", true);
    clear_all(true);
end);