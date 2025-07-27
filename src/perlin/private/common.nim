##
## Shared methods for generating noise
##

import std/importutils, types

template hash*(
    self: Noise,
    unit: Point3D[int],
    ux, uy, uz: untyped,
    pos: Point3D[float],
    gx, gy, gz: untyped,
): untyped =
  ## Generates the hash coordinate given three expressions
  privateAccess(Noise)
  let gIndex = self.perm[unit.x + ux + self.perm[unit.y + uy + self.perm[unit.z + uz]]]
  grad(gIndex, pos.x + gx, pos.y + gy, pos.z + gz)

template hash*(
    self: Noise,
    unit: Point2D[int],
    ux, uy: untyped,
    pos: Point2D[float],
    gx, gy: untyped,
): untyped =
  ## Generates the hash coordinate given three expressions
  privateAccess(Noise)
  let gIndex = self.perm[unit.x + ux + self.perm[unit.y + uy]]
  grad(gIndex, pos.x + gx, pos.y + gy, 0)

template map*(point: Point, apply: untyped): untyped =
  ## Applies a callback to all the values in a point
  when compiles(point.z):
    (x: apply(point.x), y: apply(point.y), z: apply(point.z))
  else:
    (x: apply(point.x), y: apply(point.y))

template mapIt*(point: Point, kind: typedesc, apply: untyped): untyped =
  ## Applies a callback to all the values in a point
  var output: array[3, kind]
  block applyItBlock:
    let it {.inject.} = point.x
    output[0] = apply
  block applyItBlock:
    let it {.inject.} = point.y
    output[1] = apply
  when compiles(point.z):
    block applyItBlock:
      let it {.inject.} = point.z
      output[2] = apply
    (x: output[0], y: output[1], z: output[2])
  else:
    (x: output[0], y: output[1])

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
