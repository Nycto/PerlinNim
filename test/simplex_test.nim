import unittest, simplex, math

randomize()

suite "Simplex Noise should":

    test "Allow for const instantation":
        const noise = newNoise(123444)
        discard noise.simplex(1, 2, 3)

    test "Produce values from 0 to 1":
        let noise = newNoise(987654321)
        for x in 0..50:
            for y in 0..50:
                for z in 0..50:
                    let val = noise.simplex(x, y, z)
                    require( val >= 0 and val < 1 )

    let seedOne = randomSeed()
    test "Produce values from 0 to 1 for seed " & $seedOne:
        let noise = newNoise( seedOne )
        for x in 0..50:
            for y in 0..50:
                for z in 0..50:
                    let val = noise.simplex(x, y, z)
                    require( val >= 0 and val < 1 )

    let seedTwo = randomSeed()
    test "Produce values from 0 to 1 with octaves for seed " & $seedTwo:
        let noise = newNoise( seedTwo, 4, 0.1 )
        for x in 0..50:
            for y in 0..50:
                for z in 0..50:
                    let val = noise.simplex(x, y, z)
                    require( val >= 0 and val < 1 )

