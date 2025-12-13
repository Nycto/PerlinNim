##
## Perlin noise generation
##

import std/math, types, common

proc fade(t: float): float {.inline.} =
  ## Fade function as defined by Ken Perlin. This eases coordinate values
  ## so that they will "ease" towards integral values. This ends up smoothing
  ## the final output.
  ## 6t^5 - 15t^4 + 10t^3
  (t * t * t * (t * (t * 6 - 15) + 10))

proc lerp(a, b, x: float): float {.inline.} =
  ## Linear interpolator. https://en.wikipedia.org/wiki/Linear_interpolation
  a + x * (b - a)

template withPerlinSetup(point: Point, unit, pos, faded: untyped, body: untyped) =
  ## Sets up three standard variables needed to run the generation

  # Calculate the "unit cube" that the point asked will be located in
  let unit = point.mapIt(int(floor(it)) and 255)

  # Calculate the location within the cube
  let pos = point.mapIt(it - floor(it))

  let faded = pos.mapIt(fade(it))

  # For convenience constrain to 0..1 (theoretical min/max before is -1 - 1)
  return (body + 1) / 2

proc perlin4*(self: Noise, point: Point4D[float]): float {.inline.} =
  ## Returns the noise at the given offset in 4D space

  withPerlinSetup(point, unit, pos, faded):
    # The hash coordinates of the 16 corners
    let aaaa = hash(self, unit, [0, 0, 0, 0], pos)
    let abaa = hash(self, unit, [0, 1, 0, 0], pos)
    let aaba = hash(self, unit, [0, 0, 1, 0], pos)
    let abba = hash(self, unit, [0, 1, 1, 0], pos)
    let aaab = hash(self, unit, [0, 0, 0, 1], pos)
    let abab = hash(self, unit, [0, 1, 0, 1], pos)
    let aabb = hash(self, unit, [0, 0, 1, 1], pos)
    let abbb = hash(self, unit, [0, 1, 1, 1], pos)
    let baaa = hash(self, unit, [1, 0, 0, 0], pos)
    let bbaa = hash(self, unit, [1, 1, 0, 0], pos)
    let baba = hash(self, unit, [1, 0, 1, 0], pos)
    let bbba = hash(self, unit, [1, 1, 1, 0], pos)
    let baab = hash(self, unit, [1, 0, 0, 1], pos)
    let bbab = hash(self, unit, [1, 1, 0, 1], pos)
    let babb = hash(self, unit, [1, 0, 1, 1], pos)
    let bbbb = hash(self, unit, [1, 1, 1, 1], pos)

    let z1 = lerp(
      lerp(lerp(aaaa, baaa, faded.x), lerp(abaa, bbaa, faded.x), faded.y),
      lerp(lerp(aaba, baba, faded.x), lerp(abba, bbba, faded.x), faded.y),
      faded.z,
    )
    let z2 = lerp(
      lerp(lerp(aaab, baab, faded.x), lerp(abab, bbab, faded.x), faded.y),
      lerp(lerp(aabb, babb, faded.x), lerp(abbb, bbbb, faded.x), faded.y),
      faded.z,
    )

    lerp(z1, z2, faded.w)

proc perlin3*(self: Noise, point: Point3d[float]): float {.inline.} =
  ## Returns the noise at the given offset

  withPerlinSetup(point, unit, pos, faded):
    # The hash coordinates of the 8 corners
    let aaa = hash(self, unit, [0, 0, 0], pos)
    let aba = hash(self, unit, [0, 1, 0], pos)
    let aab = hash(self, unit, [0, 0, 1], pos)
    let abb = hash(self, unit, [0, 1, 1], pos)
    let baa = hash(self, unit, [1, 0, 0], pos)
    let bba = hash(self, unit, [1, 1, 0], pos)
    let bab = hash(self, unit, [1, 0, 1], pos)
    let bbb = hash(self, unit, [1, 1, 1], pos)

    let y1 = lerp(lerp(aaa, baa, faded.x), lerp(aba, bba, faded.x), faded.y)
    let y2 = lerp(lerp(aab, bab, faded.x), lerp(abb, bbb, faded.x), faded.y)

    lerp(y1, y2, faded.z)

proc perlin2*(self: Noise, point: Point2D[float]): float {.inline.} =
  ## Returns the noise at the given offset

  withPerlinSetup(point, unit, pos, faded):
    let aa = hash(self, unit, [0, 0], pos)
    let ab = hash(self, unit, [0, 1], pos)
    let ba = hash(self, unit, [1, 0], pos)
    let bb = hash(self, unit, [1, 1], pos)
    lerp(lerp(aa, ba, faded.x), lerp(ab, bb, faded.x), faded.y)
