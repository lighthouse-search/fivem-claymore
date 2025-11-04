function GetConfig()
    return {
        conditions = {
            explode_on_sprint = toboolean(GetConvar("hades_claymore_explode_on_sprint", "true")),
            trigger_distance = tonumber(GetConvar("hades_claymore_trigger_distance", "5.0"))
        },
        defuse = {
            max_attempts = tonumber(GetConvar("hades_claymore_defuse_max_attempts", "3")),
            max_range = tonumber(GetConvar("hades_claymore_defuse_max_range", "5.0"))
        },
        pickup = {
            max_range = tonumber(GetConvar("hades_claymore_pickup_max_range", "5.0"))
        },
        feature_flags = {
            detection = toboolean(GetConvar("hades_claymore_feature_flags_detection", "true")),
            placement = toboolean(GetConvar("hades_claymore_feature_flags_placement", "true")),
            defuse = toboolean(GetConvar("hades_claymore_feature_flags_defuse", "true")),
            pickup = toboolean(GetConvar("hades_claymore_feature_flags_pickup", "true")),
        },
        admin = {
            ace_role = GetConvar("hades_claymore_admin_role", "claymore.admin")
        },
        explosion = {
            explosion_type = tonumber(GetConvar("hades_claymore_explosion_type", "28")),
            damage_scale = tonumber(GetConvar("hades_claymore_explosion_damage_scale", "1.0")),
            is_audible = toboolean(GetConvar("hades_claymore_explosion_is_audible", "true")),
            is_invisible = toboolean(GetConvar("hades_claymore_explosion_is_invisible", "false")),
            camera_shake = tonumber(GetConvar("hades_claymore_explosion_camera_shake", "1.0"))
        },
        middleware = {
            
        }
    }
end

function Value_or_default(value, default)
    return value ~= nil and value or default
end

function toboolean(value)
    if value == "true" or value == true then
        return true
    elseif value == "false" or value == false then
        return false
    else
        return nil;
    end;
end