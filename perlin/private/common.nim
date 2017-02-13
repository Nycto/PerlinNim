##
## Shared methods for generating noise
##

import sequtils, mersenne

type
    Point3D*[U: float|int] = ## \
        ## A helper definition for a 3d point
        tuple[x, y, z: U]

    Point2D*[U: float|int] = ## \
        ## A helper definition for a 3d point
        tuple[x, y: U]

    PointND*[U: float|int] = ## \
        ## a point of N dimensions with a specific precision
        Point3D[U]|Point2D[U]

    Point* = ## \
        ## A 2d or 3d point with any kind of precision
        Point3D[float]|Point3D[int]|Point2D[float]|Point2D[int]

proc shuffle[E](seed: uint32, values: var seq[E]) =
    ## Shuffles a sequence in place

    var prng = newMersenneTwister(seed)

    let max = uint32(values.high)

    # Shuffle the array of numbers
    for i in 0u32..(max - 1u32):
        let index = int(i + (prng.getNum() mod (max - i)) + 1u32)
        assert(index <= 255)
        assert(int(i) < index)
        swap values[int(i)], values[index]

proc buildPermutations*(seed: uint32): array[0..511, int] =
    ## Returns a hash lookup table. It is all the numbers from 0 to 255
    ## (inclusive) in a randomly sorted array, twice over

    # Create and shuffle a random list of ints
    var base = toSeq(0..255)
    shuffle(seed, base)

    # Copy into the result
    for i in 0..511:
        result[i] = base[i mod 256]

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

