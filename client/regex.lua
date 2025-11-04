function parse_coordinates(coord_string)
    local parts = {}
    for part in string.gmatch(coord_string, "([^,]+)") do
        part = part:gsub("^%s*(.-)%s*$", "%1")
        table.insert(parts, tonumber(part))
    end

    if #parts < 3 or not parts[1] or not parts[2] or not parts[3] then
        lib.notify({ description = 'Invalid coordinates. Use "x, y, z"', type = 'error' })
        return
    end

    return {
        x = parts[1],
        y = parts[2],
        z = parts[3]
    }
end