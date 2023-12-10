#lang racket

(provide split-input
         process-input-lists
         ;find-start
         find-index
         findXY)

(require "input.rkt")
(define sample (sample-input))

(define (split-input input)
  (map (λ (line)
         (let* [[trimmed (string-trim line)]
                [split-up (string-split trimmed "")]
                ]
           (cdr (reverse (cdr (reverse split-up))))))
       (string-split input "\n")))

(define (input-char-to-atom character)
  (match character
    ["-" '-]
    ["|" '!]
    ["7" '7]
    ["F" 'F]
    ["J" 'J]
    ["L" 'L]
    ["S" 'S]
    [ _  'X]))

(define (process-input-lists_ output-lists input-lists)
  (if (empty? input-lists)
    (reverse output-lists)
    (process-input-lists_
      (cons (input-char-to-atom (car input-lists)) output-lists)
      (cdr input-lists))))
(define (process-input-lists input-lists)
  ; expects input to be split using split-input above...
  (map (curry process-input-lists_ '())
       input-lists))

(define (atom-to-pretty-char a)
  (match a
    ['- "―"]
    ['! "⏐"]
    ['7 "┐"]
    ['F "┌"]
    ['J "┘"]
    ['L "└"]
    ['S "╳"]
    ['X " "]))

(define (format-pipemap_ pipemap-line pipemap-rest)
  (string-append
    ">>> "
    (string-join (map atom-to-pretty-char pipemap-line) "")
    "\n"
    (if (empty? pipemap-rest)
      ""
      (format-pipemap_ (car pipemap-rest)
                       (cdr pipemap-rest)))))
(define (format-pipemap pipemap)
  (format-pipemap_ (car pipemap)
                   (cdr pipemap)))

(define (findXY_ x y list-of-lists-of-atoms)
  ;; (printf "_______ x:~a y:~a _______\n~a\n\n"
  ;;         x
  ;;         y
  ;;         (format-pipemap list-of-lists-of-atoms))
  (if (= 0 y)
    (list-ref (car list-of-lists-of-atoms) x)
    (findXY_ x (y . - . 1) (cdr list-of-lists-of-atoms))))
(define (findXY x y list-of-lists-of-atoms)
  (cond
    [(empty? list-of-lists-of-atoms)              'error-malformed]
    [(empty? (car list-of-lists-of-atoms))        'error-empty]
    [(>= y (length list-of-lists-of-atoms))       'error-not-tall-enough]
    [(>= x (length (car list-of-lists-of-atoms))) 'error-not-wide-enough]
    [else
      ; no prep needed to start recursion...
      (findXY_ x y list-of-lists-of-atoms)]
    )
  )

(define (find-index needle haystack)
  (if (empty? haystack)
    #f
    (if (equal? needle (car haystack))
      0
      (+ 1 (find-index needle (cdr haystack))))))

(define start-char "S")
(define (find-start_ pipemap y)
  (let* [[top-line (car pipemap)]
        [x (find-index start-char top-line)]]
  (if (equal? x #f)
    (find-start_ (cdr pipemap) (+ 1 y))
    `(,x ,y)
    )))
(define (find-start pipemap)
  ; return '(x y) for the position of 'S in pipemap: top left is (0 0)
  (find-start_ pipemap 0))




; find the S... cursor is (xS yS)
; ... examine all neighbors... look for Pipe Atoms 'F '7 'J 'L '- '!
; ... ... ? if there are no new neighbors, we're at the end!!
; ... ... : create nodes for the (New!) Neighbors
; ... ... : link the new Neighbor Nodes to this Node...
; ... ... : now the new nodes are cursors, and this cursor is dunzo

(let [[pipemap (process-input-lists (split-input sample))]]
  (printf ">>> detritus \n~a \n\n" (format-pipemap (process-input-lists (split-input (square-with-detritus)))))
  ;; (printf ">>> sample <<<\n~a\n\n" (format-pipemap pipemap))
  ;; (printf "\t>\t>\t>\tFULL\t<\t<\t<\n~a" (format-pipemap (process-input-lists (split-input (full-input)))))
  )

(printf "\n")
