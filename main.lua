local filehandling = require("filehandling")

meta = {
    name = 'RHS',
    version = '1.0',
    description = 'test',
    author = 'hi logan',
}

register_option_combo("chosen_map", "Map", "Choose a map to play", filehandling.get_options_string().."\0\0", 1)

local level_sequence = require("LevelSequence/level_sequence")
local IB = require("invisibleblock")
local ib = IB()
--local SIGN_TYPE = level_sequence.SIGN_TYPE

local level1 = require('level1')
local level2 = require('level2')

level_sequence.set_levels({level1, level2})


level_sequence.set_on_win(function(attempts, total_time)
    print("You won!")
	warp(1, 1, THEME.BASE_CAMP)
end)

set_callback(function()
    level_sequence.activate()
end, ON.LOAD)

set_callback(function()
    level_sequence.activate()
end, ON.SCRIPT_ENABLE)

set_callback(function()
    level_sequence.deactivate()
end, ON.SCRIPT_DISABLE)

set_callback(function(ctx, hud)
    hud.opacity = 0
end, ON.RENDER_PRE_HUD)