(defn fwrite (path content)
  (def        f (file/open path :w))
  (file/write f content)
  (file/close f))

(defn prop (kind data)
  {:kind   kind
   :data   data
  })

(defn pdf-page-ref (path) 
  (fn (page)
    (prop :pdf-reference {:file path :page page})))

# (defn repr (& a) 
#   (fwrite "./play.lisp" (string/format "%j" a))
#   (pp a))

(defn mind-map/create (data)
  (def acc @[])
  (var cur nil)

  (defn reset-cur () 
    (set cur @{
      :properties @[] 
      :children   @[]
    }))

  (defn empty-cur ()
    (= 2 (length cur)))

  (reset-cur)

  (each d data
    (match (type d)
      :string (do
        (if (not (empty-cur)) (array/push acc cur))
        (reset-cur)
        (put cur :label d)
      )
      :tuple  (put         cur :children    (mind-map/create d))
      :struct (array/push (cur :properties) d)
    ))
  
  (if (not (empty? cur)) (array/push acc cur))
  acc
)

(defn mind-map/html-impl (mm)
  (string/join (map
    (fn (u) (string
      "<details>
        <summary>" (u :label) "</summary>"
        "<div style=\"padding-left:16px\">"
          "<ul style=\"padding-left:16px\">"
          (string/join (map 
            (fn (p) (string 
                "<li><a target='_blank' href='" 
                ((p :data) :file) 
                "#page=" ((p :data) :page) 
                "'>"
                "page " ((p :data) :page)
                "</a></li>"))
            (u :properties)
          ))
          "</ul>"
          (mind-map/html-impl (u :children))
        "</div>"
      "</details>"
    ))
    mm
)))
(defn mind-map/html (mm) 
  (string
    "<style>*{padding:0;margin:0;}</style>"
    (mind-map/html-impl mm)))

# --------------

(def bk (pdf-page-ref "file:///E:/konkur/Subjects/Network/Computer Networking - A Top-Down Approach 8th.pdf"))

(def mm (mind-map/create [
  "Application Layer" [
    "DHCP"
    "DNS"
  ]

  "Transport Layer" [
    "TCP"
    "UDP"
  ]
  
  "Network Layer" [
    "Data Plane" 
    "Control Plane" 
  ]
  
  "Link Layer" (bk 339)
]))

(pp mm)
(fwrite "play.html" (mind-map/html mm))