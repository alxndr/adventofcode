#lang racket

; usage:
; STDIN expected to be the input data

(define extract-depth
  (lambda (dataset)
    (car (cdr (car dataset)))))

(define add-depth
  (lambda (dataset amount)
    (cons (cons 'depth
                (cons (+ (extract-depth dataset) amount)
                      '()))
          (cdr dataset))))

(define subtract-depth
  (lambda (dataset amount)
    (cons (cons 'depth
                (cons (- (extract-depth dataset) amount)
                      '()))
          (cdr dataset))))

(define extract-position
  (lambda (dataset)
    (car (cdr (car (cdr dataset))))))

(define add-position
  (lambda (dataset amount)
    (cons (car dataset)
          (cons (cons 'position
                      (cons (+ (extract-position dataset) amount)
                            '()))
                '()))))

(define process
  (lambda (line dataset)
    (define line-pair (string-split line))
    (define direction (car line-pair))
    (define amount (string->number (car (cdr line-pair))))
    (cond
      [(equal? direction "up") (subtract-depth dataset amount)]
      [(equal? direction "down") (add-depth dataset amount)]
      [(equal? direction "forward") (add-position dataset amount)]
      [else direction])))

(define loop ; recurses until current-input-port is empty
  (lambda (dataset)
    ; (newline) (print dataset) (newline)
    (let ([line (read-line (current-input-port))])
      (if (eof-object? line)
        dataset
        (loop (process line dataset))))))

(let* ([initial-state '((depth 0) (position 0))]
       [processed     (loop initial-state)])
  (printf "~a~n" processed)
  (printf "multiplied: ~a~n" (* (extract-depth processed) (extract-position processed))))
