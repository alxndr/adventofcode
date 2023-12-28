#lang racket

(provide
  get-XY
  get-neighboring-moves
  get-next-moves
  strip-off-dirs
  solve-part1
  solve-part2)
(require "input.rkt")

(define (get-XY x y matrix)
  ; (0 0) is top right
  ; x increases to right
  ; y increases to below
  ; no negatives
  (cond
    [(equal? '(0 0) (list x y))
     (caar matrix)]
    [(equal? 0 y)
     (get-XY (x . - . 1) 0 (list (cdar matrix)))]
    [else
      (get-XY x (y . - . 1) (cdr matrix))]
    )
  )

(define (get-neighboring-moves x y matrix)
  (define above (y . - . 1))
  (define below (y . + . 1))
  (define left  (x . - . 1))
  (define right (x . + . 1))
  (define width (length (car matrix)))
  (define height (length matrix))
  (filter
    (λ (xy)
      (define x (car  xy))
      (define y (cadr xy))
      (cond
        [(x . <  . 0)      #f]
        [(y . <  . 0)      #f]
        [(x . >= . width)  #f]
        [(y . >= . height) #f]
        [else #t]
        ))
    (list
      (list x above #\^)
      (list x below #\v)
      (list left  y #\<)
      (list right y #\>))))

(define (get-next-moves route matrix)
  (define last-XY (car route)) ; note order of moves in `route`, head is most recent move
  #; (printf "looking for moves from route: ~a \n" route)
  (define possibilities (get-neighboring-moves (car last-XY) (cadr last-XY) matrix))
  (define (is-valid-move move-XYD)
    (define move-X   (car move-XYD))
    (define move-Y  (cadr move-XYD))
    (define move-D (caddr move-XYD))
    (define tile-at-move (get-XY move-X move-Y matrix))
    (cond
      [(equal? tile-at-move #\#) ; filter out steps we can't take
        #;(printf "it's a wall\n")
        #f]
      [(member (list move-X move-Y) route) ; filter out moves we've already made
        #;(printf "already came from there\n")
        #f]
      [(and (not (equal? tile-at-move #\.))
            (not (equal? tile-at-move move-D))) ; filter out "steep slopes" uphill (only allow 'downhill' i.e. matching tiles)
        #;(printf "whoa slopes wrong: ~a but ~a \n" move-D tile-at-move)
        #f]
      [else ; haven't been there and: either it's a . or the slopes match
        #t]))
  (filter is-valid-move
          possibilities))

(define (print-route route matrix)
  (for ([line matrix]
        [y (build-list (length matrix) values)])
    (for ([char line]
          [x (build-list (length line) values)])
      (display (if (member (list x y) route)
                 "O"
                 (get-XY x y matrix))))
    (display "\n"))
  (display "\n"))

(define (build-routes_ route
                       moves ; puts each of moves onto route and stores in resulting-routes
                       resulting-routes)
  (if (empty? moves)
    resulting-routes
    (let* [[   a-move (car moves)]
           [new-route (cons a-move route)]]
      (build-routes_ route
                     (cdr moves)
                     (cons new-route resulting-routes)))))

(define (strip-off-dirs list-of-XYD)
  (map (λ (xyd)
         (list (car xyd) (cadr xyd)))
       list-of-XYD))

(define (find-longest-route_ matrix
                             routes ; routes is list, containing Route lists. each Route list is a list, containing XY Pairs
                             ending-row
                             longest-trip)
  (if (empty? routes)
    longest-trip
    (let [[top-route (car routes)]]
      #; (print-route top-route matrix)
      (define remaining-routes (cdr routes))
      (if (eq? ending-row (cadr (car top-route)))

        (find-longest-route_ matrix
                             remaining-routes
                             ending-row
                             (max longest-trip (- (length top-route) 1)))

        (let [[next-moves (get-next-moves top-route matrix)]]
          #; (printf "next moves... ~a\n" next-moves) ; this should not include retraced steps...
          (define next-routes (build-routes_ top-route next-moves '()))
          #; (printf "top route x those move(s):\n~a\n\n" (map strip-off-dirs next-routes))
          #; (printf "now routes is... \n~a\n" (append (map strip-off-dirs next-routes) remaining-routes))
          #; (read)
          (find-longest-route_ matrix
                               (append (map strip-off-dirs next-routes) remaining-routes)
                               ending-row
                               longest-trip)
          )))
    )
  )

(define (solve-part1 input)
  (define startingXY '(1 0))
  (define ending-row (- (length input) 1))
  (find-longest-route_
    input
    (list (list startingXY))
    ending-row
    0)
 )

(define (solve-part2 input)
  'TODO-part2)
