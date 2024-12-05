#lang racket

(require "../advent-of-code-utils.rkt" threading rackunit rackunit/text-ui)

(define (solve-part1 input)
  (parsing-solver input))

(define (solve-part2 input)
  (parsing-solver input #:ignore-dont-sections? #true))

(define (parsing-solver input #:ignore-dont-sections? [ignore-dont-sections? #false])
  (~> input                     ; `input` is a list of strings
      (apply string-append _)   ; combine list-of-strings into a single string
      tokenizer
      (lexer #:ignore-dont-sections? ignore-dont-sections?)
      parse-multiply
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

(define (tokenizer input [tokens '()])
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
            (tokenizer remaining-input (append tokens `((KEYWORD ,matched-token))))
          ))]

    [(regexp-match-positions RE_KEYWORD_DONT input) ; need to look for DONT before DO
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)]
                 )
            (tokenizer remaining-input (append tokens `((KEYWORD ,matched-token))))
          ))]

    [(regexp-match-positions RE_KEYWORD_DO input)
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)]
                 )
            (tokenizer remaining-input (append tokens `((KEYWORD ,matched-token))))
          ))]

    [(regexp-match-positions RE_NUMBERS input)
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)])
            (tokenizer remaining-input (append tokens `((NUMBER ,(string->number matched-token)))))
          ))]

    [(regexp-match-positions RE_PAREN_OPEN input)
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)]
                 )
            (tokenizer remaining-input (append tokens `((PAREN_OPEN))))
          ))]

    [(regexp-match-positions RE_PAREN_CLOSE input)
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)]
                 )
            (tokenizer remaining-input (append tokens `((PAREN_CLOSE))))
          ))]

    [(regexp-match-positions RE_COMMA input)
     => (λ (matched-tokens)
          (let* ([matched (car matched-tokens)]
                 [matched-token-start (car matched)]
                 [matched-token-end   (cdr matched)]
                 [matched-token       (substring input matched-token-start matched-token-end)]
                 [remaining-input     (substring input matched-token-end)]
                 )
            (tokenizer remaining-input (append tokens `((COMMA))))
          ))]

    [else ; chews through `input` a single char at a time
      (tokenizer (str-tail input) (append tokens `((UNKNOWN ,(str-head input)))))]

  )
)

(define (lexer tokens
               [lexed-tokens '()]
               #:ignore-dont-sections? [ignore-dont-sections? #false]
               #:currently-ignoring? [currently-ignoring? #false])
  (if (eq? '() tokens)
    (reverse lexed-tokens) ; reverse cause we've built it using cons and so it's backwards from the input tokens
  ; else
    (let ([next-token (car tokens)]
          [tokens-tail (cdr tokens)])
      (match (list next-token ignore-dont-sections? currently-ignoring?)
        [(list '(KEYWORD "don't") #true _) ; TODO add check for open-paren-close-paren
         (if (and ((length tokens-tail) . >= . 2)
                  (eq? (take tokens-tail 2) '((PAREN_OPEN) (PAREN_CLOSE))))
           (lexer tokens-tail
                  (cons '(KEYWORD "don't" enabled) (drop lexed-tokens 2))
                  #:ignore-dont-sections? ignore-dont-sections?
                  #:currently-ignoring? #true)
         ; else
           (lexer tokens-tail
                  (cons next-token lexed-tokens)
                  #:ignore-dont-sections? ignore-dont-sections?
                  #:currently-ignoring? #true)
         )
        ]

        [(list '(KEYWORD "do") #true _) ; TODO add check for open-paren-close-paren
         (if (and ((length tokens-tail) . >= . 2)
                  (eq? (take tokens-tail 2) '((PAREN_OPEN) (PAREN_CLOSE))))

           (lexer tokens-tail
                  (cons '(KEYWORD "do" enabled) (drop lexed-tokens 2))
                  #:ignore-dont-sections? ignore-dont-sections?
                  #:currently-ignoring? #false)

         ; else
           (lexer tokens-tail
                  (cons next-token lexed-tokens)
                  #:ignore-dont-sections? ignore-dont-sections?
                  #:currently-ignoring? #false)
         )
        ]

        [(list '(KEYWORD "mul") _ #false)
         (if ((length tokens-tail) . >= . 5)
           (match (take tokens-tail 5)
             [(list (list 'PAREN_OPEN)
                    (list 'NUMBER a)
                    (list 'COMMA)
                    (list 'NUMBER b)
                    (list 'PAREN_CLOSE))
              (lexer (drop tokens-tail 5)
                     (cons (append next-token (list a b)) lexed-tokens)
                     #:ignore-dont-sections? ignore-dont-sections?
                     #:currently-ignoring? currently-ignoring?
              )
             ]
             [_ (lexer tokens-tail
                       (cons '(KEYWORD_INVALID "mul") lexed-tokens)
                       #:ignore-dont-sections? ignore-dont-sections?
                       #:currently-ignoring? currently-ignoring?)
             ])
         ; else
           (lexer tokens-tail
                             (cons '(KEYWORD_INVALID "mul") lexed-tokens)
                             #:ignore-dont-sections? ignore-dont-sections?
                             #:currently-ignoring? currently-ignoring?
                             ))]
        [_ (lexer tokens-tail
                  (cons next-token lexed-tokens)
                  #:ignore-dont-sections? ignore-dont-sections?
                  #:currently-ignoring? currently-ignoring?
                  )]))))

(define (str-head str) (string-ref str 0))
(define (str-tail str) (substring str 1))

(define (parse-multiply lexed-tokens)
  (for/fold ([sum 0]
             [allow-computation? #true] ; this value will be tweaked by part 2
             #:result sum
            )
            ([l-token lexed-tokens])
    (match l-token
      [(list 'KEYWORD "mul" a b)  (values (+ sum (* a b)) allow-computation?)]
      [_                          (values sum allow-computation?)]
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

    (test-suite "tokenizer"
      (test-case "simple input"
        (check-equal? (tokenizer "foo")      '((UNKNOWN #\f) (UNKNOWN #\o) (UNKNOWN #\o)))
        (check-equal? (tokenizer "1 23 456") '((NUMBER 1) (UNKNOWN #\space) (NUMBER 23) (UNKNOWN #\space) (NUMBER 456)))
      )
      (test-case "punctuation"
        (check-equal? (tokenizer "'.(]") '((UNKNOWN #\') (UNKNOWN #\.) (PAREN_OPEN) (UNKNOWN #\])))
        (check-equal? (tokenizer "!@#)") '((UNKNOWN #\!) (UNKNOWN #\@) (UNKNOWN #\#) (PAREN_CLOSE)))
        (check-equal? (tokenizer "$,,%") '((UNKNOWN #\$) (COMMA) (COMMA) (UNKNOWN #\%)))
      )
      (test-case "keywords"
        (check-equal? (tokenizer "mul")         '((KEYWORD "mul")))
        (check-equal? (tokenizer "muldo")       '((KEYWORD "mul") (KEYWORD "do")))
        (check-equal? (tokenizer "don'tdo_mul") '((KEYWORD "don't") (KEYWORD "do") (UNKNOWN #\_) (KEYWORD "mul")))
      )
      (test-case "sample input"
        (let ([tokenized-sample-input (tokenizer (car (sample-input)))])
          (check-equal? (car tokenized-sample-input) '(UNKNOWN #\x))
          (check-equal? (~> tokenized-sample-input cdr (take 6))       '((KEYWORD "mul") (PAREN_OPEN) (NUMBER 2) (COMMA) (NUMBER 4) (PAREN_CLOSE)))
          (check-equal? (~> tokenized-sample-input cdr (take-right 7)) '((KEYWORD "mul") (PAREN_OPEN) (NUMBER 8) (COMMA) (NUMBER 5) (PAREN_CLOSE) (PAREN_CLOSE)))
        )
      )
    )

    (test-suite "lexer"
      (test-case "happy path"
        (check-equal? (lexer '((KEYWORD "mul") (PAREN_OPEN) (NUMBER 3) (COMMA) (NUMBER 4) (PAREN_CLOSE)))
                      '((KEYWORD "mul" 3 4)))
        (check-equal? (lexer '((COMMA) (KEYWORD "mul") (PAREN_OPEN) (NUMBER 3) (COMMA) (NUMBER 4) (PAREN_CLOSE)))
                      '((COMMA) (KEYWORD "mul" 3 4)))
        (check-equal? (lexer '((KEYWORD "don't") (KEYWORD "mul") (PAREN_OPEN) (NUMBER 3) (COMMA) (NUMBER 4) (PAREN_CLOSE) (KEYWORD "mul") (PAREN_OPEN) (NUMBER 10) (COMMA) (NUMBER 20) (PAREN_CLOSE)))
                      '((KEYWORD "don't") (KEYWORD "mul" 3 4) (KEYWORD "mul" 10 20)))
      )
      (test-case "invalid sequence after mul"
        (check-equal? (lexer '((KEYWORD "mul") (PAREN_OPEN)))
                      '((KEYWORD_INVALID "mul") (PAREN_OPEN)))
        (check-equal? (lexer '((KEYWORD "mul") (COMMA)))
                      '((KEYWORD_INVALID "mul") (COMMA)))
        (check-equal? (lexer '((KEYWORD "mul") (PAREN_OPEN) (COMMA) (PAREN_CLOSE)))
                      '((KEYWORD_INVALID "mul") (PAREN_OPEN) (COMMA) (PAREN_CLOSE)))
        (check-equal? (lexer '((KEYWORD "mul") (PAREN_OPEN) (NUMBER 3) (NUMBER 4) (PAREN_CLOSE)))
                      '((KEYWORD_INVALID "mul") (PAREN_OPEN) (NUMBER 3) (NUMBER 4) (PAREN_CLOSE)))
      )
    )
    (test-suite "parse-multiply"
      (test-case "multiplies all mul(#,#) calls and adds em together"
        (check-equal? (parse-multiply '((UNKNOWN 'foo))) 0)
        (check-equal? (parse-multiply '((KEYWORD "mul" 2 3))) 6)
        (check-equal? (parse-multiply '((KEYWORD "mul" 4 5) (KEYWORD "don't") (KEYWORD "mul" 10 10))) 120)
      )
    )

    (test-suite "part 1"
      (test-case "sample input"
        (check-equal? (solve-part1 (sample-input)) 161))
      (test-case "full input"
        (check-equal? (solve-part1 (full-input))   175015740)))

    (test-suite "part 2"
      (test-case "sample input"
        (check-equal?
          (solve-part2 '("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"))
          48))
      (test-case "full input"
        (check-equal?
          (solve-part2 (full-input))
          112272912)
      )
    )
  )
)
