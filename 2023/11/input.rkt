#lang racket

(provide sample-input
         sample-input-expanded
         full-input)

(define (sample-input)
  #<<_______
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
_______
)

(define (next-line-it file) ; h/t https://www.reddit.com/r/Racket/comments/8bosc3/comment/dx8lgj9/
  (let ((line (read-line file 'any)))
    (unless (eof-object? line)
      ;; (displayln line)
      (next-line-it file))))

(define (sample-input-expanded)
  ; run in shell ahead of time...
  ; $ ./preprocess.bash >sample-preprocessed.txt 2>sample-stats.ssv
  (list
    (file->lines "./sample-preprocessed.txt")
    (file->lines "./sample-stats.ssv")
    )
  )

(define (full-input)
  'TODO-read-from-file ; input.txt
)
