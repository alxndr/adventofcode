#lang racket

(provide split-input
         process-input-lists
         ;find-start
         find-index
         findXY-within
         adjacent-dims-with-labels)

(require "input.rkt")
; assumptions about input:
; ...it's always square
; ...only care about the 8 characters mentioned
; ...only one starting "S" char

(define (split-and-trim input)
  (let* [[split-up (string-split (string-trim input) "")]
         [end-trimmed (reverse (cdr (reverse split-up)))]
         ]
    (cdr end-trimmed)))
(define (split-input input)
  (map split-and-trim (string-split input "\n")))

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
  (if (= 0 y)
    (list-ref (car list-of-lists-of-atoms) x)
    (findXY_ x (y . - . 1) (cdr list-of-lists-of-atoms))))
(define (findXY-within x y list-of-lists-of-atoms)
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
  ;; (printf "find-index... ~a w/in: ~a \n" needle haystack)
  (cond
    [(empty? haystack)
     #f]
    [(equal? needle (car haystack))
     0]
    [else
      (let [[maybe-index (find-index needle (cdr haystack))]]
        (if (equal? #f maybe-index)
          maybe-index
          (+ 1 maybe-index)))])
  )

(define start-char "S")
(define (find-start_ pipemap y)
  ;; (printf "find-start_ y:~a ... \n~a \n" y (car pipemap))
  (let* [[top-line (car pipemap)]
         [x (find-index 'S top-line)]]
    (if (equal? x #f)
      (find-start_ (cdr pipemap) (+ 1 y))
      `(,x ,y)
      )))
(define (find-start pipemap)
  ; return '(x y) for the position of 'S in pipemap: top left is (0 0)
  (find-start_ pipemap 0))

(define (is-within-dims x y width height)
  (and (>= x 0)
       (>= y 0)
       (<= x (width . - . 1))
       (<= y (height . - . 1))))
(define (adjacent-dims-with-labels x y pipemap)
  (let [[width (length (car pipemap))]
        [height (length pipemap)]]
    (filter
      (λ (xy) (is-within-dims (car xy) (car (cdr xy)) width height))
      `(
        (,x       ,(- y 1) above)
        (,(- x 1) ,y       left)
        (,(+ x 1) ,y       right)
        (,x       ,(+ y 1) below)
        )
      ))
  )

(define (is-shape-connected-in-dir shape dir)
  (match shape
    ['S #t] ; all directions valid from the starting point bc the "true shape" is unknown...
    ['J (or (equal? 'left dir)  (equal? 'above dir))] ; TODO double check that this doesn't need to be flipped...
    ['L (or (equal? 'right dir) (equal? 'above dir))]
    ['F (or (equal? 'right dir) (equal? 'below dir))]
    ['7 (or (equal? 'left dir)  (equal? 'below dir))]
    ['- (or (equal? 'left dir)  (equal? 'right dir))]
    ['! (or (equal? 'above dir) (equal? 'below dir))]
    [ _ #f]))
(define (opposite-dir-from dir)
  (match dir
    ['above 'below]
    ['left  'right]
    ['right 'left ]
    ['below 'above]))
(define (find-connectable-pipes x y pipemap)
  (let* [[neighbor-dims-with-labels (adjacent-dims-with-labels x y pipemap)]
         [this-shape (findXY-within x y pipemap)]
         [valid-connection-directions (filter (λ (dir) (is-shape-connected-in-dir this-shape dir))
                                              '(above left right below))]
         ]
    ;; (printf "find-connectable-pipes: ~a @ (~a ~a)\n" this-shape x y)
    ;; (printf "~a\n" (format-pipemap pipemap))
    ;; (printf "potential neighbors... ~a\n" neighbor-dims-with-labels)
    ;; (printf "but, valid directions: ~a\n" valid-connection-directions)
    (filter (λ (ndwl) ; does the neighbor pipe connect to this pipe??
              (let [[neighbor-dims (list (car ndwl) (car (cdr ndwl)))]
                    [neighbor-can-connect-from (car (cdr (cdr ndwl)))]
                    [shape-of-neighbor (findXY-within (car ndwl) (car (cdr ndwl)) pipemap)]
                    ]
                ;; (printf "does neighbor ~a connect to ~s @ ~a\n" neighbor-can-connect-from shape-of-neighbor neighbor-dims)
                ;; (printf "... ~a\n" (member neighbor-can-connect-from valid-connection-directions))
                ;; (printf ",,, ~a\n" (is-shape-connected-in-dir shape-of-neighbor (opposite-dir-from neighbor-can-connect-from)))
                (and
                  (member neighbor-can-connect-from valid-connection-directions) ; valid direction
                  (is-shape-connected-in-dir shape-of-neighbor
                                             (opposite-dir-from neighbor-can-connect-from))
                  )
                ))
            neighbor-dims-with-labels)
    ))

(define (traverse-pipes pipemap current-positions)
  (printf "\ncrawling around... ~a\n" current-positions)
; ... examine all neighbors... look for Pipe Atoms 'F '7 'J 'L '- '!
; ... ... ? if there are no new neighbors, we're at the end!!
; ... ... : create nodes for the (New!) Neighbors
; ... ... : link the new Neighbor Nodes to this Node...
; ... ... : now the new nodes are cursors, and this cursor is dunzo
  (let [[next-positions (find-connectable-pipes (car xy)
                                                (car (cdr xy))
                                                pipemap)]]
    (printf "... ~s connectable neighbors\n" (length next-positions))
    ; gotta tag & filter out what we've been to already...
    )
  )

(let* [[input (square-with-detritus)]
       [pipemap (process-input-lists (split-input input))]
       [start-point (find-start pipemap)]
       [start-X (car start-point)]
       [start-Y (car (cdr start-point))]
       ]
  (printf ">>>>>>> map \n~a \n\n" (format-pipemap pipemap))
  (printf ">>>>>>> start point \n>>> ~a\n\n" start-point)
  ;; (printf "neighbors... \n")
  ;; (pretty-print (adjacent-dims-with-labels 1 1 pipemap))
  ;; (find-connectable-pipes start-X start-Y pipemap)
  (traverse-pipes pipemap (list start-X start-Y))

  ;; (printf ">>> sample <<<\n~a\n\n" (format-pipemap pipemap))
  ;; (printf "\t>\t>\t>\tFULL\t<\t<\t<\n~a" (format-pipemap (process-input-lists (split-input (full-input)))))
  )

(printf "\n")
