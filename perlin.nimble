# Package

version       = "0.6.0"
author        = "Nycto"
description   = "A Perlin Noise Implementation"
license       = "MIT"
skipDirs      = @["test", ".build", "bin"]

# Deps

requires "nim >= 0.14.0"

# Targets

exec "test -d .build/ExtraNimble || git clone https://github.com/Nycto/ExtraNimble.git .build/ExtraNimble"
when existsDir(thisDir() & "/.build"):
    include ".build/ExtraNimble/extranimble.nim"

after bin:
    exec ".build/bin/noise2d.nim".outBin & " --perlin"
    exec ".build/bin/noise1d.nim".outBin & " --perlin"
    exec ".build/bin/noise2d.nim".outBin & " --simplex"
    exec ".build/bin/noise1d.nim".outBin & " --simplex --zoom=2"

