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

(define nth ; no error-checking
  (lambda (n list)
    (if (eq? 0 n)
      (car list)
      (nth (- n 1) (cdr list)))))

(define calculate-fish-family-size-recursive
  (lambda (fishes day-count sum)
    (if (null? fishes)
      sum
      (let ([remaining-fish (cdr fishes)]
            [family-size-first-fish (length (days-go-by day-count (cons (car fishes) '())))])
        (calculate-fish-family-size-recursive remaining-fish
                                              day-count
                                              (+ sum family-size-first-fish)))
      )))

(define dnc ; "divide and conquer": calculate family size of each fish in `fishes` over `day-count`, then add
  (lambda (fishes day-count)
    (calculate-fish-family-size-recursive fishes day-count 0)))

(define mcq ; montecarlo...esq... using iterative implementation
  (lambda (days init-val)
    (let* ([family (days-go-by days (cons (Fish init-val) '()))]
           [famsize (length family)]
           )
      (printf "start: ~a   days: ~a   famsize: ~a~n" init-val days famsize))))

(define period 7)
(define new-fish-period 9)
; for timer > 0, it is the (day - timer)th value of the timer = 0 value
; for timer 0...
  ; days / period = this is how many have been spawned by patient 0
  ; days / new-fish-period = how many spawned at 8..?


; could pre-calculate the sequence for 0 for the day count
; then look up the results for each of the input timer values

(define generation-size-memo
  (lambda (days memo)
    ))
(define generation-size ; for a fish with timer = 0
  (lambda (days) ; after this many days
    (generation-size-memo days memo)))


(define math-it
  (lambda (n limit); days fishes)
    (if (> n limit)
      'wip
      (begin
        (mcq 0 (- limit n))
        (math-it (+ n 1) limit)
        )
      )
    (printf "~n")
    'wip))

(let* (
       [line (read-line (current-input-port))] ; only need to look at the first line of input
       [fishes (reverse (create-fish (string-split line ",") '()))]
       [days 150]
      )
  (printf "days: ~a~n~n" days)
  ; can't figure out how to use `time-apply`
  (printf "math...~n"); (printf "~a~n~n" (time (math-it days fishes)))
  ; (math-it 31)
  ; (math-it 32)
  ; (math-it 33)
  ; (math-it 34)
  ; (math-it 35)
  ; (math-it 36)
  ; (math-it 37)
  ; (math-it 38)
  ; (math-it 39)
  ; (math-it 40)
  ; (math-it 41)
  ; (math-it 42)
  ; (math-it 43)
  ; (math-it 44)
  ; (math-it 45)
  ; (math-it 46)
  ; (math-it 47)
  ; (math-it 48)
  ; (math-it 49)
  ; (math-it 50)
  ; TODO third implementation... there's some math here
  ;       there should be a relationship between starting # and family-size after N days...
  ;       (eg, each starting # is a predictable number of days away from growing by one)
  ; (printf "piecewise...~n") (printf "~a~n~n" (time (dnc fishes days)))
  ; (printf "iterative...~n") (printf "~a~n~n" (length (time (days-go-by days fishes))))
)
