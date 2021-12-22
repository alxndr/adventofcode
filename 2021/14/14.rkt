#lang racket

(define build-mapping
  (lambda (mapping input)
    (let ([line (read-line (input))])
      (if (eof-object? line)
        mapping
        (let* ([split (string-split line " -> ")]
               [pair (car split)]
               [infix (car (cdr split))])
          ; (printf "add to mapping... '~a' produces a '~a'~n" pair infix)
          (build-mapping (cons (cons pair (cons infix '())) mapping) input))))))

(define input-to-mapping
  (lambda (input-port)
    (build-mapping '() input-port)))

(define look-up
  (lambda (pair mapping)
    (if (null? mapping)
      #f
      (let* ([first-mapping (car mapping)]
             [first-pair (car first-mapping)]
             [first-infix (car (cdr first-mapping))])
        (if (equal? pair first-pair)
          first-infix
          (look-up pair (cdr mapping)))))))

(define step-r
  (lambda (template mapping result)
    (if (eq? 1 (string-length template))
      ; at the last char of input string...
      (string-append result template) ; ...stick the last template char on to end of newly-generated string
      ; ...otherwise, first 2 chars of template are pair to look up in mapping
      (let* ([pair (substring template 0 2)]
             [infix (look-up pair mapping)])
        (if (eq? infix #f)
          ; if no infix, add only 1st char to result and recurse
          (step-r (substring template 1)
                  mapping
                  (string-append result (substring template 0 1)))
          ; if infix is found, add 1st char plus infix to result and recurse
          (step-r (substring template 1)
                  mapping
                  (string-append result (substring template 0 1) infix)))))))
(define step
  (lambda (template mapping)
    (step-r template mapping "")))
(define step-n-times
  (lambda (n template mapping)
    ; (printf "steppin ~a times... ~a~n" n template)
    (if (eq? n 0)
      template
      (step-n-times (- n 1) (step template mapping) mapping))))

(define count-letters
  (lambda (str hashtable)
    (if (eq? 0 (string-length str))
      hashtable
      (let ([first-letter (substring str 0 1)])
        (if (hash-has-key? hashtable first-letter)
          (count-letters (substring str 1)
                         (hash-set hashtable first-letter (+ 1 (hash-ref hashtable first-letter))))
          (count-letters (substring str 1)
                         (hash-set hashtable first-letter 1)))))))
(define find-most-and-least-common
  (lambda (letter-occurrences)
    (foldl (lambda (pair data)
             (let ([letter (car pair)]
                   [count (cdr pair)])
               (if (eq? '() data) ; on the first iteration; letter & count are both most and least common
                 (quasiquote (((unquote count) . (unquote letter))
                              .
                              ((unquote count) . (unquote letter))))
                 (let ([most-common-letter (car data)]
                       [least-common-letter (cdr data)])
                   (cond
                     ((> count (car most-common-letter))
                      (quasiquote (((unquote count) . (unquote letter))
                                   .
                                   (unquote least-common-letter))))
                     ((< count (car least-common-letter))
                      (quasiquote ((unquote most-common-letter)
                                   .
                                   ((unquote count) . (unquote letter)))))
                     ('else data))))))
           '()
           (hash->list letter-occurrences))))
(define print-stats
  (lambda (str)
    (let* ([letter-occurrences (count-letters str (hash))] ; TODO try using `make-hash` ?
           [common (find-most-and-least-common letter-occurrences)]
           [most-common (car common)]
           [least-common (cdr common)])
      (printf "Polymer length: ~a~n" (string-length str))
      (printf "Most Common Letter: ~a (~a)~n" (cdr most-common) (car most-common))
      (printf "Least Common Letter: ~a (~a)~n" (cdr least-common) (car least-common))
      (printf "(difference: ~a)~n" (- (car most-common) (car least-common)))
    )
))

(let* ([template (read-line (current-input-port))] ; first line is automaton starting input
       [_        (read-line (current-input-port))] ; second line is blank
       [mapping  (input-to-mapping current-input-port)]) ; rest of input are rules to create a mapping
  (printf "mapping ~a~n" mapping)
  (printf "template ~a~n" template)
  (let* ([after-ten-steps (step-n-times 10 template mapping)])
    (printf "after ten steps...~n")
    (print-stats after-ten-steps)
))
