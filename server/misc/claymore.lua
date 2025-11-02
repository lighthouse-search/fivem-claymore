-- File description: Miscellaneous claymore-related APIs.

-- Simple function to list claymore information from database.
function claymore_list(start, limit)
    if (start == nil or limit == nil) then
        error("Invalid start or limit parameters.");
        return;
    end

    -- Be careful: This data is sent to clients.
    local response = MySQL.query.await('SELECT `id`, `player_id`, `entity`, `x`, `y`, `z` FROM `hades_claymore` LIMIT ?, ?', {
        start,
        limit
    })

    return response;
end

-- Simple function to fetch claymore information from database by id.
function claymore_get(id)
    -- if id == nil or type(id) ~= "string" then
    --     error("Invalid id parameter: string expected.")
    --     return
    -- end

    local response = MySQL.query.await('SELECT `id`, `player_id`, `entity`, `x`, `y`, `z` FROM `hades_claymore` WHERE `id` = ?', {
        id
    })

    if #response == 0 or response[1] == nil then
        return nil;
    end

    return response[1];
end

-- Create new claymore entry from database.
function claymore_create(player_id, entity, x, y, z)
    local id = MySQL.insert.await('INSERT INTO `hades_claymore` (player_id, entity, x, y, z) VALUES (?, ?, ?, ?, ?)', {
        player_id, entity, x, y, z
    });

    return id;
end

-- Remove claymore entry from database.
function claymore_remove(id, remove_object)
    local claymore = claymore_get(id);
    MySQL.query.await('DELETE FROM `hades_claymore` WHERE `id` = ?', {
        id
    });

    if (claymore ~= nil and remove_object ~= false) then
        DeleteEntity(NetworkGetEntityFromNetworkId(claymore.entity))
    end

    return true;
end

-- Check if player is wearing a claymore.
function is_player_wearing_Claymore(player_id)
    local response = MySQL.query.await('SELECT `type`, `player_id`, `entity`, `x`, `y`, `z` FROM `Claymore_cameras` WHERE `player_id` = ? AND `type` = "player"', {
        player_id
    })

    if #response > 0 then
        return response;
    else
        return nil;
    end
end

function claymore_explode(claymore_id)
    local claymore = claymore_get(claymore_id);
    TriggerClientEvent('fivem:createExplosion', -1, 
        claymore.x, claymore.y, claymore.z, 
        28, 1.0, 
        true, false, 1.0)
end

exports('camera_list', camera_list)
exports('camera_get', camera_get)
exports('claymore_create', claymore_create)
exports('claymore_remove', claymore_remove)
exports('is_player_wearing_Claymore', is_player_wearing_Claymore)
exports('explode_claymore', claymore_explode)