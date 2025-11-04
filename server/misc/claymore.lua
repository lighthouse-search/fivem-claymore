-- File description: Miscellaneous claymore-related APIs.

-- Simple function to list claymore information from database.
function claymore_list(start, limit)
    -- Be careful: This data is sent to clients.
    local query = 'SELECT `id`, `player_id`, `entity`, `x`, `y`, `z` FROM `hades_claymore`';
    if start ~= nil or limit ~= nil then
        query = query .. ' LIMIT ?, ?';
    end

    local params = {};
    if start ~= nil or limit ~= nil then
        params = { start, limit };
    end

    local response = MySQL.query.await(query, params);

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

function claymore_update(claymore_id, data)
    local claymore = claymore_get(claymore_id);
    if claymore == nil then
        TriggerClientEvent('ox_lib:notify', player_id, { type = 'error', title = 'Claymore Failed', description = "Claymore not found." });
        return;
    end
    
    local coordinates = data.coordinates;
    local obj = NetworkGetEntityFromNetworkId(claymore.entity);
    local state = Entity(obj).state;

    local id = MySQL.insert.await('UPDATE `hades_claymore` SET player_id=?, x=?, y=?, z=? WHERE id=?', {
        data.player_id or claymore.player_id, coordinates.x or claymore.x, coordinates.y or claymore.y, coordinates.z or claymore.z, claymore_id
    });

    Entity(obj).state:set('enabled', data.enabled, true);
    Entity(obj).state:set('player_id', data.player_id or claymore.player_id, true);
    Entity(obj).state:set('permissions', data.permissions or state.permissions, true);

    return claymore_id;
end

-- Remove claymore entry from database.
function claymore_remove(id, remove_object)
    local claymore = claymore_get(id);
    MySQL.query.await('DELETE FROM `hades_claymore` WHERE `id` = ?', {
        id
    });

    if (claymore ~= nil and remove_object ~= false) then
        DeleteEntity(NetworkGetEntityFromNetworkId(claymore.entity));
    end

    return true;
end

function claymore_explode(claymore_id)
    -- Tell all clients to create explosion inside world.
    local config = GetConfig();

    local claymore = claymore_get(claymore_id);
    TriggerClientEvent('fivem:createExplosion', -1, 
        claymore.x, claymore.y, claymore.z, 
        config.explosion.explosion_type, config.explosion.damage_scale, 
        config.explosion.is_audible, config.explosion.is_invisible, config.explosion.camera_shake)
end

exports('claymore_list', claymore_list)
exports('claymore_get', claymore_get)
exports('claymore_create', claymore_create)
exports('claymore_remove', claymore_remove)
exports('claymore_explode', claymore_explode)