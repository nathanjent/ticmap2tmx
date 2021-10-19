describe("MAP to TMX conversion", function()
   local map2tmx = require("ticmap2tmx.map2tmx")
   local xml2lua = require("xml2lua")

   -- load test files that should not be modified by tests
   local mapfile = assert(io.open("./spec/assets/test.map", "rb"))
   local mapdata = mapfile:read("a")
   mapfile:close()

   it("should convert a MAP file to TMX with CSV tile data", function()

      local expectedxml = xml2lua.loadFile("./spec/assets/test_csv_layerdata.tmx")

      -- run conversion
      local actualxml = map2tmx:convert(mapdata)

      -- parse the outputs to compare
      local expectedhandler = require("xmlhandler.tree")
      xml2lua.parser(expectedhandler):parse(expectedxml)

      local actualhandler = require("xmlhandler.tree")
      xml2lua.parser(actualhandler):parse(actualxml)

      local expecteddata = expectedhandler.root.map[1].layer.data[1]
      local actualdata = actualhandler.root.map[1].layer.data[1]
      assert(expecteddata == actualdata, "Tile data mismatch.")
   end)
end)
