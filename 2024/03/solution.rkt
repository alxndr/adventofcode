#lang racket

(require "../advent-of-code-utils.rkt"
         rackunit
         rackunit/text-ui)

(define REGEX_MUL #px"mul\\((\\d+),(\\d+)\\)")

(define (solve-part1 input)
  (for/sum ([line input])
    (for/sum ([mult-pair (regexp-match* REGEX_MUL line #:match-select cdr)])
      (apply * (map string->number mult-pair)))))

; TODO this calls for a real parser... but I know regexes more readily

(define REGEX_DONT_SECTIONS #px"don't\\(\\).*?(do\\(\\)|$)")

(define (strip-ignored str)
  (apply string-append
         (regexp-match* REGEX_DONT_SECTIONS str #:match-select (λ (_) "_") #:gap-select? #t)))

(define (solve-part2 input)
  (for/sum ([mult-pair (regexp-match* REGEX_MUL (strip-ignored (apply string-append input)) #:match-select cdr)])
    (apply * (map string->number mult-pair))))


(run-tests
  (test-suite "2024 day 3"

    (test-suite "part 1"
      (test-case "sample input"
        (check-equal?
          (solve-part1 (sample-input))
          161))
      (test-case "full input"
        (check-equal?
          (solve-part1 (full-input))
          175015740)))

    (test-suite "strip-ignored"
      (test-case "replaces don't-to-do sections with underscore"
        (check-equal?
          (strip-ignored "foo bar do() don't() blah do() baz")
          "foo bar do() _ baz")
        (check-equal?
          (strip-ignored "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))")
          "xmul(2,4)&mul[3,7]!^_?mul(8,5))"))
      (test-case "multiple sections to remove"
        (check-equal?
          (strip-ignored "foo bar do() don't() blah do() do() baz don't() qux do()quxx don't()do() quxxxx")
          "foo bar do() _ do() baz _quxx _ quxxxx")
        (check-equal?
          (strip-ignored "don't()foo bar d_o() don't() blah do() do() baz don't() qux do()quxx don't()do() quxxxx")
          "_ do() baz _quxx _ quxxxx"))
      (test-case "don't-section at end is stripped"
        (check-equal?
          (strip-ignored "foo don't()bar do() baz don't() qux")
          "foo _ baz _")))

    (test-suite "part 2"
      (test-case "sample input"
        (check-equal?
          (solve-part2 '("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"))
          48))
      (test-case "full input"
        (check-equal?
          (solve-part2 (full-input))
          112272912)))

  )
)
