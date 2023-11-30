local top_left
local top_right
local bottom_left
local bottom_right

local rainbow = {
    r = nil,
    g = nil,
    b = nil
}

local function get_screen_bounds()
    local tl = Vec2:new(game_position(-1, 1))
    local tr = Vec2:new(game_position(1, 1))
    local bl = Vec2:new(game_position(-1, -1))
    local br = Vec2:new(game_position(1, -1))
    top_left, top_right, bottom_left, bottom_right = tl, tr, bl, br
    return tl, tr, bl, br
end

local function do_horizontal_effect(size, speed, strobe, do_rainbow)
    speed = speed or 1
    for i = 0, math.ceil(top_right.x - top_left.x), 1 do
        set_timeout(function()
            local r, g, b
            if do_rainbow == true then
                r = math.floor(rainbow.r * (120/255))
                g = math.floor(rainbow.g * (120/255))
                b = math.floor(rainbow.b * (120/255))
            else
                r = math.random(120)
                g = math.random(120)
                b = math.random(120)
            end
            local light = create_illumination(Color:new(r, g, b, 255), 1.0 * size, i + top_left.x, math.random(math.floor(bottom_left.y), math.floor(top_left.y)))
            light.brightness = 0.5
            -- strobe effect thing
            if strobe then
                light.distortion = 10
            end
        end, math.floor((i * 5) / speed))
    end
end

local function do_horizontal_effect_with_pattern(size, speed, strobe, fun, do_rainbow)
    speed = speed or 1
    for i = 0, math.ceil(top_right.x - top_left.x), 1 do
        set_timeout(function()
            local r, g, b
            if do_rainbow == true then
                r = math.floor(rainbow.r * (120/255))
                g = math.floor(rainbow.g * (120/255))
                b = math.floor(rainbow.b * (120/255))
            else
                r = math.random(120)
                g = math.random(120)
                b = math.random(120)
            end
            local light = create_illumination(Color:new(r, g, b, 255), 1.0 * size, i + top_left.x, fun(i + top_left.x))
            light.brightness = 0.5
            -- strobe effect thing
            if strobe then
                light.distortion = 10
            end
        end, math.floor((i * 5) / speed))
    end
end

local function streak_effect()
    set_timeout(function()
        do_horizontal_effect_with_pattern(2, 2, true, function(x)
            return (1.5 * math.sin(x)) + ((top_left.y + bottom_left.y) / 2)
        end, true)
    end, 0)
    set_timeout(function()
        do_horizontal_effect_with_pattern(2, 2, true, function(x)
            return (1.5 * math.sin(x)) + ((top_left.y + bottom_left.y) / 2) + 2
        end, true)
    end, 10)
    set_timeout(function()
        do_horizontal_effect_with_pattern(2, 2, true, function(x)
            return (1.5 * math.sin(x)) + ((top_left.y + bottom_left.y) / 2) - 4
        end, true)
    end, 20)
    set_timeout(function()
        do_horizontal_effect_with_pattern(2, 2, true, function(x)
            return (1.5 * math.sin(x)) + ((top_left.y + bottom_left.y) / 2) - 1
        end, true)
    end, 30)
    set_timeout(function()
        do_horizontal_effect_with_pattern(2, 2, true, function(x)
            return (1.5 * math.sin(x)) + ((top_left.y + bottom_left.y) / 2) + 4
        end, true)
    end, 40)
end

set_callback(function()
    local global_frame = get_global_frame()
    rainbow.r = (255/2) * (math.sin((global_frame/15)) + 1)
    rainbow.g = (255/2) * (math.sin((global_frame/15) - 2) + 1)
    rainbow.b = (255/2) * (math.sin((global_frame/15) - 4) + 1)
end, ON.GUIFRAME)

return {
    get_screen_bounds = get_screen_bounds,
    do_horizontal_effect = do_horizontal_effect,
    do_horizontal_effect_with_pattern = do_horizontal_effect_with_pattern,
    streak_effect = streak_effect,
}