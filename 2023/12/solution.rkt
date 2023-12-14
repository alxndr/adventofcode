#lang racket

(provide solve-part1
         check-springcode?
         generate-possibilities
         string-to-chars
         solve-part2
         split-up-springspec)

(require "input.rkt"
         graph)

(define (split-up-springspec springspec-string)
  (string-split springspec-string "." #:repeat? #t))
(define (check-springcode? springspec-string checks-list)
  (equal? checks-list (map string-length (split-up-springspec springspec-string))))

(define (string-to-chars s)
  (reverse (list-tail (reverse (list-tail (string-split s "") 1)) 1)))

(define (generate-possibilities_ cypher possibilities)
  (if (empty? cypher)
    possibilities
    (let [[top-letter (car cypher)]]
      (generate-possibilities_ (cdr cypher)
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
  (filter (λ (possibility) (check-springcode? possibility counts))
          possibilities-for-line)
  )

(define (solve-part1 split-input)
  (apply +
         (map (λ (input-line) (length (possibilities-per-line (string-split input-line))))
              split-input))
  )

(define (list-these-things what how-many)
  (build-list how-many (lambda (_) what)))

(define (process-cypher cypher fodder)
  (printf "\n\npossibilities-pruned ... ~a \n fodder: ~v \n" cypher fodder)
  ; wanna depth-first-ly create options from cypher and test w predicate
  (if (empty? cypher)
    (reverse fodder) ; TODO this is generating a list of possibilities ... can it just be a count we iterate...
    (let [[next-char (car cypher)]]
      ; if we have a # or .,
      ; ...stick it on to things (WHAT?) and check against predicate, keep if passes
      ; if not...
      ; ... it's shrödingers char... '("#" ".")
      (process-cypher (cdr cypher)
                            (cons (match next-char ["?" (list "#" ".")]
                                                   [  s              s])
                                  fodder)
                            ))))

(define (is-viable-spec? spec)
  (printf "predicate called here... ~v \n" potential-spec)
  ; TODO change this fn to ... _get_ springcode for potential spec, and then...
  ;   if its length is > (length big-counts), it's no good
  ;   if its nth item is > big-counts nth item...
  ;   ...but otherwise it's still valid fodder
)

(define (possibilies-per-line-part2 line-tuple)
  (define cypher-raw (string-to-chars (car line-tuple)))
  (define big-cypher (flatten (add-between (build-list 5 (lambda (_) cypher-raw)) "?")))
  (define counts-raw (map string->number (string-split (car (cdr line-tuple)) ",")))
  (define big-counts (flatten (list-these-things counts-raw 5)))
  (printf "big-cypher is ~s chars long \n" (length big-cypher))
  (define spec (process-cypher big-cypher '()))
  (printf "poss !! ") (pretty-print poss)
  (length poss)
  )

(define (solve-part2 split-input)
  (apply +
         (map (λ (input-line) (length (possibilies-per-line-part2 (string-split input-line))))
              ;; split-input
              (list (car split-input))
              ))
  )
