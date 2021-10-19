local xml2lua = require("xml2lua")

local Map2Tmx = {}

-- Parse map data
function Map2Tmx.parseMapData(mapdata)
    local mapvalues = {}
    for c in mapdata:gmatch('.') do
        table.insert(mapvalues, c:byte() + 1)
    end
    return mapvalues
end

-- Converts a TIC-80 map file to a Tiled TMX file.
-- Only support CSV tile data currently.
function Map2Tmx:convert(input)
    local tmxdata = {
        map = {
            _attr = {
                version = "1.5",
                tiledversion = "1.7.2",
                orientation = "orthogonal",
                renderorder = "left-up",
                width = 240,
                height = 136,
                tilewidth = 8,
                tileheight = 8,
                nextobjectid = 1,
                nextlayerid = 2,
                infinite = 0,
            },
            layer = {
                _attr = {
                    id= 1,
                    name = "Tile Layer 1",
                    width = 240,
                    height = 136
                },
                data = {
                    _attr = {
                        encoding = "csv"
                    },
                },
            },
            tileset = {
                _attr = {
                    firstgid = 1,
                    source = "tiles.tsx"
                },
            },
        },
    }

    local mapvalues = self:parseMapData(input)

    -- Create CSV string
    local csvstring = ""
    for i,v in ipairs(mapvalues) do
        csvstring = csvstring..v..","
        if i % tmxdata.map.layer._attr.width == 0 then
            csvstring = csvstring.."\n"
        end
    end

    -- Remove final comma and newline characters
    csvstring = csvstring:sub(1, -3)
    tmxdata.map.layer.data[1] = csvstring

    -- Add XML header to generated string
    return '<?xml version="1.0" encoding="UTF-8"?>\n'..xml2lua.toXml(tmxdata)
end

return Map2Tmx
