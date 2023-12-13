#lang racket

(provide split-input
         process-the-line
         process-input-lists
         format-universe
         solve-part1-preprocessed
         solve-part2-preprocessed)

(require "input.rkt"
         "../10/solution.rkt")

(define (split-input input)
  (string-split input "\n"))

(define INTERESTING '@)
(define (process-char char)
  ;; (printf "process-char ~s \n" char)
  (match char
    ["#" INTERESTING]
    ["." 1]
    [":" 2]
    [ _  0]))
(define (process-the-line_ list-of-strings processed interesting-input y x)
  ;; (printf "process-the-line_ @ (~a ~a)\n~s >>>> ~a   &  ~a \n\n" x y list-of-strings processed interesting-input)
  (if (empty? list-of-strings)
    (list
      (reverse processed)
      (reverse interesting-input))
    (let [[next-atom (process-char (car list-of-strings))]]
      ;; (printf " ~v interesting?? ~v (~v ~v)\n" next-atom (equal? INTERESTING next-atom) x y)
      (process-the-line_ (cdr list-of-strings)
                         (cons next-atom processed)
                         (if (equal? INTERESTING next-atom)
                                (cons (list x y) interesting-input)
                                interesting-input)
                         y
                         (+ 1 x)))))
(define (process-the-line input-string list-of-lists-of-atoms interesting-input y)
  ;; (printf "process-the-line: ~a ~a \n ~a \n" input-string interesting-input list-of-lists-of-atoms)
  (let*
    [[input-split (string-split input-string "")]
     [input-split-trimmed (reverse (list-tail (reverse (list-tail input-split 1)) 1))]
     [processing-results (process-the-line_ input-split-trimmed '() interesting-input y 0)]
     [processed-line (car processing-results)]
     [new-interesting-input (car (cdr processing-results))]
     ]
    ;; (printf "processed-line......... ~v \n" processed-line)
    ;; (printf "new-interesting-input ~v \n" new-interesting-input)
    (list
      (append list-of-lists-of-atoms (list processed-line))
      new-interesting-input)
  ))

(define (process-input-lists_ list-of-strings list-of-lists-of-atoms interesting-input y)
  (if (empty? list-of-strings)
    (list interesting-input list-of-lists-of-atoms)
    (let*
      [[next-string (car list-of-strings)]
       [processing-results (process-the-line next-string list-of-lists-of-atoms interesting-input y)]
       [processed-line (car processing-results)]
       [new-interesting-input (car (cdr processing-results))]
       ]
      ;; (printf "next-string ~v\n" next-string)
      ;; (printf "processed-line ~a\n" processed-line) ; TODO split this up n assign to new- etc...
      (process-input-lists_
        (cdr list-of-strings)
        processed-line
        new-interesting-input
        (+ 1 y))))
  )
(define (process-input-lists input-lists)
  (reverse (process-input-lists_ input-lists '() '() 0)))

(define (format-universe llatoms)
  (string-join
    (map (λ (latoms)
           (string-join
             (map (λ (atom) (match atom
                                   [1 " "]
                                   [2 "•"]
                                   ['@ "X"]
                                   [_ "?"]))
                  latoms)
             "")
           )
         llatoms)
    "\n"))

(define (something latoms)
  ;; (printf "gotta do sth w ~v \n" latoms)
  (if (findf (λ (atom) (not (equal? 1 atom))) latoms)
    latoms
    (build-list (length latoms) (λ (_) 2))))

(define (how-many-extras-in-dimension start end extras multiplier)
  (apply +
         (map (λ (extra)
                (if (or (and (start . < . extra) (extra . < . end))
                        (and (start . > . extra) (extra . > . end)))
                  (multiplier . - . 1)
                  0))
              extras)))

(define (calc-distance route stats multiplier)
  (define start (car route))
  (define end   (car (cdr route)))
  (define extra-cols (map string->number (cdr (car stats))))
  (define extra-rows (map string->number (cdr (car (cdr stats)))))
  (let [[startX (car start)]
        [startY (car (cdr start))]
        [endX (car end)]
        [endY (car (cdr end))]
        ]
    (+
      (abs (- startX endX))
      (how-many-extras-in-dimension startX endX extra-cols multiplier)
      (abs (- startY endY))
      (how-many-extras-in-dimension startY endY extra-rows multiplier)
      )
    ))

(define (solve-part1-preprocessed input-expanded)
  (define input-lists (car input-expanded))
  (define input-stats (map string-split (car (cdr input-expanded))))
  (define processing-results (process-input-lists input-lists))
  (define universe (car processing-results))
  (define interesting-spots (car (cdr processing-results)))
  ;; (printf "universe \n~a\n\n" (format-universe universe))
  ;; (printf "interesting-spots: ~a \n" (length interesting-spots)) ;(pretty-print interesting-spots)
  (define interesting-routes (combinations interesting-spots 2))
  ;; (printf "how many interesting routes?? ~a \n" (length interesting-routes))
  (apply + (map
     (λ (route-and-distance) (car (cdr route-and-distance)))
     (map (λ (interesting-route)
            (list interesting-route
                  (calc-distance interesting-route input-stats 2)))
          interesting-routes)
     ))
)

(define (solve-part2-preprocessed input-expanded multiplier)
  (define input-lists (car input-expanded))
  (define input-stats (map string-split (car (cdr input-expanded))))
  (define processing-results (process-input-lists input-lists))
  (define universe (car processing-results))
  (define interesting-spots (car (cdr processing-results)))
  (define interesting-routes (combinations interesting-spots 2))
  (apply + (map
     (λ (route-and-distance) (car (cdr route-and-distance)))
     (map (λ (interesting-route)
            (list interesting-route
                  (calc-distance interesting-route input-stats multiplier)))
          interesting-routes)
     ))
  )
