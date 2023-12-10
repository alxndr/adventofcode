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

    (test-suite "predict-next-val"

      (test-case "all zeroes"
        (check-equal?
          (predict-next-val '(0 0 0 0 0))
          0))

      (test-case "all ones"
        (check-equal?
          (predict-next-val '(1 1 1 1 1))
          1))

      (test-case "increasing from zero"
        (check-equal?
          (predict-next-val '(0 1 2 3 4))
          5))

      (test-case "from the example"
        (check-equal?
          (predict-next-val '(0 3 6 9 12 15))
          18))

      (test-case "from the sample input"
        (check-equal?
          (predict-next-val '(1 3 6 10 15 21))
          28))

      (test-case "from the sample input"
        (check-equal?
          (predict-next-val '(10  13  16  21  30  45))
          68))

    )

    (test-suite
      "sum-of-predictions"

      (test-case
        "start small"
        (check-equal?
          (sum-of-predictions "0 0 0\n1 1 1" predict-next-val)
          1))

      (test-case
        "sample input"
        (check-equal?
          (sum-of-predictions input-sample predict-next-val)
          114))

      (test-case
        "full input"
        (check-equal?
          (sum-of-predictions input-full predict-next-val)
          2101499000))
      )

    (test-suite
      "predict-previous-val"
      (check-equal?
        (predict-previous-val '(10  13  16  21  30  45))
        5)
      (check-equal?
        (sum-of-predictions input-full predict-previous-val)
        1089)
      )
    )

  )
