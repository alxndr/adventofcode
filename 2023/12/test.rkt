#lang racket

(require "solution.rkt"
         "input.rkt"
         rackunit
         rackunit/text-ui)

(run-tests
  (test-suite
    "2023 day 12"


    (test-suite "string-to-chars"
      (test-case "basic" (check-equal? (string-to-chars "foo") '("f" "o" "o"))))


    (test-suite "split-up-springspec"
      (test-case "fundamentals"
         (check-equal? (split-up-springspec ".") '())
         (check-equal? (split-up-springspec "#") '("#")))
      (test-case "basics"
         (check-equal? (split-up-springspec "#.#") '("#" "#"))
         (check-equal? (split-up-springspec ".##..###.####.#") '("##" "###" "####" "#")))
      )


    (test-suite "check-springcode"
      (test-case "basic truthy" (check-equal? (check-springcode? "#" '(1)) #t))
      (test-case "basic falsy" (check-equal? (check-springcode? "." '(1)) #f))
      (test-case "medium truthy" (check-equal? (check-springcode? "#.#.###" '(1 1 3)) #t))
      (test-case "medium falsy" (check-equal? (check-springcode? "#.#.###" '(1 1 4)) #f))
      (test-case "longer truthy" (check-equal? (check-springcode? ".#.###.#.######" '(1 3 1 6)) #t))
      (test-case "longer falsy" (check-equal? (check-springcode? "##.####.#.###.#.######" '(1 3 1 6)) #f))
      )


    (test-suite "string-to-chars"
      (test-case "basic" (check-equal? (string-to-chars "#?") '( "#" "?" )))
      )


    (test-suite "generate-possibilities"
      (test-case "basic" (check-equal? (generate-possibilities (string-to-chars "#?")) '("#." "##")))
      (test-case "starting with question mark" (check-equal? (generate-possibilities (string-to-chars "?.#")) '( "..#" "#.#" )))
      (test-case "all question marks" (check-equal? (generate-possibilities (string-to-chars "???")) '("..." "..#" ".#." ".##" "#.." "#.#" "##." "###")))
      (test-case "longer" (check-equal? (length (generate-possibilities (string-to-chars "#.?#.?.#?#?#?.?#.##?????"))) 2048))
      )


    (test-suite
      "part 1 solution"
      (test-case "sample" (check-equal? (solve-part1 (sample-input)) 21))
      ;(test-case "full" (check-equal? (solve-part1 (full-input)) 7118))
      )


    (test-suite
      "graph stuff..."

      (test-case
        "something"
        #| (check-equal? 'a
                      'b) |#
        )

      )


    (test-suite
      "part 2 solution"

      (test-case
        "real small sample"
        (check-equal?
          (solve-part2 (list (car (sample-input))))
          1)
        )

      #| (test-case
        "next smallest sample"
        (check-equal?
          (solve-part2 (list (car (sample-input))
                             (cadr (sample-input))))
          2)
        ) |#

      #| (test-case
        "next smallest sample"
        (check-equal?
          (solve-part2 (list (car (sample-input))
                             (cadr (sample-input))
                             (caddr (sample-input))))
          16386)
        ) |#

      #| (test-case
        "sample"
        (check-equal?
          (solve-part2 (sample-input))
          525152)
        ) |#

      #| (test-case
        "full"
        (check-equal?
          (solve-part2 (full-input))
          'unknown)
        ) |#

      )





    )
  )
