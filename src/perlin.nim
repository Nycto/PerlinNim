##
## A Noise Generation Library with support for both Perlin noise and Simplex
## noise.
##
## Simplex Noise
## -------------
##
## Take a look here:
## * http://webstaff.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf
## * http://stackoverflow.com/questions/18279456/any-simplex-noise-tutorials-or-resources
##
## Based on the implementation found here:
## * http://webstaff.itn.liu.se/~stegu/simplexnoise/SimplexNoise.java
##
## Perlin Noise
## ------------
##
## Take a look at the following resources:
## * http://mrl.nyu.edu/~perlin/noise/
## * http://flafla2.github.io/2014/08/09/perlinnoise.html
## * http://riven8192.blogspot.com/2010/08/calculate-perlinnoise-twice-as-fast.html
##

import std/random, perlin/private/[perlin, simplex, types]
export perlin, simplex, types

proc randomSeed*(): uint32 {.inline.} =
  ## Returns a random seed that can be fed into a constructor
  rand(uint32)

template applyOctaves(self: Noise, callback: untyped, point: Point): float =
  ## Applies the configured octaves to the request
  var total: float = 0
  var frequency: float = 1
  var amplitude: float = 1

  # Used for normalizing result to 0.0 - 1.0
  var maxValue: float = 0

  for i in 0 .. self.octaves:
    let noise = callback(
      self,
      when compiles(point.z):
        [point.x * frequency, point.y * frequency, point.z * frequency]
      else:
        [point.x * frequency, point.y * frequency],
    )

    total = total + amplitude * noise

    maxValue = maxValue + amplitude
    amplitude = amplitude * self.persistence
    frequency = frequency * 2

  total / maxValue

proc perlin*(self: Noise, x, y, z: SomeNumber): float =
  ## Returns the noise at the given offset. Returns a value between 0 and 1
  ##
  ## Note: This method tweaks the input values by just a bit to make sure
  ## there are decimal points. If you don't want that, use the 'purePerlin'
  ## method instead
  applyOctaves(self, perlin3, [float(x) * 0.1, float(y) * 0.1, float(z) * 0.1])

proc perlin*(self: Noise, x, y: SomeNumber): float =
  ## Returns the noise at the given offset. Returns a value between 0 and 1
  ##
  ## Note: This method tweaks the input values by just a bit to make sure
  ## there are decimal points. If you don't want that, use the 'purePerlin'
  ## method instead
  applyOctaves(self, perlin2, [float(x) * 0.1, float(y) * 0.1])

proc purePerlin*(self: Noise, x, y, z: SomeNumber): float =
  ## Returns the noise at the given offset without modifying the input.
  ## Returns a value between 0 and 1
  applyOctaves(self, perlin3, [float(x), float(y), float(z)])

proc purePerlin*(self: Noise, x, y: SomeNumber): float =
  ## Returns the noise at the given offset without modifying the input.
  ## Returns a value between 0 and 1
  applyOctaves(self, perlin2, [float(x), float(y)])

proc simplex*(self: Noise, x, y, z: SomeNumber): float =
  ## Returns the noise at the given offset. Returns a value between 0 and 1
  ##
  ## Note: This method tweaks the input values by just a bit to make sure
  ## there are decimal points. If you don't want that, use the 'purePerlin'
  ## method instead
  applyOctaves(
    self, simplex3, [float(x) * 0.1, float(y) * 0.1, float(z) * 0.1]
  )

proc simplex*(self: Noise, x, y: SomeNumber): float =
  ## Returns the noise at the given offset. Returns a value between 0 and 1
  ##
  ## Note: This method tweaks the input values by just a bit to make sure
  ## there are decimal points. If you don't want that, use the 'purePerlin'
  ## method instead
  applyOctaves(self, simplex2, [float(x) * 0.1, float(y) * 0.1])

proc pureSimplex*(self: Noise, x, y, z: SomeNumber): float =
  ## Returns the noise at the given offset without modifying the input.
  ## Returns a value between 0 and 1
  applyOctaves(self, simplex3, [float(x), float(y), float(z)])

proc pureSimplex*(self: Noise, x, y: SomeNumber): float =
  ## Returns the noise at the given offset without modifying the input.
  ## Returns a value between 0 and 1
  applyOctaves(self, simplex2, [float(x), float(y)])

proc get*(self: Noise, typ: NoiseType, x, y, z: SomeNumber): float =
  ## Returns the noise at the given offset. Returns a value between 0 and 1
  ##
  ## Note: This method tweaks the input values by just a bit to make sure
  ## there are decimal points. If you don't want that, use the 'purePerlin'
  ## method instead
  case typ
  of NoiseType.perlin:
    return perlin(self, x, y, z)
  of NoiseType.simplex:
    return simplex(self, x, y, z)

proc get*(self: Noise, typ: NoiseType, x, y: SomeNumber): float =
  ## Returns the noise at the given offset. Returns a value between 0 and 1
  ##
  ## Note: This method tweaks the input values by just a bit to make sure
  ## there are decimal points. If you don't want that, use the 'purePerlin'
  ## method instead
  case typ
  of NoiseType.perlin:
    return perlin(self, x, y)
  of NoiseType.simplex:
    return simplex(self, x, y)

proc pureGet*(self: Noise, typ: NoiseType, x, y, z: SomeNumber): float =
  ## Returns the noise at the given offset without modifying the input.
  ## Returns a value between 0 and 1
  case typ
  of NoiseType.perlin:
    return purePerlin(self, x, y, z)
  of NoiseType.simplex:
    return pureSimplex(self, x, y, z)

proc pureGet*(self: Noise, typ: NoiseType, x, y: SomeNumber): float =
  ## Returns the noise at the given offset without modifying the input.
  ## Returns a value between 0 and 1
  case typ
  of NoiseType.perlin:
    return purePerlin(self, x, y)
  of NoiseType.simplex:
    return pureSimplex(self, x, y)
