##
## Creates a PPM image file of perlin noise
##

import perlin, math, parseopt2, os, strutils


type Options = object
    ## Command line options
    width, height: int
    filename: string
    seed: uint32
    octaves: int
    persistence: float
    zoom: float

template failIf ( condition: expr, msg: string ) =
    ## Quits with a failure code and a message
    if condition:
        stderr.write("Error: ", msg, "\n")
        quit(1)

template parse( value, parser: expr, name: string ): expr =
    let result = parser(val)
    failIf(result <= 0, name & " must be positive")
    result

proc getOptions(): Options =
    ## Returns parsed command line options
    result = Options(
        width: 600, height: 600, filename: nil,
        seed: randomSeed(), octaves: 1, persistence: 1.0, zoom: 1
    )

    for kind, key, val in getopt():
        case kind
        of cmdArgument:
            failIf(result.filename != nil, "Filename already provided")

            if key.strip.toLower.endsWith(".ppm"):
                result.filename = key.strip
            else:
                result.filename = key.strip & ".ppm"

        of cmdLongOption, cmdShortOption:
            failIf(val == "", "Empty option! Make sure you use an equals sign.")
            case key
            of "width", "w":
                result.width = val.parse(parseInt, "Width")
            of "height", "h":
                result.height = val.parse(parseInt, "Height")
            of "seed", "s":
                result.seed = uint32(parseInt(val))
            of "octaves", "o":
                result.octaves = val.parse(parseInt, "Octaves")
            of "persistence", "p":
                result.persistence = val.parse(parseFloat, "Persistence")
            of "zoom", "z":
                result.zoom = val.parse(parseFloat, "Zoom")
            else:
                failIf(true, "Unrecognized option: " & key)

        of cmdEnd:
            assert(false)

    failIf(result.filename == nil, "You must provide a file name")



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
    for y in 0..image.height - 1:
        for x in 0..image.width - 1:
            yield (x: x, y: y)



let opts = getOptions()

randomize()

var noise = newPerlin( opts.seed, opts.octaves, opts.persistence )

var image = newPPM( opts.filename, opts.width, opts.height )

for point in image.pixels:
    let shade = int(
        255 * noise.get(
            float(point.x) / opts.zoom,
            float(point.y) / opts.zoom,
            PI) )
    image.draw( shade, shade, shade )


