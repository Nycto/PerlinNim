import unittest, noise, math

randomize()

suite "General Noise should":

    test "Provide perlin noise":
        let noise = newNoise()
        require( noise.get(perlin, 1, 2, 3) >= 0 )
        require( noise.get(perlin, 1, 2, 3) < 1 )

    test "Provide simplex noise":
        let noise = newNoise()
        require( noise.get(simplex, 1, 2, 3) >= 0 )
        require( noise.get(simplex, 1, 2, 3) < 1 )

