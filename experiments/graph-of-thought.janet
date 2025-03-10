# GoT (Graph of Thought) is a DAG (Direct Acyclic Graph)

(defn file/put (path content)
  (def        f (file/open path :w))
  (file/write f content)
  (file/close f))

(defn file/exists (path) 
  (not (nil? (os/stat path))))

(defn inspect (a) 
  (pp a)
  a)

(defn inspects (a) 
  (print a)
  a)


(defn svg/normalize (c)
  (match (type c)
          :array  (string/join c " ")
          :string              c))

(defn svg/wrap [w h content]
  (string 
    `<svg 
        xmlns="http://www.w3.org/2000/svg"
        viewbox="` w ` ` h ` ` w ` ` h `">`
        (svg/normalize content)
    `</svg>`))

(defn svg/group [content]
  (string `<g>` (svg/normalize content) `</g>`))

(defn svg/circle [x y r fill]
  (string `<circle r="`r`" cx="`x`" cy="`y`" fill="`fill`"></circle>`))


(defn svg/circle [x y r fill]
  (string `<circle r="`r`" cx="`x`" cy="`y`" fill="`fill`"></circle>`))

(defn svg/path [points fill]
  (string `<path d="` (string/join points " ") `" fill="transparent" stroke="`fill`"></path>`))

(defn GoT/svg/calc-pos (grid row col))

(defn GoT/to-svg [got cfg] 
  (svg/wrap 50 50
    (let [h    (length (got :grid))
          acc  @[]]
      (eachp [l nodes] (got :grid)
        (eachp [i n] nodes
          (if (nil? n) nil 
              (array/push acc (svg/circle 
                              (+ (cfg :padx) (* (cfg :space) i)) 
                              (+ (cfg :pady) (* (cfg :space) (- h l))) 
                              (cfg :size) 
                              (cfg :color))))))
      acc)))

(defn rev-table [tab]
  (def acc @{})
  (eachp (k v) tab
    (let [lst (acc v)]
         (if (nil? lst)
              (put acc v @[k])
              (array/push lst k))))
  acc)

(defn GoT/build-levels [events]
  (def  levels @{})
  (each e events 
    (match (e :kind)
           :question nil
           :node     (put levels (e :id) (+ 1 (reduce max 0 (map levels (e :ans)))))))
  levels)

(defn GoT/extract-edges [events]
  (let [acc @[]]
       (each e events
          (match (e :kind)
            :node (each a (e :ans)
                    (array/push acc [a (e :id)]))))
       acc))


(defn grid-size (rows)
  (tuple 
    (length rows) 
    (reduce max 0 (map length (values rows)))))

(defn matrix-of (rows cols val)
  (map (fn [_] (array/new-filled cols)) (range rows)))

(defn GoT/init-grid [rows]
  (let [size (grid-size rows)]
       (matrix-of (first size) (last size) nil)))

(defn get-cell [grid y x]
  ((grid y) x))

(defn put-cell [grid y x val]
  (put (grid y) x val))

(defn avg (lst)
  (/ (reduce + 0 lst) (length lst)))

(defn GoT/place-node (grid size levels node selected-row parents)
  # places and then returns the position
  (def height (first size))
  (def width  (last size))
  
  (def parents-col (map (fn [p] (let [row (dec (levels p))
                        col (find-index (fn [y] (= y p)) (grid row))] 
                        col)) 
                    parents))
 
  (def center (/ (if (even? width) width (inc width)) 2))
  (def avg-parents-col (if (empty? parents) center (avg parents-col)))

  (var i avg-parents-col)
  (var j avg-parents-col)

  (while true 
    (cond
      (nil? (get-cell grid selected-row i)) (break (put-cell grid selected-row i node))
      (nil? (get-cell grid selected-row j)) (break (put-cell grid selected-row j node))
            (do 
              (set i (max 0           (dec i)))
              (set j (min (dec width) (inc j)))))))

(defn GoT/fill-grid (events levels)
  (let [rows  (rev-table levels)
        shape (grid-size     rows)
        grid  (GoT/init-grid rows)]
    (each e events
      (match (e :kind)
        :node (GoT/place-node grid shape levels (e :id) (dec (levels (e :id))) (e :ans) )))
    grid))


(defn GoT/init [events] 
  (let [levels   (GoT/build-levels events)]
        {:events events
         :edges  (GoT/extract-edges events)
         :levels levels
         :grid   (GoT/fill-grid events levels)}))


:problem :recall :reason :reason :compute

(defn n [id class anscestors] # node
  {:kind  :node 
   :id    id
   :class class 
   :ans   anscestors})

(defn q [content] # question or hint
  {:kind    :question 
   :content content})

(def p1 (GoT/init [
  (n :root :problem [])
  (q  "what is")
  (n :t1 :recall [:root])
  (n :t2 :recall [:t1])
  (n :t3 :recall [:t2 :t1])
  (n :t4 :recall [:t2])
]))
(pp p1)
(file/put "./play.svg" (GoT/to-svg p1 {:size  10
                                       :space 60
                                       :padx 300
                                       :pady 300
                                       :color "black"}))