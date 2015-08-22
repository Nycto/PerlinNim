##
## Shared methods for generating noise
##

import sequtils, math, random/mersenne

type
    Point*[U: float|int] = ## \
        ## A helper definition for a 3d point
        tuple[x, y, z: U]

proc shuffle*[E]( seed: uint32, values: var seq[E] ) =
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

proc randomSeed*(): uint32 {.inline.} =
    ## Returns a random seed that can be fed into a perlin constructor
    uint32(random(high(int)))

template map*( point, apply: expr ): expr =
    ## Applies a callback to all the values in a point
    ( x: apply(point.x), y: apply(point.y), z: apply(point.z) )

template applyOctaves* ( self: expr, x, y, z: int|float ): float {.immediate.} =
    ## Applies the configured octaves to the request
    var total: float = 0
    var frequency: float = 1
    var amplitude: float = 1

    # Used for normalizing result to 0.0 - 1.0
    var maxValue: float = 0

    for i in 0..self.octaves:
        let noise = self.noise( (x * frequency, y * frequency, z * frequency) )
        total = total + amplitude * noise

        maxValue = maxValue + amplitude
        amplitude = amplitude * self.persistence
        frequency = frequency * 2

    total / maxValue


