import unittest, perlin, math

randomize()

suite "Perlin Noise should":

    test "Allow for const instantation":
        const noise = newPerlin(123444)
        discard noise.get(1, 2, 3)

    test "Produce values from 0 to 1":
        let noise = newPerlin(987654321)
        for x in 0..50:
            for y in 0..50:
                for z in 0..50:
                    let val = noise.get(x, y, z)
                    require( val >= 0 and val <= 1 )

    let seedOne = randomSeed()
    test "Produce values from 0 to 1 for seed " & $seedOne:
        let noise = newPerlin( seedOne )
        for x in 0..50:
            for y in 0..50:
                for z in 0..50:
                    let val = noise.get(x, y, z)
                    require( val >= 0 and val <= 1 )

    let seedTwo = randomSeed()
    test "Produce values from 0 to 1 with octaves for seed " & $seedTwo:
        let noise = newPerlin( seedTwo, 4, 0.1 )
        for x in 0..50:
            for y in 0..50:
                for z in 0..50:
                    let val = noise.get(x, y, z)
                    require( val >= 0 and val <= 1 )

