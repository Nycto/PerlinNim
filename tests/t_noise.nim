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

