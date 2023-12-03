#!/usr/bin/env gawk -f

## usage: expects input via STDIN (either piped in or entered interactively...)
##   eg$ ./02.awk <input.txt

BEGIN {
  ## setup...
  CONTENTS["red"] = 12
  CONTENTS["green"] = 13
  CONTENTS["blue"] = 14
  SUM_IDS = 0
  ## input-splitting config...
  FS = ": "
}
## split fields:
# $1: 'Game #'
# $2: string of rounds (semicolon-separated)
{
  GAME_ID = $1; sub(/[^0-9]+/, "", GAME_ID)
  printf "\n%3d game%3d… ", FNR, GAME_ID
  VALID = 1
  split($2, COLOR_PAIRS, /[,;] /)
  if (length(COLOR_PAIRS) < 1) {
    print "⚠️  ⚠️  ⚠️  no color pairs??"
  }
  for (I = 1; I < length(COLOR_PAIRS); I++) {
    split(COLOR_PAIRS[I], PAIR, " ")
    if (length(PAIR[3])) {
      print "⚠️  ⚠️  ⚠️  wtfffffff" PAIR[3] "???"
    }
    INT_COUNT = PAIR[1]
    STR_COLOR = PAIR[2]
    if (INT_COUNT > CONTENTS[STR_COLOR]) {
      VALID = 0
      printf "❌ %d %s (%d)", INT_COUNT, STR_COLOR, CONTENTS[STR_COLOR]
      break
    }
    printf "%s:%d ", substr(STR_COLOR, 1, 1), INT_COUNT
  }
  if (VALID) {
    SUM_IDS += FNR # GAME_ID
    printf "\n\tnew SUM_IDS:%5d", SUM_IDS
  }
}
END {
  print "\n\nSUM_IDS = " SUM_IDS
  # 2858 too high...
}
