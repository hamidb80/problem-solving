#lang racket

(require "utils.rkt")


(define (char->number c)
  (- (char->integer c) 48))

(define (main word)
  (for ([c word])
    (printf "~c: ~a\n" c (make-string (char->number c) c))))

(main (read-from-stdin))