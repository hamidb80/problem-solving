#lang racket

(require "utils.rkt")

(define (calc-diameter n upper-bound)
  (let ([d (- (* n 2) 1)])
    (if (< d upper-bound) d
        (- (* 2 upper-bound) d))))

(define (print-dual-diomand diameter)
  (for ([n (in-inclusive-range 1 diameter)])
    (let* ([repeat (calc-diameter n diameter)]
           [row (~.a (make-string repeat #\*) #:align 'center #:width diameter)])

      (printf "~a~a\n" row row))))


(print-dual-diomand (string->number (read-from-stdin)))