"converts Lisp code to Latex"

(defn blur-code (ctx expr)
  (match (type expr)
         :tuple (let [sym (ctx (first expr))]
                  (match (sym :form)
                         :infix  (string "(" (blur-code ctx (expr 1)) " " (sym :label) " " (blur-code ctx (expr 2)) ")")
                         :prefix (string `\ ` (sym :label) " " (blur-code ctx (expr 1)) "" )
                  ))
         :number (string expr)
         (string expr)
    )
)


(def ctx {
  'join {
    :label `\bowtie`
    :form  :infix
  }


  '*  {
    :label `\times`
    :form :infix
  }

  '+  {
    :label `+`
    :form :infix
  }

  'range {
    :label `\updownarrow`
    :form  :prefix
  }

  'reverse {
    :label `\phi`
    :form  :prefix
  }

  'not  {
    :label `\neg`
    :form :prefix
  }

  'do {
    :form :normal
    :label 'do  
  }

  'var {
    :form :infix
    :label `\gets`
  }

  'defn {
    :form :infix
    :label `\gets`
  }

})

(print (blur-code ctx '(var a (reverse (join 1 (not 2))))))
(print (blur-code ctx '(+ 1 (* 2 (range y))) )) # 1 + 2 * i. y
(print (blur-code ctx '() ))