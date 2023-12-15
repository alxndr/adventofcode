#lang racket

(provide solve-part1
         solve-part2
         run-algorithm
         )

(require "input.rkt")

(define (churn-on-value baseVal n)
  (let* [[increased (+ baseVal n)]
         [multiplied (* increased 17)]
         [moduloed (modulo multiplied 256)]]
    ;; (printf "churning ~v & ~v into... ~v\n" baseVal n moduloed)
    moduloed))
(define (run-algorithm_ loc val)
  ;; To run the HASH algorithm on a string, start with a current value of 0.
  ;; Then, for each character in the string starting from the beginning:
  ;; • Determine the ASCII code for the current character of the string.
  ;; • Increase the current value by the ASCII code you just determined.
  ;; • Set the current value to itself multiplied by 17.
  ;; • Set the current value to the remainder of dividing itself by 256.
  (if (empty? loc)
    val
    (run-algorithm_ (cdr loc)
                    (churn-on-value val (char->integer (car loc))))))
(define (run-algorithm input-string)
  (run-algorithm_ (string->list input-string)
                  0))

(define (solve-part1 input)
  (apply + (map run-algorithm input)))

(define (solve-part2 input)
  #f)
