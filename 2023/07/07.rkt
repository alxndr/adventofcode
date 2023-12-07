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
  (map convert-card (filter (lambda (card) (not (equal? "" card)))
                            (string-split unsorted-hand-string ""))))

; do it manually: count how many there are of each value...

(define (r-how-many-of-each-card-in-a-hand hand accumulator) ; accumulator: list of tuples (CardInt CountOfCard)
  ;; (printf "\nr..... ~a /// ~a \n\n" hand accumulator)
  (if (or (empty? hand) (empty? (car hand)))
    accumulator
    (let*-values [[(first-card) (car hand)] ; `let`'s `-values` variant allowes multiple return values (for the use of `partition`)
                  [(remaining-hand) (cdr hand)]
                  [(matching-cards remaining-cards)
                   (partition (curry = first-card) ;; => `(lambda (card) (= first-card card))`
                              remaining-hand)]
                 [(matched-cards) (cons first-card matching-cards)]
                 ]
      (r-how-many-of-each-card-in-a-hand remaining-cards
                                         (cons (list first-card (length matched-cards))
                                               accumulator)))))

; now we can tell what type of hand we have...
; sort by count of each card, then pattern-match to determine type
(define (hand-to-type-num hand) ; ...then extract so that this is just the pattern-match??
  (let* [[first-card (car hand)]
         [cards-per-hand (r-how-many-of-each-card-in-a-hand hand '())]
         ; e.g.          ((14 1) (11 1) (12 3))
         ;               ((11 1)  (5 3) (10 1))
         ;               ( (7 2)  (6 1) (13 2))
         ;; [sorted-by-count (sort
         ;;                    (λ (card-and-count-a card-and-count-b) (> (car (cdr card-and-count-a))
         ;;                                                             (car (cdr card-and-count-b))))
         ;;                    cards-per-hand)]
         [sorted-by-count
           (reverse (sort cards-per-hand
                          (λ (aC&C bC&C)
                            (let [[aCard (car aC&C)]
                                  [aCount (car (cdr aC&C))]
                                  [bCard (car bC&C)]
                                  [bCount (car (cdr bC&C))]]
                              (if (= aCount bCount)
                                (< aCard bCard)
                                (< aCount bCount))))))
           ]
         ]
    ;; (printf ">>> ~a : \n" hand)
    ;; (printf "--> ~a \n" (car hand))
    ;; (printf "--> ~a \n" (cdr hand))
    ;; (printf "cards-per-hand\t  ~a \n" cards-per-hand)
    ;; (printf "sorted    >>>>>   ~a \n" sorted-by-count)
    (match sorted-by-count
      [(list (list _ 5)                                 ) 55] ; 5 of a kind
      [(list (list _ 4) (list _ 1)                      ) 44] ; 4 of a kind
      [(list (list _ 3) (list _ 2)                      )  4] ; full house
      [(list (list _ 3) (list _ 1) (list _ 1)           )  3] ; 3 of a kind
      [(list (list _ 2) (list _ 2) (list _ 1)           )  2] ; 2 pair
      [(list (list _ 2) (list _ 1) (list _ 1) (list _ 1))  1] ; 1 pair
      [ _                                                  0] ; ruh roh
      )))

(define (compare-hands hand-a hand-b)
  (printf "comparing hands ~a ...&... ~a ?? \n" hand-a hand-b)
  (let* [[hand-type-a (hand-to-type-num hand-a)]
         [hand-type-b (hand-to-type-num hand-b)]
         ]
    (if (= hand-type-a hand-type-b)
      (let []
        (printf "ruh roh they're equal...\n")
        )
      (< hand-type-a hand-type-b))))

(printf "\n\n\n")
(let* [[split-input (string-split input-sample)]
       [hands-and-bids (pair-em-up split-input '())]
       [processed-hands-and-bids (map (lambda (hand-and-bid) (list (process-hand (car hand-and-bid))
                                                                   (car (cdr hand-and-bid))))
                                      hands-and-bids)]
       [sorted-hands-and-bids (sort processed-hands-and-bids
                                    (lambda (a b)
                                      (let [[hand-a (car a)] [bid-a (car (cdr a))]
                                            [hand-b (car b)] [bid-b (car (cdr b))]]
                                        (compare-hands hand-a hand-b)
                                        )))]
       ]
  ;; (printf "split-input: ~s \n" split-input)
  (printf "hands-and-bids: ~s \n" hands-and-bids)
  ;; (printf "processed: ~a \n" processed-hands-and-bids)
  (printf "sorted??? ~a \n" sorted-hands-and-bids)
  ; once sorted, each bid is multiplied by the rank... (length - (index + 1))
  )

(printf "\ndone\n")
