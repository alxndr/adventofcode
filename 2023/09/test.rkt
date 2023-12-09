#lang racket/base

(require "09.rkt"
         "input.rkt"
         rackunit
         rackunit/text-ui)

(run-tests

  (test-suite "2023 day 9"

    (test-suite "find-the-gaps"

      (test-case "decreasing"
        (check-equal? '(-1 -2 -3 -4)
          (find-the-gaps '(10 9 7 4 0))))

      (test-case "increasing"
        (check-equal? '(1 1 1)
          (find-the-gaps '(0 1 2 3))))

      (test-case "increasing more"
        (check-equal? '(1 2 4)
          (find-the-gaps '(1 2 4 8))))

    )

    (test-suite "steps-til-zero-deriv"

      (test-case "already all zeroes"
        (check-equal? 0
         (steps-til-zero-deriv '(0 0 0))))

      (test-case "steady but not yet zeroes: one step"
        (check-equal? 1
         (steps-til-zero-deriv '(999 999 999))))

      (test-case "nonzero, increasing: two steps"
        (check-equal? 2
         (steps-til-zero-deriv '(11 22 33))))

      (test-case "nonzero, decreasing: three steps"
        (check-equal? 3
         (steps-til-zero-deriv '(1000 980 940 880 800 700))))

    )

    (test-suite "predict-next-val"

      (test-case "all zeroes"
        (check-equal?
          (predict-next-val '(0 0 0 0 0))
          0))
      (test-case "all ones"
        (check-equal?
          (predict-next-val '(1 1 1 1 1))
          1))
      (test-case "increasing by one"
        (check-equal?
          (predict-next-val '(1 2 3 4 5))
          6))
      ;; (test-case "increasing from zero"
      ;;   (check-equal?
      ;;     (predict-next-val '(0 1 2 3 4))
      ;;     5))

      ;; (test-case "from the example"
      ;;   (check-equal?
      ;;     (predict-next-val '(0 3 6 9 12 15))
      ;;     18))
    )


    )

  )
