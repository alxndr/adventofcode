#lang racket

(require "solution.rkt"
         "input.rkt"
         rackunit
         rackunit/text-ui)

(run-tests

  (test-suite
    "2023 day 10"

    (test-suite "split-input"
      (test-case "basic"  (check-equal? (split-input "ab\ncd") '(("a" "b") ("c" "d"))))
      (test-case "spaces" (check-equal? (split-input " ab\ncd\n") '(("a" "b") ("c" "d"))))
      )

    (test-suite "process-input-lists"
      (test-case "basic" (check-equal? (process-input-lists '(("." "F" "7" "J" "|" "S" "L" "-" "a" "B" "blargh"))) '((X F 7 J ! S L - X X X))))
      (test-case "many lists" (check-equal? (process-input-lists '(("!") ("J" "?" "|") ("7" "F" "L" "-" "S"))) '((X) (J X !) (7 F L - S))))
      )

    (test-suite "findXY"
      (test-case "simple"
        (check-equal? (findXY 0 0 '()) 'error-malformed)
        (check-equal? (findXY 0 0 '(())) 'error-empty)
        (check-equal? (findXY 1 2 '((a b c) (d e f) (g h i) (j k l))) 'h)
        )
      )

    (test-suite
      "find-index"

      (test-case
        "basic"

        (check-equal?
          (find-index 3 '(1 2 3))
          2)

        ))

    )

  )
