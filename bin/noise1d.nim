##
## Draws an 80 by 80 column of noise to the console
##

import perlin, math, strutils

randomize()

var noise = newPerlin()

for y in 0..200:
    let offset = int(noise.get(PI, float(y), E) * 80)
    stdout.write(repeatChar(offset, ' '))
    stdout.write(".\n")

