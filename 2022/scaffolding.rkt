#lang racket

; usage: send input to STDIN

(define process
  (lambda (line dataset)
    (printf "~s~n" line)
    dataset))

(define loop ; recurses until current-input-port is empty
  (lambda (dataset)
    (let ([line (read-line (current-input-port))])
      (if (eof-object? line)
        dataset
        (loop (process line dataset))))))

(let* ([result (loop '())])
  (printf "result... ~s~n" result)
  )
