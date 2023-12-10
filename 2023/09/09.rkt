#lang racket

(require "input.rkt")

(provide ;steps-til-zero-deriv
         find-the-gaps
         predict-next-val
         sum-of-predictions)

(define (find-the-gaps-r vals prev-val gaps)
  ; gaps will be built backwards from the order of vals, and reversed before being returned
  ;; (printf "find-the-gaps-r ~a ~a ~a\n" vals prev-val gaps)
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

(define (steps-til-zero-deriv-R vals num-derivs max-derivs)
  (if (empty? vals)
    'error-unexpected
    (if (or (>= num-derivs max-derivs)
            (apply (curry = 0) vals)) ; note that it must be _all_zeroes_ not just non-changing...
      num-derivs
      (steps-til-zero-deriv-R (find-the-gaps vals)
                              (+ 1 num-derivs)
                              max-derivs))))
(define (steps-til-zero-deriv xs)
  ; how many "deriv" steps until the gaps are all zero?
  ; ... this might be a red herring for the answer??
  (steps-til-zero-deriv-R xs 0 99)) ; TODO can we do optional keyword args??

(define (predict-next-val-R vals) ; vals is backwards from input
  (printf "predicting... ~a \n" vals)
  (let* [[the-gaps (find-the-gaps vals)]]
    (printf "    . . . gaps ~a  \n" the-gaps)
    (if (apply (curry = 0) the-gaps)
      (car vals) ; simplest base case
      (let [[predicted-next-gap (predict-next-val-R the-gaps)]]
        ;; (printf "\t\tnext gap= ~a ... + ~a = ~a\n" predicted-next-gap
        ;;         (car vals)
        ;;         (+ (* -1 predicted-next-gap) (car vals))
        ;;         )
        (+ (* -1 predicted-next-gap) ; TODO not sure why * -1
           (car vals))))))
(define (predict-next-val xs)
  ; make a slightly-informed guess about what the next value could be...
  (predict-next-val-R (reverse xs)))

(define (sum-of-predictions input)
  (printf "input..... ~s \n" (string-split input))
  (apply +
       (map (λ (string) (predict-next-val (map string->number (string-split string))))
            (string-split input "\n"))
       )
  )
