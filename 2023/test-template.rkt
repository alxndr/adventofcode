#lang racket

(require "solution.rkt"
         "input.rkt"
         rackunit
         rackunit/text-ui)

(run-tests

  (test-suite
    "2023 day ##"

    (test-suite "split-input"
      (test-case "basic"  (check-equal? '0 '1))
      )

    )

  )
