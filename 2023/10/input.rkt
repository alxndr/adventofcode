#lang racket

(provide sample-input
         sample-input-bare
         basic-square
         square-with-detritus
         full-input
         )
(define (sample-input)
  #<<_______
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
_______
)

(define (sample-input-bare)
  #<<_______
 ..F7.
 .FJ|.
 SJ.L7
 |F--J
 LJ...
_______
)

(define (basic-square) ; NOTE no starting S
  #<<_______
.....
.F-7.
.|.|.
.L-J.
.....
_______
)

(define (square-with-detritus)
  #<<_______
-L|F7
7S-7|
L|7||
-L-J|
L|-JF
_______
)

(define (full-input) ; 140-square ~~> 20k chars
  (file->string "input.txt"))

(define (sample-loop-input-bare)
  #<<_______
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
_______)

(define (sample-loop-input-detritus)
  #<<_______
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
_______
)

(define (sample-loop-input-detritus-more)
  #<<_______
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L

_______
)
