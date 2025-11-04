function place()
    lib.callback.await('hades_claymore:request_placement', false);
end

exports('place', place);