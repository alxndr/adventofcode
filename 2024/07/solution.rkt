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
    (for/or [[op-sequence (generate-combinations ((length arguments) . - . 1) operations)]]
      (equal? intended-result
              (for/fold ([a (first arguments)])
                ([b (rest arguments)]
                 [op op-sequence])
                (op a b))))))

(define {solve-it operations}
  (for/sum [[input-line (process-input)]
            #:when (checks-out? input-line operations)]
    (first input-line)))

(define {solve-part1}
  (solve-it (list + *)))

(define {|| a b} ; TODO optimize this?? using math ops rather than string stuff saves 20% of the time...
  (string->number (string-append (number->string a) (number->string b))))

(define {solve-part2}
  (solve-it (list + * ||)))


(printf "part 1\n")
(check-equal? (with-input-from-file "sample.txt" solve-part1) 3749)
(printf "sample works!\n")
(check-equal? (with-input-from-file "input.txt"  solve-part1) 42283209483350)

(printf "part 2\n")
(check-equal? (with-input-from-file "sample.txt" solve-part2) 11387)
(printf "sample works!\n")
(check-equal? (with-input-from-file "input.txt"  solve-part2) 1026766857276279)
