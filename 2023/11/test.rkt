#lang racket

(require "solution.rkt"
         "input.rkt"
         rackunit
         rackunit/text-ui)

(run-tests

  (test-suite
    "2023 day 11"

    (test-suite
      "process-the-line"

      (test-case "basic" (check-equal? (process-the-line "..." '() '() 0) '( ((1 1 1)) ())))
      (test-case "basic"
        (check-equal?
          (process-the-line ".#..." '((foo)) '((0 0)) 5)
          '(
            ((foo) (1 @ 1 1 1))
            ((0 0) (1 5))
          ))
        )
      )

    (test-suite "process-input-lists"
      (test-case "basic"
        (check-equal?
          (process-input-lists '("..#.") )
          '(((1 1 @ 1))
            ((2 0)))))
      (test-case "basic"
        (check-equal?
          (process-input-lists '("..." "#..") )
          '(((1 1 1) (@ 1 1))
            ((0 1)))))
      )

    (test-suite
      "format-universe"
      (test-case "basic"
                 (check-equal?
                   (format-universe '((1 1) (@ 1)))
                   "  \nX ")))

    (test-suite
      "expand-universe"

      ;; (test-case
      ;;   "basic"
      ;;   (check-equal?
      ;;     (expand-universe
      ;;       '((1 1 @)
      ;;         (1 @ 1)
      ;;         (1 1 1)))
      ;;     '((2 1 @)
      ;;       (2 @ 1)
      ;;       (2 2 2)))
      ;;   )

      )

    (test-suite
      "solutions"

      ;; (test-suite
      ;;   "part 1"
      ;;   (test-case
      ;;     "sample"
      ;;     (check-equal?
      ;;       (solve-part1 (sample-input))
      ;;       374)
      ;;     )
      ;;   )

      (test-suite
        "part 1"
        (test-case
          "preprocessed sample"
          (check-equal?
            (solve-part1-preprocessed (sample-input-expanded))
            374)
          )
        )

      )
    )

  )
