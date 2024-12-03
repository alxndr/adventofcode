#lang racket

(provide (all-defined-out))

(define (sample-input) (file->lines "sample.txt"))
(define (full-input)   (file->lines "input.txt"))

(define (remove-nth-element sequence n)
  (for/list ([index (length sequence)]
             #:when (not (eq? n index)))
    (list-ref sequence index)))
