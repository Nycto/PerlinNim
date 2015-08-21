##
## Draws an 80 by 80 column of noise to the console
##

import perlin, math

const symbols = [ " ", "░", "▒", "▓", "█", "█" ]

randomize()

var noise = newPerlin()

for y in 0..40:
    for x in 0..79:
        let index = int( floor(symbols.len * noise.get(x, y, 0)) )
        stdout.write( symbols[index] )
    stdout.write("\n")

