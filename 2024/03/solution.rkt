#lang racket

(require "../advent-of-code-utils.rkt"
         rackunit
         rackunit/text-ui)

(define REGEX #px"mul\\((\\d+),(\\d+)\\)")

(define (solve-part1 input)
  (for/sum ([line input])
    (for/sum ([mult-pair (regexp-match* REGEX line #:match-select cdr)])
      (apply * (map string->number mult-pair)))))

(define (solve-part2 input)
  'TODO)


(run-tests
  (test-suite "2024 day 3"

    (test-suite "part 1"
      (test-case "sample input"
        (check-equal?
          (solve-part1 (sample-input))
          161))
      (test-case "full input"
        (check-equal?
          (solve-part1 (full-input))
          175015740)))

    #; (test-suite "part 2"
      (test-case "sample input"
        (check-equal?
          (solve-part2 (sample-input))
          'TODO))
      (test-case "full input"
        (check-equal?
          (solve-part2 (full-input))
          'TODO)))

  )
)
