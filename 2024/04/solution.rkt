#lang racket

(require rackunit)

(define {lines->vector in-lines}
  (for/vector [[line-in (in-lines)]]
    (for/vector [[char (string-split line-in "")]]
      char)))

(define {vector-xy v x y} (vector-ref (vector-ref v y) x))

(define-struct direction   [x  y])
(define NN (make-direction  0 -1))
(define NE (make-direction  1 -1))
(define EE (make-direction  1  0))
(define SE (make-direction  1  1))
(define SS (make-direction  0  1))
(define SW (make-direction -1  1))
(define WW (make-direction -1  0))
(define NW (make-direction -1 -1))
(define DIRS (list NN NE EE SE SS SW WW NW))

(define {word-goes-in-this-direction? chars x y dir xy}
  (for/and [[letter chars]
            [index (string-length chars)]]
    (equal? (string letter)
            (xy (+ x (* index (direction-x dir)))
                (+ y (* index (direction-y dir)))))))

(define {solve-part1}
  (let [[v (lines->vector in-lines)]]
    (define xy (curry vector-xy v))
    (define {count-words-starting-from x y}
      (for/sum [[dir DIRS]]
        (with-handlers [[exn:fail:contract? (λ (x) 0)]] ; trying to look for a word that goes off the square
          (if (word-goes-in-this-direction? "XMAS" x y dir xy)
            1
            0))))
    (for*/fold ; for*/fold is the Cartesian product version of for/fold
      [[sum 0]]
      [[y (vector-length v)]
       [x (vector-length (vector-ref v y))]]
      (+ sum (count-words-starting-from x y)))))

(check-equal? (with-input-from-file "sample.txt" solve-part1) 18)
(check-equal? (with-input-from-file "input.txt"  solve-part1) 2685)

(define {solve-part2}
  'TODO)

#; (check-equal? (with-input-from-file "sample.txt" solve-part2) 9)
#; (check-equal? (with-input-from-file "input.txt"  solve-part2) 2048)
