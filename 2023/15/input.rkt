#lang racket

(provide sample-input
         full-input)

(define (extract-and-split filename)
  (string-split
    (car (file->lines filename))
    ","))

(define (sample-input)
  (extract-and-split "sample.txt"))

(define (full-input)
  (extract-and-split "input.txt"))
