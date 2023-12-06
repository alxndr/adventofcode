#lang racket

(define bigger-input
  #<<HERE
Time:      71530
Distance:  940200
HERE
)

(define biggest-input
  #<<HERE
Time:        49787980
Distance:   298118510661181
HERE
)

(define (transpose xss)
  (apply map list xss)) ; h/t 0xF https://stackoverflow.com/a/69269638/303896

(define (calc-race-time button-hold-time total-time)
  (* button-hold-time (- total-time button-hold-time)))

(define (r-run-the-numbers input hold-time to-beat num-winners)
  (if (= hold-time input)
    num-winners ; we're done here
    (let [[result (calc-race-time hold-time input)]]
      (r-run-the-numbers input
                         (+ 1 hold-time)
                         to-beat
                         (if (> result to-beat)
                           (+ 1 num-winners)
                           num-winners)))))

(let* [[t-s (map string-trim (string-split biggest-input "\n") )]
       [t-s-t (map cdr (map string-split t-s))]
       [transposed (car (transpose (map (lambda (l-o-s) (map string->number l-o-s)) t-s-t)))]
       [race-time (car transposed)]
       [distance (car (cdr transposed))]]
  (printf "\nrace time: ~s \ndistance record: ~s \nHow many ways can you beat the record in this one much longer race?\n\n"
          race-time distance)
  (printf "this many: ~s \n\n"
          (r-run-the-numbers race-time 0 distance 0)))
