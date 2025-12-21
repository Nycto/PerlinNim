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

  Point*[S: static int, T: SomeNumber] = ## A point of N dimensions with a specific precision
    array[S, T]

  Point3D*[T: SomeNumber] = ## A helper definition for a 3d point
    Point[3, T]

  Point2D*[T: SomeNumber] = ## \
    ## A helper definition for a 3d point
    Point[2, T]

  AnyPoint*[T: SomeNumber] = Point3D[T] | Point2D[T]

converter tupleToPoint3D*[T](tup: tuple[x, y, z: T]): Point3D[T] =
  [tup.x, tup.y, tup.z]

converter tupleToPoint2D*[T](tup: tuple[x, y: T]): Point2D[T] =
  [tup.x, tup.y]

proc x*(point: AnyPoint): auto {.inline.} =
  point[0]

proc y*(point: AnyPoint): auto {.inline.} =
  point[1]

proc z*(point: Point3D): auto {.inline.} =
  point[2]

proc i*(point: AnyPoint): auto {.inline.} =
  point[0]

proc j*(point: AnyPoint): auto {.inline.} =
  point[1]

proc k*(point: Point3D): auto {.inline.} =
  point[2]

proc octaves*(noise: Noise): auto {.inline.} =
  noise.octaves

proc persistence*(noise: Noise): auto {.inline.} =
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
