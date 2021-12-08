#lang racket

(define Fish
  (lambda (timer)
    (quasiquote (F (unquote timer)))))

(define create-fish
  (lambda (numbers fishes)
    (if (null? numbers)
      fishes
      (create-fish (cdr numbers) (cons (Fish (car numbers)) fishes)))
    ))

(let* ([line (read-line (current-input-port))] ; only need to look at the first line of input
       [fishes (reverse (create-fish (string-split line ",") '()))]
       )
  (printf "fishes... ~a~n" fishes)
  )
