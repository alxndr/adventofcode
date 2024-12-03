#lang racket

(require "../advent-of-code-utils.rkt" rackunit rackunit/text-ui)

(define (solve-part1 input)
  'TODO)

(define (solve-part2 input)
  'TODO)

(run-tests
  (test-suite "2024 day #"

    (test-suite "part 1"
      (test-case "sample input"
        (check-equal?
          (solve-part1 (extract-and-split (sample-input)))
          'TODO))
      #; (test-case "full input"
        (check-equal?
          (solve-part1 (extract-and-split (full-input)))
          'TODO)))

    #; (test-suite "part 2"
      (test-case "sample input"
        (check-equal?
          (solve-part2 (extract-and-split (sample-input)))
          'TODO))
      (test-case "full input"
        (check-equal?
          (solve-part2 (extract-and-split (full-input)))
          'TODO)))

  )
)
