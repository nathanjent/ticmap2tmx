local xml2lua = require("xml2lua")
local tiledataparser = require("ticmap2tmx.tiledataparser")

-- TIC-80 map size
local SIZE = 32640

local Tmx2Map = {}

-- Converts a Tiled TMX file to a TIC-80 map string
function Tmx2Map:convert(xml)
    local tiledata = self:convertToArray(xml)
    return table.unpack(tiledata)
end

-- Converts a Tiled TMX file to a TIC-80 map data array
function Tmx2Map:convertToArray(xml)
    local handler = require("xmlhandler.tree")
    local parser = xml2lua.parser(handler)
    parser:parse(xml)

    local map = handler.root.map
    local data
    if map.layer then
        -- Parser works differently for XML tile data versus CSV and base64?
        data = map.layer.data
    else
        data = map[1].layer.data
    end
    local tiledata
    if data._attr then
        if data._attr.encoding == "csv" then
            tiledata = tiledataparser:parseCSV(data[1])
        elseif data._attr.encoding == "base64" then
            tiledata = tiledataparser:parseBase64(data[1], data._attr.compression)
        end
    else
        tiledata = tiledataparser:processXML(data, SIZE)
    end

    -- TIC-80 doesn't have empty tiles, default to 0
    for i,t in pairs(tiledata) do
        if t < 0 then tiledata[i] = 0 end
    end

    return tiledata
end

return Tmx2Map
