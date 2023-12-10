#lang racket

(require "input.rkt")

(provide find-the-gaps
         predict-next-val
         sum-of-predictions
         predict-previous-val)

(define (find-the-gaps-r vals prev-val gaps)
  ; gaps will be built backwards from the order of vals, and reversed before being returned
  (cond
    [(equal? 'NULL gaps)  ; first case, start of recursion
     (find-the-gaps-r
       (cdr vals)
       (car vals)
       '()) ]
    [(empty? vals)        ; last case, end of recursion
     (reverse gaps)]
    [else                 ; normal recursion
      (let* {
        [head (car vals)]
        [tail (cdr vals)]
        [diff (- head prev-val)]}
        (find-the-gaps-r tail
                         head
                         (cons diff
                               gaps)))
      ]))
(define (find-the-gaps xs)
  ; return a list containing the numeric gaps between the values in `xs`
  (find-the-gaps-r xs 'NULL 'NULL))

(define (predict-next-val-R vals) ; vals is backwards from input
  (let* [[the-gaps (find-the-gaps vals)]]
    (if (apply (curry = 0) the-gaps)
      (car vals) ; simplest base case
      (let [[predicted-next-gap (predict-next-val-R the-gaps)]]
        (+ (* -1 predicted-next-gap) ; TODO not sure why * -1
           (car vals))))))
(define (predict-next-val xs)
  ; make a slightly-informed guess about what the next value could be...
  (predict-next-val-R (reverse xs)))

(define (sum-of-predictions input which-predictor)
  (apply +
       (map (λ (string) (which-predictor (map string->number (string-split string))))
            (string-split input "\n"))
       )
  )

(define (predict-previous-val xs)
  ; part 2: extrapolate backwards
  (predict-next-val-R xs))
