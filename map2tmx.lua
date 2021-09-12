local xml2lua = require("xml2lua")

local Map2Tmx = {}
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

 -- parse map data
 local mapvalues = {}
 for c in input:gmatch('.') do
  table.insert(mapvalues, c:byte() + 1)
 end

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

local function test_MapToTmx()
 -- load test files that should not be modified by tests
 local mapfile, maperr = io.open("./testassets/test.map", "rb")
 if not mapfile then
  error(maperr)
 end
 local mapdata = mapfile:read("a")
 mapfile:close()

 local expectedxml = xml2lua.loadFile("./testassets/test_csv_layerdata.tmx")

 -- run conversion
 local actualxml = Map2Tmx:convert(mapdata)

 -- parse the outputs to compare
 local expectedhandler = require("xmlhandler.tree")
 xml2lua.parser(expectedhandler):parse(expectedxml)

 local actualhandler = require("xmlhandler.tree")
 xml2lua.parser(actualhandler):parse(actualxml)

 local expecteddata = expectedhandler.root.map[1].layer.data[1]
 local actualdata = actualhandler.root.map[1].layer.data[1]
 assert(expecteddata == actualdata, "Tile data mismatch.")
end

return Map2Tmx
