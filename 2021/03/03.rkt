#lang racket

; usage:
; STDIN expected to be the input data

; dataset: a list of "bitcounter"s
; '(
;   (zeroes # ones #)
;   (zeroes # ones #)
;   ...
;  )

(define extract-nth ; 0-indexed
  (lambda (nth list-of-things)
    (if (eq? nth 0)
      (car list-of-things)
      (extract-nth (- nth 1) (cdr list-of-things)))))

(define increment-zeroes
  (lambda (bitcounter)
    (cons 'zeroes
          (cons (+ 1 (extract-nth 1 bitcounter))
                (cons 'ones
                      (cons (extract-nth 3 bitcounter)
                            '()))))))

(define increment-ones
  (lambda (bitcounter)
    (cons 'zeroes
          (cons (extract-nth 1 bitcounter)
                (cons 'ones
                      (cons (+ 1 (extract-nth 3 bitcounter))
                            '()))))))

(define adjust-counter
  (lambda (n bit bitcounter)
    (cond
      [(equal? bit "0") (increment-zeroes bitcounter)]
      [else (increment-ones bitcounter)])))

(define process
  (lambda (rawline dataset)
    (let* ([line (string-split rawline "")]
          [bit0 (extract-nth 1 line)] ; the 0th is an empty string, because of how `string-split` works
          [bit1 (extract-nth 2 line)]
          [bit2 (extract-nth 3 line)]
          [bit3 (extract-nth 4 line)]
          [bit4 (extract-nth 5 line)]
          [bit5 (extract-nth 6 line)]
          [bit6 (extract-nth 7 line)]
          [bit7 (extract-nth 8 line)]
          [bit8 (extract-nth 9 line)]
          [bit9 (extract-nth 10 line)]
          [bit10 (extract-nth 11 line)]
          [bit11 (extract-nth 12 line)])
      (cons (adjust-counter 0 bit0 (extract-nth 0 dataset))
            (cons (adjust-counter 1 bit1 (extract-nth 1 dataset))
                  (cons (adjust-counter 2 bit2 (extract-nth 2 dataset))
                        (cons (adjust-counter 3 bit3 (extract-nth 3 dataset))
                              (cons (adjust-counter 4 bit4 (extract-nth 4 dataset))
                                    (cons (adjust-counter 5 bit5 (extract-nth 5 dataset))
                                          (cons (adjust-counter 6 bit6 (extract-nth 6 dataset))
                                                (cons (adjust-counter 7 bit7 (extract-nth 7 dataset))
                                                      (cons (adjust-counter 8 bit8 (extract-nth 8 dataset))
                                                            (cons (adjust-counter 9 bit9 (extract-nth 9 dataset))
                                                                  (cons (adjust-counter 10 bit10 (extract-nth 10 dataset))
                                                                        (cons (adjust-counter 11 bit11 (extract-nth 11 dataset))
                                                                              '())))))))))))))))

(define loop ; recurses until current-input-port is empty
  (lambda (dataset)
    (let ([line (read-line (current-input-port))])
      (if (eof-object? line)
        dataset ; end recursion
        (loop (process line dataset))))))

(define less-common
  (lambda (bitcounter)
    (if (< (extract-nth 1 bitcounter) (extract-nth 3 bitcounter))
      "0"
      "1")))

(define more-common
  (lambda (bitcounter)
    (if (> (extract-nth 1 bitcounter) (extract-nth 3 bitcounter))
      "0"
      "1")))

(define calc-gamma
  (lambda (data)
    (string->number (string-join 
                      (cons (more-common (extract-nth 0 data))
                            (cons (more-common (extract-nth 1 data))
                                  (cons (more-common (extract-nth 2 data))
                                        (cons (more-common (extract-nth 3 data))
                                              (cons (more-common (extract-nth 4 data))
                                                    (cons (more-common (extract-nth 5 data))
                                                          (cons (more-common (extract-nth 6 data))
                                                                (cons (more-common (extract-nth 7 data))
                                                                      (cons (more-common (extract-nth 8 data))
                                                                            (cons (more-common (extract-nth 9 data))
                                                                                  (cons (more-common (extract-nth 10 data))
                                                                                        (cons (more-common (extract-nth 11 data))
                                                                                              '()))))))))))))
                      "")
                    2)))

(define calc-epsilon
  (lambda (data)
    (string->number (string-join 
                      (cons (less-common (extract-nth 0 data))
                            (cons (less-common (extract-nth 1 data))
                                  (cons (less-common (extract-nth 2 data))
                                        (cons (less-common (extract-nth 3 data))
                                              (cons (less-common (extract-nth 4 data))
                                                    (cons (less-common (extract-nth 5 data))
                                                          (cons (less-common (extract-nth 6 data))
                                                                (cons (less-common (extract-nth 7 data))
                                                                      (cons (less-common (extract-nth 8 data))
                                                                            (cons (less-common (extract-nth 9 data))
                                                                                  (cons (less-common (extract-nth 10 data))
                                                                                        (cons (less-common (extract-nth 11 data))
                                                                                              '()))))))))))))
                      "")
                    2)))

(let* ([processed-data (loop '( (zeroes 0 ones 0) (zeroes 0 ones 0) (zeroes 0 ones 0) (zeroes 0 ones 0) (zeroes 0 ones 0) (zeroes 0 ones 0) (zeroes 0 ones 0) (zeroes 0 ones 0) (zeroes 0 ones 0) (zeroes 0 ones 0) (zeroes 0 ones 0) (zeroes 0 ones 0)))]
       [gamma-rate (calc-gamma processed-data)]
       [epsilon-rate (calc-epsilon processed-data)])
  (printf "gamma: ~s~n" gamma-rate)
  (printf "epsilon: ~s~n" epsilon-rate)
  (printf "~nmultiplied: ~s~n" (* gamma-rate epsilon-rate)))
