#lang racket

(provide input-sample)
(provide input-large)

(define input-sample
  #<<HERE
KTJJT 220
32T3K 765
KK677 28
T55J5 684
QQQJA 483
HERE
)

(define input-large
  (file->string "input.txt"))
