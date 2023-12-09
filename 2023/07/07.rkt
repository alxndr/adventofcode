#lang racket

(require "input.rkt")

(provide answer-sample
         answer-full
         hand-to-type-num)

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
        ["J"  0] ; this is part 2; part 1 used ["J" 11]
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
  (if (or (empty? hand) (empty? (car hand)))
    accumulator
    (let*-values [[(first-card) (car hand)] ; `let`'s `-values` variant allowes multiple return values (for the use of `partition`)
                  [(remaining-hand) (cdr hand)]
                  [(matching-cards remaining-cards) (partition (curry = first-card) remaining-hand)]
                  [(matched-cards) (cons first-card matching-cards)]
                  ]
      (r-how-many-of-each-card-in-a-hand remaining-cards
                                         (cons (list first-card (length matched-cards))
                                               accumulator)))))

; now we can tell what type of hand we have...
; sort by count of each card, then pattern-match to determine type
(define (hand-to-type-num sorted-by-count) ; return val: bigger number is more winningest
  ;; (printf "sorted-by-count... ~a \n" sorted-by-count)
  (match sorted-by-count
    [(list (list _ 5)                ) 55] ; 5 of a kind
    [(list (list _ 4)            _...) 44] ; 4 of a kind
    [(list (list _ 3) (list _ 2) _...) 40] ; full house
    [(list (list _ 3)            _...) 33] ; 3 of a kind
    [(list (list _ 2) (list _ 2) _...) 22] ; 2 pair
    [(list (list _ 2)            _...) 11] ; 1 pair
    [(list (list _ 1)            _...)  1] ; high card
    [ _                                 0] ; ruh roh
    ))

(define (r-add-n-to-the-count-of-everything-in n non-joker-cards-with-count added)
  (if (empty? non-joker-cards-with-count)
    added
    (let* {
      [topmost-nonjoker-cardcountpair (car non-joker-cards-with-count)]
      [cardval (car topmost-nonjoker-cardcountpair)]
      [cardcount (car (cdr topmost-nonjoker-cardcountpair))]
      }
      (r-add-n-to-the-count-of-everything-in n
                                             (cdr non-joker-cards-with-count)
                                             (cons (list cardval (+ n cardcount))
                                                   added)))))

(define (hand-to-type hand)
  ; handling Joker (n=0):
  ; "T55J5, KTJJT, and QQQJA are now all four of a kind! T55J5 gets rank 3, QQQJA gets rank 4, and KTJJT gets rank 5"
  ; a 0 in the hand adds 1 to the count of every other card...
  ; ...the number of each card (that's not a Joker) is increased by the count of how many 0s there are
  ; ...edge case: hand of all Jokers, 5x0 => lowest-scored 5-of-a-kind
  (let*-values {
    [(cards-per-hand) (r-how-many-of-each-card-in-a-hand hand '())] ; note: unsorted...  e.g. ((14 1) (11 1) (12 3))
    [(hand-of-jokers hand-without-jokers) (partition (λ (card-count-pair) (= 0 (car card-count-pair))) cards-per-hand)]
    [(how-many-jokers) (if (empty? hand-of-jokers) 0 (car (cdr (car hand-of-jokers))))]
    [(cards-per-hand-after-jokers) (r-add-n-to-the-count-of-everything-in
                                     how-many-jokers
                                     hand-without-jokers '())]
    [(sorted-by-count) ; and by high card (first is strongest hand, last is weakest)
       (reverse (sort cards-per-hand-after-jokers
                    (λ (aC&C bC&C)
                      (let [[aCard (car aC&C)]
                            [aCount (car (cdr aC&C))]
                            [bCard (car bC&C)]
                            [bCount (car (cdr bC&C))]]
                        (if (= aCount bCount) ; TODO is this tiebreaking unnecessary / the comparison we want to do in `compare-hands`??
                          (< aCard bCard)
                          (< aCount bCount))))))]
    }
    ;; (printf "... how many jokers? ~s \n" how-many-jokers)
    ;; (printf "cards-per-hand-after-jokers\t  ~a \n" cards-per-hand-after-jokers)
    ;; (printf "sorted-by-count > ~a \n" sorted-by-count)
    ;; (printf "type?? \t ~v  \n" (hand-to-type-num sorted-by-count))
    (if (= 5 how-many-jokers) ; cheaty mcCheaterface
      (list (hand-to-type-num (list (list 0 5))))
      (cons (hand-to-type-num sorted-by-count)
            sorted-by-count)))
      )

#| (define (compare-hands hand-a hand-b) ; NOTE this is *Actual* poker ranking (i.e. order independent...)
  ;; (printf "\ncomparing hands ~a ...&... ~a ?? \n" hand-a hand-b)
  (let* [[a-ranked (hand-to-type hand-a)]
         [b-ranked (hand-to-type hand-b)]
         [a-ranked-type (car a-ranked)]
         [b-ranked-type (car b-ranked)]
         ]
    (if (= a-ranked-type b-ranked-type)
      (let* [[a-ranked-cards (cdr a-ranked)]
             [b-ranked-cards (cdr b-ranked)]
             [a-first-card-value (car (car a-ranked-cards))]
             [b-first-card-value (car (car b-ranked-cards))] ]
        (< a-first-card-value
           b-first-card-value))
      (< a-ranked-type b-ranked-type)))) |#

(define (camel-compare a b)
  (if (or (empty? a) (empty? b))
    #f ;??
    (if (equal? (car a) (car b))
      (camel-compare (cdr a) (cdr b))
      (< (car a) (car b)))))

(define (compare-camel-hands hand-a hand-b)
  ; "33332 and 2AAAA are both four of a kind hands, but 33332 is stronger because its first card is stronger. Similarly, 77888 and 77788 are both a full house, but 77888 is stronger because its third card is stronger (and both hands have the same first and second card)"
  ;; (printf "🐪 ~a ——— ~a \n" hand-a hand-b)
  (let* {
    [a-ranked (hand-to-type hand-a)]
    [b-ranked (hand-to-type hand-b)]
    [a-ranked-type (car a-ranked)]
    [b-ranked-type (car b-ranked)]
    }
    ;; (printf "🐪🐪🐪🐪 okay now A:~s <> B:~s .......... ( ~s )\n" a-ranked-type b-ranked-type (camel-compare hand-a hand-b))
    (if (= a-ranked-type b-ranked-type)
      (not (camel-compare hand-a hand-b))
      (not (< a-ranked-type b-ranked-type))))) ; TODO doublecheck the not...

(define (r-pretty-hand hand s)
  (if (= 0 (length hand))
    s
    (let {[letter-for-card (match (car hand)
                             [10 "T"]
                             [11 "J"]
                             [12 "Q"]
                             [13 "K"]
                             [14 "A"]
                             [0  "j"]
                             [_  (number->string (car hand))])]}
      (r-pretty-hand (cdr hand)
                     (string-append s letter-for-card)))))
(define (pretty-hand hand) (r-pretty-hand hand ""))

(define (r-fold-with-rank hands-and-bids rank sum)
  (if (empty? hands-and-bids)
    sum
    (let* {
      [hand-and-bid (car hands-and-bids)]
      [hand (pretty-hand (car hand-and-bid))]
      [bid (car (cdr hand-and-bid))]
      }
      ;; (printf "~a  $ ~a *~a#  =>  $ ~a\n"
      ;;         hand
      ;;         (~a bid  #:align 'right  #:min-width 3)
      ;;         (~a rank #:align 'center #:min-width 5)
      ;;         (~a (* bid rank) #:align 'center))
      (r-fold-with-rank (cdr hands-and-bids)
                        (+ rank 1)
                        (+ sum (* bid rank))))))

(define (process-input-hand-and-bids hands-and-bids)
  ; returns a list full of ((card card card card card) bid) ; TODO alter to include Type!!
  (map (λ (hand-and-bid)
         (let {[processed-hand (process-hand (car hand-and-bid))]}
           (list processed-hand
                 (car (cdr hand-and-bid))
                 (car (hand-to-type processed-hand)))))
       hands-and-bids))

(define (answer-with-input input)
  (let* [[split-input (string-split input)]
         [hands-and-bids (pair-em-up split-input '())] ; same order as input...?
         [processed-hands-and-bids (process-input-hand-and-bids hands-and-bids)] ; reverse order from input
         [sorted-hands-and-bids ; first element is winning hand; last element is ranked 1
           (sort processed-hands-and-bids
                 (λ (a b)
                   (let* {
                     [hand-a (car a)]
                    ;[bid-a  (car (cdr a))]
                     [hand-b (car b)]
                    ;[bid-b  (car (cdr b))]
                     [a-ranked (hand-to-type hand-a)]
                     [b-ranked (hand-to-type hand-b)]
                     [a-ranked-type (car a-ranked)]
                     [b-ranked-type (car b-ranked)]
                     }
                     (compare-camel-hands hand-a hand-b)
                     ;; (if (equal? a-ranked-type b-ranked-type) (compare-camel-hands hand-a hand-b) (not (< a-ranked-type b-ranked-type)))
                     )))]
         ]
    ;; (printf "\nsplit-input: ~s \n" split-input)
    ;; (printf "\nhands-and-bids: \n~s\n" hands-and-bids)
    ;; (printf "\nprocessed ") (pretty-print processed-hands-and-bids)
    ;; (printf "\nsorted... \n") (pretty-print sorted-hands-and-bids) ; TODO alter to show type as well...
    ; score for each hand: once sorted, each bid is multiplied by its rank... (length - (index + 1))
    ;; (printf "\ngotta sum up (~s things) now......\n" (length sorted-hands-and-bids))
    (r-fold-with-rank
      (reverse sorted-hands-and-bids)
      1
      0))
  )

(define (answer-sample)
  (answer-with-input input-sample))
; 5905 correct

(define (answer-full)
  (answer-with-input input-large))
; 253997357 too high
; 253552043 too high
