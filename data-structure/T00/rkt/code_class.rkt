#lang racket


(define number-ranges #(
                       (0 . 9)
                       (10 . 99)
                       (100 . 999)
                       (1000 . 9999)))

(define (range-len r)
  (add1 (- (cdr r) (car r))))

(define (range-ref r index)
  (+ index (car r)))

(define (find-digit-impl index)
  (for/fold ([i index]
             [len 1]
             #:result (cons i len))

            ([nr number-ranges]
             #:break (<= i (* len (range-len nr))))

    (values (- i (* len (range-len nr))) (add1 len))))

(define (find-digit index)
  (match-let ([(cons relative-index len) (find-digit-impl index)])
    (let ([number-index (floor (/ relative-index len))]
          [digit-index (modulo relative-index len)])

      (string-ref (number->string (range-ref
                                   (vector-ref number-ranges (sub1 len))
                                   number-index))
                  digit-index)
      )
    ))


;  run -----------------------------

(for ([n '(2345 920 600 100 29 11 9)])
  (displayln (find-digit n)))
