#lang racket

(require "utils.rkt")


(define (parse-garden-info line)
  (map string->number (string-split line " ")))

(define (score flower)
  (if (char=? flower #\W) 1 0))

(define (main)
  (match-define (list width months) (parse-garden-info (read-from-stdin)))

  (string-join
   (map (lambda (n) (if (= 1 (modulo n 2)) "F" "B"))
        (for/fold ([acc (make-list width 0)])
                  ([i (in-range months)])
          (map + acc
               (map score (string->list (read-from-stdin))))))
   ""))

(display (main))
