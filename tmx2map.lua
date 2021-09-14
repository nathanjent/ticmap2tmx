local xml2lua = require("xml2lua")
local handler = require("xmlhandler.tree")
local base64 = require("base64")
local zlib = require("zlib")
local zstd = require("zstd")

-- TIC-80 map size
local SIZE = 32640

local Tmx2Map = {}

local function parseCSV(csvtiledata)
    local tiledata = {}
    local i = 1
    for value in csvtiledata:gmatch("([^,%s]+)") do
        tiledata[i] = value - 1
        i = i + 1
    end
    return tiledata
end

local function test_TmxCsvToMap()
    local expected = {
        1,2,3,4,
        2,4,5,6,
        3,5,6,7,
        4,6,7,8
    }

    local actual = parseCSV([[
        2,3,4,5,
        3,5,6,7,
        4,6,7,8,
        5,7,8,9
        ]])

    for i, e in ipairs(expected) do
        assert(e == actual[i], "Unmatch value at index ["..i.."] "..e.." <> "..actual[i])
    end
end

-- Parse the deprecated XML tile layer format
local function processXMLtiledata(xmltiledata, size)
    local tiledata = {}
    for i=1,size do
        tiledata[i] = xmltiledata.tile[i]._attr.gid - 1
    end
    return tiledata
end

local function test_TmxXmlToMap()
    local expected = {
        1,2,3,4,
        2,4,5,6,
        3,5,6,7,
        4,6,7,8
    }

    local xml = [[
    <data>
        <tile gid="2"/>
        <tile gid="3"/>
        <tile gid="4"/>
        <tile gid="5"/>
        <tile gid="3"/>
        <tile gid="5"/>
        <tile gid="6"/>
        <tile gid="7"/>
        <tile gid="4"/>
        <tile gid="6"/>
        <tile gid="7"/>
        <tile gid="8"/>
        <tile gid="5"/>
        <tile gid="7"/>
        <tile gid="8"/>
        <tile gid="9"/>
    </data>
    ]]

    xml2lua.parser(handler):parse(xml)

    local actual = processXMLtiledata(handler.root.data, 16)

    for i, e in ipairs(expected) do
        assert(e == actual[i], "Unmatch value at index ["..i.."] "..e.." <> "..actual[i])
    end
end

local function parseBase64(base64tiledata, compression)
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

-- Converts a Tiled TMX file to a TIC-80 map file
function Tmx2Map:convert(xml)
    local parser = xml2lua.parser(handler)
    parser:parse(xml)

    local data = handler.root.map.layer.data
    if data._attr then
        if data._attr.encoding == "csv" then
            local tiledata = parseCSV(data[1])
            return string.char(table.unpack(tiledata))
        elseif data._attr.encoding == "base64" then
            local tiledata = parseBase64(data[1], data._attr.compression)
            return string.char(table.unpack(tiledata))
        end
    else
        local tiledata = processXMLtiledata(data, SIZE)
        return string.char(table.unpack(tiledata))
    end
end

return Tmx2Map
