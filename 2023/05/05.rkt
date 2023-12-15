#lang racket

(define part 2)

; usage: send input to STDIN

(define create-range-spec
  (lambda (split-line)
    (let* ([nums (map string->number split-line)]) ;; TODO don't need nums...
      (hash 'DestinationRangeStart (string->number (car split-line))
            'SourceRangeStart (string->number (car (cdr split-line)))
            'RangeLength (string->number (car (cdr (cdr split-line))))))))

(define r-build-seed-list
  (lambda (num remaining-length seed-list)
    (if (= 0 remaining-length)
      seed-list
      (r-build-seed-list (+ num 1) (- remaining-length 1)
                         (cons num seed-list)))))

(define r-construct-seed-list-from-ranges
  (lambda (list-of-numbers results)
    (if (or (empty? list-of-numbers) (empty? (car list-of-numbers)))
      results
      (let ([seed-list-start (car list-of-numbers)]
            [seed-list-length (car (cdr list-of-numbers))]
            [seed-list-rest (cdr (cdr list-of-numbers))])
        (r-construct-seed-list-from-ranges
          seed-list-rest
          (r-build-seed-list seed-list-start seed-list-length results))))))

(define construct-dataset
  (lambda (line dataset)
    (let ([split-line (string-split line)]) ;; NOTE these are all strings not numbers...
      (cond
        [(= 0 (string-length line)) ; if line is empty ...this mapping is done
         dataset]

        [(equal? "seeds:" (car split-line)) ; if line starts with "seeds:" ...it's the first line, which specifies the starting values...
         ; for part 2 this is a naive approach; the data expands too much to handle in memory...
         ;; (list (r-construct-seed-list-from-ranges (map string->number (cdr split-line)) '()))
         ; ...so we're gonna leave the seeds untouched for now, and construct em as we calculate the result later on
         (list (cdr split-line)) ]

        [(equal? "map:" (car (cdr split-line))) ; if line ends in "map:" ...set up a new empty mapping
         (cons `(,(car split-line) ())
               dataset)]

        [else ; it's a bunch of numbers ...add this set to the topmost mapping
          (let* ([active-mapping (car dataset)] ; a 'mapping' is list, car is name, cdr is a list of range-hash structs
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
        (loop-input (construct-dataset line dataset))))))

(define r-calculate-result-via-mapping
  (lambda (input mapping-ranges)
    (if (or (empty? mapping-ranges) (empty? (car mapping-ranges)))
      #f
      (let* ([first-mapping (car mapping-ranges)]
             [src-range-start (hash-ref first-mapping 'SourceRangeStart)]
             [dst-range-start (hash-ref first-mapping 'DestinationRangeStart)]
             [len-range (hash-ref first-mapping 'RangeLength)])
        ;; if Input is >= SourceRangeStart and < SRS+RangeLength-1
        (if (and (>= input src-range-start)
                 (<  input (+ src-range-start len-range)))
          ;; ...result is Input + (DRS-SRS)
          (input . + . (dst-range-start . - . src-range-start)) ; wheeeee
          (let ([recursive-result (r-calculate-result-via-mapping input (car (cdr mapping-ranges)))])
            (if (equal? #f recursive-result)
              input ;; "Any source numbers that aren't mapped correspond to the same destination number. So, seed number 10 corresponds to soil number 10."
              recursive-result)))))))

(define r-calculate-seed-results
  (lambda (input mappings)
    (if (or (empty? mappings) (empty? (car mappings)))
      input
      (let* ([top-mapping (car mappings)]
             [remaining-mappings (cdr mappings)]
             [first-mapping-name (car top-mapping)]
             [first-mapping-ranges (car (cdr top-mapping))])
        (r-calculate-seed-results
          (r-calculate-result-via-mapping input first-mapping-ranges)
          remaining-mappings)
        ))))

(define r-calculate-location-with-seed-ranges
  (lambda (mappings seed-ranges lowest-location)
    (if (or (empty? seed-ranges) (empty? (car (cdr seed-ranges))))
      lowest-location
      (let ([seed-range-start (car seed-ranges)]
            [seed-range-length (car (cdr seed-ranges))])
        (if (= 1 seed-range-length)
          (let ()
            (printf "rclwsr:~s\tseed-ranges:~a\n" lowest-location seed-ranges)
            (r-calculate-location-with-seed-ranges mappings
                                                   (cdr (cdr seed-ranges))
                                                   lowest-location))
          (let* ([seed-location-result (r-calculate-seed-results seed-range-start mappings)]
                 [seed-range-left (cons (seed-range-start . + . 1)
                                        (cons (seed-range-length . - . 1)
                                              (cdr (cdr seed-ranges))))])
            (r-calculate-location-with-seed-ranges mappings
                                                   seed-range-left
                                                   (if (or (equal? #f lowest-location) (< seed-location-result lowest-location))
                                                     seed-location-result
                                                     lowest-location))))))))

(define mapping-spec-to-rangeshift
  (lambda (mapping-spec)
    (let* ([srs (hash-ref (car mapping-spec) 'SourceRangeStart)]
          [dst (hash-ref (car mapping-spec) 'DestinationRangeStart)]
          [len (hash-ref (car mapping-spec) 'RangeLength)])
    (hash 'Range `(,srs ,(+ srs (- len 1)))
          'Shift (- dst srs)))))

(define r-process-mapping
  (lambda (oom-mapping-list processed)
    (printf "~a\n" oom-mapping-list)
    (if (empty? oom-mapping-list)
      processed
      (let ([pop (car oom-mapping-list)]
            [therest (cdr oom-mapping-list)])
        (r-process-mapping therest (cons (mapping-spec-to-rangeshift pop)
                                         processed))))
    ))
(define r-reprocess-mappings
  (lambda (original-order-mappings processed-mappings)
    (if (empty? original-order-mappings)
      processed-mappings
      (let* ([oom (car original-order-mappings)]
             [rest-mappings (cdr original-order-mappings)]
             [oom-name (car oom)]
             [oom-mapping-list (cdr oom)])
        (printf "\n~a... \n" oom-name)
        (r-reprocess-mappings rest-mappings
                              (cons (r-process-mapping oom-mapping-list '())
                                    processed-mappings))))))
(define reprocess-mappings
  (lambda (original-order-mappings)
    (r-reprocess-mappings original-order-mappings '())))

(let* ([built-state (reverse (loop-input '()))]
       [seeds-numbers (map string->number (car built-state))]
       [mappings (cdr built-state)] ; these are in order of the input
       )
  (if (equal? part 1)

    (printf "\npart 1: calculate locations, lowest with my sample data should be 35 == ~a\n"
            (apply min (map (lambda (seed) (r-calculate-seed-results seed mappings)) seeds-numbers)))

    (let ([mappings-reprocessed (reprocess-mappings mappings)])
      (printf "\npart 2:...\n")
      ; the implementation of part 1 swallows up way too much memory to be useful...
      ; initial implementation here is to brute-force calculate every result for every input, but that takes per (seed-range-start seed-range-length) pairing...
      ; 10 min.    10min tot
      ; 20 min..   30min tot
      ; 40 min.... 75min tot
      ;
      ;
      ;
      ;
      ;         ...180min total
      ;; (r-calculate-location-with-seed-ranges mappings seeds #f)

      ; so based on the Map, can I tell which part of the Range will be the lowest Location???
      ; preprocess the mappings into Range+Shift...
      (printf "~a \n\n" mappings-reprocessed)
      ; i peeked 🫣 start at the end and work backwards?!?
      )))
