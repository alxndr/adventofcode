#lang racket

(define process
  (lambda (line dataset)
    dataset))

(define loop ; recurses until current-input-port is empty
  (lambda (dataset)
    (let ([line (read-line (current-input-port))])
      (if (eof-object? line)
        dataset ; end recursion
        (loop (process line dataset))))))

(define initial-dataset
  '())

(let* ([processed-data (loop initial-dataset)])
  processed-data)
