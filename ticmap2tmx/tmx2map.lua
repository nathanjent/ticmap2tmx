local xml2lua = require("xml2lua")
local tiledataparser = require("ticmap2tmx.tiledataparser")

-- TIC-80 map size
local SIZE = 32640

local Tmx2Map = {}

-- Converts a Tiled TMX file to a TIC-80 map string
function Tmx2Map:convert(xml)
    local tiledata = self:convertToArray(xml)
    return string.char(table.unpack(tiledata))
end

-- Converts a Tiled TMX file to a TIC-80 map data array
function Tmx2Map:convertToArray(xml)
    local handler = require("xmlhandler.tree")
    local parser = xml2lua.parser(handler)
    parser:parse(xml)

    local data = handler.root.map.layer.data
    if data._attr then
        if data._attr.encoding == "csv" then
            return tiledataparser:parseCSV(data[1])
        elseif data._attr.encoding == "base64" then
            return tiledataparser:parseBase64(data[1], data._attr.compression)
        end
    else
        return tiledataparser:processXML(data, SIZE)
    end
end

return Tmx2Map
