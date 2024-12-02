#lang racket

; "collection not found for module path: rackunit collection: "rackunit" in collection directories"
; ...run the below in CLI:
; $ raco pkg install rackunit

(require racket/pretty
         rackunit
         rackunit/text-ui)

(define (solve-part1 input)
  '())

(define (solve-part2 input)
  '())

(define (extract-and-split file-contents)
  (map (λ (line)
         (string-split line))
       file-contents))

(define (sample-input) (file->lines "sample.txt"))
(define (full-input)   (file->lines "input.txt"))

(run-tests
  (test-suite "2024 day ##"

    (test-suite "extract-and-split"
      (test-case "basic"
        (let ([split-input (extract-and-split (sample-input))])
          (check-equal?
            (car split-input)
            '())
          (check-equal?
            (length split-input)
            0)
          )
        )
      )

    (test-suite "part 1"
      (test-case "sample input"
        (check-equal?
          (solve-part1 (extract-and-split (sample-input)))
          #f)
        )
      #; (test-case "full input"
        (check-equal?
          (solve-part1 (extract-and-split (full-input)))
          #f)
        )
      )

    (test-suite "part 2"
      #; (test-case "sample input"
        (check-equal?
          (solve-part2 (extract-and-split (sample-input)))
          #f)
        )
      #; (test-case "full input"
        (check-equal?
          (solve-part2 (extract-and-split (full-input)))
          #f)
        )
      )

    )
  )
