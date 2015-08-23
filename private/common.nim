##
## Shared methods for generating noise
##

import sequtils, math, random/mersenne

type
    Point3D*[U: float|int] = ## \
        ## A helper definition for a 3d point
        tuple[x, y, z: U]

proc shuffle[E]( seed: uint32, values: var seq[E] ) =
    ## Shuffles a sequence in place

    var prng = initMersenneTwister(seed)

    let max = uint32(values.high)

    # Shuffle the array of numbers
    for i in 0u32..(max - 1u32):
        let index = int(i + (prng.randomUint32() mod (max - i)) + 1u32)
        assert(index <= 255)
        assert(int(i) < index)
        swap values[int(i)], values[index]

proc buildPermutations*( seed: uint32 ): array[0..511, int] =
    ## Returns a hash lookup table. It is all the numbers from 0 to 255
    ## (inclusive) in a randomly sorted array, twice over

    # Create and shuffle a random list of ints
    var base = toSeq(0..255)
    shuffle(seed, base)

    # Copy into the result
    for i in 0..511:
        result[i] = base[i mod 256]

template map*( point: tuple, apply: expr ): expr =
    ## Applies a callback to all the values in a point
    ( x: apply(point.x), y: apply(point.y), z: apply(point.z) )

template mapIt*( point: tuple, kind, apply: expr ): expr =
    ## Applies a callback to all the values in a point
    var output: array[3, kind]
    block applyItBlock:
        let it {.inject.} = point.x
        output[0] = apply
    block applyItBlock:
        let it {.inject.} = point.y
        output[1] = apply
    block applyItBlock:
        let it {.inject.} = point.z
        output[2] = apply
    ( x: output[0], y: output[1], z: output[2] )


# Gradient lookup table
const grad3*: array[12, Point3d[float]] = [
    (x:  1.0, y:  1.0, z:  0.0),
    (x: -1.0, y:  1.0, z:  0.0),
    (x:  1.0, y: -1.0, z:  0.0),
    (x: -1.0, y: -1.0, z:  0.0),
    (x:  1.0, y:  0.0, z:  1.0),
    (x: -1.0, y:  0.0, z:  1.0),
    (x:  1.0, y:  0.0, z: -1.0),
    (x: -1.0, y:  0.0, z: -1.0),
    (x:  0.0, y:  1.0, z:  1.0),
    (x:  0.0, y: -1.0, z:  1.0),
    (x:  0.0, y:  1.0, z: -1.0),
    (x:  0.0, y: -1.0, z: -1.0)
]

proc dot*(g: Point3d[float], p: Point3d[float] ): float {.inline.} =
    return g.x * p.x + g.y * p.y + g.z * p.z


