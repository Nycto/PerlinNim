##
## 3D Simplex noise generation
##

# 3D Skewing and unskewing factors
const F3 = 1.0 / 3.0
const G3 = 1.0 / 6.0

# 2D Skewing and unskewing factors
const F2 = 0.5 * (sqrt(3.0) - 1.0)
const G2 = (3.0 - sqrt(3.0)) / 6.0

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
    point: Point2D[float],
    ijk: tuple[i, j: int],
    multiplier: float
): Point2D[float] {.inline.} =
    ## Calculates the offset for various corners
    (
        x: point.x - float(ijk.i) + multiplier,
        y: point.y - float(ijk.j) + multiplier )

proc getCornerOffset(
    point: Point3D[float],
    ijk: tuple[i, j, k: int],
    multiplier: float
): Point3D[float] {.inline.} =
    ## Calculates the offset for various corners
    (
        x: point.x - float(ijk.i) + multiplier,
        y: point.y - float(ijk.j) + multiplier,
        z: point.z - float(ijk.k) + multiplier )

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

template sum( point: Point ): untyped =
    ## Adds all the points in a tuple
    point.x + point.y + (when compiles(point.z): point.z else: 0)

template subtract( a, b: Point ): untyped =
    ## Subtracts two points
    when compiles(a.z) or compiles(b.z):
        ( x: a.x - b.x, y: a.y - b.y, z: a.z - b.z )
    else:
        ( x: a.x - b.x, y: a.y - b.y )

template withSimplexSetup(
    point: PointND[float],
    F, G, unit, origin: untyped,
    body: untyped
): untyped =

    # Skew the input space to determine which simplex cell we're in
    let skew = sum(point) * F

    let floored = point.mapIt(int, int(floor(it + skew)) )

    let t = float(sum(floored)) * G

    # Unskew the cell origin back to (x,y,z) space
    let unskewed = floored.mapIt(float, float(it) - t)

    # The x,y,z distances from the cell origin
    let origin = subtract(point, unskewed)

    let unit = floored.mapIt(int, it and 255)

    # Restrict the range to 0 to 1 for convenience
    return (body + 1) / 2

proc contribution(
    self: Noise,
    point: Point2D[float],
    unit: Point2D[int],
    ijk: tuple[i, j: int]
): float {.inline.} =
    ## Noise contributions from a corners
    let t = 0.5 - point.x * point.x - point.y * point.y
    if t < 0:
        return 0.0
    else:
        let hash = self.hash(unit, ijk.i, ijk.j, point, 0, 0)
        return t * t * t * t * hash


proc simplex3 ( self: Noise, point: Point3D[float] ): float {.inline.} =
    ## 3D simplex noise

    withSimplexSetup(point, F3, G3, unit, origin):

        # Offsets for the second and third corner of simplex in (i, j, k) coords
        let (ijk1, ijk2) = getSimplexCorners(origin)

        # Offsets for second corner in (x,y,z) coords
        let pos1 = getCornerOffset(origin, ijk1,      1.0 * G3)
        let pos2 = getCornerOffset(origin, ijk2,      2.0 * G3)
        let pos3 = getCornerOffset(origin, (1, 1, 1), 3.0 * G3)

        # Add contributions from each corner to get the final noise value.
        32.0 * (
            self.contribution(origin, unit, (0, 0, 0)) +
            self.contribution(pos1,   unit, ijk1) +
            self.contribution(pos2,   unit, ijk2) +
            self.contribution(pos3,   unit, (1, 1, 1)) )

proc simplex2 ( self: Noise, point: Point2D[float] ): float {.inline.} =
    ## 2D simplex noise

    withSimplexSetup(point, F2, G2, unit, origin):

        # Offsets for the second corner of simplex in (i, j) coords
        let ijk = if origin.x > origin.y: (i: 1, j: 0) else: (i: 0, j: 1)

        # Offsets for second corner in (x,y,z) coords
        let pos1 = getCornerOffset(origin, ijk ,   1.0 * G2)
        let pos2 = getCornerOffset(origin, (1, 1), 2.0 * G2)

        # Add contributions from each corner to get the final noise value.
        70.0 * (
            self.contribution(origin, unit, (0, 0)) +
            self.contribution(pos1,   unit, ijk) +
            self.contribution(pos2,   unit, (1, 1)) )


