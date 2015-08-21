import unittest, perlin

suite "Perlin Noise should":

    test "Allow for const instantation":
        const noise = newPerlin(123444)
        discard noise.get(1, 2, 3)

    test "Produce values from 0 to 1":
        let noise = newPerlin(987654321)
        for x in 0..100:
            for y in 0..100:
                for z in 0..100:
                    let val = noise.get(x, y, z)
                    require( val >= 0 and val <= 1 )


