#lang racket

; usage:
; STDIN expected to be the input data

(define process
  (lambda (line dataset)
    (cond
      [(equal? line "foo") 'foo]
      [else 'bar])))

(define loop ; recurses until current-input-port is empty
  (lambda (dataset)
    ; (printf "~n~s~n" dataset)
    (let ([line (read-line (current-input-port))])
      (if (eof-object? line)
        dataset
        (loop (process line dataset))))))

(loop '())
