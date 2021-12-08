#lang racket

(define Fish
  (lambda (timer)
    timer))

(define create-fish
  (lambda (numbers fishes)
    (if (null? numbers)
      fishes
      (create-fish (cdr numbers) (cons (Fish (string->number (car numbers)))
                                       fishes)))))

(define age-fish ; takes a single Fish, returns list-of-Fish with either 1 or 2 elements
  (lambda (fish)
    (if (eq? 0 fish)
      (cons (Fish 6)
            (cons (Fish 8)
                  '()))
      (cons (Fish (- fish 1))
            '()))))

(define age-fishes ; recursive
  (lambda (list-of-fish)
    (if (null? list-of-fish)
      '()
      (let* ([first-fish-with-spawn (age-fish (car list-of-fish))]
             [rest-fish (age-fishes (cdr list-of-fish))]
             )
        (if (eq? 2 (length first-fish-with-spawn))
          (let ([orig-fish (car first-fish-with-spawn)]
                [new-fish (car (cdr first-fish-with-spawn))])
            (cons orig-fish
                  (cons new-fish
                        rest-fish)))
          (cons (car first-fish-with-spawn)
                rest-fish))))))

(define days-go-by
  (lambda (num-days fishes)
    (if (eq? 0 num-days)
      fishes
      (days-go-by (- num-days 1) (age-fishes fishes)))))

(let* ([line (read-line (current-input-port))] ; only need to look at the first line of input
       [fishes (reverse (create-fish (string-split line ",") '()))])
  (printf "how many after 18 days: ~a~n" (length (days-go-by 18 fishes)))
  (printf "how many after 80 days: ~a~n" (length (days-go-by 80 fishes))))
