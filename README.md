# TIC-80 Map to Tiled TMX

A tool to convert between TIC-80 map export data and Tiled TMX format.

I took [TiledMapEditor-TIC-80](https://github.com/AlRado/TiledMapEditor-TIC-80)
and ported it Lua. I wanted it to be in a language that a majority of
TIC-80 users would understand. I also wanted to update it to work with
recent versions of TIC-80 and Tiled applications.

## Install

Install from luarocks.org.

    luarocks install ticmap2tmx

## Convert from TIC-80 Map to Tiled TMX

From TIC-80 export your map data.

    export map mytic80.map

Run the installed rock.

    ticmap2tmx mytic80.map mytic80.tmx

## Convert from Tiled TMX to TIC-80 Map

TIC-80 maps should be setup in Tiled with specific parameters. Only one tileset
of 16x16 should be used. (I think you can only use one of either the tiles or
sprites tileset on a map at a time in TIC-80.)

### Map Settings

- Width: 240
- Height: 136
- Tile width: 8
- Tile height: 8
- Tile layer format: [ XML, CSV, Base64 ]
  - Supported Base64 compression formats
    - gzip (lua-zlib)
    - zlib (lua-zlib)
  - Unsupported Base64 compression formats
    - zstd (lua-zstd)
      - Support dropped to wait on OS adoption.

### Tileset Settings

- Grid width: 8
- Grid height: 8

Convert your TMX file to a TIC-80 map. Save it to a location accessible to the
TIC-80 application.

    ticmap2tmx mytic80.tmx mytic80.map

From TIC-80 import your map data.

    import map mytic80.map
