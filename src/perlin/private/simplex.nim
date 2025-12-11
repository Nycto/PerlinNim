##
## 3D Simplex noise generation
##

import std/math, types, common

# 3D Skewing and unskewing factors
const F3 = 1.0 / 3.0
const G3 = 1.0 / 6.0

# 2D Skewing and unskewing factors
const F2 = 0.5 * (sqrt(3.0) - 1.0)
const G2 = (3.0 - sqrt(3.0)) / 6.0

proc getSimplexCorners(
    point: Point3D[float]
): tuple[second, third: Point3D[int]] {.inline.} =
  ## Determine which simplex we are in and return the points for the corner
  if point.x >= point.y:
    if point.y >= point.z:
      # X Y Z order
      return (second: [1, 0, 0], third: [1, 1, 0])
    elif point.x >= point.z:
      # X Z Y order
      return (second: [1, 0, 0], third: [1, 0, 1])
    else:
      # Z X Y order
      return (second: [0, 0, 1], third: [1, 0, 1])
  else:
    if point.y < point.z:
      # Z Y X order
      return (second: [0, 0, 1], third: [0, 1, 1])
    elif point.x < point.z:
      # Y Z X order
      return (second: [0, 1, 0], third: [0, 1, 1])
    else:
      # Y X Z order
      return (second: [0, 1, 0], third: [1, 1, 0])

proc getCornerOffset(
    point: AnyPoint[float], ijk: AnyPoint[int], multiplier: float
): typeof(point) {.inline.} =
  ## Calculates the offset for various corners
  zipIt(point, ijk, a - b.float + multiplier)

proc contribution(
    self: Noise, point: Point3D[float], unit: Point3D[int], ijk: Point3d[int]
): float {.inline.} =
  ## Noise contributions from a corners
  let t = 0.6 - point.x * point.x - point.y * point.y - point.z * point.z
  if t < 0:
    return 0.0
  else:
    let hash = self.hash(unit, ijk, point, [0, 0, 0])
    return t * t * t * t * hash

template subtract(a, b: Point): untyped =
  ## Subtracts two points
  when compiles(a.z) or compiles(b.z):
    [a.x - b.x, a.y - b.y, a.z - b.z]
  else:
    [a.x - b.x, a.y - b.y]

template withSimplexSetup(
    point: AnyPoint[float], F, G, unit, origin: untyped, body: untyped
): untyped =
  # Skew the input space to determine which simplex cell we're in
  let skew = sum(point) * F

  let floored = point.mapIt(int(floor(it + skew)))

  let t = float(sum(floored)) * G

  # Unskew the cell origin back to (x,y,z) space
  let unskewed = floored.mapIt(float(it) - t)

  # The x,y,z distances from the cell origin
  let origin = zipIt(point, unskewed, a - b)

  let unit = floored.mapIt(it and 255)

  # Restrict the range to 0 to 1 for convenience
  return (body + 1) / 2

proc contribution(
    self: Noise, point: Point2D[float], unit: Point2D[int], ijk: Point2D[int]
): float {.inline.} =
  ## Noise contributions from a corners
  let t = 0.5 - point.x * point.x - point.y * point.y
  if t < 0:
    return 0.0
  else:
    let hash = self.hash(unit, ijk, point, [0, 0])
    return t * t * t * t * hash

proc simplex3*(self: Noise, point: Point3D[float]): float {.inline.} =
  ## 3D simplex noise

  withSimplexSetup(point, F3, G3, unit, origin):
    # Offsets for the second and third corner of simplex in (i, j, k) coords
    let (ijk1, ijk2) = getSimplexCorners(origin)

    # Offsets for second corner in (x,y,z) coords
    let pos1 = getCornerOffset(origin, ijk1, 1.0 * G3)
    let pos2 = getCornerOffset(origin, ijk2, 2.0 * G3)
    let pos3 = getCornerOffset(origin, [1, 1, 1], 3.0 * G3)

    # Add contributions from each corner to get the final noise value.
    32.0 * (
      self.contribution(origin, unit, [0, 0, 0]) + self.contribution(pos1, unit, ijk1) +
      self.contribution(pos2, unit, ijk2) + self.contribution(pos3, unit, [1, 1, 1])
    )

proc simplex2*(self: Noise, point: Point2D[float]): float {.inline.} =
  ## 2D simplex noise

  withSimplexSetup(point, F2, G2, unit, origin):
    # Offsets for the second corner of simplex in (i, j) coords
    let ijk =
      if origin.x > origin.y:
        [1, 0]
      else:
        [0, 1]

    # Offsets for second corner in (x,y,z) coords
    let pos1 = getCornerOffset(origin, ijk, 1.0 * G2)
    let pos2 = getCornerOffset(origin, [1, 1], 2.0 * G2)

    # Add contributions from each corner to get the final noise value.
    70.0 * (
      self.contribution(origin, unit, [0, 0]) + self.contribution(pos1, unit, ijk) +
      self.contribution(pos2, unit, [1, 1])
    )
