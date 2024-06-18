#lang racket

(provide solve-part1
         solve-part2
         )

(require "input.rkt")

; can ignore the colors for now...
; need a matrix-y data structure
; — mutable
; — arbitrary data in each chunk
; have multiple Cursor objects, w/direction, every iteration they bounce around
; the M stores the mirror field, plus direction(s) that light have passed thru (to detect cycles)
; then at the end we'll want the count of chunks which were visited yb light

(define (solve-part1 input)
  #t)

(define (solve-part2 input)
  #f)
