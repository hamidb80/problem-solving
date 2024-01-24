(defun ->list (smth) 
  (coerce smth 'list))

(defun ->string (list)
  (coerce list 'string))

(defun same-but-different-case (u1 u2)
  (and
   (char-equal u1 u2) 
   (not (char= u1 u2))))

(defun remove-multi (list str)
  (if list
      (remove-multi (cdr list) (remove (car list) str))
      str))

(defun remove-both-cases (ch str)
  (remove-multi
   (list (char-downcase ch) (char-upcase ch))
   str))

;; (trace reduce-polymer-impl)
;; (untrace reduce-polymer-impl)

(defun reduce-polymer-impl (in out)
  (if out
      (if (and in (same-but-different-case (car in) (car out)))
          (reduce-polymer-impl (cdr in) (cdr out))
          (reduce-polymer-impl (cons (car out) in) (cdr out)))
      in))

(defun reduce-polymer (polymer)
  (reverse (->string
    (reduce-polymer-impl '() (->list polymer)))))

(defun part-1 (polymer)
  (length (reduce-polymer polymer)))


(defun part-2 (polymer)
  (loop for ch in (->list "abcdefghijklmnopqrstuvwxyz")
        for modified-polymer = (remove-both-cases ch polymer)
        for after-reaction-len = (length (reduce-polymer modified-polymer))
        minimizing after-reaction-len into min-len
        finally (return min-len)))


;;; test
(loop for polymer in '("abcCBdA" "dabAcCaCBAcCcaDA") do
      (print (reduce-polymer polymer)))

(print (part-2 "dabAcCaCBAcCcaDA"))


;;; main
(let ((input (uiop:stripln
              (uiop:read-file-string "./input.txt"))))
  (print (length input))
  (print (part-1 input)) ;; 11894
  (print (part-2 input)) ;;  5310
  )
