#lang racket

(require rackunit
         rackunit/text-ui)

(define (solve-part1)
  'TODO)

(define (solve-part2)
  'TODO)


(run-tests
  (test-suite "part 1"
    (test-case "sample data"
      (check-equal? (with-input-from-file "sample.txt" solve-part1) 'DONE)
    )
    #; (test-case "real data"
      (check-equal? (with-input-from-file "input.txt"  solve-part1) 'DONE)
    )
  )
  (test-suite "part 2"
    #; (test-case "sample data"
      (check-equal? (with-input-from-file "sample.txt" solve-part2) 'DONE)
    )
    #; (test-case "real data"
      (check-equal? (with-input-from-file "input.txt"  solve-part2) 'DONE)
    )
  )
)
