##
## Perlin noise generation
##

import math

proc lerp( a, b, x: float ): float {.inline.} =
    ## Linear interpolator. https://en.wikipedia.org/wiki/Linear_interpolation
    a + x * (b - a)

template withPerlinSetup(point: Point, unit, pos, faded: untyped, body: untyped) =
    ## Sets up three standard variables needed to run the generation

    # Calculate the "unit cube" that the point asked will be located in
    let unit = point.mapIt(int, int(floor(it)) and 255)

    # Calculate the location within the cube
    let pos = point.mapIt(float, it - floor(it))

    ## Fade function as defined by Ken Perlin. This eases coordinate values
    ## so that they will "ease" towards integral values. This ends up smoothing
    ## the final output.
    ## 6t^5 - 15t^4 + 10t^3
    let faded = pos.mapIt(float, it * it * it * (it * (it * 6 - 15) + 10))

    # For convenience constrain to 0..1 (theoretical min/max before is -1 - 1)
    return (body + 1) / 2

proc perlin3 ( self: Noise, point: Point3d[float] ): float {.inline.} =
    ## Returns the noise at the given offset

    withPerlinSetup(point, unit, pos, faded):

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
        let y2 = lerp(lerp(aab, bab, faded.x), lerp(abb, bbb, faded.x), faded.y)

        lerp(y1, y2, faded.z)

proc perlin2 ( self: Noise, point: Point2D[float] ): float {.inline.} =
    ## Returns the noise at the given offset

    withPerlinSetup(point, unit, pos, faded):
        let aa = hash(self, unit, 0, 0, pos,  0,  0)
        let ab = hash(self, unit, 0, 1, pos,  0, -1)
        let ba = hash(self, unit, 1, 0, pos, -1,  0)
        let bb = hash(self, unit, 1, 1, pos, -1, -1)
        lerp(lerp(aa, ba, faded.x), lerp(ab, bb, faded.x), faded.y)

