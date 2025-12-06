import std/[sequtils, random]
import random/mersenne

type
  Noise* = object
    ## A noise instance
    ## * `perm` is a set of random numbers used to generate the results
    ## * `octaves` allows you to combine multiple layers of noise
    ##   into a single result
    ## * `persistence` is how much impact each successive octave has on
    ##   the result
    perm: array[0 .. 511, int]
    octaves: int
    persistence: float

  NoiseType* {.pure.} = enum ## \
    ## The types of noise available
    perlin
    simplex

  Point3D*[U: float | int] = ## \
    ## A helper definition for a 3d point
    tuple[x, y, z: U]

  Point2D*[U: float | int] = ## \
    ## A helper definition for a 3d point
    tuple[x, y: U]

  PointND*[U: float | int] = ## \
    ## a point of N dimensions with a specific precision
    Point3D[U] | Point2D[U]

  Point* = ## \
    ## A 2d or 3d point with any kind of precision
    Point3D[float] | Point3D[int] | Point2D[float] | Point2D[int]

proc octaves*(noise: Noise): auto =
  noise.octaves

proc persistence*(noise: Noise): auto =
  noise.persistence

proc shuffle[E](seed: uint32, values: var seq[E]) =
  ## Shuffles a sequence in place

  var prng = initMersenneTwister(seed)

  let max = uint32(values.high)

  # Shuffle the array of numbers
  for i in 0u32 .. (max - 1u32):
    let index = int(i + (prng.randomUint32() mod (max - i)) + 1u32)
    assert(index <= 255)
    assert(int(i) < index)
    swap values[int(i)], values[index]

proc buildPermutations*(seed: uint32): array[0 .. 511, int] =
  ## Returns a hash lookup table. It is all the numbers from 0 to 255
  ## (inclusive) in a randomly sorted array, twice over

  # Create and shuffle a random list of ints
  var base = toSeq(0 .. 255)
  shuffle(seed, base)

  # Copy into the result
  for i in 0 .. 511:
    result[i] = base[i mod 256]

proc newNoise*(seed: uint32, octaves: int = 1, persistence: float = 0.5): Noise =
  ## Creates a new noise instance with the given seed
  ## * `octaves` allows you to combine multiple layers of noise
  ##   into a single result
  ## * `persistence` is how much impact each successive octave has on
  ##   the result
  assert(octaves >= 1)
  return
    Noise(perm: buildPermutations(seed), octaves: octaves, persistence: persistence)

proc newNoise*(octaves: int, persistence: float): Noise =
  ## Creates a new noise instance with a random seed
  ## * `octaves` allows you to combine multiple layers of noise
  ##   into a single result
  ## * `persistence` is how much impact each successive octave has on
  ##   the result
  newNoise(rand(uint32), octaves, persistence)

proc newNoise*(): Noise =
  ## Creates a new noise instance with a random seed
  newNoise(1, 1.0)
