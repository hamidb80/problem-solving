(defn wrap-svg [w h content]
  (string 
    `<svg 
        width="`  w `" 
        height="` h `" 
        xmlns="http://www.w3.org/2000/svg">`
        content
    `</svg>`))

(defn rev-table [tab]
  (var acc @{})
  (eachp (k v) tab
    (pp [k v])
    (let [lst (acc v)]
         (if (nil? lst)
              (put acc v @[k])
              (array/push lst k))))
  acc)

(defn GoT/build-levels [events]
  (var  levels @{:root 0})
  (each e events 
    (match (e :kind)
           :question nil
           :node     (if (= :root (e :id)) nil
                         (let [l (levels (e :from))]
                              (if l
                                  (put levels (e :id) (+ 1 l))
                                  (error (string "reference not found: " (e :from))))))))
  levels)

(defn GoT/init [events] 
  (pp (rev-table (GoT/build-levels events)))
)

(defn GoT/to-svg [got] 
  (wrap-svg 100 100 got))

:problem :recall :reason :reason :compute

(defn n [id class from] # node
  {:kind  :node 
   :id    id
   :class class 
   :from  from})

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