# Package

version       = "0.6.0"
author        = "Nycto"
description   = "A Perlin Noise Implementation"
license       = "MIT"
srcDir        = "src"
skipDirs      = @[]

# Deps

requires "nim >= 0.14.0"

# Targets

task demo, "Executes demo code":
    exec "nimble c ./bin/noise1d.nim"
    exec "nimble c ./bin/noise2d.nim"
    exec "./bin/noise2d --perlin"
    exec "./bin/noise1d --perlin"
    exec "./bin/noise2d --simplex"
    exec "./bin/noise1d --simplex --zoom=2"

