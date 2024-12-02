#lang racket

; "collection not found for module path: rackunit collection: "rackunit" in collection directories"
; ...run the below in CLI:
; $ raco pkg install rackunit

(require racket/pretty
         rackunit
         rackunit/text-ui)

(define (solve-part1 input)
  (let* [[numbers (strings-to-numbers input)]
         [l-sorted (sort (map (λ (ns) (car ns)) numbers) <)] ; TODO implement unzip rather than go over the input twice...
         [r-sorted (sort (map (λ (ns) (cadr ns)) numbers) <)]]
    (sum-differences l-sorted r-sorted)))

(define (sum-differences left right [sum 0])
  (if (empty? left) ; assuming that left and right are same length...
    sum
    (let [[l0 (car left)]
          [r0 (car right)]]
      (sum-differences (cdr left)
                       (cdr right)
                       (+ sum (abs (- l0 r0)))))))


(define (solve-part2 input)
  (let* [[numbers (strings-to-numbers input)]
         [hashes (numbers-to-hashes numbers)]
         [hash-l (car hashes)]
         [hash-r (cadr hashes)]]
    #; (pretty-print hashes)
    ; for each number in the left, increase the score by:
    ; the number itself multiplied by how many times it occurs in the right _and_ how many times it occurs in the left
    (foldl (λ (n acc)
             (let [[count-left  (hash-ref hash-l n)]
                   [count-right (hash-ref hash-r n 0)]]
               (+ acc (* count-right count-left n))))
           0
           (hash-keys hash-l))))

(define (numbers-to-hashes numbers)
  (foldl (λ (elem acc)
           #; (pretty-print `("elem" ,elem "acc" ,acc))
           (let* [[left-value (car elem)]
                  [left-hash  (car acc)]
                  [left-count (hash-ref left-hash left-value 0)]
                  [right-value (cadr elem)]
                  [right-hash  (cadr acc)]
                  [right-count (hash-ref right-hash right-value 0)]
                  ]
             `(
               ,(hash-set left-hash  left-value  (+ 1 left-count))
               ,(hash-set right-hash right-value (+ 1 right-count)))))
         `(,(hash) ,(hash))
         numbers))


(define (strings-to-numbers input)
  (map (λ (line)
         (cons (string->number (car line))
               (cons (string->number (cadr line))
                     '())))
       input))

(define (extract-and-split file-contents)
  (map (λ (line)
         (string-split line))
       file-contents))

(define (sample-input) (file->lines "sample.txt"))
(define (full-input)   (file->lines "input.txt"))

(run-tests
  (test-suite "2024 day 1"

    (test-suite "extract-and-split"
      (test-case "basic"
        (let ([split-input (extract-and-split (sample-input))])
          (check-equal?
            (car split-input)
            '("3" "4"))
          (check-equal?
            (cadr split-input)
            '("4" "3"))
          (check-equal?
            (length split-input)
            6)
          )
        )
      )

    (test-suite "strings-to-numbers"
      (test-case "basic"
        (check-equal?
          (strings-to-numbers '(("1" "2") ("3" "4")))
          '((1 2) (3 4)))))

    (test-suite "part 1"
      (test-case "sample input"
        (check-equal?
          (solve-part1 (extract-and-split (sample-input)))
          11)
        )
      (test-case "full input"
        (check-equal?
          (solve-part1 (extract-and-split (full-input)))
          2164381)
        )
      )

    (test-suite "part 2"
      (test-case "sample input"
        (check-equal?
          (solve-part2 (extract-and-split (sample-input)))
          31)
        )
      (test-case "full input"
        (check-equal?
          (solve-part2 (extract-and-split (full-input)))
          20719933)
        )
      )

    )
  )
