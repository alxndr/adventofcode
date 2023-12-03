#!/usr/bin/env gawk -f

## usage: expects input via STDIN (either piped in or entered interactively...)
##   eg$ ./02.awk <input.txt

BEGIN {
  ## setup...
  SUM_POWERS = 0
  ## input-splitting config...
  FS = ": "
}
## split fields:
# $1: 'Game #'
# $2: string of rounds (semicolon-separated)
{
  GAME_ID = $1; sub(/[^0-9]+/, "", GAME_ID)
  split($2, COLOR_PAIRS, /[,;] /)
  MAX_SEEN["red"] = 0
  MAX_SEEN["green"] = 0
  MAX_SEEN["blue"] = 0
  for (I = 1; I <= length(COLOR_PAIRS); I++) {
    split(COLOR_PAIRS[I], PAIR, " ")
    INT_COUNT = PAIR[1]
    STR_COLOR = PAIR[2]

    if (INT_COUNT > MAX_SEEN[STR_COLOR]) {
      MAX_SEEN[STR_COLOR] = INT_COUNT
    }
  }
  printf "#%3d… R:%d G:%d B:%d\n", GAME_ID, MAX_SEEN["red"], MAX_SEEN["green"], MAX_SEEN["blue"]
  # The power of a set of cubes is equal to the numbers of red, green, and blue cubes multiplied together
  POWER = MAX_SEEN["red"] * MAX_SEEN["green"] * MAX_SEEN["blue"]
  # For each game, find the minimum set of cubes that must have been present. What is the sum of the power of these sets?
  SUM_POWERS = SUM_POWERS + POWER
}
END {
  print "\n\nSUM_POWERS = " SUM_POWERS
}
