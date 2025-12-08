#lang racket

#; (require seq
         #; threading)

(provide sample-input
         full-input)

(define {extract-and-split filename}
  (let* { [lines (file->lines filename)]
          [banks (map (λ [line] (printf "line... ~a\n" line)
                                (line->batterybank line))
                      lines)]
          #; [trimmed (map (λ [bank] (printf "bank... ~a\n" bank)
                                  (trim #f bank))
                        banks)]}
    (printf "lines ~a \n\n" lines)
    (printf "banks ~a \n\n" banks)
    #; (printf "trimmed ~a \n\n" trimmed)
    #; banks
    'bruv))

(define {line->batterybank line}
  (print line)
  (printf "line to bank... ~a \n" line)
  (map string->number
       (string-split line "")))

(define (sample-input)
  (extract-and-split "sample.txt"))

(define (full-input)
  (extract-and-split "input.txt"))
