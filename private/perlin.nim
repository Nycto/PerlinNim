##
## A Perlin Noise Generation Library
##
## Take a look at the following resources:
## * http://mrl.nyu.edu/~perlin/noise/
## * http://flafla2.github.io/2014/08/09/perlinnoise.html
## * http://riven8192.blogspot.com/2010/08/calculate-perlinnoise-twice-as-fast.html
##

proc unitCubePos( num: float ): int {.inline.} =
    ## Returns the unit cube position for this given value. This chops off
    ## any decimal points and truncates down to < 255
    int(num) and 255

proc decimal( num: float ): float {.inline.} =
    ## Returns just the decimal portion of the given number
    num - float(int(num))

template hash( self: Noise, x, y, z: expr ): expr =
    ## Generates the hash coordinate given three expressions
    self.perm[self.perm[self.perm[x] + y] + z]

proc grad ( hash: int, x, y, z: float ): float =
    ## Calculate the dot product of a randomly selected gradient vector and the
    ## 8 location vectors
    case (hash and 0xF)
    of 0x0: return  x + y
    of 0x1: return -x + y
    of 0x2: return  x - y
    of 0x3: return -x - y
    of 0x4: return  x + z
    of 0x5: return -x + z
    of 0x6: return  x - z
    of 0x7: return -x - z
    of 0x8: return  y + z
    of 0x9: return -y + z
    of 0xA: return  y - z
    of 0xB: return -y - z
    of 0xC: return  y + x
    of 0xD: return -y + z
    of 0xE: return  y - x
    of 0xF: return -y - z
    else: raise newException(AssertionError, "Should not happen")

proc fade ( t: float ): float {.inline.} =
    ## Fade function as defined by Ken Perlin. This eases coordinate values
    ## so that they will "ease" towards integral values. This ends up smoothing
    ## the final output.
    ## 6t^5 - 15t^4 + 10t^3
    t * t * t * (t * (t * 6 - 15) + 10)

proc lerp( a, b, x: float ): float {.inline.} =
    ## Linear interpolator. https://en.wikipedia.org/wiki/Linear_interpolation
    a + x * (b - a)

proc perlinNoise ( self: Noise, point: Point[float] ): float {.inline.} =
    ## Returns the noise at the given offset

    # Calculate the "unit cube" that the point asked will be located in
    let unit: Point[int] = point.map(unitCubePos)

    # Calculate the location within the cube
    let pos: Point[float] = point.map(decimal)

    # Compute the fade curves
    let faded: Point[float] = pos.map(fade)

    # The hash coordinates of the 8 corners
    let aaa = hash(self, unit.x,     unit.y,     unit.z    )
    let aba = hash(self, unit.x,     unit.y + 1, unit.z    )
    let aab = hash(self, unit.x,     unit.y,     unit.z + 1)
    let abb = hash(self, unit.x,     unit.y + 1, unit.z + 1)
    let baa = hash(self, unit.x + 1, unit.y,     unit.z    )
    let bba = hash(self, unit.x + 1, unit.y + 1, unit.z    )
    let bab = hash(self, unit.x + 1, unit.y,     unit.z + 1)
    let bbb = hash(self, unit.x + 1, unit.y + 1, unit.z + 1)

    let x1 = lerp(grad (aaa, pos.x  , pos.y  , pos.z),
                  grad (baa, pos.x-1, pos.y  , pos.z),
                  faded.x)

    let x2 = lerp(grad (aba, pos.x  , pos.y-1, pos.z),
                  grad (bba, pos.x-1, pos.y-1, pos.z),
                  faded.x)

    let y1 = lerp(x1, x2, faded.y)

    let x3 = lerp(grad (aab, pos.x  , pos.y  , pos.z-1),
                  grad (bab, pos.x-1, pos.y  , pos.z-1),
                  faded.x)

    let x4 = lerp(grad (abb, pos.x  , pos.y-1, pos.z-1),
                  grad (bbb, pos.x-1, pos.y-1, pos.z-1),
                  faded.x)

    let y2 = lerp (x3, x4, faded.y)

    let output = lerp(y1, y2, faded.z)

    # For convenience constrain to 0..1 (theoretical min/max before is -1 - 1)
    return (output + 1) / 2

