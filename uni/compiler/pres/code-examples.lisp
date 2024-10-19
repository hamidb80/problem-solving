; sbcl --script code.lisp
; use --load for interactive modes

;; ----- tree like structure of s-expression -----

(when nil 
  (-
    (* 
      b 
      b) 
    (*
      (*
          4 
          a) 
      c))

  (- (* b b) (* (* 4 a) c))
  (- (* b b) (* 4 a c))
)

;; ----- function def -----

(defun function-name (arg1 arg2 ...) body)

(defun delta (a b c) 
  (- (* b b) (* 4 a c)))

(defun double (n) 
  (* 2 n))

;; ----- var def -----

(defvar name value)
(defvar result (delta 1 5 6))

;; ----- if clause -----

(if condition when-true when-false)

(if 
  (< result 0)
  (error "imaginary roots")
  (format t "result is ~s" result))

;; ----- progn clause -----

(progn operation-1 operation-2 ...)

(progn
  (defvar name "Ali Baghaee")
  (format t "Salam ~s" name)
  (error "cannot live anymore ×_×"))

:; ----- other -----

(describe 'delta)
