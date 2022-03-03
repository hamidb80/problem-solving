#lang racket

(require "utils.rkt")

(define (octet-distributions size)
  (for*/list ([n1 (in-range 1 4)]
              [n2 (in-range 1 4)]
              [n3 (in-range 1 4)]
              [n4 (in-range 1 4)]
              #:when (= (+ n1 n2 n3 n4) size))

    (list n1 n2 n3 n4)))


(define (octet? o)
  (and
   (<= 0 (string->number o) 255)
   (or (string=? o "0")
       (not (char=? (string-ref o 0) #\0)))))

(define (ip? maybe-ip)
  (for/and ([o maybe-ip]) (octet? o)))


(define (build-ip ambiguous-ip distribution)
  (for/foldr ([end-bound (string-length ambiguous-ip)]
              [ip empty]
              #:result ip)

    ([d distribution])

    (let ([start-index (- end-bound d)])
      (values
       start-index
       (cons (substring ambiguous-ip start-index end-bound) ip)))))

(define (ip->string ip)
  (string-join ip "."))


(define (possible-ips ambiguous-ip)
  (filter-map
   (lambda (d)
     (let ([ip (build-ip ambiguous-ip d)])
       (and (ip? ip) ip)))

   (octet-distributions (string-length ambiguous-ip))))

; --------------------------------------

(define (main ambiguous-ip)
  (for ([ip (possible-ips ambiguous-ip)])
    (displayln (ip->string ip))))

(main (read-from-stdin))