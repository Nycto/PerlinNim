##
## Shared methods for generating noise
##

import std/importutils, types

proc grad4(hash: int, x, y, z, w: float): float {.inline.} =
  #!fmt: off
  case hash
  # --- 24 gradients: permutations of (±1, ±1, 0, 0) ---
  of 0: return x + y
  of 1: return -x + y
  of 2: return x - y
  of 3: return -x - y
  of 4: return x + z
  of 5: return -x + z
  of 6: return x - z
  of 7: return -x - z
  of 8: return y + z
  of 9: return -y + z
  of 10: return y - z
  of 11: return -y - z
  of 12: return y + x
  of 13: return -y + z
  of 14: return y - x
  of 15: return -y - z
  of 16: return y + w
  of 17: return y - w
  of 18: return -y + w
  of 19: return -y - w
  of 20: return z + w
  of 21: return z - w
  of 22: return -z + w
  of 23: return -z - w

  # --- 3ents: permutations of (±1, ±1, ±1, 0) ---
  of 24: return x + y + z
  of 25: return x + y - z
  of 26: return x - y + z
  of 27: return x - y - z
  of 28: return -x + y + z
  of 29: return -x + y - z
  of 30: return -x - y + z
  of 31: return -x - y - z
  of 32: return x + y + w
  of 33: return x + y - w
  of 34: return x - y + w
  of 35: return x - y - w
  of 36: return -x + y + w
  of 37: return -x + y - w
  of 38: return -x - y + w
  of 39: return -x - y - w
  of 40: return x + z + w
  of 41: return x + z - w
  of 42: return x - z + w
  of 43: return x - z - w
  of 44: return -x + z + w
  of 45: return -x + z - w
  of 46: return -x - z + w
  of 47: return -x - z - w
  of 48: return y + z + w
  of 49: return y + z - w
  of 50: return y - z + w
  of 51: return y - z - w
  of 52: return -y + z + w
  of 53: return -y + z - w
  of 54: return -y - z + w
  of 55: return -y - z - w

  # --- 8nts: (±1, ±1, ±1, ±1) with even parity ---
  of 56: return x + y + z + w
  of 57: return x + y + z - w
  of 58: return x + y - z + w
  of 59: return x + y - z - w
  of 60: return x - y + z + w
  of 61: return x - y + z - w
  of 62: return x - y - z + w
  of 63: return x - y - z - w
  else: assert(false, "Should not happen")
  #!fmt: on

proc grad*(hash: int, p: Point3d[float]): float {.inline.} =
  grad4(hash and 15, p.x, p.y, p.z, 0)

proc grad*(hash: int, p: Point2d[float]): float {.inline.} =
  grad4(hash and 7, p.x, p.y, 0, 0)

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
    self: Noise, unit: AnyPoint[int], u: AnyPoint[int], pos: AnyPoint[float]
): float {.inline.} =
  ## Generates the hash coordinate for a point
  hash(self, unit, u, pos, u.mapIt(it * -1))
