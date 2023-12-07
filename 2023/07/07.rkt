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
        ["A" 14])
      )))

; to determine the relative strength of a Hand... first sort the Hand's Cards??

#| (define (process-and-sort unsorted-hand-string)
  (let* [[unsorted-hand (filter (lambda (card) (not (equal? "" card)))
                                (string-split unsorted-hand-string ""))]
         [unsorted-hand-converted (map convert-card unsorted-hand)]
         [sorted-hand (sort unsorted-hand-converted >)]]
    sorted-hand)) |#

; nope don't need to sort... but do need to identify how many of each value in the hand...

(define (process-hand unsorted-hand-string)
  (map convert-card (filter (lambda (card) (not (equal? "" card)))
                            (string-split unsorted-hand-string ""))))

#| (define (hand-to-type-num hand)
     (match hand
       [(list a a a a a) 6];5-of-a-kind]
       [(list a a a a b) 5];4-of-a-kind]
       [(list a a a b b) 4];full-house]
       [(list a a a b c) 3];3-of-a-kind]
       [(list a a b b c) 2];2-pair]
       [(list a a b c d) 1];1-pair]
       [(list a b c d e) 0];high-card]
       [_ 'error]
       )) |#

; do it manually: count how many there are of each value...
(define (hand-to-type-num hand)
  (let* [[first-card (car hand)]
         [remaining-cards-partitioned
           (partition (lambda (card)
                        (equal? card first-card)) (cdr hand))]
         ]
    (printf ">>> ~a : \n" hand)
    (printf ">>> ~a : \n" (car hand))
    (printf ">>> ~a : \n" (cdr hand))
    ;; (printf "… ~a \n" remaining-cards-partitioned)
    )
  0)
(define (compare-hands hand-a hand-b)
  (let* [[hand-type-a (hand-to-type-num hand-a)]
         [hand-type-b (hand-to-type-num hand-b)]
         [type-comparison (< hand-type-a hand-type-b)]]
    (if (= hand-type-a hand-type-b)
      (let []
        (printf "ruh roh they're equal...\n"))
      type-comparison)))

(let* [[split-input (string-split input-sample)]
       [hands-and-bids (pair-em-up split-input '())]
       ;; [processed-hands-and-bids (map (lambda (hand-and-bid) (list (process-and-sort (car hand-and-bid))
       ;;                                                             (car (cdr hand-and-bid))))
       ;;                                hands-and-bids)]
       [processed-hands-and-bids (map (lambda (hand-and-bid) (list (process-hand (car hand-and-bid))
                                                                   (car (cdr hand-and-bid))))
                                      hands-and-bids)]
       [sorted-hands-and-bids (sort processed-hands-and-bids
                                    (lambda (a b)
                                      (let [[hand-a (car a)] [bid-a (car (cdr a))]
                                            [hand-b (car b)] [bid-b (car (cdr b))]]
                                        ;; (printf "comparing bids $~s < $~s ?? ~a \n" bid-a bid-b (< bid-a bid-b))
                                        ;; (< bid-a bid-b)
                                        (printf "comparing hands ~a < ~a ?? \n" hand-a hand-b)
                                        (printf "\t\t?? ~a \n" (compare-hands hand-a hand-b))
                                        ;; (printf "hand-a......... ~a \n" hand-a)
                                        (compare-hands hand-a hand-b)
                                        )))]
       ]
  ;; (printf "split-input: ~s \n" split-input)
  (printf "hands-and-bids: ~s \n" hands-and-bids)
  (printf "processed : ~a \n" processed-hands-and-bids)
  ;; (printf "sorted... : ~a \n" sorted-hands-and-bids)
  ; once sorted, each bid is multiplied by the rank... (length - (index + 1))
  )

(printf "\ndone\n")
