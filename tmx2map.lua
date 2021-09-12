local xml2lua = require("xml2lua")
local handler = require("xmlhandler.tree")
local base64 = require("base64")
local SIZE = 32640

local Tmx2Map = {}
-- Converts a Tiled TMX file to a TIC-80 map file
function Tmx2Map:convert(xml)
    local parser = xml2lua.parser(handler)
    parser:parse(xml)

    print(handler.root.map.layer)
    for index, value in pairs(handler.root.map.layer) do
     print(index, ':', value)
    end
    local data = handler.root.map.layer.data
    local mapdata = {}
    if data._attr then
        if data._attr.encoding == "csv" then
            local csvdata = data[1]
            local i = 1
            for value in csvdata:gmatch("([^,%s]+)") do
                mapdata[i] = value - 1
                i = i + 1
            end
        elseif data._attr.encoding == "base64" then
            if data._attr.compression then
                if data._attr.compression == "gzip" then
                    print(data)
                elseif data._attr.compression == "zlib" then
                    print(data)
                elseif data._attr.compression == "zstd" then
                    print(data)
                end
            else
                -- uncompressed
                local decodeddata = base64.decode(data[1])
                mapdata = decodeddata
                --local i = 1
                --for value in decodeddata:gmatch('.') do
                --    print(i, ":", value)
                --    mapdata[i] = ("<I4"):unpack(value) - 1
                --    i = i + 1
                --end
            end
        end
    else
        -- Deprecated XML tile layer format
        local tiles = data.tile
        for i=1,SIZE do
            mapdata[i] = tiles[i]._attr.gid - 1
        end
    end

    if type(mapdata) == "table" then
     return string.char(table.unpack(mapdata))
    else
     return mapdata
    end
end

local function loadTestMap()
 local mapfile, e = io.open("./testassets/test.map", "rb")
 if mapfile then
  local mapdata = mapfile:read("*a")
  mapfile:close()
  return mapdata
 end
 error(e)
end

local function loadTestTmx(encoding, compression)
 local testfile = ""
 local filenamepart1 = "./testassets/test_"
 local filenamepart2 = "_layerdata.tmx"
 if not encoding then
  -- Deprecated XML
  testfile = filenamepart1.."xml"..filenamepart2
 elseif not compression then
  -- Uncompressed
  testfile = filenamepart1..encoding..filenamepart2
 else
  -- Compressed
  testfile = filenamepart1..encoding..compression..filenamepart2
 end
  return xml2lua.loadFile(testfile)
end

local function test_TmxCsvToMap()
 local expectedmapdata = loadTestMap()
 local tmxxmlcsv = loadTestTmx("csv")

 -- run conversion
 local actualmapdata = Tmx2Map:convert(tmxxmlcsv)

 assert(expectedmapdata == actualmapdata, "Tile data mismatch")
end

local function test_TmxBase64ToMap()
 local expectedmapdata = loadTestMap()
 local tmxxmlbase64 = loadTestTmx("base64")

 -- run conversion
 local actualmapdata = Tmx2Map:convert(tmxxmlbase64)

 assert(expectedmapdata == actualmapdata, "Tile data mismatch")
end

return Tmx2Map
