##
## 3D Simplex noise generation
##

# Skewing and unskewing factors
const F3: float = 1.0 / 3.0
const G3: float = 1.0 / 6.0

proc getSimplexCorners(
    point: Point3d[float]
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
    point: Point3d[float], ijk: tuple[i, j, k: int], multiplier: float
): Point3d[float] {.inline.} =
    ## Calculates the offset for various corners
    ( x: point.x - float(ijk.i) + multiplier * G3,
      y: point.y - float(ijk.j) + multiplier * G3,
      z: point.z - float(ijk.k) + multiplier * G3 )

proc contribution( point: Point3d[float], gIndex: int ): float {.inline.} =
    ## Noise contributions from a corners
    let t = 0.6 - point.x * point.x - point.y * point.y - point.z * point.z
    if t < 0:
        return 0.0
    else:
        return t * t * t * t * grad(gIndex, point.x, point.y, point.z)

proc simplexNoise ( self: Noise, point: Point3d[float] ): float {.inline.} =
    ## 3D simplex noise

    # Skew the input space to determine which simplex cell we're in
    let skew = (point.x + point.y + point.z) * F3

    let floored: Point3d[int] = point.mapIt(int, int(floor(it + skew)) )

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

    let unit = floored.mapIt(int, it and 255)

    # Work out the hashed gradient indices of the four simplex corners
    let gIndex0 = self.gradientIndex(unit, 0, 0, 0)
    let gIndex1 = self.gradientIndex(unit, ijk1.i, ijk1.j, ijk1.k)
    let gIndex2 = self.gradientIndex(unit, ijk2.i, ijk2.j, ijk2.k)
    let gIndex3 = self.gradientIndex(unit, 1, 1, 1)

    # Add contributions from each corner to get the final noise value.
    # The result is scaled to stay just inside [-1,1]
    result = 32.0 * (
        contribution(origin, gIndex0) +
        contribution(pos1, gIndex1) +
        contribution(pos2, gIndex2) +
        contribution(pos3, gIndex3) )

    # Restrict the range to 0 to 1 for convenience
    result = (result + 1) / 2


