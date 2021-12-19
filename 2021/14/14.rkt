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
    ; (printf "t:~a \t r:~a~n" template result)
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

(define find-and-add-one
  (lambda (letter occurrences)
    ))
(define occurrences-of-each-letter
  (lambda (str occurrences)
    (if (eq? 0 (string-length str))
      occurrences
      (occurrences-of-each-letter (substring str 1)
                                  (find-and-add-one (substring str 0 1) occurrences)))))

(define calc-stats
  (lambda (str)
    ; count occurrences of each letter in string
    (occurrences-of-each-letter str '())))

(let* (
       [template (read-line (current-input-port))] ; first line is automaton starting input
       [_ (read-line (current-input-port))]        ; second line is blank
       [mapping (input-to-mapping current-input-port)]
       )
  (printf "mapping ~a~n" mapping)
  (printf "template ~a~n" template)
  (let* ([after-ten-steps (step-n-times 10 template mapping)]
         [letter-stats (calc-stats after-ten-steps)])
    (printf "after ten steps... ~a~n" (string-length after-ten-steps))
    ))
