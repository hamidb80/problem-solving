;; incomplete
;; Advent of Code 2018 day 10

(ql:quickload "cl-ppcre")

(defstruct vec x y) ;; vector
(defstruct star pos vel) ;; position velocity


(defun extract-ints (s)
  (mapcar
   'parse-integer
   (ppcre:all-matches-as-strings "-?\\d+" s)))

(defun make-star2 (px py vx vy)
  (make-star
   :pos (make-vec :x px :y py)
   :vel (make-vec :x vx :y vy)))

(defun parse-input (ints)
  (loop
    repeat (/ (length ints) 4)
    collect (make-star2
             (pop ints)
             (pop ints)
             (pop ints)
             (pop ints))))

;; find when they intersect

(defun vec+ (a b)
  (make-vec
   :x (+ (vec-x b) (vec-x a))
   :y (+ (vec-y b) (vec-y a))))

(defun vec-scale (scale v)
  (make-vec
   :x (* scale (vec-x v))
   :y (* scale (vec-y v))))

(defun predict-pos (star time)
  (vec+
   (star-pos star)
   (vec-scale time (star-vel star))))

(defun solve-linear-eq (p1 p2 m1 m2)
  (/
   (- p1 p2)
   (- m2 m1)))

(defun when-collide (s1 s2)
  (let ((t1 (solve-linear-eq
             (vec-x (star-pos s1))
             (vec-x (star-pos s2))
             (vec-x (star-vel s1))
             (vec-x (star-vel s2))))
        (t2 (solve-linear-eq
             (vec-y (star-pos s1))
             (vec-y (star-pos s2))
             (vec-y (star-vel s1))
             (vec-y (star-vel s2)))))
    (and
     (= t1 t2)
     t1)))

(defun part-1 (stars)
  )

(print
 (part-1
  (parse-input
   (extract-ints
    (uiop:read-file-string "./test.txt")))))
