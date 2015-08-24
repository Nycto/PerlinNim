##
## Perlin noise generation
##

proc unitCubePos( num: float ): int {.inline.} =
    ## Returns the unit cube position for this given value. This chops off
    ## any decimal points and truncates down to < 255
    int(num) and 255

proc decimal( num: float ): float {.inline.} =
    ## Returns just the decimal portion of the given number
    num - float(int(num))

proc fade ( t: float ): float {.inline.} =
    ## Fade function as defined by Ken Perlin. This eases coordinate values
    ## so that they will "ease" towards integral values. This ends up smoothing
    ## the final output.
    ## 6t^5 - 15t^4 + 10t^3
    t * t * t * (t * (t * 6 - 15) + 10)

proc lerp( a, b, x: float ): float {.inline.} =
    ## Linear interpolator. https://en.wikipedia.org/wiki/Linear_interpolation
    a + x * (b - a)

proc perlinNoise ( self: Noise, point: Point3d[float] ): float {.inline.} =
    ## Returns the noise at the given offset

    # Calculate the "unit cube" that the point asked will be located in
    let unit = point.map(unitCubePos)

    # Calculate the location within the cube
    let pos = point.map(decimal)

    # Compute the fade curves
    let faded = pos.map(fade)

    # The hash coordinates of the 8 corners
    let aaa = hash(self, unit, 0, 0, 0, pos,  0,  0,  0)
    let aba = hash(self, unit, 0, 1, 0, pos,  0, -1,  0)
    let aab = hash(self, unit, 0, 0, 1, pos,  0,  0, -1)
    let abb = hash(self, unit, 0, 1, 1, pos,  0, -1, -1)
    let baa = hash(self, unit, 1, 0, 0, pos, -1,  0,  0)
    let bba = hash(self, unit, 1, 1, 0, pos, -1, -1,  0)
    let bab = hash(self, unit, 1, 0, 1, pos, -1,  0, -1)
    let bbb = hash(self, unit, 1, 1, 1, pos, -1, -1, -1)

    let y1 = lerp(lerp(aaa, baa, faded.x), lerp(aba, bba, faded.x), faded.y)
    let y2 = lerp (lerp(aab, bab, faded.x), lerp(abb, bbb, faded.x), faded.y)

    let output = lerp(y1, y2, faded.z)

    # For convenience constrain to 0..1 (theoretical min/max before is -1 - 1)
    return (output + 1) / 2

