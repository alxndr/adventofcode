#lang racket

(require memo threading rackunit)

(define {process-input input}
  (map
    string->number
    (string-split input " ")))

(define/memoize {num-digits int}
  (+ 1 (inexact->exact (floor (/ (log int) (log 10))))))

(define/memoize {blink stone}
  (cond
    [(equal? 0 stone)
     '(1)]
    [(even? (num-digits stone))
     (let [[stone-str (number->string stone)]
           [half-length (/ (num-digits stone) 2)]]
       (list (string->number (substring stone-str 0 half-length))
             (string->number (substring stone-str half-length))))
     ]
    [else
      (list (* stone 2024))]))

(define {blink-at-stones starting-stones blinks #:print-blinks? [print-blinks? #false]}
  (for/fold [[stones starting-stones]]
            [[n blinks]]
    (when print-blinks?
      (printf "#~a (~a) ... \n" n (length stones)))
    (flatten (map blink stones))))

(define {solve-part1 input [blinks 25]}
  (length (blink-at-stones (process-input input) blinks)))

(define {add-counts-onto-stones stones n}
  (map (lambda (v) (list v n)) stones))

(define (unwrap l [unwrapped '()]) ; messes with ordering but we don't care about that rn
  (if (empty? l)
    unwrapped
    (unwrap (cdr l) (append (car l) unwrapped))))

(define {blink-at-stones-hash starting-stones blinks #:print-blinks? [print-blinks? #false]}
  (when print-blinks? (printf "blinking at ~a this many times: ~a \n" starting-stones blinks))
  (for/fold [[h (apply hash (unwrap (add-counts-onto-stones starting-stones 1)))]]
            [[n blinks]]
    (when print-blinks? (printf "#~a/~a (~a keys) ... \n" n blinks (length (hash-keys h))))
    (let [[list-of-stone-and-count-pairs
      (unwrap (hash-map h
                 (λ (stone num-stones)
                   (let [[new-stones (blink stone)]]
                     (when print-blinks?
                       (printf " ... blink at ~a => ~a \n" stone new-stones))
                     (add-counts-onto-stones new-stones num-stones)))))]]
      (for/fold [[new-h (hash)]]
                [[next-pair list-of-stone-and-count-pairs]]
        (hash-update new-h
                     (car next-pair)
                     (curry + (cadr next-pair))
                     0)))))

(define {solve-part2 input [blinks 75] #:print-blinks? [print-blinks? #false]}
  (~>
    (process-input input)
    (blink-at-stones-hash blinks #:print-blinks? print-blinks?)
    hash-values
    (apply + _)))

(printf "part 1...\n")
(check-equal? (blink-at-stones (process-input (car (file->lines "sample.txt"))) 1)
              '(253000 1 7))
(check-equal? (blink-at-stones (process-input (car (file->lines "sample.txt"))) 3)
              '(512072 1 20 24 28676032))
(check-equal? (blink-at-stones (process-input (car (file->lines "sample.txt"))) 5)
              '(1036288 7 2 20 24 4048 1 4048 8096 28 67 60 32))
(check-equal? (blink-at-stones (process-input (car (file->lines "sample.txt"))) 6)
              '(2097446912 14168 4048 2 0 2 4 40 48 2024 40 48 80 96 2 8 6 7 6 0 3 2))
(check-equal? (solve-part1 "0 1 10 99 999" 1)
              7)
(check-equal? (solve-part1 (car (file->lines "sample.txt")))
              55312)
(check-equal? (solve-part1 (car (file->lines "input.txt")))
              218079)

(printf "part 2...\n")
(check-equal? (blink-at-stones-hash (process-input (car (file->lines "sample.txt"))) 1)
              (hash 1 1 7 1 253000 1))
(check-equal? (blink-at-stones-hash (process-input (car (file->lines "sample.txt"))) 2)
              (hash 0 1 253 1 2024 1 14168 1))
(check-equal? (blink-at-stones-hash (process-input (car (file->lines "sample.txt"))) 3)
              (hash 512072 1 1 1 20 1 24 1 28676032 1))
(check-equal? (blink-at-stones-hash (process-input (car (file->lines "sample.txt"))) 4)
              (hash 512  1
                    72   1
                    2024 1
                    2    2 ; note that there are two of stone "2" here
                    0    1
                    4    1
                    2867 1
                    6032 1))
(check-equal? (blink-at-stones-hash (process-input (car (file->lines "sample.txt"))) 6)
              (hash 2097446912 1
                    14168      1
                    4048       1
                    2024       1
                    96         1
                    80         1
                    48         2
                    40         2
                    8          1
                    7          1
                    6          2
                    4          1
                    3          1
                    2          4
                    0          2
                    ))
(check-equal? (solve-part2 (car (file->lines "input.txt")) 25)
              218079)
(check-equal? (solve-part2 (car (file->lines "input.txt")) 75)
              259755538429618)
