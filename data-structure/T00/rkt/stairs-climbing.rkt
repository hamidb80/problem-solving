#lang racket

(require "utils.rkt")


(define (calc-steps-impl n cache)
  (cond
    [(<= n 0) 0]
    [(hash-ref cache n #f)]
    [else (let ([v (for/sum ([s '(1 2 5)])
                     (calc-steps-impl (- n s) cache))])
            (hash-set! cache n v)
            v)]))

(define (calc-steps n)
  (calc-steps-impl n (make-hash '((1 . 1)
                                  (2 . 2)
                                  (5 . 9)))))

; -----------------------------

(displayln (calc-steps (string->number (read-from-stdin))))