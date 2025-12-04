#lang racket

(require rackunit
         rackunit/text-ui)

(define (solve-part1)
  (in-lines))

(define (solve-part2)
  (in-lines))


(printf "\n……about to run tests……\n\n")

(run-tests (test-suite "day #"

  (test-case "part 1: sample data"
    (check-equal? (with-input-from-file "sample.txt" solve-part1)
                  'DONE))

  #; (test-case "part 1: real data"
    (check-equal? (with-input-from-file "input.txt"  solve-part1)
                  'DONE))

  #; (test-case "part 2: sample data"
    (check-equal? (with-input-from-file "sample.txt" solve-part2)
                  'DONE))

  #; (test-case "part 2: real data"
    (check-equal? (with-input-from-file "input.txt"  solve-part2)
                  'DONE)))
'verbose)
