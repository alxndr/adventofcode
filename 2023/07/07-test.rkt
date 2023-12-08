#lang racket/base

(require "07.rkt"
         rackunit)
; error? "collection not found for module path: rackunit collection: "rackunit" in collection directories"
; ...run the below in CLI:
; $ raco pkg install rackunit

;; (run-test ; "Unlike a check or test case, a test suite is not immediately run"
;;   (test-suite
;;     "2023 Day 7"
;;     #:before (λ () (display "\n⚖ ⚖ ⚖ tests starting...\n"))
;;     #:after  (λ () (display "\n⚖ ⚖ ⚖ tests ending!\n"))

    (test-case
      "check assumptions..."
      (check-equal? (+ 1 1) 2
                    "tap tap is this thing on..."))

    (test-case
      "sample input is 5905"
      (check-equal? (answer-sample)
                    5905))

    (check-true
      (< 253552043
         (answer-full))
      "full input is less than 253552043")
    ;; ))
