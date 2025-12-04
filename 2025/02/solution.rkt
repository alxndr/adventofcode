#lang racket

(provide solve-part1
         solve-part2)

(require "input.rkt"
         rackunit
         rackunit/text-ui)

(define {even? n}
  (eq? 0 (modulo n 2)))

(define {is-invalid? id-num}
  (let* { [id-str (number->string id-num)]
          [id-length (string-length id-str)] }
    (and (even? id-length)
         (equal? (substring id-str 0 (id-length . / . 2))
                 (substring id-str (id-length . / . 2)))
         #t)))

(define {solve-part1 input}
  (let { [invalid-ids (recursive-solve-part1 input '())] }
    (for/fold {[sum 0]} {[n invalid-ids]} (+ sum n))))

(define {recursive-solve-part1 ranges invalid-ids}
  (if (empty? ranges)
      invalid-ids
      (let { [range-start (caar ranges)]
             [range-end  (cadar ranges)]
             [ranges-rest  (cdr ranges)] }
        (recursive-solve-part1
          (if (= range-start range-end)
              ranges-rest
              (cons (list (+ 1 range-start) range-end) ranges-rest))
          (if (is-invalid? range-start)
              (cons range-start invalid-ids)
              invalid-ids))
        )
      )
  )

(define {solve-part2 input}
  input)


(printf "\n……about to run tests……\n\n")

(run-tests (test-suite "day 2"

  (test-case "helpers: is-invalid?"
    (check-equal? (is-invalid?        1)    #false)
    (check-equal? (is-invalid?       11)    #true)
    (check-equal? (is-invalid?       12)    #false)
    (check-equal? (is-invalid?     1234)    #false)
    (check-equal? (is-invalid?     1234123) #false)
    (check-equal? (is-invalid? 12341234)    #true)
    (check-equal? (is-invalid? 123412341)   #false)
    (check-equal? (is-invalid? 56565656)    #true)
    (check-equal? (is-invalid?  787878)     #false)
    (check-equal? (is-invalid?  878878)     #true)
    )

  (test-case "part 1: sample data"
    (check-equal? (solve-part1 (sample-input))
                  1227775554))

  (test-case "part 1: real data"
    (check-equal? (solve-part1 (full-input))
                  40398804950))

  #; (test-case "part 2: sample data"
    (check-equal? (solve-part2 (sample-input))
                  'DONE))

  #; (test-case "part 2: real data"
    (check-equal? (solve-part2 (full-input))
                  'DONE))))
