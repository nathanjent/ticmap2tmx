describe("Tile data parser", function ()
    local parser = require("ticmap2tmx.tiledataparser")
    it("should convert from TMX with CSV formatted tile data", function ()
        local expected = {
            1,2,3,4,
            2,4,5,6,
            3,5,6,7,
            4,6,7,8
        }

        local actual = parser:parseCSV([[
            2,3,4,5,
            3,5,6,7,
            4,6,7,8,
            5,7,8,9
            ]])

        for i, e in ipairs(expected) do
            assert.same(e, actual[i], "Unmatch value at index ["..i.."] "..e.." <> "..actual[i])
        end
    end)

    it("should process XML tile data into a list", function ()
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
        local xml2lua = require("xml2lua")
        local handler = require("xmlhandler.tree")
        xml2lua.parser(handler):parse(xml)
        local actual = parser:processXML(handler.root.data, 16)

        for i, e in ipairs(expected) do
            assert(e == actual[i], "Unmatch value at index ["..i.."] "..e.." <> "..actual[i])
        end
    end)
end)
