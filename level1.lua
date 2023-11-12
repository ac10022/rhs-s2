local filehandling = require("filehandling")

local level1 = {
    identifier = "level1",
    title = "Level 1",
    theme = THEME.DUAT,
    file_name = "level1.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
    orb_speed = 0.15,
    player_spawn_x = 14,
    map_audio = nil
}

local ORB_LEVELS = {
    UPPER = 1,
    LOWER = 0
}

local function spawn_orb(orb_level)
    
    -- spawn new orb 
    local new_orb = spawn_entity(ENT_TYPE.ITEM_FLOATING_ORB, 29, 107.05 + (orb_level * 4), LAYER.FRONT, 0, 0)
    get_entity(new_orb).user_data = { y = 107.05 + (orb_level * 4) }

    -- stops looping sound
    get_entity(new_orb).sound.playing = false

    -- if orb destroyed remove from list
    get_entity(new_orb):set_post_destroy(function(orb)
        orb.sound.playing = false
        return false
    end)

end

level1.load_level = function()

    if level_state.loaded then return end
    level_state.loaded = true

    -- destroy osiris and anubis
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent)
        ent:destroy()
    end, SPAWN_TYPE.ANY, MASK.MONSTER, 257, 258, 259)

    -- setting camera position
    local camera_center = spawn_entity(ENT_TYPE.ITEM_BROKEN_MATTOCK, 21.0, 109.05, LAYER.FRONT, 0, 0)
    local camera_center_ent = get_entity(camera_center)
    camera_center_ent.flags = set_flag(camera_center_ent.flags, ENT_FLAG.NO_GRAVITY)
    camera_center_ent.flags = set_flag(camera_center_ent.flags, ENT_FLAG.INVISIBLE)
    level_state.callbacks[#level_state.callbacks+1] = set_interval(function()
        state.camera.focused_entity_uid = camera_center
    end, 1)

    -- map content handling
    local map_content = filehandling.read_map("1")
    local map_length
    level_state.map_audio = filehandling.get_map_audio("1")
    if level_state.map_audio then
        level_state.map_audio:play()
    end

    set_timeout(function()
        map_length = filehandling.find_map_length(map_content)
    end, 5)

    set_timeout(function()

        -- if map has content
        if map_content then
            level_state.callbacks[#level_state.callbacks+1] = set_interval(function()
                -- if map has not finished
                if state.time_level < map_length then
                    local current_frame_action = map_content[state.time_level + 97]
                    if current_frame_action ~= nil then
                        if current_frame_action == '1' then
                            spawn_orb(ORB_LEVELS.LOWER)
                        elseif current_frame_action == '2' then
                            spawn_orb(ORB_LEVELS.UPPER)
                        end
                    end
                end
            end, 1)
        end

    end, 10)

    level_state.callbacks[#level_state.callbacks+1] = set_interval(function()
        local orb_speed = -1 * level_state.orb_speed
        for _, orb in ipairs(get_entities_by(ENT_TYPE.ITEM_FLOATING_ORB, MASK.ITEM, LAYER.FRONT)) do
            local orb_ent = get_entity(orb)
            orb_ent.velocityx = orb_speed
            orb_ent.y = orb_ent.user_data.y
            if orb_ent.x < level_state.player_spawn_x - 2 then
                --do_lose_sequence()
                orb_ent:destroy()
            end
        end
    end, 1)

    -- player can't move
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(player)
        player.flags = clr_flag(player.flags, ENT_FLAG.THROWABLE_OR_KNOCKBACKABLE)
        player.flags = set_flag(player.flags, ENT_FLAG.TAKE_NO_DAMAGE)
    end, SPAWN_TYPE.ANY, MASK.PLAYER)

    -- replace bomb and rope with projectiles
    level_state.callbacks[#level_state.callbacks+1] = set_pre_entity_spawn(function(_, x, y, layer)
        local uid = spawn_entity(ENT_TYPE.ITEM_ROCK, x + 0.5, y, layer, 1, 0.2)
        get_entity(uid):set_post_on_collision1(function(ent)
            ent:destroy()
            return false
        end)
        return uid
    end, SPAWN_TYPE.ANY, MASK.ANY, 349, 350, 351, 511, 512)
    
    level_state.callbacks[#level_state.callbacks+1] = set_pre_entity_spawn(function(_, x, y, layer)
        local uid = spawn_entity(ENT_TYPE.ITEM_ROCK, x + 0.5, y, layer, 1, -0.2)
        get_entity(uid):set_post_on_collision1(function(ent)
            ent:destroy()
            return false
        end)
        return uid
    end, SPAWN_TYPE.ANY, MASK.ITEM, 347)

    -- projectiles not affected by gravity
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent)
        ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
    end, SPAWN_TYPE.ANY, MASK.ITEM, ENT_TYPE.ITEM_ROCK)

end

level1.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks

    level_state.loaded = false
    level_state.callbacks = {}

    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end

    -- clear orbs and table
    -- for _, orb in level_state.orbs do
    --     orb:destroy()
    -- end
    -- level_state.orbs = {}

end

return level1