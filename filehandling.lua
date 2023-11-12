local dir = "Maps/"

local function map_exists(map_name)
    local map = io.open_mod(dir..tostring(map_name)..".txt", "r")
    if map then map:close() return true end
    return false
end

local function audio_exists(map_name)
    local map = io.open_mod(dir..tostring(map_name).."_audio.mp3", "r")
    if map then map:close() return true end
    return false
end

local function parse_map_data(map_contents)
    local parsed_table = {}
    for match in string.gmatch(map_contents, '%d%d%d%d%d%d_%d') do
        local index = string.find(match, '_') - 1
        parsed_table[tonumber(string.sub(match, 0, index))] = string.sub(match, index + 2)
    end
    return parsed_table
end

local function find_map_length(map_contents)
    local highest_index = 0
    for a, _ in pairs(map_contents) do
        if highest_index < a then
            highest_index = a    
        end
    end
    return highest_index
end

local function read_map(map_name)
    if map_exists(map_name) then
        local map = io.open_mod(dir..tostring(map_name)..".txt", "r")
        local map_contents = map:read("a")
        map:close()
        return (parse_map_data(tostring(map_contents)))
    else
        return {}
    end
end

local function get_map_audio(map_name)
    if audio_exists(map_name) then
        return create_sound(dir..tostring(map_name).."_audio.mp3")
    else
        return nil
    end
end

return {
    read_map = read_map,
    get_map_audio = get_map_audio,
    map_exists = map_exists,
    audio_exists = audio_exists,
    find_map_length = find_map_length,
}