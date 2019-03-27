##
## Creates a PPM image file of perlin noise
##

import perlin, math, random, parseopt2, os, strutils, private/cli

# Seed the random number generator in Nim
randomize()

# The various config options to be filled from the CLI
var filename: string
var noiseType = NoiseType.perlin
var width = 600
var height = 600
var octaves = 1
var persistence = 1.0
var seed = randomSeed()
var zoom = 1.0

# Parse the command line options
parseOptions(opts):
    opts.parse(width, ["width", "w"], parseInt(it), it > 0)
    opts.parse(height, ["height", "h"], parseInt(it), it > 0)
    opts.parse(octaves, ["octaves", "o"], parseInt(it), it > 0)
    opts.parse(persistence, ["persistence", "p"], parseFloat(it), it > 0)
    opts.parse(seed, ["seed", "s"], uint32(parseInt(it)))
    opts.parse(zoom, ["zoom", "z"], parseFloat(it), it > 0)
    opts.parseFlag(noiseType, ["perlin"], NoiseType.perlin)
    opts.parseFlag(noiseType, ["simplex"], NoiseType.simplex)

    opts.parseArg(filename)
    if not filename.strip.toLowerAscii.endsWith(".ppm"):
        filename = filename.strip & ".ppm"


type PpmImage = object
    ## Creates a PPM file
    file: File
    width, height: int

proc newPPM( filename: string, width, height: int ): PpmImage =
    ## Creates a new PPM
    assert( width > 0 )
    assert( height > 0 )
    assert( filename.len > 0 )

    var image = PpmImage(
        file: open(filename, fmwrite),
        width: width, height: height)

    image.file.write( "P3\n" )
    image.file.write( width, " ", height, "\n" )
    image.file.write( "255\n" )
    return image

proc draw( image: var PpmImage, r, g, b: int ) =
    ## Writes a pixel to a Ppm file
    assert( r >= 0 and g >= 0 and b >= 0 )
    assert( r <= 255 and g <= 255 and b <= 255 )
    image.file.write( r, " ", g, " ", b, "\n" )

iterator pixels( image: PpmImage ): tuple[x, y: int] =
    ## Presents each pixel in this image in the order it appears in the file
    for y in 0..image.height - 1:
        for x in 0..image.width - 1:
            yield (x: x, y: y)



var noiseConf = newNoise( seed, octaves, persistence )

var image = newPPM( filename, width, height )

for point in image.pixels:
    let shade = int(
        255 * noiseConf.get(
            noiseType,
            float(point.x) / zoom,
            float(point.y) / zoom) )
    image.draw( shade, shade, shade )


