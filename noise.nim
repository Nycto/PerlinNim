##
## A simple interface for providing various types of noise
##

import private/common
import simplex as simplexNoise
import perlin as perlinNoise

export randomSeed, Noise, newNoise

type NoiseType* = enum ## \
    ## The types of noise available
    perlin, simplex

proc get* ( self: Noise, typ: NoiseType, x, y, z: int|float ): float =
    ## Returns the noise at the given offset. The value returned will be
    ## between 0 and 1.
    ##
    ## Note: This method tweaks the input values by just a bit to make sure
    ## there are decimal points. If you don't want that, use the 'purePerlin'
    ## method instead
    case typ
    of perlin: return perlinNoise.perlin(self, x, y, z)
    of simplex: return simplexNoise.simplex(self, x, y, z)

proc pureGet* ( self: Noise, typ: NoiseType, x, y, z: int|float ): float =
    ## Returns the noise at the given offset without modifying the input. The
    ## value returned will be between 0 and 1.
    case typ
    of perlin: return perlinNoise.pureperlin(self, x, y, z)
    of simplex: return simplexNoise.puresimplex(self, x, y, z)

