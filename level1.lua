local filehandling = require("filehandling")
local drawing = require("drawing")

local level1 = {
    identifier = "level1",
    title = "Level 1",
    theme = THEME.DUAT,
    file_name = "level1.lvl",
}

local level_state = {
    -- generic
    loaded = false,
    callbacks = {},
    -- game specific
    orb_speed = 0.15,
    map_accuracy_accumulative = 0,
    map_accuracy_percentage = 0,
    notes_passed = 0,
    crit = 0,
    map_audio = nil
}

local function reset_level_state()
    level_state.map_accuracy_accumulative = 0
    level_state.notes_passed = 0
    level_state.map_accuracy_percentage = 0
    level_state.map_audio = nil
    level_state.crit = 0
end

local ORB_LEVELS = {
    UPPER = 1,
    LOWER = 0
}

local HIT_ACCURACY = {
    MARVELOUS = 1.0,
    PERFECT = 0.9825,
    GREAT = 0.65,
    GOOD = 0.25
}

local function recalculate_accuracy(x_destroyed)
    if level_state.notes_passed == 0 then return end
    local deviation = math.abs((x_destroyed/19) - 1)
    if (deviation < 0.05) then
        level_state.map_accuracy_accumulative = level_state.map_accuracy_accumulative + HIT_ACCURACY.MARVELOUS
    elseif (deviation < 0.2) then
        level_state.map_accuracy_accumulative = level_state.map_accuracy_accumulative + HIT_ACCURACY.PERFECT
    elseif (deviation < 0.4) then
        level_state.map_accuracy_accumulative = level_state.map_accuracy_accumulative + HIT_ACCURACY.GREAT
    elseif (deviation < 0.5) then
        level_state.map_accuracy_accumulative = level_state.map_accuracy_accumulative + HIT_ACCURACY.GOOD
    else
        level_state.map_accuracy_accumulative = level_state.map_accuracy_accumulative - 1
    end
    level_state.map_accuracy_percentage = (level_state.map_accuracy_accumulative / level_state.notes_passed) * 100
    drawing.set_accuracy(string.format("%.2f", level_state.map_accuracy_percentage))
end

local function spawn_orb(orb_level)
    
    -- spawn new orb 
    local new_orb = spawn_entity(ENT_TYPE.ITEM_FLOATING_ORB, 29, 107.05 + (orb_level * 4), LAYER.FRONT, 0, 0)
    get_entity(new_orb).user_data = { def_y = 107.05 + (orb_level * 4) }

    -- stops looping sound
    get_entity(new_orb).sound.playing = false

    -- if orb destroyed remove from list
    get_entity(new_orb):set_post_destroy(function(orb)
        if orb.x < 12.5 then
            level_state.crit = 0
        else
            level_state.crit = level_state.crit + 1
        end
        level_state.notes_passed = level_state.notes_passed + 1
        recalculate_accuracy(orb.x)
        drawing.set_crit(tostring(level_state.crit))
        return false
    end)

end

level1.load_level = function()

    if level_state.loaded then return end
    
    reset_level_state()
    drawing.reset_draw_data()
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

    -- ensure map content has been read first
    set_timeout(function()
        map_length = filehandling.find_map_length(map_content)
    end, 5)

    level_state.map_audio = filehandling.get_map_audio("1")
    
    set_timeout(function()
        if level_state.map_audio then
            level_state.map_audio:play()
        end
    end, 10)

    set_timeout(function()

        -- if map has content
        if map_content then
            level_state.callbacks[#level_state.callbacks+1] = set_interval(function()
                -- if map has not finished
                if state.time_level < map_length then
                    -- godd damnit
                    local current_frame_action = map_content[state.time_level + 65]
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

    end, 20)

    level_state.callbacks[#level_state.callbacks+1] = set_interval(function()
        local orb_speed = -1 * level_state.orb_speed
        for _, orb in ipairs(get_entities_by(ENT_TYPE.ITEM_FLOATING_ORB, MASK.ITEM, LAYER.FRONT)) do
            
            local orb_ent = get_entity(orb)

            -- make orb move
            orb_ent.velocityx = orb_speed
            -- make orb wavy
            orb_ent.y = orb_ent.user_data.def_y + ((-math.sin(0.571 * (orb_ent.x - 23.5))) * 0.2)

            -- miss
            if orb_ent.x < 12 then
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
        return uid
    end, SPAWN_TYPE.ANY, MASK.ANY, 349, 350, 351, 511, 512)
    
    level_state.callbacks[#level_state.callbacks+1] = set_pre_entity_spawn(function(_, x, y, layer)
        local uid = spawn_entity(ENT_TYPE.ITEM_ROCK, x + 0.5, y, layer, 1, -0.2)
        return uid
    end, SPAWN_TYPE.ANY, MASK.ITEM, 347)

    -- projectiles not affected by gravity
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent)
        ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
        ent.hitboxx = ent.hitboxx * 2
        ent.hitboxy = ent.hitboxy * 2
        ent:set_post_on_collision1(function(ent)
            ent:destroy()
            return false
        end)
    end, SPAWN_TYPE.ANY, MASK.ITEM, ENT_TYPE.ITEM_ROCK)

end

level1.unload_level = function()
    if not level_state.loaded then return end

    drawing.reset_draw_data()

    local callbacks_to_clear = level_state.callbacks

    level_state.loaded = false
    level_state.callbacks = {}

    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return level1