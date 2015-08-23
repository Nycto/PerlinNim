##
## Simplex noise generation in 3d
##
## Take a look here:
## * http://webstaff.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf
## * http://stackoverflow.com/questions/18279456/any-simplex-noise-tutorials-or-resources
##
## Based on the implementation found here:
## * http://webstaff.itn.liu.se/~stegu/simplexnoise/SimplexNoise.java
##

import private/common, math
export randomSeed, Noise, newNoise

const grad3: array[12, Point[float]] = [
    (x:  1.0, y:  1.0, z:  0.0),
    (x: -1.0, y:  1.0, z:  0.0),
    (x:  1.0, y: -1.0, z:  0.0),
    (x: -1.0, y: -1.0, z:  0.0),
    (x:  1.0, y:  0.0, z:  1.0),
    (x: -1.0, y:  0.0, z:  1.0),
    (x:  1.0, y:  0.0, z: -1.0),
    (x: -1.0, y:  0.0, z: -1.0),
    (x:  0.0, y:  1.0, z:  1.0),
    (x:  0.0, y: -1.0, z:  1.0),
    (x:  0.0, y:  1.0, z: -1.0),
    (x:  0.0, y: -1.0, z: -1.0)
]

proc permMod12( self: Noise, index: int ): int {.inline.} =
    ## Provides access to to the perm module, but modulo 12
    self.perm(index) mod 12

# Skewing and unskewing factors for 2, 3, and 4 dimensions
const F3: float = 1.0 / 3.0

const G3: float = 1.0 / 6.0

proc dot(g: Point[float], p: Point[float] ): float {.inline.} =
    return g.x * p.x + g.y * p.y + g.z * p.z

proc getSimplexCorners(
    point: Point[float]
): tuple[second, third: tuple[i, j, k: int]] {.inline.} =
    ## Determine which simplex we are in and return the points for the corner
    if point.x >= point.y:
        if point.y >= point.z:
            # X Y Z order
            return (second: (1, 0, 0), third: (1, 1, 0))
        elif point.x >= point.z:
            # X Z Y order
            return (second: (1, 0, 0), third: (1, 0, 1))
        else:
            # Z X Y order
            return (second: (0, 0, 1), third: (1, 0, 1))
    else:
        if point.y < point.z:
            # Z Y X order
            return (second: (0, 0, 1), third: (0, 1, 1))
        elif point.x < point.z:
            # Y Z X order
            return (second: (0, 1, 0), third: (0, 1, 1))
        else:
            # Y X Z order
            return (second: (0, 1, 0), third: (1, 1, 0))

proc getCornerOffset(
    point: Point[float], ijk: tuple[i, j, k: int], multiplier: float
): Point[float] {.inline.} =
    ## Calculates the offset for various corners
    ( x: point.x - float(ijk.i) + multiplier * G3,
      y: point.y - float(ijk.j) + multiplier * G3,
      z: point.z - float(ijk.k) + multiplier * G3 )

proc getGradientIndex(
    self: Noise, hash: Point[int], ijk: tuple[i, j, k: int]
): int {.inline.} =
    ## Work out the hashed gradient index of the a simplex corner
    self.permMod12(hash.x + ijk.i +
        self.perm(hash.y + ijk.j +
            self.perm(hash.z + ijk.k)))

proc contribution( point: Point[float], gIndex: int ): float {.inline.} =
    ## Noise contributions from a corners
    let t = 0.6 - point.x * point.x - point.y * point.y - point.z * point.z
    if t < 0:
        return 0.0
    else:
        return t * t * t * t * dot(grad3[gIndex], point)

proc noise ( self: Noise, point: Point[float] ): float {.inline.} =
    ## 3D simplex noise

    # Skew the input space to determine which simplex cell we're in
    let skew = (point.x + point.y + point.z) * F3

    let floored: Point[int] = point.mapIt(int, int(floor(it + skew)) )

    let t = float(floored.x + floored.y + floored.z) * G3;

    # Unskew the cell origin back to (x,y,z) space
    let unskewed = floored.mapIt(float, float(it) - t)

    # The x,y,z distances from the cell origin
    let origin = (
        x: point.x - unskewed.x,
        y: point.y - unskewed.y,
        z: point.z - unskewed.z )

    # Offsets for the second and third corner of simplex in (i, j, k) coords
    let (ijk1, ijk2) = getSimplexCorners(origin)

    # A step of (1,0,0) in (i,j,k) means a step of (1-c,-c,-c) in (x,y,z),
    # a step of (0,1,0) in (i,j,k) means a step of (-c,1-c,-c) in (x,y,z), and
    # a step of (0,0,1) in (i,j,k) means a step of (-c,-c,1-c) in (x,y,z), where
    # c = 1/6.

    # Offsets for second corner in (x,y,z) coords
    let pos1 = getCornerOffset(origin, ijk1, 1.0)

    # Offsets for third corner in (x,y,z) coords
    let pos2 = getCornerOffset(origin, ijk2, 2.0)

    # Offsets for last corner in (x,y,z) coords
    let pos3 = getCornerOffset(origin, (1, 1, 1), 3.0)

    # Work out the hashed gradient indices of the four simplex corners
    let hash = floored.mapIt(int, it and 255)

    let gIndex0 = self.getGradientIndex(hash, (0, 0, 0))
    let gIndex1 = self.getGradientIndex(hash, ijk1)
    let gIndex2 = self.getGradientIndex(hash, ijk2)
    let gIndex3 = self.getGradientIndex(hash, (1, 1, 1))

    # Add contributions from each corner to get the final noise value.
    # The result is scaled to stay just inside [-1,1]
    result = 32.0 * (
        contribution(origin, gIndex0) +
        contribution(pos1, gIndex1) +
        contribution(pos2, gIndex2) +
        contribution(pos3, gIndex3) )

    # Restrict the range to 0 to 1 for convenience
    result = (result + 1) / 2


proc simplex* ( self: Noise, x, y, z: int|float ): float =
    ## Returns the noise at the given offset. The value returned will be
    ## between 0 and 1.
    ##
    ## Note: This method tweaks the input values by just a bit to make sure
    ## there are decimal points. If you don't want that, use the 'purePerlin'
    ## method instead
    applyOctaves( self, noise, float(x) * 0.1, float(y) * 0.1, float(z) * 0.1 )

proc pureSimplex* ( self: Noise, x, y, z: int|float ): float =
    ## Returns the noise at the given offset without modifying the input. The
    ## value returned will be between 0 and 1.
    applyOctaves( self, noise, float(x), float(y), float(z) )

