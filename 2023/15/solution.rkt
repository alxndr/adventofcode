#lang racket

(provide solve-part1
         solve-part2
         run-algorithm
         )

(require "input.rkt")

(define (churn-on-value baseVal n)
  (let* [[increased (+ baseVal n)]
         [multiplied (* increased 17)]
         [moduloed (modulo multiplied 256)]]
    ;; (printf "churning ~v & ~v into... ~v\n" baseVal n moduloed)
    moduloed))
(define (run-algorithm_ loc val)
  ;; To run the HASH algorithm on a string, start with a current value of 0.
  ;; Then, for each character in the string starting from the beginning:
  ;; • Determine the ASCII code for the current character of the string.
  ;; • Increase the current value by the ASCII code you just determined.
  ;; • Set the current value to itself multiplied by 17.
  ;; • Set the current value to the remainder of dividing itself by 256.
  (if (empty? loc)
    val
    (run-algorithm_ (cdr loc)
                    (churn-on-value val (char->integer (car loc))))))
(define (run-algorithm input-string)
  (run-algorithm_ (string->list input-string)
                  0))

(define (solve-part1 input)
  (apply + (map run-algorithm input)))

(define (get-list-from-boxnum boxnum H-boxnum-to-list)
  (hash-ref! H-boxnum-to-list
             boxnum
             '()))

(define (get-boxnum-from-label label H-label-to-boxnum)
  ; memoized...
  (hash-ref! H-label-to-boxnum
             label
             (λ () (run-algorithm label))))

(define (replace-lens_ label val l newl)
  (if (empty? l)
    (reverse newl)
    (let* [[existing-val (car l)]
           [existing-label (car existing-val)]
           [to-cons (if (equal? label existing-label) val existing-val)]]
      (replace-lens_ label
                     val
                     (cdr l)
                     (cons to-cons newl))
      )))
(define (replace-lens label lens contents)
 (replace-lens_ label lens contents '()))

(define (run-labeled-algorithm_ list-of-strings H-label-to-boxnum H-boxnum-to-list)
  (if (empty? list-of-strings)
    H-boxnum-to-list
    (let [[input-string (car list-of-strings)]]
      ;; (printf "\n\n\ninput:~a\n" input-string)
      (if (string-suffix? input-string "-")
        ; "If the operation character is a dash":
        (let* [[split-up     (string-split input-string "-")]
               [label        (car split-up)]
               [relevant-box (get-boxnum-from-label label H-label-to-boxnum)]
               [lens-list    (get-list-from-boxnum relevant-box H-boxnum-to-list)]
               ]
          ;; (printf "\ndash!!! … lens-list[~a]: \n " relevant-box) (pretty-print lens-list)
          ; "remove the lens with the given label … move any remaining lenses as far forward in the box as they can go without changing their order, filling any space made by removing the indicated lens")
          ; "If no lens in that box has the given label, nothing happens."
          (hash-set! H-boxnum-to-list
                     relevant-box
                     (remf (λ (lens-pair) ; NOTE using remf and not remf* — assumption is that there will only ever be a single matching member...
                             ;; (printf "does htis eq that?? ~a <> ~a ...\n" label (car lens-pair))
                             (equal? label (car lens-pair)))
                           lens-list)))
        ; "the operation character is an equals sign" ...
        (let* [[split-up (string-split input-string "=")]
               [label        (car split-up)]
               [focal-length (string->number (cadr split-up))] ; "...of the lens that needs to go into the relevant box"
               [lens         `(,label ,focal-length)]
               [relevant-box (get-boxnum-from-label label H-label-to-boxnum)]
               [lens-list    (get-list-from-boxnum relevant-box H-boxnum-to-list)]
               ]
          ;; (printf "lens:~a … lens-list[~a]: \n " lens relevant-box) (pretty-print lens-list)
          (if (empty? lens-list) ; TODO convert to a cond... (then move it into the let*??)
            ; "If there aren't any lenses in the box, the new lens goes all the way to the front of the box"
            (hash-set! H-boxnum-to-list relevant-box (list lens))
            ; there are lenses in the box...
            (if (member label lens-list (λ (lbl lens-pair) (equal? lbl (car lens-pair))))
              ; "If there is already a lens in the box with the same label, replace the old lens with the new lens (remove the old lens and put the new lens in its place, not moving any other lenses in the box)"
              (hash-set! H-boxnum-to-list relevant-box (replace-lens label lens lens-list))
              ; "If there is not already a lens in the box with the same label, add the lens to the box immediately behind any lenses already in the box"
              (hash-set! H-boxnum-to-list relevant-box (reverse (cons lens (reverse lens-list))))
              )
            )
        )
      )
    ;; (printf "okay what we got now/?\n")
    ;; (printf "label-to-box: ") (pretty-print H-label-to-boxnum)
    ;; (printf "things in boxes... \n ") (pretty-print H-boxnum-to-list)
    (run-labeled-algorithm_ (cdr list-of-strings) H-label-to-boxnum H-boxnum-to-list)
    )
  )
)

(define (calculate-value-for-lens lens-pair index boxnum)
  (*
    (+ 1 boxnum)
    (+ 1 index)
    (cadr lens-pair)))

(define (calculate-value-for-box lenses boxnum)
  (if (empty? lenses)
    0
    (apply +
           (map (λ (lens-pair index) (calculate-value-for-lens lens-pair index boxnum))
                lenses
                (build-list (length lenses) values)))))

(define (solve-part2 input)
  (define hash-of-lenses (run-labeled-algorithm_ input (make-hash) (make-hash)))
  ;; (printf "after all that here's what we gotta process... \n") (pretty-print hash-of-lenses)
  ; "add up the focusing power of all of the lenses"
  (apply +
         (map (λ (boxnum) (calculate-value-for-box (hash-ref hash-of-lenses boxnum) boxnum))
              (hash-keys hash-of-lenses))))
