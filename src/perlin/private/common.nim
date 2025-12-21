##
## Shared methods for generating noise
##

import std/importutils, types

proc grad*(hash: int, x, y: float, z: float = 0): float {.inline.} =
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

proc hash*(
    self: Noise,
    unit: Point3D[int],
    ux, uy, uz: int,
    pos: Point3D[float],
    gx, gy, gz: float,
): float {.inline.} =
  ## Generates the hash coordinate given three expressions
  privateAccess(Noise)
  let gIndex = self.perm[unit.x + ux + self.perm[unit.y + uy + self.perm[unit.z + uz]]]
  return grad(gIndex, pos.x + gx, pos.y + gy, pos.z + gz)

proc hash*(
    self: Noise, unit: Point2D[int], ux, uy: int, pos: Point2D[float], gx, gy: float
): float {.inline.} =
  ## Generates the hash coordinate given three expressions
  privateAccess(Noise)
  let gIndex = self.perm[unit.x + ux + self.perm[unit.y + uy]]
  return grad(gIndex, pos.x + gx, pos.y + gy)

template map*(point: Point, apply: untyped): untyped =
  ## Applies a callback to all the values in a point
  when compiles(point.z):
    [apply(point.x), apply(point.y), apply(point.z)]
  else:
    [apply(point.x), apply(point.y)]

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
