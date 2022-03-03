#lang racket

(provide read-from-stdin)

(define (read-from-stdin)
  (read-line (current-input-port) 'any))
