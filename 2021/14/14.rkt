#lang racket/base

(define convert-to-symbols-r ; returns list of symbols in reverse order from input string
  (lambda (str list-of-symbols)
    (if (eq? 0 (string-length str))
      list-of-symbols
      (convert-to-symbols-r (substring str 1)
                            (cons (string->symbol (substring str 0 1))
                                  list-of-symbols)))))

(define build-mapping-r ; returns a hash
  (lambda (hsh input)
    (let ([line (read-line (input))])
      (if (eof-object? line)
        hsh
        (let* ([letter1 (string->symbol (substring line 0 1))]
               [letter2 (string->symbol (substring line 1 2))]
               [infix (string->symbol (substring line 6 7))])
          (build-mapping-r
            (hash-set hsh
                      `(,letter2 ,letter1) ; this is "backwards" cause template-lists are backwards
                      infix)
            input))))))
(define look-up ; returns infix for given pair if found in given mapping, else `#g`
  (lambda (pair hash)
    ; (printf "look-up... pair: ~a~n" pair)
    (hash-ref hash pair #f)
    ))

(define step-r ; returns template-list; recursive
  (lambda (template hash result)
    ; (printf "template ~a~n" template)
    ; (printf "hash ~a~n" hash)
    ; (printf "result ~a~n" result)
    (if (eq? 1 (length template))
      (cons (car template) result)
      (let* ([first (car template)]
             [second (car (cdr template))]
             [pair `(,second ,first)] ; backwards cause the template list is backwards
             [infix (look-up pair hash)])
        ; (printf "step...  ~a  ~n" pair)
        (if (eq? infix #f)
          (step-r (cdr template) hash (cons first result))
          (step-r (cdr template) hash (cons first (cons infix result))))))))
(define step-multiple-r ; returns template-list after running `n` steps; recursive
  (lambda (n template hash)
    (printf "~a\t~a~n" n template)
    ; TODO refactor to special-case for n = 1 : calculate letter occurences as pass through template is done (thereby avoiding iteration over the last/largest value)
    (if (eq? n 0)
      template
      (step-multiple-r (- n 1)
                       (step-r (reverse template) hash '())
                       hash))))

(define count-letters-r
  (lambda (template hashtable)
    ; (printf "counting.. ~a~n" hashtable)
    (if (eq? '() template)
      hashtable
      (begin
        (hash-update! hashtable (car template) add1 0)
        (count-letters-r (cdr template)
                         hashtable)))))
(define find-most-and-least-common
  (lambda (letter-occurrences)
    (foldl
      (lambda (pair data)
        (let ([letter (car pair)]
              [count (cdr pair)])
          (if (eq? '() data) ; on the first iteration; letter & count are both most and least common
            ; TODO rewrite using ` and ,
            (quasiquote (((unquote count) . (unquote letter)) . ((unquote count) . (unquote letter))))
            (let ([most-common-letter (car data)]
                  [least-common-letter (cdr data)])
              (cond
                ((> count (car most-common-letter))
                 (quasiquote (((unquote count) . (unquote letter)) . (unquote least-common-letter))))
                ((< count (car least-common-letter))
                 (quasiquote ((unquote most-common-letter) . ((unquote count) . (unquote letter)))))
                ('else data))))))
      '()
      (hash->list letter-occurrences))))
(define print-stats
  (lambda (template-list)
    (printf "Polymer length: ~a~n" (length template-list))
    (let* ([letter-occurrences (count-letters-r template-list (make-hash))]
           [common (find-most-and-least-common letter-occurrences)]
           [most-common (car common)]
           [least-common (cdr common)])
      (printf "Most Common Letter: ~a (~a)~n" (cdr most-common) (car most-common))
      (printf "Least Common Letter: ~a (~a)~n" (cdr least-common) (car least-common))
      (printf "\t(difference: ~a)~n" (- (car most-common) (car least-common)))
      )))

(let* ([template (convert-to-symbols-r (read-line (current-input-port)) '())] ; first line is automaton starting input
       [_        (read-line (current-input-port))] ; second line is blank
       [hash     (build-mapping-r (hash) current-input-port)]) ; rest of input are rules to create a mapping
  (printf "mapping ~a~n" hash)
  (printf "template ~a~n" template)
  (time
    (print-stats (time
                   (step-multiple-r 2 template hash)))))
; multi-minute results for more than 17 iterations...
