import unittest, perlin, math, random

randomize()

suite "Simplex Noise should":

    let seedOne = randomSeed()
    test "Produce values from 0 to 1 for seed " & $seedOne:
        let noise = newNoise( seedOne )
        for x in -20..20:
            for y in -20..20:
                for z in -20..20:
                    let val = noise.simplex(x, y, z)
                    check( val >= 0 and val < 1 )
                    check( val == noise.simplex(x, y, z) )

                    let pure = noise.pureSimplex(x, y, z)
                    check( pure >= 0 and val < 1 )
                    check( pure == noise.pureSimplex(x, y, z) )

    let seedTwo = randomSeed()
    test "Produce values from 0 to 1 with octaves for seed " & $seedTwo:
        let noise = newNoise( seedTwo, 4, 0.1 )
        for x in -20..20:
            for y in -20..20:
                for z in -20..20:
                    let val = noise.simplex(x, y, z)
                    check( val >= 0 and val < 1 )
                    check( val == noise.simplex(x, y, z) )

    let seedThree = randomSeed()
    test "Produce 2D values from 0 to 1 for seed " & $seedThree:
        let noise = newNoise( seedOne )
        for x in -20..20:
            for y in -20..20:
                let val = noise.simplex(x, y)
                check( val >= 0 and val < 1 )
                check( val == noise.simplex(x, y) )

                let pure = noise.pureSimplex(x, y)
                check( pure >= 0 and val < 1 )
                check( pure == noise.pureSimplex(x, y) )

