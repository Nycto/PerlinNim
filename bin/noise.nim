##
## Draws an 80 by 80 column of noise to the console
##

import perlin, math

const symbols = [ " ", "░", "▒", "▓", "█", "█" ]

randomize()

var noise = newPerlin()

for y in 0..40:
    for x in 0..79:
        let value = noise.get(x, y, 0)
        stdout.write( symbols[int(symbols.len * value)] )
    stdout.write("\n")

