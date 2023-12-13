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

    (test-suite "solutions"

      (test-suite "part 1"
        (test-case "preprocessed sample" (check-equal? (solve-part1-preprocessed (sample-input-expanded)) 374))
        (test-case "preprocessed full" (check-equal? (solve-part1-preprocessed (full-input-expanded)) 10228230))
        )

      (test-suite "part 2"

        (test-case "preprocessed sample"
          (check-equal?
            (solve-part2-preprocessed (sample-input-expanded) 10)
            1030)
          )

        (test-case "preprocessed sample"
          (check-equal?
            (solve-part2-preprocessed (sample-input-expanded) 100)
            8410)
          )

        (test-case "preprocessed full"
          (check-equal?
            (solve-part2-preprocessed (full-input-expanded) 1000000)
            1)
          )


        )

      )
    )

  )
