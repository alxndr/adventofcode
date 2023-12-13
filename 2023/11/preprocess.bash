#!/bin/bash

# Usage: ./preprocess.bash input.txt >processed.txt 2>processed-info.ssv
# This will emit the processed text to STDOUT, and statistics to STDERR.
# The statistics are which columns and rows in the input have all-"."s.
# (In the processed output, these characters will be replaced with ":"s)

INPUT=${1:-sample.txt}

# h/t steeldriver https://unix.stackexchange.com/a/383232/48320
<$INPUT awk '{$1=$1} 1' FS= \
  | rs -Tng0 \
  | awk 'BEGIN {COLS="cols"} /^\.*$/{gsub(/\./, ":"); COLS=sprintf("%s %s", COLS, NR-1)} {print} END {print COLS > "/dev/stderr" }' \
  | awk '{$1=$1} 1' FS=  \
  | rs -Tng0 \
  | awk 'BEGIN {ROWS="rows"} /^[.: ]*$/{gsub(/\./, ":"); ROWS=sprintf("%s %s", ROWS, NR-1)} {print} END {print ROWS > "/dev/stderr" }' \
