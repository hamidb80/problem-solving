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

(defn svg/rect [x y w h c]
   (string `<rect 
      x="`x`" 
      y="`y`" 
      width="`w`" 
      height="`h`" 
      fill="`c`" 
    />`))

(defn svg/wrap [ox oy w h b content]
  (string 
    `<svg 
      xmlns="http://www.w3.org/2000/svg"
      viewBox="`ox` `oy` ` w ` ` h `"
      width="` w`"
      height="`h`"
    >`
      (if b (svg/rect 0 0 w h b))
      (svg/normalize content)
    `</svg>`))

(defn svg/group [content]
  (string `<g>` (svg/normalize content) `</g>`))

(defn svg/circle [x y r fill]
  (string 
    `<circle 
      r="` r`" 
      cx="`x`" 
      cy="`y`" 
      fill="`fill`"
      />`))

(defn svg/line [p g w fill]
  (string 
    `<line 
      x1="` (first p) `" 
      y1="` (last  p) `" 
      x2="` (first g) `" 
      y2="` (last  g) `" 
      stroke-width="` w `"
      stroke="` fill `"/>`))

(defn not-nil-indexes (row)
  (let [acc @[]]
    (eachp [i n] row
      (if n (array/push acc i)))
    acc))

(defn keep-ends (lst) 
    [(first lst) (last lst)])

(defn range-len (indicies)
  (+ 1 (- (last indicies) (first indicies))))

(defn to-table (lst key-generator)
  (let [acc @{}]
      (each n lst (put acc (key-generator n) n))
      acc))

(defn positioned-item (n r c rng rw) 
  {:node n :row r :col c :row-range rng :row-width rw})

(defn GoT/to-svg-impl (got) # extracts nessesary information for plotting
  (let [acc @[]]
    (eachp [l nodes] (got :grid)
      (eachp [i n] nodes
        (let [idx (not-nil-indexes nodes)]
          (if n (array/push acc (positioned-item n l i (keep-ends idx) (range-len idx)))))))
    acc))

# (defn zip (a b) (map tuple a b))
(defn v+    (v1 v2) (map + v1 v2))
(defn v-    (v1 v2) (map - v1 v2))
(defn v* (scalar v) (map (fn (x) (* x scalar)) v))
(defn v-mag     (v) (math/sqrt (reduce + 0 (map * v v))))
(defn v-norm    (a) (v* (/ 1 (v-mag a)) a))

(defn GoT/svg-calc-pos (item got cfg)
    [(+ (cfg :padx) (* (cfg :spacex)    (got :width)  (* (/ 1 (+ 1 (item :row-width))) (+ 1 (- (item :col) (first (item :row-range))))) )) 
     (+ (cfg :pady) (* (cfg :spacey) (- (got :height) (item :row) 1)))])

(defn GoT/to-svg [got cfg]
  (def cutx (/ (* (got :width)(cfg :spacex)) (+ 1 (got :width))))
  (svg/wrap 0 0
    (+ (* 2 (cfg :padx)) (* (+  0  (got :width))  (cfg :spacex)))
    (+ (* 2 (cfg :pady)) (* (+ -1 (got :height)) (cfg :spacey))) 

    (cfg :background)
    
    (let [acc  @[]
          locs @{}]
      
      (each item (GoT/to-svg-impl got)
        (let [pos (GoT/svg-calc-pos item got cfg)]
          (put locs   (item :node) pos)
          (array/push acc (svg/circle (first pos) (last pos) (cfg :radius) ((cfg :color-map) (((got :nodes) (item :node)) :class)) ))))
      
      (each e (got :edges)
        (let [head (locs (first e))
              tail (locs (last  e))
              vec  (v- tail head)
              nv   (v-norm vec)
              diff (v* (+ (cfg :node-pad) (cfg :radius)) nv)
              h    (v+ head diff)
              t    (v- tail diff)
              ]
          (array/push acc (svg/line h t (cfg :stroke) (cfg :stroke-color)))))
    
      (reverse acc))))

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
  [ (length rows) 
    (reduce max 0 (map length (values rows)))])

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
  (let [rows  (rev-table   levels)
        shape (grid-size     rows)
        grid  (GoT/init-grid rows)]
    (each e events
      (match (e :kind)
        :node (GoT/place-node grid shape levels (e :id) (dec (levels (e :id))) (e :ans) )))
    grid))


(defn GoT/init [events] 
  (let [levels   (GoT/build-levels events)
        grid     (GoT/fill-grid    events levels)]
        {:events events
         :levels levels
         :grid   grid
         :nodes  (to-table events (fn [e] (if (= :node (e :kind)) (e :id))))
         :edges  (GoT/extract-edges events)
         :height (length grid) 
         :width  (length (grid 0))}))


(defn n [id class anscestors] # node
  # :problem :recall :reason :calculate
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
  (n :t2 :reason [:t1])
  (n :t22 :calculate [:root])
  (n :t23 :recall [:root])
  (n :t3 :calculate [:t2 :t1])
  (n :t4 :reason [:t2])
  (n :t5 :goal [:t4])
]))


(pp p1)
# colors stolen from https://colorhunt.co/
(file/put "./play.svg" (GoT/to-svg p1 {:radius  16
                                       :spacex  100
                                       :spacey  80
                                       :padx     0
                                       :pady     50
                                       :stroke   4
                                       :node-pad 6
                                       :background nil # "black"
                                       :stroke-color "#212121"
                                       :color-map { :problem   "#212121"
                                                    :goal      "#212121"
                                                    :recall    "#864AF9"
                                                    :calculate "#E85C0D"
                                                    :reason    "#5CB338" }}))