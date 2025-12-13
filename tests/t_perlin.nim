import unittest, perlin, math, random

randomize()

suite "Perlin Noise should":
  let seedOne = randomSeed()
  test "Produce 3D values from 0 to 1 for seed " & $seedOne:
    let noise = newNoise(seedOne)
    for x in -20 .. 20:
      for y in -20 .. 20:
        for z in -20 .. 20:
          let val = noise.perlin(x, y, z)
          require(val >= 0)
          require(val < 1)
          require(val == noise.perlin(x, y, z))

          let pure = noise.purePerlin(x, y, z)
          require(pure >= 0)
          require(pure < 1)
          require(pure == noise.purePerlin(x, y, z))

  let seedTwo = randomSeed()
  test "Produce 3D values from 0 to 1 with octaves for seed " & $seedTwo:
    let noise = newNoise(seedTwo, 4, 0.1)
    for x in -20 .. 20:
      for y in -20 .. 20:
        for z in -20 .. 20:
          let val = noise.perlin(x, y, z)
          require(val >= 0)
          require(val < 1)
          require(val == noise.perlin(x, y, z))

  let seedThree = randomSeed()
  test "Produce 2D values from 0 to 1 for seed " & $seedThree:
    let noise = newNoise(seedOne)
    for x in -20 .. 20:
      for y in -20 .. 20:
        let val = noise.perlin(x, y)
        require(val >= 0)
        require(val < 1)
        require(val == noise.perlin(x, y))

        let pure = noise.purePerlin(x, y)
        require(pure >= 0)
        require(pure < 1)
        require(pure == noise.purePerlin(x, y))

  let seedFour = randomSeed()
  test "Produce 4D values from 0 to 1 with octaves for seed " & $seedFour:
    let noise = newNoise(seedFour, 4, 0.1)
    for x in -5 .. 5:
      for y in -5 .. 5:
        for z in -5 .. 5:
          for w in -5 .. 5:
            let val = noise.perlin(x, y, z, w)
            require(val >= 0)
            require(val < 1)
            require(val == noise.perlin(x, y, z, w))
