;;; helpers

(defun chars (str)
  (coerce str 'list))

(defun to-char-set (str)
  (remove-duplicates (chars str)))

(defun to-count-table (id)
  (mapcar
   (lambda (char) (count char id))
   (to-char-set id)))

(defun to-int (x)
  (if (null x) 0 1))

(defun repeat-check (repeats source)
  (mapcar
   (lambda (r) (to-int (member r source)))
   repeats))

(defun vec+ (a b)
  (mapcar '+ a b))

;;; main

(defun part-1-impl (acc box-id)
  (vec+ acc (repeat-check '(2 3) (to-count-table box-id))))

(defun part-1 (box-ids)
  (apply
   '*
   (reduce
    'part-1-impl
    box-ids
    :initial-value '(0 0))))

(defun diff (s1 s2)
  (apply '+ (mapcar
    (lambda (a b) (to-int (null (eql a b))))
    (chars s1)
    (chars s2))))

(defun filter (fn seq)
  (remove-if-not fn seq))

(defun find-one-diff (box-ids)
  (loop
    named outer
    for b1 in box-ids do
    (loop
      for b2 in box-ids do
      (if (eql 1 (diff b1 b2))
          (return-from outer
            (list b1 b2))))))

(defun part-2 (box-ids)
  (find-one-diff box-ids))

;;; test

(print (to-char-set "salam"))
(print (to-count-table "salam"))
(print (repeat-check '(2 3) (to-count-table "salam")))
(print (--- (list "salam" "hello" "wow")))
(print (part-1 (list "salam" "hello" "wow")))

(print "-----------------")
(print (diff "hey" "wow"))
(print (diff "hey" "hel"))
(print (diff "low" "wow"))

;; real

(let (
      (data-1 (uiop:read-file-lines "test.txt"))
      (data-2 (uiop:read-file-lines "input.txt")))
  ;; tests
  (print (part-1 data-1)) ;; 12
  (print (part-2 data-1)) ;; ("abcdef" "abcdee") 
  ;; main
  (print (part-1 data-2)) ;; 7134
  (print (part-2 data-2)) ;; ("kbqwtcvzhymhpoelrnaxydifyb" "kbqwtcvzhsmhpoelrnaxydifyb")
  )
