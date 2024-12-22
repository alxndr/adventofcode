#lang racket

(require #; bitwise-ops threading rackunit)

(define (mix a b)
  (bitwise-xor a b))

(define (prune n)
  (modulo n 16777216))

(define (next-secret secret-number)
  (let* {[a (~> secret-number
                (* 64)
                (mix secret-number)
                prune)]
         [b (~> a
                (/ 32)
                floor
                (mix a)
                prune)]
         [c (~> b
                (* 2048)
                (mix b)
                prune)]
         }
    c))

(define (collect-n-secrets n secret-number [collected-results '()])
  (if (eq? n 0)
    (reverse collected-results)
    (let {[next-secret-number (next-secret secret-number)]}
      (collect-n-secrets (- n 1)
                         next-secret-number
                         (cons next-secret-number
                               collected-results))
      )
    ))

(define (find-nth-secret n secret-number)
  (if (equal? 0 n)
    secret-number
    (find-nth-secret (- n 1) (next-secret secret-number))))

(define (solve-part1 input-lines [num-generations 2000])
  (apply +
         (map (λ (input-num) (find-nth-secret num-generations (string->number input-num)))
              input-lines)))

(printf "setup...\n")
(check-equal? (mix 42 15)
              37)
(check-equal? (prune 100000000)
              16113920)
(check-equal? (next-secret 123)
             15887950)
(check-equal? (collect-n-secrets 10 123)
             '(
               15887950
               16495136
               527345
               704524
               1553684
               12683156
               11100544
               12249484
               7753432
               5908254
               ))
(check-equal? (find-nth-secret 0 123)
              123)
(check-equal? (find-nth-secret 1 123)
              15887950)
(check-equal? (find-nth-secret 2 123)
              16495136)
(check-equal? (find-nth-secret 10 123)
              5908254)

(printf "part 1\n")
(check-equal? (solve-part1 (file->lines "sample.txt"))
              37327623)
(check-equal? (solve-part1 (file->lines "input.txt"))
              13429191512)
