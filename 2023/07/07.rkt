#lang racket

(printf "\nstarting...\n\n")

(define input-sample
  #<<HERE
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
HERE
)
;44555 6666

(define (pair-em-up split-input hands-and-bids)
  (if (or (empty? split-input) (empty? (car split-input)))
    hands-and-bids
    (let [[hand (car split-input)]
          [bid (car (cdr split-input))]
          [the-rest (cdr (cdr split-input))]]
      (pair-em-up the-rest
                  (cons `(,hand ,(string->number bid))
                        hands-and-bids)))))

(define (convert-card card-character)
  (let [[maybe-number (string->number card-character 10 'number-or-false)]]
    (if (not (equal? #f maybe-number))
      maybe-number
      (match card-character
        ["T" 10]
        ["J" 11]
        ["Q" 12]
        ["K" 13]
        ["A" 14]))))

; to determine the relative strength of a Hand... first sort the Hand's Cards??

; nope don't need to sort... but do need to identify how many of each value in the hand...

(define (process-hand unsorted-hand-string)
  (map convert-card (filter (λ (card) (not (equal? "" card)))
                            (string-split unsorted-hand-string ""))))

; do it manually: count how many there are of each value...

(define (r-how-many-of-each-card-in-a-hand hand accumulator) ; accumulator: list of tuples (CardInt CountOfCard)
  ;; (printf "\nr..... ~a /// ~a \n\n" hand accumulator)
  (if (or (empty? hand) (empty? (car hand)))
    accumulator
    (let*-values [[(first-card) (car hand)] ; `let`'s `-values` variant allowes multiple return values (for the use of `partition`)
                  [(remaining-hand) (cdr hand)]
                  [(matching-cards remaining-cards)
                   (partition (curry = first-card) ;; => `(λ (card) (= first-card card))`
                              remaining-hand)]
                 [(matched-cards) (cons first-card matching-cards)]
                 ]
      (r-how-many-of-each-card-in-a-hand remaining-cards
                                         (cons (list first-card (length matched-cards))
                                               accumulator)))))

; now we can tell what type of hand we have...
; sort by count of each card, then pattern-match to determine type
(define (hand-to-type-num sorted-by-count)
  (match sorted-by-count
    [(list (list _ 5)                                 ) 55] ; 5 of a kind
    [(list (list _ 4) (list _ 1)                      ) 44] ; 4 of a kind
    [(list (list _ 3) (list _ 2)                      )  4] ; full house
    [(list (list _ 3) (list _ 1) (list _ 1)           )  3] ; 3 of a kind
    [(list (list _ 2) (list _ 2) (list _ 1)           )  2] ; 2 pair
    [(list (list _ 2) (list _ 1) (list _ 1) (list _ 1))  1] ; 1 pair
    [ _                                                  0] ; ruh roh
    ))
; type number: bigger number is more winningest

(define (rank-hand hand)
  (let* [[cards-per-hand (r-how-many-of-each-card-in-a-hand hand '())] ; e.g. ((14 1) (11 1) (12 3))
         [sorted-by-count
           (reverse
             (sort cards-per-hand
                   (λ (aC&C bC&C)
                     (let [[aCard (car aC&C)]
                           [aCount (car (cdr aC&C))]
                           [bCard (car bC&C)]
                           [bCount (car (cdr bC&C))]]
                       (if (= aCount bCount) ; TODO is this tiebreaking aunneccessary / the comparison we want to do in `compare-hands`??
                         (< aCard bCard)
                         (< aCount bCount)))))
             )
           ]
         ]
    ;; (printf ">>> ~a : \n" hand)
    ;; (printf "cards-per-hand\t  ~a \n" cards-per-hand)
    ;; (printf "sorted    >>>>>   ~a \n" sorted-by-count)
    ;; (printf "type??  ~v  \n" (hand-to-type-num sorted-by-count))
    (cons (hand-to-type-num sorted-by-count)
          sorted-by-count)))

(define (compare-hands hand-a hand-b) ; NOTE this is *Actual* poker ranking (i.e. order independent...)
  ;; (printf "\ncomparing hands ~a ...&... ~a ?? \n" hand-a hand-b)
  (let* [[a-ranked (rank-hand hand-a)]
         [b-ranked (rank-hand hand-b)]
         [a-ranked-type (car a-ranked)]
         [b-ranked-type (car b-ranked)]
         ]
    (if (= a-ranked-type b-ranked-type)
      (let* [[a-ranked-cards (cdr a-ranked)]
             [b-ranked-cards (cdr b-ranked)]
             [a-first-card-value (car (car a-ranked-cards))]
             [b-first-card-value (car (car b-ranked-cards))] ]
        ;; (printf "uh oh they're same type... break the tie??\n :::: ~a \n :::: ~a \n\n" a-ranked-cards b-ranked-cards)
        (< a-first-card-value
           b-first-card-value))
      (< a-ranked-type b-ranked-type))))

(define (camel-compare a b)
  (if (or (empty? a) (empty? b))
    0
    (if (equal? (car a) (car b))
      (camel-compare (cdr a) (cdr b))
      (< (car a) (car b)))))

(define (compare-camel-hands hand-a hand-b)
  ; "33332 and 2AAAA are both four of a kind hands, but 33332 is stronger because its first card is stronger. Similarly, 77888 and 77788 are both a full house, but 77888 is stronger because its third card is stronger (and both hands have the same first and second card)"
  (let* {
    [a-ranked (rank-hand hand-a)]
    [b-ranked (rank-hand hand-b)]
    [a-ranked-type (car a-ranked)]
    [b-ranked-type (car b-ranked)]
    }
    ;; (printf "🐪 ~a ——— ~a \n" hand-a hand-b)
    (if (= a-ranked-type b-ranked-type)
      (camel-compare hand-a hand-b)
      (< a-ranked-type b-ranked-type))))

(printf "\n\n\n")
(let* [[split-input (string-split input-sample)]
       [hands-and-bids (pair-em-up split-input '())]
       [processed-hands-and-bids (map (λ (hand-and-bid)
                                        (list (process-hand (car hand-and-bid))
                                              (car (cdr hand-and-bid))))
                                      hands-and-bids)]
       [sorted-hands-and-bids (reverse (sort processed-hands-and-bids
                                     (λ (a b)
                                       (let [[hand-a (car a)]
                                             ;[bid-a  (car (cdr a))]
                                             [hand-b (car b)]
                                             ;[bid-b  (car (cdr b))]
                                             ]
                                         (compare-camel-hands hand-a hand-b)))))]
       ]
  ;; (printf "split-input: ~s \n" split-input)

  (printf "\nhands-and-bids: \n") (pretty-print hands-and-bids)

  (printf "\nsorted... \n") (pretty-print sorted-hands-and-bids)

  (printf "sum...")
  (pretty-print (foldl (λ (hand-and-bid sum)
                         (let* {
                           [hand (car hand-and-bid)]
                           [bid (car (cdr hand-and-bid))]
                           [rank 0] ; TODO
                           [payout (* rank bid)]
                           }
                           (printf "hand ~a \tbid $~s \tranked #~s \t= payout$~s \n" hand bid rank payout)
                           (+ sum payout)))
                       0
                       sorted-hands-and-bids))

  ; score for each hand:
  ; once sorted, each bid is multiplied by the rank... (length - (index + 1))
  )

(printf "\ndone\n")
