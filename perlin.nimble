# Package

version       = "0.6.0"
author        = "Nycto"
description   = "A Perlin Noise Implementation"
license       = "MIT"
srcDir        = "src"
skipDirs      = @[]

# Deps

requires "nim >= 0.14.0"

## Targets
#
#after bin:
#    exec ".build/bin/noise2d.nim".outBin & " --perlin"
#    exec ".build/bin/noise1d.nim".outBin & " --perlin"
#    exec ".build/bin/noise2d.nim".outBin & " --simplex"
#    exec ".build/bin/noise1d.nim".outBin & " --simplex --zoom=2"

