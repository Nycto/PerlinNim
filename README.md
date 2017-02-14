PerlinNim [![Build Status](https://travis-ci.org/Nycto/PerlinNim.svg?branch=master)](https://travis-ci.org/Nycto/PerlinNim)
===========

A noise generation library for Nim, with support for both Perlin noise and
Simplex noise.

![](http://nycto.github.io/PerlinNim/example.png)

API Docs
--------

http://nycto.github.io/PerlinNim/perlin.html

A Quick Example
---------------

```nimrod
import perlin, random, math

# Call randomize from the 'math' module to ensure the seed is unique
randomize()

let noise = newNoise()

# Output a 20x10 grid of noise
for y in 0..10:
    for x in 0..20:
        let value = noise.simplex(x, y)
        # If you wanted to use Perlin noise, you would swap that line out with:
        # let value = noise.perlin(x, y)

        stdout.write( int(10 * value) )
    stdout.write("\n")
```

License
-------

This library is released under the MIT License, which is pretty spiffy. You
should have received a copy of the MIT License along with this program. If
not, see http://www.opensource.org/licenses/mit-license.php

