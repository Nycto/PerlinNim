##
## Shared methods for generating noise
##

import sequtils, math, random/mersenne

type
    Point*[U: float|int] = ## \
        ## A helper definition for a 3d point
        tuple[x, y, z: U]

    Noise* = object
        ## A noise instance
        ## * `perm` is a set of random numbers used to generate the results
        ## * `octaves` allows you to combine multiple layers of noise
        ##   into a single result
        ## * `persistence` is how much impact each successive octave has on
        ##   the result
        perm: array[0..511, int]
        octaves: int
        persistence: float


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

proc buildPermutations( seed: uint32 ): array[0..511, int] =
    ## Returns a hash lookup table. It is all the numbers from 0 to 255
    ## (inclusive) in a randomly sorted array, twice over

    # Create and shuffle a random list of ints
    var base = toSeq(0..255)
    shuffle(seed, base)

    # Copy into the result
    for i in 0..511:
        result[i] = base[i mod 256]


proc randomSeed*(): uint32 {.inline.} =
    ## Returns a random seed that can be fed into a constructor
    uint32(random(high(int)))


proc newNoise*(
    seed: uint32,
    octaves: int = 1, persistence: float = 0.5
): Noise =
    ## Creates a new noise instance with the given seed
    ## * `octaves` allows you to combine multiple layers of noise
    ##   into a single result
    ## * `persistence` is how much impact each successive octave has on
    ##   the result
    assert(octaves >= 1)
    return Noise(
        perm: buildPermutations(seed),
        octaves: octaves, persistence: persistence )

proc newNoise*( octaves: int, persistence: float ): Noise =
    ## Creates a new noise instance with a random seed
    ## * `octaves` allows you to combine multiple layers of noise
    ##   into a single result
    ## * `persistence` is how much impact each successive octave has on
    ##   the result
    newNoise( randomSeed(), octaves, persistence )

proc newNoise*(): Noise =
    ## Creates a new noise instance with a random seed
    newNoise( 1, 0.5 )

proc perm*( self: Noise, index: int ): int {.inline.} =
    ## An accessor for the permutation table, so it isn't made public
    self.perm[index]


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


template applyOctaves*( self: Noise, callback: expr, x, y, z: float ): float =
    ## Applies the configured octaves to the request
    var total: float = 0
    var frequency: float = 1
    var amplitude: float = 1

    # Used for normalizing result to 0.0 - 1.0
    var maxValue: float = 0

    for i in 0..self.octaves:
        let noise = callback(
            self,
            (x * frequency, y * frequency, z * frequency)
        )
        total = total + amplitude * noise

        maxValue = maxValue + amplitude
        amplitude = amplitude * self.persistence
        frequency = frequency * 2

    total / maxValue


