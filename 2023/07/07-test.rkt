#lang racket/base

(require "07.rkt"
         rackunit
         rackunit/text-ui)
; "collection not found for module path: rackunit collection: "rackunit" in collection directories"
; ...run the below in CLI:
; $ raco pkg install rackunit

(run-tests
  (test-suite ; "Unlike a check or test case, a test suite is not immediately run"

    "2023 Day 7"

    ;#:before (λ () (display "\n⚖ ⚖ ⚖ tests starting...\n"))
    ;#:after  (λ () (display "\n⚖ ⚖ ⚖ tests ending!\n"))

    (test-case
      "hand-to-type-num"
      ; TODO more-than-5 cards...
      (check-equal?
        (hand-to-type-num
          '((6 1) (5 1) (4 1) (3 1) (2 1)))
        1
        "high card")
      (check-equal?
        (hand-to-type-num
          '((5 2) (4 1) (3 1) (2 1)))
        11
        "1 pair")
      (check-equal?
        (hand-to-type-num
          '((4 2) (3 2) (2 1)))
        22
        "2 pair")
      (check-equal?
        (hand-to-type-num
          '((4 3) (3 1) (2 1)))
        33
        "3-of-a-kind")
      (check-equal?
        (hand-to-type-num
          '((4 3) (3 2)))
        40
        "full house")
      (check-equal?
        (hand-to-type-num
          '((4 4) (1 1)))
        44
        "4-of-a-kind")
      (check-equal?
        (hand-to-type-num
          '((4 5)))
        55
        "5-of-a-kind"))

    (test-case
      "...part 2"

      (check-equal?
        (answer-sample)
        5905
        "answer-sample — result is 5905")

      (check-true
        (< 253552043 (answer-full))
        "answer-full — less than 253552043")

      )))
