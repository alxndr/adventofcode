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
                (cdr (cdr dataset))))))

(define extract-aim
  (lambda (dataset)
    (car (cdr (car (cdr (cdr dataset)))))))

(define add-aim
  (lambda (dataset amount)
    (cons (car dataset)
          (cons (car (cdr dataset))
                (cons (cons 'aim
                            (cons (+ (extract-aim dataset) amount)
                                  '()))
                      (cdr (cdr (cdr dataset))))))))

(define subtract-aim
  (lambda (dataset amount)
    (cons (car dataset)
          (cons (car (cdr dataset))
                (cons (cons 'aim
                            (cons (- (extract-aim dataset) amount)
                                  '()))
                      (cdr (cdr (cdr dataset))))))))

(define process
  (lambda (line dataset)
    (define line-pair (string-split line))
    (define direction (car line-pair))
    (define amount (string->number (car (cdr line-pair))))
    (cond
      [(equal? direction "up")      (subtract-aim dataset amount)]
      [(equal? direction "down")    (add-aim dataset amount)]
      [(equal? direction "forward") (add-depth (add-position dataset amount)
                                               (* amount (extract-aim dataset)))]
      [else direction])))

(define loop ; recurses until current-input-port is empty
  (lambda (dataset)
    ; (printf "~n~s~n" dataset)
    (let ([line (read-line (current-input-port))])
      (if (eof-object? line)
        dataset
        (loop (process line dataset))))))

(let* ([initial-state '((depth 0) (position 0) (aim 0))]
       [processed     (loop initial-state)])
  (printf "~a~n" processed)
  (printf "multiplied: ~a~n" (* (extract-depth processed) (extract-position processed))))
