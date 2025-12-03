#lang racket

(require rackunit
         rackunit/text-ui)

(define (solve-part1)
  (match-let-values {[(dial-result the-count)
                      (let* {[dial-max 99] ; "around the dial are the numbers 0 through 99 in order"
                             [modulo-value (+ 1 dial-max)]}
                        (for*/fold {[dial 50] ; "The dial starts by pointing at 50"
                                    [count-of-zeroes 0]}
                                   {[line (in-lines)]}
                          (let* {[turn-instruction (string-split line #px"(?<=[LR])(?=\\d)")]
                                 [turn-direction (car turn-instruction)]
                                 [turn-amount (string->number (cadr turn-instruction))]
                                 [turn-vector (if (equal? "L" turn-direction) ; equal? for strings...
                                                  (* -1 turn-amount)
                                                  turn-amount)]
                                 [new-dial-value (modulo (+ dial turn-vector)
                                                         modulo-value)] }
                            (values new-dial-value
                                    (if (eq? 0 new-dial-value)
                                        (+ 1 count-of-zeroes)
                                        count-of-zeroes)))))]}
    (printf "\ndial is now at ~a\nsaw 0 this many times: ~a\n\n" dial-result the-count)
    the-count))

(define (solve-part2)
  'TODO)

(run-tests
  (test-suite "part 1"
    (test-case "sample data"
      (check-equal? (with-input-from-file "sample.txt" solve-part1) 3)
    )
    (test-case "real data"
      (check-equal? (with-input-from-file "input.txt"  solve-part1) 1081)
    )
  )

  #; (let {[p1-sample-result (with-input-from-file "sample.txt" solve-part1)]}
    (write "\npart 1 sample result: ~d" p1-sample-result)
    (check-equal? p1-sample-result 3))

  ;; part 2

  #; (check-equal? (with-input-from-file "sample.txt" solve-part2) 'DONE)
  #; (check-equal? (with-input-from-file "input.txt"  solve-part2) 'DONE)
)
