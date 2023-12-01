#!/usr/bin/env gawk -f

## usage: expects input via STDIN (either piped in or entered interactively...)
##   eg$ ./01.awk <input.txt

BEGIN {
  print "01...\n"
  SUM=0
}

{
  gsub(/[^0-9]/, "")
  POS_FIRST_INT = match($0, /[0-9]/) # 1-indexed...
  POS_LAST_INT = match($0, /[0-9]$/) # 1-indexed...
  LINE_CALCULATION = (int(substr($0, POS_FIRST_INT, 1)) * 10) + int(substr($0, POS_LAST_INT, 1))
  SUM = SUM + LINE_CALCULATION
}

END {
  print "= " SUM
}
