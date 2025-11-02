-- place_self() uses "self"=true. Ox_inventory's "use" export obviously doesn't pass ox_target objects ("data"). passing a special flag here allows us to re-use the existing where_to_place pipeline without creating a duplicate.
function place(data, is_self)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    lib.callback.await('hades_claymore:request_placement', false, coords.x, coords.y, coords.z);
end

exports('place', place);