function GetConfig()
    return {
        conditions = {
            explode_on_sprint = GlobalState.hades_claymore_explode_on_sprint or (true),
            trigger_distance = GlobalState.hades_claymore_trigger_distance or 5.0
        },
        defuse = {
            max_attempts = GlobalState.hades_claymore_defuse_max_attempts or 3,
            max_range = 5.0
        },
        pickup = {
            max_range = 5.0
        },
        feature_flags = {
            detection = GlobalState.hades_claymore_feature_flags_detection or (true),
            placement = GlobalState.hades_claymore_feature_flags_placement or (true),
            defuse = GlobalState.hades_claymore_feature_flags_defuse or (true),
            pickup = GlobalState.hades_claymore_feature_flags_pickup or (true)
        },
    }
end