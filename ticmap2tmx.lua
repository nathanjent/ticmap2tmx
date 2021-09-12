#!/usr/bin/env lua

local xml2lua = require("xml2lua")
local tmx2map = require("tmx2map")
local map2tmx = require("map2tmx")

local fromfilename = arg[1]
local tofilename = arg[2]
print(fromfilename.."-->"..tofilename)

local fromext = fromfilename:match("[^.]+$")
local toext = tofilename:match("[^.]+$")

if fromext == "tmx" and toext == "map" then
    local xml = xml2lua.loadFile(fromfilename)
    local output = tmx2map:convert(xml)
    local tofile  = io.open(tofilename, "wb")
    tofile:write(output)
    tofile:close()
elseif fromext == "map" and toext == "tmx" then
    local fromfile = io.open(fromfilename, "rb")
    local input = fromfile:read("a")
    local output = map2tmx:convert(input)
    local tofile  = io.open(tofilename, "w")
    tofile:write(output)
    tofile:close()
    fromfile:close()
end
