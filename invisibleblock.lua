define_tile_code("invisibleblock")
local invisibleblock_tilecode

local TEXTURE = TextureDefinition.new()
TEXTURE.width, TEXTURE.height, TEXTURE.tile_width, TEXTURE.tile_height, TEXTURE.texture_path = 128, 128, 128, 128, "Sprites/invisibleblock.png"

local function activate()

    local function spawn_invisible_block(x, y, layer)
        local ib_uid = spawn_entity(ENT_TYPE.FLOOR_YAMA_PLATFORM, x, y, layer, 0, 0)
        local ib = get_entity(ib_uid)
        ib:set_texture(define_texture(TEXTURE))
        return ib
    end

    invisibleblock_tilecode = set_pre_tile_code_callback(function(x, y, layer)
        local ib = spawn_invisible_block(x, y, layer)
        return true
    end, "invisibleblock")

    return {
        spawn_invisible_block = spawn_invisible_block
    }

end

return activate