#lang racket

; usage: send input to STDIN

(define create-range-spec
  (lambda (split-line)
    (let* ([nums (map string->number split-line)])
      (hash 'DestinationRangeStart (string->number (car split-line))
            'SourceRangeStart (string->number (car (cdr split-line)))
            'RangeLength (string->number (car (cdr (cdr split-line))))))))

(define construct-dataset
  (lambda (line dataset)
    (let ([split-line (string-split line)]) ;; NOTE these are all strings not numbers...
      (cond
        [(= 0 (string-length line)) ; if line is empty ...this mapping is done
         dataset]

        [(equal? "map:" (car (cdr split-line))) ; if line ends in "map:" ...set up a new empty mapping
         (cons `(,(car split-line) ())
               dataset)]

        [(equal? "seeds:" (car split-line)) ; if line starts with "seeds:" ...it's the first line, which specifies the starting values...
         (cons (map string->number (cdr split-line))
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
  (lambda (input mapping-ranges) ; recurses until mapping-ranges is empty
    ;; (printf "input:~v\nmapping:~v\n" input mapping-ranges)
    (cond
      ((empty? mapping-ranges)       #f)
      ((empty? (car mapping-ranges)) #f)
      (else
        (let* ([first-mapping (car mapping-ranges)]
               [src-range-start (hash-ref first-mapping 'SourceRangeStart)]
               [dst-range-start (hash-ref first-mapping 'DestinationRangeStart)]
               [len-range (hash-ref first-mapping 'RangeLength)])
          ;; if Input is > SourceRangeStart and < SRS+RangeLength-1
          (if (and (>= input src-range-start)
                   (<  input (src-range-start . + . (len-range . - . 1))))
            ;; ...result is Input + (DRS-SRS)
            (input . + . (dst-range-start . - . src-range-start)) ; wheeeee
            (let ([recursive-result (r-calculate-result-via-mapping input (car (cdr mapping-ranges)))])
              (if (equal? #f recursive-result)
                input ;; "Any source numbers that aren't mapped correspond to the same destination number. So, seed number 10 corresponds to soil number 10."
                recursive-result))))))))

(define calculate-seed-results
  (lambda (input mappings)
    (cond
      ((empty? mappings)
       input)
      ((empty? (car mappings))
       input)
      (else
      (let* ([top-mapping (car mappings)]
             [first-mapping-name (car top-mapping)]
             [first-mapping-ranges (car (cdr top-mapping))])
        ;; which range (in the top mapping on built-state) does the first-seed fit into?
        (printf "mapping ~a \t seed... ~s\n" first-mapping-name input)
        (r-calculate-result-via-mapping input first-mapping-ranges)
        ;; (build a lil fn for each range... then run the seed through it... return the adjusted destination value...)
        ;; ...and then do for the next mapping in built-state...
        )))))

(let* ([built-state (reverse (loop-input '()))]
       [seeds (car built-state)]
       [mappings (cdr built-state)])
  ;; (printf "\nseeds ~a\n" seeds)
  ;; (printf "\nmappings ~a\n" mappings)
  (map (lambda (seed) (calculate-seed-results seed mappings))
       seeds)
  ;; pop off the seeds from built-state...
  ;; ... and then look for the lowest Location value: "What is the lowest location number that corresponds to any of the initial seed numbers?"
  )
