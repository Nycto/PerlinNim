##
## 3D Simplex noise generation
##

# Skewing and unskewing factors
const F3: float = 1.0 / 3.0
const G3: float = 1.0 / 6.0

proc getSimplexCorners(
    point: Point3D[float]
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
    point: Point3D[float], ijk: tuple[i, j, k: int], multiplier: float
): Point3D[float] {.inline.} =
    ## Calculates the offset for various corners
    ( x: point.x - float(ijk.i) + multiplier * G3,
      y: point.y - float(ijk.j) + multiplier * G3,
      z: point.z - float(ijk.k) + multiplier * G3 )

proc contribution(
    self: Noise,
    point: Point3D[float],
    unit: Point3D[int],
    ijk: tuple[i, j, k: int]
): float {.inline.} =
    ## Noise contributions from a corners
    let t = 0.6 - point.x * point.x - point.y * point.y - point.z * point.z
    if t < 0:
        return 0.0
    else:
        let hash = self.hash(unit, ijk.i, ijk.j, ijk.k, point, 0, 0, 0)
        return t * t * t * t * hash

template sum( point: Point3D[float]|Point3D[int] ): expr =
    ## Adds all the points in a tuple
    point.x + point.y + point.z

template subtract( a, b: Point3D[float] ): expr =
    ## Subtracts two points
    ( x: a.x - b.x, y: a.y - b.y, z: a.z - b.z )

template withSimplexSetup(
    point: Point3D[float], unit, origin, body: stmt
): expr {.immediate.} =

    # Skew the input space to determine which simplex cell we're in
    let skew = sum(point) * F3

    let floored = point.mapIt(int, int(floor(it + skew)) )

    let t = float(sum(floored)) * G3;

    # Unskew the cell origin back to (x,y,z) space
    let unskewed = floored.mapIt(float, float(it) - t)

    # The x,y,z distances from the cell origin
    let origin = subtract(point, unskewed)

    let unit = floored.mapIt(int, it and 255)

    # Restrict the range to 0 to 1 for convenience
    return (body + 1) / 2


proc simplexNoise ( self: Noise, point: Point3D[float] ): float {.inline.} =
    ## 3D simplex noise

    withSimplexSetup(point, unit, origin):

        # Offsets for the second and third corner of simplex in (i, j, k) coords
        let (ijk1, ijk2) = getSimplexCorners(origin)

        # Offsets for second corner in (x,y,z) coords
        let pos1 = getCornerOffset(origin, ijk1,      1.0)
        let pos2 = getCornerOffset(origin, ijk2,      2.0)
        let pos3 = getCornerOffset(origin, (1, 1, 1), 3.0)

        # Add contributions from each corner to get the final noise value.
        # The result is scaled to stay just inside [-1,1]
        32.0 * (
            self.contribution(origin, unit, (0, 0, 0)) +
            self.contribution(pos1,   unit, ijk1) +
            self.contribution(pos2,   unit, ijk2) +
            self.contribution(pos3,   unit, (1, 1, 1)) )


