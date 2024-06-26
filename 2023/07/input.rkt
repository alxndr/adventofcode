#lang racket

(provide input-sample)
(provide input-large)

(define input-sample
  #<<HERE
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
HERE
)

(define input-large
  (file->string "input.txt"))
