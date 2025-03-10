# GoT (Graph of Thought) is a DAG (Direct Acyclic Graph)

(defn file/put (path content)
  (def        f (file/open path :w))
  (file/write f content)
  (file/close f))

(defn file/exists (path) 
  (not (nil? (os/stat path))))


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


(defn GoT/to-svg [got] 
  (svg/wrap 50 50
    (let [size  10
          space 60
          padx 300
          pady 300
          h    (length (got :levels))
          c    "black"
          acc  @[]
          ]
      (eachp [l nodes] (got :levels)
        (eachp [i n] nodes
          (array/push acc (svg/circle 
                              (+ padx (* space i)) 
                              (+ pady (* space (- h l))) 
                              size 
                              c))))
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


(defn grid-size (levels)
  (tuple 
    (length levels) 
    (reduce max 0 (map length (values levels)))))

(defn matrix-of (rows cols val)
  (def matrix @[])
  (for y 0 rows
    (def row @[])
    (for x 0 cols
      (array/push row val))
    (array/push matrix row))
  matrix)

(defn GoT/init-grid [levels]
  (let [size (grid-size levels)]
       (matrix-of (first size) (last size) nil)))

(defn GoT/place-node (grid node r parent)
  # places and then returns the position
  (def   avg-parents-col 1)
  (var i avg-parents-col)
  (var j avg-parents-col)

  )


(defn GoT/fill-grid (events levels)
  (let [grid (GoT/init-grid levels)]
    (each e events
      (match (e :kind)
        :node (GoT/place-node grid (e :id) (dec (levels (e :id))) (e :ans) )))))


(defn GoT/init [events] 
  (def levels (rev-table (GoT/build-levels events)))
  {:events events
   :edges  (GoT/extract-edges events)
   :levels levels
   :grid   (GoT/fill-grid events levels)}
)


:problem :recall :reason :reason :compute

(defn n [id class anscestors] # node
  {:kind  :node 
   :id    id
   :class class 
   :ans   anscestors})

(defn q [content] # question or hint
  {:kind    :question 
   :content content})

# TODO list
(def p1 (GoT/init [
  (n :root :problem [])
  (q  "what is")
  (n :t1 :recall [:root])
  (n :t2 :recall [:t1])
  (n :t3 :recall [:t2 :t1])
  (n :t4 :recall [:t2])
]))
(pp p1)
(file/put "./play.svg" (GoT/to-svg p1))
