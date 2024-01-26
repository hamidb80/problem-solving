;; Advent of Code 2018 day 8

(ql:quickload "cl-ppcre")


(defstruct node children metadata)

(defun sum (lst)
  (reduce '+ lst))

(defun extract-numbers (str)
  (mapcar
   'parse-integer
   (ppcre:all-matches-as-strings "\\d+" str)))

(defun parse-tree (numbers)
  (let ((n-children (car  numbers))
        (n-meta     (cadr numbers))
        (rest       (cddr numbers)))
   
    (values
     (make-node
      :children
      (loop repeat n-children
            collect (multiple-value-bind
                     (n r)
                     (parse-tree rest)
                      (progn
                        (setf rest r)
                        n)))
      :metadata
      (loop repeat n-meta
            collect (pop rest)))
     rest)))


(defun sum-meta (node)
  (+
   (sum (node-metadata node))
   (loop for n in (node-children node)
         summing (sum-meta n) into sum
         finally (return sum))))

(defun sum-meta-indexes (node)
  (let ((children (node-children node)))
    (if children
        (loop for m in (node-metadata node)
              with n-children = (length children)
              when (<= 0 m n-children)
              summing (sum-meta-indexes
                       (nth (- m 1) children))
              into sum
              finally (return sum))
        (sum (node-metadata node)))))

;; tun
(loop
  for str in (list
              '(2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2)   ;; test
              (extract-numbers
               (uiop:read-file-string "./input.txt"))) ;; real
  for tree = (parse-tree str)
  do (progn
       (print (sum-meta tree))         ;; part 1 = 41454
       (print (sum-meta-indexes tree)) ;; part 2 = 25752
       ))
