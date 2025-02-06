(defn fwrite (path content)
  (def        f (file/open path :w))
  (file/write f content)
  (file/close f))

(defn pdf-page-ref (path) 
  (fn (page)
    [:file path :page page]))

(def bk (pdf-page-ref "network.pdf"))

(defn mind-map (& a) 
  # (fwrite "./play.lisp" (string/format "%j" a))
  (pp a)
)

# (defn formula [code] (latex code))
# (def formula-1 (formula ""))
(def article "./article")

(pp
  [
    "Computer Networking" [
      "Application Layer 📱" [
        "DHCP"
        "DNS"
      ]
    
      "Transport Layer 🛺" [
        "TCP"
        "UDP"
      ]
      
      "Network Layer" [
        "Data Plane 🗄" 
        "Control Plane 🎮" (bk 26)
      ]
      
      "Link Layer" [
      ]
    ]
  ]
)