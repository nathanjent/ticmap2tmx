local base64 = require("base64")
local zlib = require("zlib")
local zstd = require("zstd")

local TileDataParser = {}

function TileDataParser:parseCSV(csvStr)
    local data = {}
    local i = 1
    for value in csvStr:gmatch("([^,%s]+)") do
        data[i] = value - 1
        i = i + 1
    end
    return data
end

-- Parse the deprecated XML tile layer format
function TileDataParser:processXML(xmltiledata, size)
    local tiledata = {}
    for i=1,size do
        tiledata[i] = xmltiledata.tile[i]._attr.gid - 1
    end
    return tiledata
end

function TileDataParser:parseBase64(base64tiledata, compression)
    local decodeddata = base64.decode(base64tiledata)

    -- Decompress if compression type provided
    if compression then
        if compression == "gzip"
            or compression == "zlib" then
            decodeddata = zlib.inflate()(decodeddata)
        elseif compression == "zstd" then
            decodeddata = zstd.decompress(decodeddata)
        end
    end

    local bytedata = { decodeddata:byte(1, -1) }
    local tiledata = {}

    -- Step over the extra bytes from 32 bit data
    -- The TIC-80 map is not big enough to use the extra bytes
    for i=1,#bytedata,4 do
        table.insert(tiledata,  bytedata[i] - 1)
    end
    return tiledata
end


return TileDataParser
