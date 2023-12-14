#lang racket

(provide solve-part1
         check-springcode?*
         generate-possibilities
         string-to-chars)

(require "input.rkt")

(printf "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n")

(define (check-springcode? springspec-string checks-string)
  (define split-up (string-split springspec-string "." #:repeat? #t))
  (define checks (map string->number (string-split checks-string ",")))
  (equal? checks (map string-length split-up)))

(define (check-springcode?* springspec-string checks-list)
  (define split-up (string-split springspec-string "." #:repeat? #t))
  (equal? checks-list (map string-length split-up)))

(define (string-to-chars s)
  (reverse (list-tail (reverse (list-tail (string-split s "") 1)) 1)))

(define (generate-possibilities_ cypher possibilities)
  ; TODO generate a TREE rather than a big list... then we can prune to reduce search space
  (if (empty? cypher)
    possibilities ; TODO use of append means we don't have to reverse here right?
    (let [[top-letter (car cypher)]
          ]
      (generate-possibilities_ (cdr cypher) ; TODO prune as we generate..??
                               (if (equal? "?" top-letter)
                                 (flatten (map (λ (possibility) (list
                                                                   (string-append possibility ".")
                                                                   (string-append possibility "#")))
                                               possibilities))
                                 (map (λ (possibility) (string-append possibility top-letter))
                                      possibilities)))
      )))
(define (generate-possibilities list-of-strings)
  (generate-possibilities_ list-of-strings '("")))

(define (possibilities-per-line line-tuple)
  (define cypher (string-to-chars (car line-tuple)))
  (define counts (map string->number (string-split (car (cdr line-tuple)) ",")))
  (define possibilities-for-line (generate-possibilities cypher))
  (filter (λ (possibility) (check-springcode?* possibility counts))
          possibilities-for-line)
  )

(define (solve-part1 split-input)
  (apply +
         (map (λ (input-line) (length (possibilities-per-line (string-split input-line))))
              split-input))
  )
