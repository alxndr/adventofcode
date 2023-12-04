#lang racket

; usage: send input to STDIN

(define process
  (lambda (line dataset)
    (let* ([line-length (string-length line)])
    ; if line is a newline...
    (if (= 0 line-length)
      ; ...add a 0 to (beginning of) dataset
      (cons 0 dataset)
      ; ...else add int to dataset's most recent value and replace into daaset
      (let ([line-int (string->number	line)]
            [dataset-val (car dataset)]
            [dataset-remainder (cdr dataset)])
        (cons (+ line-int dataset-val)
              dataset-remainder))))))

(define loop ; recurses until current-input-port is empty
  (lambda (dataset)
    (let ([line (read-line (current-input-port))])
      (if (eof-object? line)
        dataset
        (loop (process line dataset))))))

(let* ([initial-state '(0)]
       [result         (loop initial-state)])
  (printf "part1: largest: ~s~n" (apply max result))
  (printf "part2: sorted: ~s~n" (take (sort result >) 3) )
  )
