import unittest, perlin, math

randomize()

suite "Perlin Noise should":

    test "Produce values from 0 to 1":
        let noise = newNoise(987654321)
        for x in 0..50:
            for y in 0..50:
                for z in 0..50:
                    let val = noise.perlin(x, y, z)
                    require( val >= 0 and val < 1 )
                    require( val == noise.perlin(x, y, z) )

    let seedOne = randomSeed()
    test "Produce 3D values from 0 to 1 for seed " & $seedOne:
        let noise = newNoise( seedOne )
        for x in 0..50:
            for y in 0..50:
                for z in 0..50:
                    let val = noise.perlin(x, y, z)
                    require( val >= 0 and val < 1 )
                    require( val == noise.perlin(x, y, z) )

    let seedTwo = randomSeed()
    test "Produce 3D values from 0 to 1 with octaves for seed " & $seedTwo:
        let noise = newNoise( seedTwo, 4, 0.1 )
        for x in 0..50:
            for y in 0..50:
                for z in 0..50:
                    let val = noise.perlin(x, y, z)
                    require( val >= 0 and val < 1 )
                    require( val == noise.perlin(x, y, z) )

    let seedThree = randomSeed()
    test "Produce 2D values from 0 to 1 for seed " & $seedThree:
        let noise = newNoise( seedOne )
        for x in 0..50:
            for y in 0..50:
                let val = noise.perlin(x, y)
                require( val >= 0 and val < 1 )
                require( val == noise.perlin(x, y) )

    let seedFour = randomSeed()
    test "Produce 2D values from 0 to 1 with octaves for seed " & $seedFour:
        let noise = newNoise( seedTwo, 4, 0.1 )
        for x in 0..50:
            for y in 0..50:
                let val = noise.perlin(x, y)
                require( val >= 0 and val < 1 )
                require( val == noise.perlin(x, y) )

