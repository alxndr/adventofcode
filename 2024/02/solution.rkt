#lang racket

(require racket/pretty
         rackunit
         rackunit/text-ui)

(define (solve-part1 input)
  '())

(define (out-of-bounds? diff)
  (or (> diff 3)
      (< diff -3)
      (eq? diff 0)))

(define (acceptable-sequence? sequence)
  (and
    (for/fold ([prev #f]
               [dir  #f])
       ([i sequence])
       (printf "prev:~a ... dir:~a \n" prev dir)
       (if (eq? prev #f)

         ; 1st iteration
         (values i #f)

         (let ([diff (- i prev)])
           (cond
             [(out-of-bounds? diff)
              (error "difference is out of bounds:" diff)]

             ; 2nd iteration — establish the `dir` for remaining iterations
             [(eq? dir #f)
              (values i (if (> diff 0) 'positive 'negative))]

             ; remaining iterations — check that `diff` is consistent with `dir`
             [(or (and (eq? dir 'positive) (< diff 0))
                  (and (eq? dir 'negative) (> diff 0)))
              (error "direction of change has changed, was:" dir "but diff is" diff)]

             [else
               (printf "lookin okay...\n")
               (values i dir)]
             )
           )
         )
       )
    #t)
  )
(acceptable-sequence? '(5 4 3 2 1))

(define (solve-part2 input)
  '())

(define (extract-and-split file-contents)
  (for/list ([line file-contents])
    (for/list ([str (string-split line)])
      (string->number str))))

(define (sample-input) (file->lines "sample.txt"))
(define (full-input)   (file->lines "input.txt"))

(run-tests
  (test-suite "2024 day 2"

    (test-suite "extract-and-split"
      (test-case "basic"
        (let ([split-input (extract-and-split (sample-input))])
          (check-equal? (car split-input) '(7 6 4 2 1))
          (check-equal? (length split-input) 6))))

    (test-suite "acceptable-sequence?"
      (test-case "increasing values"
        (printf "here we go\n")
        (printf "result... " )
        (pretty-print (acceptable-sequence? '(1 2 3 4 5)))
        (check-equal? (acceptable-sequence? '(1 2 3)) #t))
    )

    (test-suite "part 1"
      #; (test-case "sample input"
        (check-equal?
          (solve-part1 (extract-and-split (sample-input)))
          #f))
      #; (test-case "full input"
        (check-equal?
          (solve-part1 (extract-and-split (full-input)))
          #f)))

    (test-suite "part 2"
      #; (test-case "sample input"
        (check-equal?
          (solve-part2 (extract-and-split (sample-input)))
          #f))
      #; (test-case "full input"
        (check-equal?
          (solve-part2 (extract-and-split (full-input)))
          #f)))

  )
)
