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

    ; TODO "So, 33332 and 2AAAA are both four of a kind hands, but 33332 is stronger because its first card is stronger. Similarly, 77888 and 77788 are both a full house, but 77888 is stronger because its third card is stronger (and both hands have the same first and second card)."
    ; TODO "Now, you can determine the total winnings of this set of hands by adding up the result of multiplying each hand's bid with its rank (765 * 1 + 220 * 2 + 28 * 3 + 684 * 4 + 483 * 5). So the total winnings in this example are 6440.
    ; TODO "Find the rank of every hand in your set. What are the total winnings?
    ; TODO "Your puzzle answer was 252656917."

    ; TODO test camel-compare...
    (test-case
      "hand-to-type-num"
      ; TODO more-than-5 cards...
      (check-equal?
        (hand-to-type-num ; TODO why this fails...??
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
        "5-of-a-kind")
      (check-equal?
        (hand-to-type-num
          '(3))
        0
        "unknown")
      (check-equal?
        (hand-to-type-num
          '())
        0
        "unknown")
      )

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
