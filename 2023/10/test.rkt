#lang racket

(require "solution.rkt"
         "input.rkt"
         rackunit
         rackunit/text-ui)


(printf "running tests...\n")
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

    (test-suite "findXY-within"
      (test-case "simple usage" (check-equal? (findXY-within 1 2 '((a b c) (d e f) (g h i) (j k l))) 'h))
      (test-case "error handling"
        (check-equal? (findXY-within 0 0 '())   'error-malformed)
        (check-equal? (findXY-within 0 0 '(())) 'error-empty))
      )

    (test-suite "find-index"
      (test-case "basic" (check-equal? (find-index 3 '(1 2 3)) 2))
      )

    (test-suite
      "adjacent-dims-with-labels"

      (test-case "center" (check-equal? (adjacent-dims-with-labels 1 1 '((1 2 3) (4 5 6) (7 8 9))) '((1 0 above) (0 1 left) (2 1 right) (1 2 below))))
      (test-case
        "sides"
        (check-equal? (adjacent-dims-with-labels 1 0 '((1 2 3) (4 5 6) (7 8 9))) '((0 0 left)  (2 0 right) (1 1 below)))
        (check-equal? (adjacent-dims-with-labels 0 1 '((1 2 3) (4 5 6) (7 8 9))) '((0 0 above) (1 1 right) (0 2 below)))
        (check-equal? (adjacent-dims-with-labels 1 2 '((1 2 3) (4 5 6) (7 8 9))) '((1 1 above) (0 2 left)  (2 2 right)))
        )
      (test-case
        "corners"
        (check-equal? (adjacent-dims-with-labels 0 0 '((1 2 3) (4 5 6) (7 8 9))) '((1 0 right) (0 1 below)))
        (check-equal? (adjacent-dims-with-labels 2 0 '((1 2 3) (4 5 6) (7 8 9))) '((1 0 left)  (2 1 below)))
        (check-equal? (adjacent-dims-with-labels 2 2 '((1 2 3) (4 5 6) (7 8 9))) '((2 1 above) (1 2 left)))
        )
      )

    (test-suite
      "unwrap"
      (test-case
        "error checking"
        (check-equal? (unwrap 'foo) 'error-malformed)
        (check-equal? (unwrap '(foo)) 'error-malformed-still))
      (test-case "empty" (check-equal? (unwrap '()) '()))
      (test-case
        "multiple"
        (check-equal?
          (unwrap '(   ((a b) (1 2 3))    ((4 5) (c d) (e))    ((z y x) (e)) ))
          '((a b) (1 2 3) (4 5) (c d) (e) (z y x) (e))))
      )

    (test-suite
      "solutions"

      (test-suite "part 1"
        (test-case "sample input" (check-equal? (solve-part1 (sample-input)) 8))
        (test-case "full input" (check-equal? (solve-part1 (full-input)) 6778)))

      (test-suite
        "part 2"
        (test-case
          "sample input"
          (check-equal? (solve-part2 (sample-input)) 10))
        ;; (test-case
        ;;   "full input"
        ;;   (check-equal? (solve-part2 (full-input)) 'unknown))
        )

      )

    )

  )
