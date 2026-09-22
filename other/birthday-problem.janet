(defn birthday-prob [k]
    (let 
        [y 365
         t (map (fn [i] (- y i)) (range 0 k))
         a (* ;t)
         b (math/pow y k)]
        
        # (pp [a b t])
        (- 1 (/ a b))))

(let 
    [k (range 1 100)]
    (pp (zipcoll k (map birthday-prob k))))
