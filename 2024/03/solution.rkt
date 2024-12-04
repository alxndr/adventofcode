#lang racket

(require "../advent-of-code-utils.rkt" threading rackunit rackunit/text-ui)

(define (solve-part1 input)
  (parsing-solver input))

(define (solve-part2 input)
  (parsing-solver input #:ignore-dont-sections #t))


(define (parsing-solver input)
  (~> input                     ; `input` is a list of strings
      (apply string-append _)   ; combine list-of-strings into a single string
      (tee~> pretty-print)
      tokenize
      (tee~> pretty-print)
  )
)

; Only the numbers one is really using any regex features, but we'll keep it this way for convenience...
(define RE_NUMBERS      #px"^\\d+") ; integers only
(define RE_KEYWORD_MUL  #px"^mul")
(define RE_KEYWORD_DO   #px"^do")
(define RE_KEYWORD_DONT #px"^don't")
(define RE_PAREN_OPEN   #px"^\\(")
(define RE_PAREN_CLOSE  #px"^\\)")
(define RE_COMMA        #px"^,")

(define (tokenize input [tokens '()])
  ; Expects input to be a single string, newlines treated like any other char...
  ; Note that there are no lexical errors in this grammar; rather, they're ignored and only the sequences which are valid are interpreted for meaning.
  (cond

    [(eq? 0 (string-length input))
     tokens
     #; (append tokens '((END_OF_INPUT)))] ; TODO add the end-of-input token...

    ; TODO create a macro for these...
    [(regexp-match-positions RE_KEYWORD_MUL input)
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)] ; this is a pair, not a list...
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)] ; ...so this is a number, not a list-wrapped number
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)]
                 )
            #; (pretty-print `(matched-token ,matched-token remaining ,remaining-input))
            (tokenize remaining-input (append tokens `((KEYWORD ,matched-token))))
          ))]

    [(regexp-match-positions RE_KEYWORD_DONT input) ; need to look for DONT before DO
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)]
                 )
            (tokenize remaining-input (append tokens `((KEYWORD ,matched-token))))
          ))]

    [(regexp-match-positions RE_KEYWORD_DO input)
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)]
                 )
            (tokenize remaining-input (append tokens `((KEYWORD ,matched-token))))
          ))]

    [(regexp-match-positions RE_NUMBERS input)
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)])
            (tokenize remaining-input (append tokens `((NUMBER ,(string->number matched-token)))))
          ))]

    [(regexp-match-positions RE_PAREN_OPEN input)
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)]
                 )
            (tokenize remaining-input (append tokens `((PAREN_OPEN))))
          ))]

    [(regexp-match-positions RE_PAREN_CLOSE input)
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)]
                 )
            (tokenize remaining-input (append tokens `((PAREN_CLOSE))))
          ))]

    [(regexp-match-positions RE_COMMA input)
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)]
                 )
            (tokenize remaining-input (append tokens `((COMMA))))
          ))]

    [else ; chews through `input` a single char at a time
      (tokenize (str-tail input) (append tokens `((UNKNOWN ,(str-head input)))))]

  )
)

(define (str-head str) (string-ref str 0))
(define (str-tail str) (substring str 1))

(define (parse tokens)
  (for/fold ([sum 0]
             [allow-computation #t] ; this value will be tweaked by part 2
            )
            ([token tokens])
    (pretty-print token)
    (match token
      [(list 'UNKNOWN _)
       0]
      [(list 'KEYWORD "mul" a b) ; todo this should probably include the whole thing... so we can calculate it here... but that may not be what a lexer is really for
       (* a b)]
      ; todo...
    )
  )
)


(run-tests
  (test-suite "2024 day 3"

    (test-suite "str-head"
      (test-case "basic usage"
        (check-equal? (str-head "a")   #\a)
        (check-equal? (str-head "xyz") #\x)))

    (test-suite "str-tail"
      (test-case "basic usage"
        (check-equal? (str-tail "abcd") "bcd")
        (check-equal? (str-tail "z")    "")))

    (test-suite "tokenize"
      (test-case "simple input"
        (check-equal? (tokenize "foo")      '((UNKNOWN #\f) (UNKNOWN #\o) (UNKNOWN #\o)))
        (check-equal? (tokenize "1 23 456") '((NUMBER 1) (UNKNOWN #\space) (NUMBER 23) (UNKNOWN #\space) (NUMBER 456)))
      )
      (test-case "punctuation"
        (check-equal? (tokenize "'.(]") '((UNKNOWN #\') (UNKNOWN #\.) (PAREN_OPEN) (UNKNOWN #\])))
        (check-equal? (tokenize "!@#)") '((UNKNOWN #\!) (UNKNOWN #\@) (UNKNOWN #\#) (PAREN_CLOSE)))
        (check-equal? (tokenize "$,,%") '((UNKNOWN #\$) (COMMA) (COMMA) (UNKNOWN #\%)))
      )
      (test-case "keywords"
        (check-equal? (tokenize "mul")         '((KEYWORD "mul")))
        (check-equal? (tokenize "muldo")       '((KEYWORD "mul") (KEYWORD "do")))
        (check-equal? (tokenize "don'tdo_mul") '((KEYWORD "don't") (KEYWORD "do") (UNKNOWN #\_) (KEYWORD "mul")))
      )
      (test-case "sample input"
        (let ([tokenized-sample-input (tokenize (car (sample-input)))])
          (check-equal? (car tokenized-sample-input) '(UNKNOWN #\x))
          (check-equal? (~> tokenized-sample-input cdr (take 6))       '((KEYWORD "mul") (PAREN_OPEN) (NUMBER 2) (COMMA) (NUMBER 4) (PAREN_CLOSE)))
          (check-equal? (~> tokenized-sample-input cdr (take-right 7)) '((KEYWORD "mul") (PAREN_OPEN) (NUMBER 8) (COMMA) (NUMBER 5) (PAREN_CLOSE) (PAREN_CLOSE)))
        )
      )
    )

    #| (test-suite "parse"
      (test-case "yeah"
        (check-equal? (parse '((UNKNOWN 'foo)))      0)
        (check-equal? (parse '((KEYWORD "mul" 2 3))) 6)
      )
    ) |#

    (test-suite "part 1"
      #; (test-case "sample input"
        (check-equal? (solve-part1 (sample-input)) 161))
      #; (test-case "full input"
        (check-equal? (solve-part1 (full-input))   175015740)))

    #; (test-suite "part 2"
      (test-case "sample input"
        (check-equal?
          (solve-part2 '("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"))
          48))
      (test-case "full input"
        (check-equal?
          (solve-part2 (full-input))
          112272912)))))
