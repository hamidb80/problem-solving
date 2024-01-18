;;; constants

(defparameter *INPUT_PATH* "./input.txt")

;;; helpers

(defun parse-input (path)
  (mapcar
   #'parse-integer
   (uiop:read-file-lines path)))


(defmacro letm (list-of-var-names fn-call body)
  ;; just a shorthand for multiple-value-bind
  (list 'multiple-value-bind
        list-of-var-names
        fn-call
        body))

(defun make-circular (items)
  ;; stolen from https://stackoverflow.com/questions/16678371/circular-list-in-common-lisp
  
  (setf (cdr (last items)) items)
  items)

(defun sum (values)
  (reduce #'+ values))

;;; main

(defun part-1 (signals)
  (sum signals))

(defun part-2-impl (seen freq signals)
  (let* (
        (freq^ (+ freq (pop signals)))
        (has? (member freq^ seen)))
    
    (if has?
        freq^
        (part-2-impl (cons freq^ seen) freq^ signals))))

(defun part-2 (signals)
  (part-2-impl '(0) 0 (make-circular signals)))

;;; run

(print (part-1 (parse-input *input_path*))) ;; 540
(print (part-2 (parse-input *input_path*))) ;; 73056

;;; tests
(print (part-2 (list +1 -1)))          ;; 0
(print (part-2 (list +3 +3 +4 -2 -4))) ;; 10
(print (part-2 (list -6 +3 +8 +5 -6))) ;; 5
(print (part-2 (list +7 +7 -2 -7 -4))) ;; 14
