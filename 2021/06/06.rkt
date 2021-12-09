#lang racket

(define days 18)

; could pre-calculate the sequence for 0 for the day count
; then look up the results for each of the input timer values

(define process
  (lambda (day dataset)
    ; if day is in dataset, return it
    ; if not, look for day - 1... then run the transform on it and store it
    (cond
      ((in-dataset day dataset)
       (retrieve day dataset)) ; TODO collapse into an or...
      ((in-dataset (- day 1) dataset)

       )
      'wip)
    ))

(define pop-size-r;ecursive
  (lambda (day totalDays dataset)
    (if (eq? day totalDays)
      dataset
      (pop-size-r (+ 1 day)
                  (process day dataset)))))
(define calc-population-sizes ; for a Fish with timer = 0
  (lambda (totalDays)
    (pop-size-r 1 totalDays '())))

(let* (
       [line (read-line (current-input-port))] ; only need to look at the first line of input
       [list-of-timers (string-split line ",")]
      )
  (printf "input: ~a~n" list-of-timers)
  (printf "days: ~a~n~n" days)
)
