local xml2lua = require("xml2lua")
local handler = require("xmlhandler.tree")
local base64 = require("base64")
local zlib = require("zlib")
local zstd = require("zstd")
local SIZE = 32640

local Tmx2Map = {}
-- Converts a Tiled TMX file to a TIC-80 map file
function Tmx2Map:convert(xml)
    local parser = xml2lua.parser(handler)
    parser:parse(xml)

    local data = handler.root.map.layer.data
    if data._attr then
        if data._attr.encoding == "csv" then
            local tiledata = {}
            local i = 1
            for value in data[1]:gmatch("([^,%s]+)") do
                tiledata[i] = value - 1
                i = i + 1
            end
            return string.char(table.unpack(tiledata))
        elseif data._attr.encoding == "base64" then
            local decodeddata = base64.decode(data[1])

            -- Decompress if compression type provided
            if data._attr.compression then
                if data._attr.compression == "gzip"
                    or data._attr.compression == "zlib" then
                    decodeddata = zlib.inflate()(decodeddata)
                elseif data._attr.compression == "zstd" then
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

            return string.char(table.unpack(tiledata))
        end
    else
        -- Deprecated XML tile layer format
        local tiledata = {}
        for i=1,SIZE do
            tiledata[i] = data.tile[i]._attr.gid - 1
        end
        return string.char(table.unpack(tiledata))
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
    print("Testing conversion of "..testfile)
    return xml2lua.loadFile(testfile)
end

local function test_TmxXmlToMap()
    local expectedmapdata = loadTestMap()
    local tmxxml = loadTestTmx()

    -- run conversion
    local actualmapdata = Tmx2Map:convert(tmxxml)

    assert(expectedmapdata == actualmapdata, "Tile data mismatch")
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
