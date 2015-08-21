##
## A Perlin Noise Generation Library
##
## Take a look at the following resources:
## * http://mrl.nyu.edu/~perlin/noise/
## * http://flafla2.github.io/2014/08/09/perlinnoise.html
## * http://riven8192.blogspot.com/2010/08/calculate-perlinnoise-twice-as-fast.html
##

import sequtils, math, random/mersenne

type
    Perlin* = object
        ## A perl noise instance
        ## * `perm` is a set of random numbers used to generate the results
        ## * `octaves` allows you to combine multiple layers of perlin noise
        ##   into a single result
        ## * `persistence` is how much impact each successive octave has on
        ##   the result
        perm: array[0..511, int]
        octaves: int
        persistence: float

    Point[U: float|int] = ## \
        ## A helper definition for a 3d point
        tuple[x, y, z: U]

proc shuffle[E]( seed: uint32, values: var seq[E] ) =
    ## Shuffles a sequence in place

    var prng = initMersenneTwister(seed)

    let max = uint32(values.high)

    # Shuffle the array of numbers
    for i in 0u32..(max - 1u32):
        let index = int(i + (prng.randomUint32() mod (max - i)) + 1u32)
        assert(index <= 255)
        assert(int(i) < index)
        swap values[int(i)], values[index]

proc buildPermutations( seed: uint32 ): array[0..511, int] =
    ## Returns a hash lookup table. It is all the numbers from 0 to 255
    ## (inclusive) in a randomly sorted array, twice over

    # Create and shuffle a random list of ints
    var base = toSeq(0..255)
    shuffle(seed, base)

    # Copy into the result
    for i in 0..511:
        result[i] = base[i mod 256]

proc randomSeed*(): uint32 {.inline.} =
    ## Returns a random seed that can be fed into a perlin constructor
    uint32(random(high(int)))

proc newPerlin*(
    seed: uint32,
    octaves: int = 1, persistence: float = 0.5
): Perlin =
    ## Creates a new perlin noise instance with the given seed
    ## * `octaves` allows you to combine multiple layers of perlin noise
    ##   into a single result
    ## * `persistence` is how much impact each successive octave has on
    ##   the result
    assert(octaves >= 1)
    return Perlin(
        perm: buildPermutations(seed),
        octaves: octaves, persistence: persistence )

proc newPerlin*( octaves: int, persistence: float ): Perlin =
    ## Creates a new perlin noise instance with a random seed
    ## * `octaves` allows you to combine multiple layers of perlin noise
    ##   into a single result
    ## * `persistence` is how much impact each successive octave has on
    ##   the result
    newPerlin( randomSeed(), octaves, persistence )

proc newPerlin*(): Perlin =
    ## Creates a new perlin noise instance with a random seed
    newPerlin( 1, 0.5 )

template map( obj, apply: expr ): expr =
    ## Applies a callback to three numbers and presents them as a tuple
    ( x: apply(obj.x), y: apply(obj.y), z: apply(obj.z) )

proc unitCubePos( num: float ): int {.inline.} =
    ## Returns the unit cube position for this given value. This chops off
    ## any decimal points and truncates down to < 255
    int(num) and 255

proc decimal( num: float ): float {.inline.} =
    ## Returns just the decimal portion of the given number
    num - float(int(num))

template hash( self: Perlin, x, y, z: expr ): expr =
    ## Generates the hash coordinate given three expressions
    self.perm[self.perm[self.perm[x] + y] + z]

proc grad ( hash: int, x, y, z: float ): float =
    ## Calculate the dot product of a randomly selected gradient vector and the
    ## 8 location vectors
    case (hash and 0xF)
    of 0x0: return  x + y
    of 0x1: return -x + y
    of 0x2: return  x - y
    of 0x3: return -x - y
    of 0x4: return  x + z
    of 0x5: return -x + z
    of 0x6: return  x - z
    of 0x7: return -x - z
    of 0x8: return  y + z
    of 0x9: return -y + z
    of 0xA: return  y - z
    of 0xB: return -y - z
    of 0xC: return  y + x
    of 0xD: return -y + z
    of 0xE: return  y - x
    of 0xF: return -y - z
    else: raise newException(AssertionError, "Should not happen")

proc fade ( t: float ): float {.inline.} =
    ## Fade function as defined by Ken Perlin. This eases coordinate values
    ## so that they will "ease" towards integral values. This ends up smoothing
    ## the final output.
    ## 6t^5 - 15t^4 + 10t^3
    t * t * t * (t * (t * 6 - 15) + 10)

proc lerp( a, b, x: float ): float {.inline.} =
    ## Linear interpolator. https://en.wikipedia.org/wiki/Linear_interpolation
    a + x * (b - a)

proc noise ( self: Perlin, point: Point[float] ): float {.inline.} =
    ## Returns the noise at the given offset

    # Calculate the "unit cube" that the point asked will be located in
    let unit: Point[int] = point.map(unitCubePos)

    # Calculate the location within the cube
    let pos: Point[float] = point.map(decimal)

    # Compute the fade curves
    let faded: Point[float] = pos.map(fade)

    # The hash coordinates of the 8 corners
    let aaa = self.hash(unit.x,     unit.y,     unit.z    )
    let aba = self.hash(unit.x,     unit.y + 1, unit.z    )
    let aab = self.hash(unit.x,     unit.y,     unit.z + 1)
    let abb = self.hash(unit.x,     unit.y + 1, unit.z + 1)
    let baa = self.hash(unit.x + 1, unit.y,     unit.z    )
    let bba = self.hash(unit.x + 1, unit.y + 1, unit.z    )
    let bab = self.hash(unit.x + 1, unit.y,     unit.z + 1)
    let bbb = self.hash(unit.x + 1, unit.y + 1, unit.z + 1)

    let x1 = lerp(grad (aaa, pos.x  , pos.y  , pos.z),
                  grad (baa, pos.x-1, pos.y  , pos.z),
                  faded.x)

    let x2 = lerp(grad (aba, pos.x  , pos.y-1, pos.z),
                  grad (bba, pos.x-1, pos.y-1, pos.z),
                  faded.x)

    let y1 = lerp(x1, x2, faded.y)

    let x3 = lerp(grad (aab, pos.x  , pos.y  , pos.z-1),
                  grad (bab, pos.x-1, pos.y  , pos.z-1),
                  faded.x)

    let x4 = lerp(grad (abb, pos.x  , pos.y-1, pos.z-1),
                  grad (bbb, pos.x-1, pos.y-1, pos.z-1),
                  faded.x)

    let y2 = lerp (x3, x4, faded.y)

    let output = lerp(y1, y2, faded.z)

    # For convenience constrain to 0..1 (theoretical min/max before is -1 - 1)
    return (output + 1) / 2

proc octaves ( self: Perlin, x, y, z: int|float ): float {.inline.} =
    ## Applies the configured octaves to the request
    var total: float = 0
    var frequency: float = 1
    var amplitude: float = 1

    # Used for normalizing result to 0.0 - 1.0
    var maxValue: float = 0

    for i in 0..self.octaves:
        let noise = self.noise( (x * frequency, y * frequency, z * frequency) )
        total = total + amplitude * noise

        maxValue = maxValue + amplitude
        amplitude = amplitude * self.persistence
        frequency = frequency * 2

    return total / maxValue

proc get* ( self: Perlin, x, y, z: int|float ): float =
    ## Returns the noise at the given offset. This method bumps the values by
    ## just a bit to make sure there are decimal points. If you don't want
    ## that, use the 'pureGet' method instead
    octaves( self, float(x) * 0.1, float(y) * 0.1, float(z) * 0.1 )

proc pureGet* ( self: Perlin, x, y, z: int|float ): float =
    ## Returns the noise at the given offset without modifying the input
    octaves( self, float(x), float(y), float(z) )

