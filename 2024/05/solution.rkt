#lang racket

; h/t @jairtrejo

(require threading rackunit)

(define [read-rules]
  (for/list [[line-in (in-lines)]
             #:break (equal? line-in "")] ; TODO why does `eq?` not work here?
    (~> line-in
        (string-split "|")
        (map string->number _))))

(define [read-updates]
  (for/list [[line-in (in-lines)]]
    (~> line-in
        (string-split ",")
        (map string->number _))))

(define [should-come-before? rules a b]
  (for/or [[rule rules]]
    (and (eq? a (first rule))
         (eq? b (second rule)))))

(define [already-sorted? lst rules]
  (let [[sorted (sort lst (curry should-come-before? rules))]]
    (equal? sorted lst)))

(define [extract-middle lst]
  (list-ref lst
            (floor ((length lst) . / . 2))))

(define [solve-part1]
  (let [[the-rules (read-rules)] ; NOTE this must be done before `read-updates`
        [the-updates (read-updates)]]
    (for/sum [[update the-updates]
              #:when (already-sorted? update the-rules)]
      (extract-middle update))))

(define [solve-part2]
  (let [[the-rules (read-rules)]
        [the-updates (read-updates)]]
    (for/sum [[update the-updates]
              #:unless (already-sorted? update the-rules)]
      (~> update
          (sort _ (curry should-come-before? the-rules)) ; TODO come up with a way to avoid sorting twice
          extract-middle))))

(check-equal? (extract-middle '(1 2 3 4 5))         3)
(check-equal? (extract-middle '(1 2 3 4 5 6 7 8 9)) 5)

(check-equal? (with-input-from-file "sample.txt" solve-part1) 143)
(check-equal? (with-input-from-file "input.txt" solve-part1) 6034)

(check-equal? (with-input-from-file "sample.txt" solve-part2) 123)
(check-equal? (with-input-from-file "input.txt" solve-part2) 6305)
