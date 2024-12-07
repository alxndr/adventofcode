#lang racket

(require rackunit)

(define (generate-combinations n l-o-v)                 ;; [Claude.ai wrote this function]
  (if (= n 1)
    (map list l-o-v)                                    ;; Base case: if n is 1, convert each value to a single-item list
    (let loop ([current-combinations (map list l-o-v)]) ;; Recursive case: generate combination
      (if (= (length (first current-combinations)) n)
        current-combinations
        (loop
          (append-map
            (lambda (current-combination)
              (map
                (lambda (value) (append current-combination (list value)))
                l-o-v))
            current-combinations))))))

(define {strings->numbers test-value-and-arguments-pair}
  (list (string->number (first test-value-and-arguments-pair))
        (map string->number
             (string-split (second test-value-and-arguments-pair) " "))))
(define {process-input}
  (map strings->numbers
       (for/list [[line-in (in-lines)]]
         (string-split line-in ":"))))

(define {checks-out? input-line operations}
  (let [[intended-result (first input-line)]
        [arguments (second input-line)] ]
    (for/or [[op-sequence (generate-combinations (- (length arguments) 1)
                                                 operations)]]
      (equal? intended-result
              (for/fold ([result (first arguments)])
                        ([a-value (rest arguments)]
                         [op op-sequence]
                         #:break (> result intended-result) ; NOTE This only saves ~0.1 sec on full input... and extracting a named function _adds_ 2.0 sec 😱
                         )
                (op result a-value))))))

(define {solve-it operations}
  (for/sum [[input-line (process-input)]
            #:when (checks-out? input-line operations)]
    (first input-line)))

(define {solve-part1}
  (solve-it (list + *)))

(define BASE 10)
(define {num-digits n [accumulator 0]}
  ; (+ 1 (exact-round (floor (log n 10)))) ; NOTE this is correct and seems elegant, but 2 seconds slower with full input
  (cond
    [(= n 0)
     accumulator]
    [(< n BASE)
     (+ accumulator 1)]
    [else
     (num-digits (quotient n BASE) (+ accumulator 1))]))

(define {|| a b}
  (+ b (* a (expt 10 (num-digits b)))))

(define {solve-part2}
  (solve-it (list + * ||)))

(check-equal? (|| 12 3456) 123456)
(check-equal? (|| 123 456) 123456)
(check-equal? (|| 12345 6) 123456)

(printf "part 1\n")
(check-equal? (with-input-from-file "sample.txt" solve-part1) 3749)
(printf "sample done...\n")
(check-equal? (with-input-from-file "input.txt"  solve-part1) 42283209483350)

(printf "part 2\n")
(check-equal? (with-input-from-file "sample.txt" solve-part2) 11387)
(printf "sample done...\n")
(check-equal? (with-input-from-file "input.txt"  solve-part2) 1026766857276279)
