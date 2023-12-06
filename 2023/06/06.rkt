#lang racket

(define sample-input
  #<<HERE
Time:      7  15   30
Distance:  9  40  200
HERE
)

(define big-input
  #<<HERE
Time:        49     78     79     80
Distance:   298   1185   1066   1181
HERE
)

(define (transpose xss) (apply map list xss)) ; h/t 0xF https://stackoverflow.com/a/69269638/303896

(define calc-race-time
  (lambda (button-hold-time total-time)
    (* button-hold-time
       (- total-time button-hold-time))))

(define r-decrement
  (lambda (n xs)
    (if (= 0 n)
      xs
      (r-decrement (- n 1) (cons n xs)))))
(define calc-race-results
  (lambda (total-time dist-to-beat)
    (let ([all-hold-times (r-decrement total-time '())])
      ;; (printf "all-times..... ~a\n\n" all-hold-times)
      (map (lambda (hold-time) (calc-race-time hold-time total-time)) all-hold-times))))

(define do-thing
  (lambda (pairing) ; (Time Distance)
    (let* ([total-time (car pairing)]
           [dist-to-beat (car (cdr pairing))]
           [race-results (calc-race-results total-time dist-to-beat)]
           [winning-results (filter (lambda (result) (> result dist-to-beat)) race-results)])
      (printf "race-results ~s\n\n" race-results)
      (printf "winning-results ~s\n\n" winning-results)
      (length winning-results))))

(let* {
  [t-s (map string-trim (string-split big-input "\n") )]
  [t-s-t (map cdr (map string-split t-s))]
  [transposed (transpose (map (lambda (l-o-s) (map string->number l-o-s)) t-s-t))] ; omg such map
  }
  (printf "Determine the number of ways you could beat the record in each race. What do you get if you multiply these numbers together?\n")
  (printf "multiply together: ~s\n\n"
   (apply * (map do-thing transposed)))
  )
