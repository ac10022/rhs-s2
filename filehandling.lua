local dir = "Maps/"
local loaded_map_names = {}

local function map_exists(map_name)
    local map = io.open_mod(dir..tostring(map_name).."/"..tostring(map_name)..".txt", "r")
    if map then map:close() return true end
    return false
end

local function audio_exists(map_name)
    local map = io.open_mod(dir..tostring(map_name).."/"..tostring(map_name).."_audio.mp3", "r")
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

local function total_notes(map_contents)
    local highest_index = find_map_length(map_contents)
    if highest_index == 0 then return 0 end
    local note_tally = 0
    for i = 1, highest_index, 1 do
        if map_contents[i] ~= nil then
            note_tally = note_tally + 1
        end
    end
    return note_tally
end

local function read_map(map_name)
    if map_exists(map_name) then
        local map = io.open_mod(dir..tostring(map_name).."/"..tostring(map_name)..".txt", "r")
        local map_contents = map:read("a")
        map:close()
        return (parse_map_data(tostring(map_contents)))
    else
        return {}
    end
end

local function get_pure_map_content(map_name)
    if map_exists(map_name) then
        local map = io.open_mod(dir..tostring(map_name).."/"..tostring(map_name)..".txt", "r")
        return map:read("a")
    else
        return ""
    end
end

local function get_map_audio(map_name)
    if audio_exists(map_name) then
        return create_sound(dir..tostring(map_name).."/"..tostring(map_name).."_audio.mp3")
    else
        return nil
    end
end

local function get_all_official_maps()
    local map_list = {}
    local list = io.open_mod(dir.."MAPS_DIR.txt", "r")
    local list_contents
    if list then
        list_contents = list:read("a")
    else
        return map_list
    end
    for match in string.gmatch(list_contents, '%d%d%d%d%d%d') do
        local parsed_match = tostring(tonumber(match))
        if map_exists(parsed_match) and audio_exists(parsed_match) then
            table.insert(map_list, parsed_match)
        end
    end
    return map_list
end

local function get_map_order()
    if loaded_map_names then
        return loaded_map_names
    else 
        return {}
    end
end

local function get_map_metadata(map_content)
    local name, song, author, difficulty = nil, nil, nil, nil
    local start_i = string.find(map_content, "Title:")
    local end_i = string.find(map_content, "Song:")
    if start_i and end_i then
        name = string.sub(map_content, start_i + 7, end_i - 2)
    end
    start_i = string.find(map_content, "Song:")
    end_i = string.find(map_content, "Author:")
    if start_i and end_i then
        song = string.sub(map_content, start_i + 6, end_i - 2)
    end
    start_i = string.find(map_content, "Author:")
    end_i = string.find(map_content, "Difficulty:")
    if start_i and end_i then
        author = string.sub(map_content, start_i + 8, end_i - 2)
    end
    start_i = string.find(map_content, "Difficulty:")
    end_i = string.find(map_content, "END")
    if start_i and end_i then
        difficulty = string.sub(map_content, start_i + 12, end_i - 2)
    end
    return name, song, author, difficulty
end

local function get_all_official_maps_metadata()
    local maps_with_metadata = {}
    for _, map_name in pairs(get_all_official_maps()) do
        local name, song, author, difficulty = get_map_metadata(get_pure_map_content(tostring(map_name)))
        local new_table = { name = name, song = song, author = author, difficulty = difficulty }
        maps_with_metadata[tostring(map_name)] = new_table
    end
    return maps_with_metadata
end

local function get_options_string()
    local options_string = ""
    for map_name, metadata in pairs(get_all_official_maps_metadata()) do
        options_string = options_string..tostring(metadata.name).." ["..tostring(metadata.difficulty).."]\nby "..tostring(metadata.author).."\0"
        table.insert(loaded_map_names, map_name)
    end
    return options_string
end

local function push_save_data_to_file(save_table, map_name)
    local save_file, err = io.open_mod(dir..tostring(map_name).."/"..tostring(map_name).."saves.txt", "w")
    if err then
        print(err)
    end
    if save_file then
        save_file:write(F"{save_table.score}\n{save_table.highest_crit}\n{save_table.date_time}")
        save_file:close()
    end
end

return {
    read_map = read_map,
    get_map_audio = get_map_audio,
    map_exists = map_exists,
    audio_exists = audio_exists,
    find_map_length = find_map_length,
    get_all_official_maps = get_all_official_maps,
    get_map_metadata = get_map_metadata,
    get_pure_map_content = get_pure_map_content,
    get_all_official_maps_metadata = get_all_official_maps_metadata,
    get_options_string = get_options_string,
    get_map_order = get_map_order,
    total_notes = total_notes,
    push_save_data_to_file = push_save_data_to_file,
}