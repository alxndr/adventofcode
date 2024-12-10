#lang racket

(require threading rackunit)

(define {process-input}
  (define {strip-empty v} (not (equal? "" v)))
  (for/vector [[line-in (in-lines)]]
    (~> line-in
        (string-split "")
        (filter strip-empty _)
        (map string->number _)
        list->vector)))

(define {get-value-at xy mtx} ; xy is an imaginary number; real part is x; imag part is y
  (let [[x (real-part xy)]
        [y (imag-part xy)]]
    (~> mtx
        (vector-ref y)
        (vector-ref x))))

(define {within-map mtx nxy}
   (let [[x (real-part nxy)]
         [y (imag-part nxy)]]
     (and
       (<= 0 x (- (vector-length (vector-ref mtx 0)) 1))
       (<= 0 y (- (vector-length mtx) 1)))))
(define MOVES '(0-1i 1+0i 0+1i -1+0i))
(define {neighbors-xy xy mtx}
  (filter (curry within-map mtx)
          (map + MOVES (make-list (length MOVES) xy))))

(define {next-steps xy target-value mtx}
  (filter (λ (nxy) (equal? target-value (get-value-at nxy mtx)))
          (neighbors-xy xy mtx)))

(define {walk-paths xy mtx nines}
  (let [[current-value (get-value-at xy mtx)]]
    (if (equal? 9 current-value)
      (cons xy nines)
      (flatten (map (λ (nxy) (walk-paths nxy mtx nines)) ; TODO would be ideal to uniq here rather than in get-trail-score-for
                    (next-steps xy (+ 1 current-value) mtx))))))

(define {get-trail-score-for xy mtx}
  ; xy is trailhead (0-value)...
  ; trail score is: how many 9-values (not paths) can be found starting from here?
  ; 9-values are unique per starting-point but not per-path...
  ; path is: value increasing by 1 each step
  (set-count (list->set (walk-paths xy mtx (list))))) ; this is a silly way to uniq the list of results...

(define {solve-part1}
  (let [[vec-matrix (process-input)]]
    (for*/fold [[total-score 0]]
               [[y (vector-length vec-matrix)]
                [x (vector-length (vector-ref vec-matrix 0))]]
      (let [[xy (make-rectangular x y)]]
        (if (equal? 0 (get-value-at xy vec-matrix))
          (+ total-score (get-trail-score-for xy vec-matrix))
          total-score)))))

(define {get-trail-rating-for xy mtx}
  ; xy is trailhead (0-value)...
  ; trail _rating_ is: how many unique paths to all 9-values can be found starting from here?
  ; path is still: value increasing by 1 each step
  (define walked (walk-paths xy mtx (list)))
  (length walked)) ; this is a silly way to uniq the list of results...

(define {solve-part2}
  (let [[vec-matrix (process-input)]]
    (for*/fold [[total-ratings 0]]
               [[y (vector-length vec-matrix)]
                [x (vector-length (vector-ref vec-matrix 0))]]
      (let [[xy (make-rectangular x y)]]
        (if (equal? 0 (get-value-at xy vec-matrix))
          (+ total-ratings (get-trail-rating-for xy vec-matrix))
          total-ratings)))))

(printf "part 1...\n")
(check-equal? (with-input-from-file "sample.txt" solve-part1) 36)
(check-equal? (with-input-from-file "input.txt"  solve-part1) 754)

(printf "part 2...\n")
(check-equal? (with-input-from-file "sample.txt" solve-part2) 81)
(check-equal? (with-input-from-file "input.txt"  solve-part2) 1609)
