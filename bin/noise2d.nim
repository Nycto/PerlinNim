##
## Draws an 80 by 80 column of noise to the console
##

import noise, math, strutils, private/cli

# The symbols to use for representing noise scale
const symbols = [ " ", "░", "▒", "▓", "█", "█" ]

# Seed the random number generator in Nim
randomize()

# The various config options to be filled from the CLI
var noiseType = perlin
var columns = 80
var rows = 40
var octaves = 1
var persistence = 1.0
var seed = randomSeed()

# Parse the command line options
parseOptions(opts):
    opts.parse(columns, ["width", "w", "cols", "columns"], parseInt(it), it > 0)
    opts.parse(rows, ["height", "h", "rows", "r"], parseInt(it), it > 0)
    opts.parse(octaves, ["octaves", "o"], parseInt(it), it > 0)
    opts.parse(persistence, ["persistence", "p"], parseFloat(it), it > 0)
    opts.parse(seed, ["seed", "s"], uint32(parseInt(it)))
    opts.parseFlag(noiseType, ["perlin"], perlin)
    opts.parseFlag(noiseType, ["simplex"], simplex)

let noiseConf = newNoise(seed, octaves, persistence)

for y in 0..(rows - 1):
    for x in 0..(columns - 1):
        let index = int(floor(symbols.len * noiseConf.get(noiseType, x, y, 0)))
        stdout.write( symbols[index] )
    stdout.write("\n")

