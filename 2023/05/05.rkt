#lang racket

; usage: send input to STDIN

;; mappings...
;; D>S
;; S>F
;; F>W
;; W>L
;; L>T
;; T>H
;; H>N

;; each line in the mapping is... DestinationRangeStart SourceRangeStart RangeLength
;; input: seed number...
;; if Seed is < SourceRangeStart and > SRS+RangeLength-1 ...result is Seed + (DRS-SRS)

(define create-range-spec
  (lambda (split-line)
    (let* ([nums (map string->number split-line)])
      `(DestinationRangeStart ,(car split-line)
        SourceRangeStart ,(car (cdr split-line))
        RangeLength ,(car (cdr(cdr split-line))))
      )))

(define do-it
  (lambda (line dataset)
    (let ([split-line (string-split line)]) ;; TODO These are all strings not numbers...
      (cond
        [(= 0 (string-length line)) ; if line is empty ...this mapping is done
         dataset]

        [(equal? "map:" (car (cdr split-line))) ; if line ends in "map:" ...set up a new empty mapping
         (cons `(,(car split-line) ())                 dataset)]

        [(equal? "seeds:" (car split-line)) ; if line starts with "seeds:" ...it's the first line, which specifies the starting values...
         (cons (map string->number (cdr split-line))   dataset)]

        [else ; else it's a bunch of numbers ...add this set to the topmost mapping
          (let* ([active-mapping (car dataset)]
                 [mapping-name (car active-mapping)]
                 [mapping-data (cdr active-mapping)]
                 [new-mapping `(,mapping-name ,(cons (create-range-spec split-line)
                                                     mapping-data))])
            (cons new-mapping
                  (cdr dataset)))]))))

(define loop-input
  (lambda (dataset) ; recurses until current-input-port is empty
    (let ([line (read-line (current-input-port))])
      (if (eof-object? line) dataset
        (loop-input (do-it line dataset))))))

(let ([built-state (reverse (loop-input '()))])
  (printf "\nbuilt state... ~a \n" built-state)
  (printf "\nseeds ~s\n" (car built-state))
  (let* ([seeds (car built-state)]
         [first-seed (car seeds)])
    (printf "seed:~s \n" first-seed))
  )
