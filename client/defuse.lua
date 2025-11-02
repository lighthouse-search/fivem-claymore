local fail_count = 0;

function defuse(claymore_id, entity)
    local success = lib.skillCheck({'easy', 'hard', {areaSize = 60, speedMultiplier = 2}, 'hard'}, {'w', 'a', 's', 'd'})
    lib.callback.await('hades_claymore:defuse', false, claymore_id, success);
    
    -- if success then
    --     lib.callback.await('hades_claymore:defuse', false, claymore_id);
    -- else
    --     fail_count = fail_count+1;

    --     if fail_count >= 3 then
    --         local playerPed = PlayerPedId();
    --         local playerCoords = GetEntityCoords(playerPed);
    --         AddExplosion(playerCoords.x, playerCoords.y, playerCoords.z, 2, 1.0, true, false, 1.0);
    --         DeleteObject(entity);
    --     end
    -- end
end