; sbcl --script code.lisp
; use --load for interactive modes


(defun delta (a b c)
  (- (* b b) (* 4 a c)))

; -----------------------------

(print (quote defun))
(print (quote delta))

(print 'defun)
(print 'delta)

(print (type-of (quote defun)))
(print (type-of (quote delta)))


(print               (list 1 2 3))
(print         (rest (list 1 2 3)))
(print (cons 0 (rest (list 1 2 3))))


(print
  (quote 
    (defun delta (a b c)
      (- (* b b) (* 4 a c)))))

(print 
  (first
    (quote 
      (defun delta (a b c)
        (- (* b b) (* 4 a c))))))

(print 
  (rest 
    (quote 
      (defun delta (a b c)
        (- (* b b) (* 4 a c))))))

(print 
  (cons 
    (quote salam)
    (rest
      (quote 
        (defun delta (a b c)
          (- (* b b) (* 4 a c)))))))
