import unittest, perlin, math, random

randomize()

suite "General Noise should":

    test "Provide perlin noise":
        let noise = newNoise()
        check( noise.get(NoiseType.perlin, 1, 2, 3) >= 0 )
        check( noise.get(NoiseType.perlin, 1, 2, 3) < 1 )

    test "Provide simplex noise":
        let noise = newNoise()
        check( noise.get(NoiseType.simplex, 1, 2, 3) >= 0 )
        check( noise.get(NoiseType.simplex, 1, 2, 3) < 1 )

    test "Noise should be assignable at build time":
        const noise = newNoise(12345)
        const simplexVal = noise.get(NoiseType.simplex, 1, 2, 3)
        const noiseVal = noise.get(NoiseType.perlin, 1, 2, 3)

        check(simplexVal == 0.3310572195555556)
        check(noiseVal == 0.492089610128111)

