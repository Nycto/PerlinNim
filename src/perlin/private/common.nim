##
## Shared methods for generating noise
##

import std/importutils, types

proc grad*(hash: int, x, y, z: float): float {.inline.} =
  ## Calculate the dot product of a randomly selected gradient vector and the
  ## 8 location vectors
  case (hash and 0xF)
  of 0x0:
    return x + y
  of 0x1:
    return -x + y
  of 0x2:
    return x - y
  of 0x3:
    return -x - y
  of 0x4:
    return x + z
  of 0x5:
    return -x + z
  of 0x6:
    return x - z
  of 0x7:
    return -x - z
  of 0x8:
    return y + z
  of 0x9:
    return -y + z
  of 0xA:
    return y - z
  of 0xB:
    return -y - z
  of 0xC:
    return y + x
  of 0xD:
    return -y + z
  of 0xE:
    return y - x
  of 0xF:
    return -y - z
  else:
    assert(false, "Should not happen")

proc grad*(hash: int, p: Point3d[float]): float {.inline.} =
  grad(hash, p.x, p.y, p.z)

proc grad*(hash: int, p: Point2d[float]): float {.inline.} =
  grad(hash, p.x, p.y, 0)

template mapIt*[S: static int, T](point: Point[S, T], apply: untyped): untyped =
  ## Applies a callback to all the values in a point
  block:
    type InnerType = typeof(block:
      let it {.inject.} = point.x
      apply)

    var output: Point[S, InnerType]
    for i in 0..<S:
      template it(): auto {.inject.} = point[i]
      output[i] = apply
    output

template zipIt*[S: static int, A, B](
    pointA: Point[S, A], pointB: Point[S, B], apply: untyped
): untyped =
  block:
    type InnerType = typeOf(block:
      let a {.inject.} = pointA[0]
      let b {.inject.} = pointB[0]
      apply)

    var output: Point[S, InnerType]

    for key in 0 ..< S:
      template a(): auto {.inject.} = pointA[key]
      template b(): auto {.inject.} = pointB[key]
      output[key] = apply

    output

proc calculatePerm*(noise: Noise, coords: AnyPoint[int]): int =
  ## Calculates the permutation for a set of coordinates. This
  ## winds up looking like: `perm[ix0 + perm[iy0 + perm[iz0]]]`
  privateAccess(Noise)
  for i in countdown(coords.len - 1, 0):
    result = noise.perm[coords[i] + result]

proc hash*(
    self: Noise,
    unit: AnyPoint[int],
    u: AnyPoint[int],
    pos: AnyPoint[float],
    g: AnyPoint,
): float {.inline.} =
  ## Generates the hash coordinate for a point
  privateAccess(Noise)
  let gIndex = self.calculatePerm(zipIt(unit, u, a + b))
  return grad(gIndex, zipIt(pos, g, a + b.float))

proc hash*(
    self: Noise,
    unit: AnyPoint[int],
    u: AnyPoint[int],
    pos: AnyPoint[float]
): float {.inline.} =
  ## Generates the hash coordinate for a point
  hash(self, unit, u, pos, u.mapIt(it * -1))
