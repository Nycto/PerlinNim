##
## Draws an 80 by 80 column of noise to the console
##

import perlin, math, strutils

randomize()

var noise = newNoise(8, 10)

for y in 0..100:
    let offset = int(noise.perlin(PI, float(y), E) * 80)
    stdout.write(repeatChar(offset, ' '))
    stdout.write(".\n")

