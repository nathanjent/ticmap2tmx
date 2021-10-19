describe("TMX to MAP conversion", function ()
   local tmx2map = require("ticmap2tmx.tmx2map")
   local map2tmx = require("ticmap2tmx.map2tmx")

   local mapfile = assert(io.open("./spec/assets/test.map", "rb"))
   local mapdata = mapfile:read("a")
   mapfile:close()
   local mapvalues = map2tmx:parseMapData(mapdata)

   describe("with XML tile data", function()
      -- load test files that should not be modified by tests
      local tmxfile = assert(io.open("./spec/assets/test_xml_layerdata.tmx", "rb"))
      local tmxdata = tmxfile:read("a")
      tmxfile:close()

      it("should convert to a MAP file", function ()
         local actualmapdata = tmx2map:convertToArray(tmxdata)
         for i,c in ipairs(actualmapdata) do
            assert(mapvalues[i] == c + 1, "Map mismatch at "..i)
         end
      end)
   end)

   describe("with CSV tile data", function()
      -- load test files that should not be modified by tests
      local tmxfile = assert(io.open("./spec/assets/test_csv_layerdata.tmx", "rb"))
      local tmxdata = tmxfile:read("a")
      tmxfile:close()

      it("should convert to a MAP file", function ()
         local actualmapdata = tmx2map:convertToArray(tmxdata)
         for i,c in ipairs(actualmapdata) do
            assert(mapvalues[i] == c + 1, "Map mismatch at "..i)
         end
      end)
   end)

   describe("with Base64 uncompressed tile data", function()
      -- load test files that should not be modified by tests
      local tmxfile = assert(io.open("./spec/assets/test_base64_layerdata.tmx", "rb"))
      local tmxdata = tmxfile:read("a")
      tmxfile:close()

      it("should convert to a MAP file", function ()
         local actualmapdata = tmx2map:convertToArray(tmxdata)
         for i,c in ipairs(actualmapdata) do
            assert(mapvalues[i] == c + 1, "Map mismatch at "..i)
         end
      end)
   end)

   describe("with Base64 gzip compressed tile data", function()
      -- load test files that should not be modified by tests
      local tmxfile = assert(io.open("./spec/assets/test_base64_gzip_layerdata.tmx", "rb"))
      local tmxdata = tmxfile:read("a")
      tmxfile:close()

      it("should convert to a MAP file", function ()
         local actualmapdata = tmx2map:convertToArray(tmxdata)
         for i,c in ipairs(actualmapdata) do
            assert(mapvalues[i] == c + 1, "Map mismatch at "..i)
         end
      end)
   end)

   describe("with Base64 zlib compressed tile data", function()
      -- load test files that should not be modified by tests
      local tmxfile = assert(io.open("./spec/assets/test_base64_zlib_layerdata.tmx", "rb"))
      local tmxdata = tmxfile:read("a")
      tmxfile:close()

      it("should convert to a MAP file", function ()
         local actualmapdata = tmx2map:convertToArray(tmxdata)
         for i,c in ipairs(actualmapdata) do
            assert(mapvalues[i] == c + 1, "Map mismatch at "..i)
         end
      end)
   end)

   describe("with Base64 Zstandard compressed tile data", function()
      -- load test files that should not be modified by tests
      local tmxfile = assert(io.open("./spec/assets/test_base64_zstd_layerdata.tmx", "rb"))
      local tmxdata = tmxfile:read("a")
      tmxfile:close()

      it("should convert to a MAP file", function ()
         local actualmapdata = tmx2map:convertToArray(tmxdata)
         for i,c in ipairs(actualmapdata) do
            assert(mapvalues[i] == c + 1, "Map mismatch at "..i)
         end
      end)
   end)
end)
