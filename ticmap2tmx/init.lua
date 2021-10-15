local xml2lua = require("xml2lua")
local tmx2map = require("ticmap2tmx.tmx2map")
local map2tmx = require("ticmap2tmx.map2tmx")

local Ticmap2tmx = {}

function Ticmap2tmx:convert(fromfilename, tofilename)
    print(fromfilename.."-->"..tofilename)

    local fromext = fromfilename:match("[^.]+$")
    local toext = tofilename:match("[^.]+$")

    if fromext == "tmx" and toext == "map" then
        local xml = xml2lua.loadFile(fromfilename)
        local output = tmx2map:convert(xml)
        local tofile  = assert(io.open(tofilename, "wb"))
        tofile:write(output)
        tofile:close()
        print("Converted TMX to MAP.")
    elseif fromext == "map" and toext == "tmx" then
        local fromfile = assert(io.open(fromfilename, "rb"))
        local input = fromfile:read("a")
        local output = map2tmx:convert(input)
        local tofile  = assert(io.open(tofilename, "w"))
        tofile:write(output)
        tofile:close()
        fromfile:close()
        print("Converted MAP to TMX.")
    else
        error("File extensions must be 'tmx'->'map' or 'map'->'tmx' only.")
    end
end

return Ticmap2tmx
