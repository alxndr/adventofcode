#lang racket

(require "solution.rkt"
         "input.rkt"
         rackunit
         rackunit/text-ui)

(run-tests

  (test-suite
    "2023 day 15"

    (test-suite "sample-input"
      (test-case "is a list" (check-equal? (empty? (sample-input)) #f))
      (test-case "contains strings" (check-equal? (car (sample-input)) "rn=1"))
      )

    (test-suite "run-algorithm"
      (test-case "HASH" (check-equal? (run-algorithm "HASH") 52))
      (for-each
        (λ (hash-and-result)
          (let [[input    (car hash-and-result)]
                [expected (cadr hash-and-result)]]
            (test-case input (check-equal? (run-algorithm input) expected))))
        '( ("rn=1" 30) ("cm-"  253) ("qp=3" 97) ("cm=2" 47) ("qp-"  14) ("pc=4" 180) ("ot=9" 9) ("ab=5" 197) ("pc-"  48) ("pc=6" 214) ("ot=7" 231) )
        )
      )

    (test-suite
      "solve-part1"
      (test-case "sample-input" (check-equal? (solve-part1 (sample-input)) 1320))
      (test-case "full-input" (check-equal? (solve-part1 (full-input)) 515210))
      )

    (test-suite
      "solve-part2"

      (test-case
        "sample-input"
        (check-equal?
          (solve-part2 (sample-input))
          145)
        )

      (test-case
        "full-input"
        (check-equal?
          (solve-part2 (full-input))
          246762)
        )

      )

    )

  )
