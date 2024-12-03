#lang racket

(require racket/pretty
         rackunit
         rackunit/text-ui)

(define (solve-part1 input)
  ; return the number of entries within `input` which are considered safe
  (for/sum ([report input])
    (if (acceptable-sequence? report)
      1
      0)))

(define (out-of-bounds? diff)
  (or (> diff 3)
      (< diff -3)
      (eq? diff 0)))

(define (remove-nth-element sequence n)
  (for/list ([index (length sequence)]
             #:when (not (eq? n index)))
    (list-ref sequence index)))

(define (acceptable-sequence? sequence #:allow-single-removal [allow-single-removal #f])
  (with-handlers ([exn:fail? ; TODO this is a bit awkward...
                    (if allow-single-removal
                      (λ (_) (for/or ([i (length sequence)])
                                     (let ([sequence-without-nth-element (remove-nth-element sequence i)])
                                       (acceptable-sequence? sequence-without-nth-element))))
                      (λ (_) #f))])
    (for/fold ([prev #f]
               [dir  #f]
               #:result #t)
              ([i sequence])
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
              (values i dir)]))))))

(define (solve-part2 input)
  (for/sum ([report input])
    (if (acceptable-sequence? report #:allow-single-removal #t)
      1
      0)))

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

    (test-suite "remove-nth-element"
      (test-case "basic usage"
        (check-equal? (remove-nth-element '(1 2 3 4 5) 0)
                      '(2 3 4 5))
        (check-equal? (remove-nth-element '(1 2 3 4 5) 2)
                      '(1 2 4 5))
      (test-case "when n is out of bounds"
        (check-equal? (remove-nth-element '(1 2 3 4 5) 9)
                      '(1 2 3 4 5)))))

    (test-suite "acceptable-sequence?"
      (test-case "increasing values: true"   (check-equal? (acceptable-sequence? '(1 2 3))
                                                           #t))
      (test-case "decreasing values: true"   (check-equal? (acceptable-sequence? '(99 96 93 90))
                                                           #t))
      (test-case "out-of-bounds step: false" (check-equal? (acceptable-sequence? '(99 96 93 89))
                                                           #f))
      (test-case "zero step: false"          (check-equal? (acceptable-sequence? '(4 5 6 6 7 8))
                                                           #f))
      (test-suite "with allow-single-removal"
        (test-case "direction switch: true" (check-equal? (acceptable-sequence? #:allow-single-removal #t '(5 6 7 5 8 9))
                                                          #t))
      )
    )

    (test-suite "part 1"
      (test-case "sample input"
        (check-equal?
          (solve-part1 (extract-and-split (sample-input)))
          2))
      (test-case "full input"
        (check-equal?
          (solve-part1 (extract-and-split (full-input)))
          490)))

    (test-suite "part 2"
      (test-case "sample input"
        (check-equal?
          (solve-part2 (extract-and-split (sample-input)))
          4))
      (test-case "full input"
        (check-equal?
          (solve-part2 (extract-and-split (full-input)))
          536)))

  )
)
