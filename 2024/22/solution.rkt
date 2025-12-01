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

(define (collect-n-secrets n secret-number [collected-results '[]])
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

(printf "part 1\n")
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
(check-equal? (solve-part1 (file->lines "sample.txt"))
              37327623)
(check-equal? (solve-part1 (file->lines "input.txt"))
              13429191512)

(define (price n) ; ones-digit of the input
  (modulo n 10))

(define (price-delta a b)
  (- (price b) (price a)))

(define (list-n-deltas
          n
          secret-number
          [deltas 'nil]
          [previous-price 'nil])
  (if (eq? 0 n)
    (reverse deltas)
    (let* {[next-secret-number (next-secret secret-number)]
           [current-price (price secret-number)]}
      (list-n-deltas
        (- n 1)
        next-secret-number
        (if (eq? 'nil previous-price)
          '[]
          (cons (- current-price previous-price) deltas))
        current-price))))

(define (calculate-deltas l [deltas '[]])
  (if (< (length l) 2)
    (reverse deltas)
    (calculate-deltas (cdr l)
                      (cons (- (car l) (cadr l))
                            deltas))))

(define (track-deltas starting-number num-generations [recent-results '[]] [hash-deltas (hash)])
  ; keys in hash-deltas are "backwards" from how the writeup describes them...
  (cond
    [(eq? num-generations 0)
     hash-deltas]
    [(< (length recent-results) 5)
     (let {[next-secret-number (next-secret starting-number)]}
       (track-deltas next-secret-number
                    (- num-generations 1)
                    (cons (price next-secret-number) recent-results)
                    hash-deltas))]
    [else
     (let* {[next-secret-number (next-secret starting-number)]
            [next-results (take (cons (price next-secret-number) recent-results) 5)]}
       (track-deltas next-secret-number
                     (- num-generations 1)
                     next-results
                     (hash-set hash-deltas ; TODO fix hash-set: if there's already a value there, it shouldn't overwrite value with a new result
                               (calculate-deltas next-results) ; this is the tuple of last 4 deltas
                               (price next-secret-number)      ; this is ... "price" of next-secret-num
                               )))]))

(define (determine-highest-price hash-as-list)
  #; (printf "what's the highest price here??\n")
  #; (pretty-print hash-as-list)
  (for/fold {[deltas-and-max-price 'nil]}
            {[key-val-pair hash-as-list]}
    #; (printf "considering: ")
    #; (pretty-print key-val-pair)
    (if (equal? 'nil deltas-and-max-price)
      key-val-pair
      (let {[highest-price-so-far (cdr deltas-and-max-price)]
            [current-iteration-price (cdr key-val-pair)]}
        #; (printf "is ~a > ~a ?? ...\n" current-iteration-price highest-price-so-far)
        (if (> current-iteration-price highest-price-so-far)
          key-val-pair
          deltas-and-max-price)
      )
    )
  )
)

(define (find-largest-price list-of-hashes)
  ; go through key-val pairs of each hash and sum up values for each tuple-key...
  ; determine the largest summed value, then return the summed value and associated tuple-key
  (~>
    (for/fold {[hash-of-deltas-to-price-sum (make-hash)]}
              {[hash-deltas list-of-hashes]}
      #; (printf "hash-deltas... \n")
      #; (pretty-print hash-deltas)
      (for {[key-val (hash->list hash-deltas)]}
        #; (pretty-print key-val)
        (let {[deltas (reverse (car key-val))]
              [price (cdr key-val)]}
          #; (printf "deltas: ~a => price: ~a\n"
                  deltas
                  price)
          (hash-update! hash-of-deltas-to-price-sum
                        deltas
                        (curry + price)
                        0)
        )
      )
      hash-of-deltas-to-price-sum)
    hash->list
    determine-highest-price
  )
)

(define (solve-part2 input-lines)
  (~> input-lines
      (map (λ (input) (~> input
                          string->number
                          (track-deltas 2000))
           )
         _)
      find-largest-price
      cdr))

(printf "part 2\n")
(check-equal? (list-n-deltas 5 123)
              (list -3 6 -1 -1)) ; NOTE "track n:5" gives 4 results
(check-equal? (list-n-deltas 10 123)
              (list -3 6 -1 -1 0 2 -2 0 -2))

(check-equal? (calculate-deltas (list 1 2 3 4 2))
              (list -1 -1 -1 2))
(check-equal? (find-largest-price (list (track-deltas 123 10)))
              '((-1 -1 0 2) . 6))
(check-equal? (find-largest-price (list (track-deltas 123 10) (track-deltas 123 10)))
              '((-1 -1 0 2) . 12))
(check-equal? (solve-part2 (list "1" "2" "3" "2024"))
              23)
(check-equal? (solve-part2 (file->lines "input.txt"))
              'greater-than-1579)

; make a hash for each input line...
; hash is: 4-part-tuple-of-deltas => result number of bananas
; do that for all the lines, we'll have a bunch of giant hashes...
; then iterate across all keys of the hashes (tuples-of-deltas) and sum the results,
; ... keep the one tuple-of-deltas which has the highest sum
