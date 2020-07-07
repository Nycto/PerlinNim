##
## Draws an 80 by 80 column of noise to the console
##

import perlin, math, random, strutils, private/cli, sugar

# Seed the random number generator in Nim
randomize()

# The various config options to be filled from the CLI
var noiseType = NoiseType.perlin
var columns = 80
var rows = 40
var octaves = 1
var persistence = 1.0
var seed = randomSeed()
var zoom = 1.0

# Parse the command line options
parse(
    option(proc(it: int) = columns = it, ["width", "w", "cols", "columns"], (it) => parseInt(it), (it) => it > 0),
    option(proc(it: int) = rows = it, ["height", "h", "rows", "r"], (it) => parseInt(it), (it) => it > 0),
    option(proc(it: int) = octaves = it, ["octaves", "o"], (it) => parseInt(it), (it) => it > 0),
    option(proc(it: float) = persistence = it, ["persistence", "p"], (it) => parseFloat(it), (it) => it > 0),
    option(proc(it: uint32) = seed = it, ["seed", "s"], (it) => uint32(parseInt(it))),
    option(proc(it: float) = zoom = it, ["zoom", "z"], (it) => parseFloat(it), (it) => it > 0),
    flag(proc() = noiseType = NoiseType.perlin, ["perlin"]),
    flag(proc() = noiseType = NoiseType.simplex, ["simplex"])
)

let noiseConf = newNoise(seed, octaves, persistence)

# The symbols to use for representing noise scale
const symbols = [ " ", "░", "▒", "▓", "█", "█" ]

for y in 0..(rows - 1):
    for x in 0..(columns - 1):
        let rand = noiseConf.get(noiseType, float(x) / zoom, float(y) / zoom)
        let index = int(floor(symbols.len * rand))
        stdout.write( symbols[index] )
    stdout.write("\n")

