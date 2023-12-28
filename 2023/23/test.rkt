#lang racket

(require "solution.rkt"
         "input.rkt"
         rackunit
         rackunit/text-ui)

(printf "\n\n\nrunning tests...\n\n")

(define-simple-check (check-in-list needle haystack)
                     (member needle haystack))

(run-tests

  (test-suite "2023 day 23"

    (test-suite "sample-input"
      (test-case "first few chars of first line"
        (check-equal?   (caar (sample-input)) #\#)
        (check-equal?  (cadar (sample-input)) #\.)
        (check-equal? (caddar (sample-input)) #\#))
      (test-case "first few chars of second line"
        (check-equal?       (caadr (sample-input))  #\#)
        (check-equal?      (cadadr (sample-input))  #\.)
        (check-equal? (cadr (cdadr (sample-input))) #\.)))

    (test-suite "get-XY"
      (test-case "basic"
        (define basic-map '((7 6 5) (1 2 3)))
        (check-equal? (get-XY 0 0 basic-map) 7)
        (check-equal? (get-XY 1 0 basic-map) 6)
        (check-equal? (get-XY 0 1 basic-map) 1)
        (check-equal? (get-XY 2 1 basic-map) 3)))

    (test-suite
      "get-neighboring-moves"

      (test-case
        "basic"
        (define basic-map '(( a  b  c)
                            (() () ())
                            (I II III)))
        (define neighbors (get-neighboring-moves 1 1 basic-map))
        (check-in-list '(1 0 #\^) neighbors)
        (check-in-list '(1 2 #\v) neighbors)
        (check-in-list '(0 1 #\<) neighbors)
        (check-in-list '(2 1 #\>) neighbors))
      (test-case
        "edge"
        (define basic-map '( (a b c) (d e f)))
        (define neighbors (get-neighboring-moves 1 1 basic-map))
        (check-in-list '(1 0 #\^) neighbors)
        (check-false (member '(1 2 #\v) neighbors))
        (check-in-list '(0 1 #\<) neighbors)
        (check-in-list '(2 1 #\>) neighbors)))


    (test-suite
      "get-next-moves"
      (test-case
        "basic"
        (define the-map '( (#\# #\# #\#)
                           (#\. #\. #\#)
                           (#\# #\. #\#)))
        (define result (get-next-moves '((1 1)) the-map))
        (check-in-list '(1 2 #\v) result)
        (check-in-list '(0 1 #\<) result))

      (test-case
        "with route"
        (define the-map '( (#\# #\# #\#)
                           (#\. #\. #\#)
                           (#\# #\. #\#)))
        (define result (get-next-moves '((1 1) (1 2)) the-map))
        (check-equal? '((0 1 #\<)) result)))


    (test-suite
      "strip-off-dirs"
      (test-case
        "basic"
        (check-equal?
          (strip-off-dirs '((1 2 x) (9 8 y)))
          '((1 2) (9 8)))))


    (test-suite "solve-part1"
      (test-case "sample-input"
        (check-equal?
          (solve-part1 (sample-input))
          94))
      (test-case "full-input"
        (check-equal?
          (solve-part1 (full-input))
          2334))
      )

    )

  )
