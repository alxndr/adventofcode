#lang racket

; usage: send input to STDIN

;; 1st col: opponent's throw, "A for Rock, B for Paper, and C for Scissors"
;; 2nd col: you play: "X for Rock, Y for Paper, and Z for Scissors"
;; "total score is the sum of your scores for each round"
;; round score: sum of...
;; ...your play "1 for Rock, 2 for Paper, and 3 for Scissors"
;; ...+ outcome "0 if you lost, 3 if the round was a draw, and 6 if you won"

;; observations:
;; ...max for round score is 9, min is 1

; want a mapping of A->Rock->1 etc... and X->Rock Y->Paper Z->Scissors
; ... can do that with pattern matching 🎉

(define
  process (lambda (line dataset)
            (let ([line-split (string-split line)])
              (printf ":~s :~s ~n" (car line-split) (car (cdr line-split)))
              dataset)))

(define
  loop (lambda (dataset) ; recurses until current-input-port is empty
         (let ([line (read-line (current-input-port))])
           (if (eof-object? line)
             dataset
             (loop (process line dataset))))))

(let* ([result (loop '())])
  (printf "result... ~s~n" result))
