#lang racket

(require "input.rkt")

(provide steps-til-zero-deriv
         find-the-gaps
         predict-next-val)

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
                         (cons (- head prev-val)
                               gaps)))
      ]))
(define (find-the-gaps xs)
  ; return a list containing the numeric gaps between the values in `xs`
  (find-the-gaps-r xs 'NULL 'NULL))

(define (steps-til-zero-deriv-R vals num-derivs max-derivs)
  ;; (printf "steps-til-zero-deriv-R ~a ~a\n" vals num-derivs)
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
  (steps-til-zero-deriv-R xs 0 99)) ; TODO can we do optional keyword args??

(define (predict-next-val-R vals n)
  (printf "predict-next-val-R ~a n=~a \n" vals n)
  (printf "...??? ~a \n\n" (- (car (cdr vals)) (car vals)))
  (if (= 0 n)
    (car vals)
    (if (= 1 n)
      (+ (car vals)
         (- (car (cdr vals)) (car vals)))
      (+ 1
         (predict-next-val-R (find-the-gaps vals) (n . - . 1))))))

    ; (2) ...  9  12  15  __
    ; (1) ...   3   3   3   
    ; (0) ...     0   0   +0

(define (predict-next-val xs)
  ; make a slightly-informed guess about what the next value could be...
  (let {
    [steps (steps-til-zero-deriv xs)]
    }
    (printf "steps.. ~a \n~a\n" steps xs)
    (predict-next-val-R (reverse xs) steps)
    )
  )
