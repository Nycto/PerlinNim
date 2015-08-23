##
## A Noise Generation Library with support for both Perlin noise and Simplex
## noise.
##
## Simplex Noise
## -------------
##
## Take a look here:
## * http://webstaff.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf
## * http://stackoverflow.com/questions/18279456/any-simplex-noise-tutorials-or-resources
##
## Based on the implementation found here:
## * http://webstaff.itn.liu.se/~stegu/simplexnoise/SimplexNoise.java
##
## Perlin Noise
## ------------
##
## Take a look at the following resources:
## * http://mrl.nyu.edu/~perlin/noise/
## * http://flafla2.github.io/2014/08/09/perlinnoise.html
## * http://riven8192.blogspot.com/2010/08/calculate-perlinnoise-twice-as-fast.html
##

import math, private/common

type
    Noise* = object
        ## A noise instance
        ## * `perm` is a set of random numbers used to generate the results
        ## * `octaves` allows you to combine multiple layers of noise
        ##   into a single result
        ## * `persistence` is how much impact each successive octave has on
        ##   the result
        perm: array[0..511, int]
        octaves: int
        persistence: float

    NoiseType* {.pure.} = enum ## \
        ## The types of noise available
        perlin, simplex

proc randomSeed*(): uint32 {.inline.} =
    ## Returns a random seed that can be fed into a constructor
    uint32(random(high(int)))

proc newNoise*(
    seed: uint32,
    octaves: int = 1, persistence: float = 0.5
): Noise =
    ## Creates a new noise instance with the given seed
    ## * `octaves` allows you to combine multiple layers of noise
    ##   into a single result
    ## * `persistence` is how much impact each successive octave has on
    ##   the result
    assert(octaves >= 1)
    return Noise(
        perm: buildPermutations(seed),
        octaves: octaves, persistence: persistence )

proc newNoise*( octaves: int, persistence: float ): Noise =
    ## Creates a new noise instance with a random seed
    ## * `octaves` allows you to combine multiple layers of noise
    ##   into a single result
    ## * `persistence` is how much impact each successive octave has on
    ##   the result
    newNoise( randomSeed(), octaves, persistence )

proc newNoise*(): Noise =
    ## Creates a new noise instance with a random seed
    newNoise( 1, 1.0 )

proc permMod12( self: Noise, index: int ): int {.inline.} =
    ## Provides access to to the perm module, but modulo 12
    self.perm[index] mod 12


include private/perlin, private/simplex


template applyOctaves( self: Noise, callback: expr, x, y, z: float ): float =
    ## Applies the configured octaves to the request
    var total: float = 0
    var frequency: float = 1
    var amplitude: float = 1

    # Used for normalizing result to 0.0 - 1.0
    var maxValue: float = 0

    for i in 0..self.octaves:
        let noise = callback(
            self,
            (x * frequency, y * frequency, z * frequency)
        )
        total = total + amplitude * noise

        maxValue = maxValue + amplitude
        amplitude = amplitude * self.persistence
        frequency = frequency * 2

    total / maxValue

proc perlin* ( self: Noise, x, y, z: int|float ): float =
    ## Returns the noise at the given offset. The value returned will be
    ## between 0 and 1.
    ##
    ## Note: This method tweaks the input values by just a bit to make sure
    ## there are decimal points. If you don't want that, use the 'purePerlin'
    ## method instead
    applyOctaves(
        self, perlinNoise,
        float(x) * 0.1, float(y) * 0.1, float(z) * 0.1 )

proc purePerlin* ( self: Noise, x, y, z: int|float ): float =
    ## Returns the noise at the given offset without modifying the input. The
    ## value returned will be between 0 and 1.
    applyOctaves(
        self, perlinNoise,
        float(x), float(y), float(z) )


proc simplex* ( self: Noise, x, y, z: int|float ): float =
    ## Returns the noise at the given offset. The value returned will be
    ## between 0 and 1.
    ##
    ## Note: This method tweaks the input values by just a bit to make sure
    ## there are decimal points. If you don't want that, use the 'purePerlin'
    ## method instead
    applyOctaves(
        self, simplexNoise,
        float(x) * 0.1, float(y) * 0.1, float(z) * 0.1 )

proc pureSimplex* ( self: Noise, x, y, z: int|float ): float =
    ## Returns the noise at the given offset without modifying the input. The
    ## value returned will be between 0 and 1.
    applyOctaves(
        self, noise,
        float(x), float(y), float(z) )


proc get* ( self: Noise, typ: NoiseType, x, y, z: int|float ): float =
    ## Returns the noise at the given offset. The value returned will be
    ## between 0 and 1.
    ##
    ## Note: This method tweaks the input values by just a bit to make sure
    ## there are decimal points. If you don't want that, use the 'purePerlin'
    ## method instead
    case typ
    of NoiseType.perlin: return perlin(self, x, y, z)
    of NoiseType.simplex: return simplex(self, x, y, z)

proc pureGet* ( self: Noise, typ: NoiseType, x, y, z: int|float ): float =
    ## Returns the noise at the given offset without modifying the input. The
    ## value returned will be between 0 and 1.
    case typ
    of NoiseType.perlin: return purePerlin(self, x, y, z)
    of NoiseType.simplex: return pureSimplex(self, x, y, z)
