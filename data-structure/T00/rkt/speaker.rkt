#lang racket

(require "utils.rkt")

(define (echo word)
  (for ([i (in-range (string-length word))])
    (printf
     "~a~a\n"
     (make-string i (string-ref word i))
     (substring word i))))


(echo (read-from-stdin))