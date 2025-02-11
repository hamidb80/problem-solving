"""
tiny mind-tree creator.
"""

(defn exec (cmd)
  (os/execute cmd :pe))

(defn file/put (path content)
  (def        f (file/open path :w))
  (file/write f content)
  (file/close f))

(defn file/exists (path) 
  (not (nil? (os/stat path))))

# props

(defn prop (kind data) 
  {:kind kind :data data })

(defn latex (code) 
  (prop :latex code))

(defn important () 
  (prop :important nil))

(defn web (url &opt text) 
  (prop :web-url {:url url 
                  :text (if (nil? text) url text)}))

(defn pdf-page-ref (path) 
  (fn (page)
    (prop :pdf-reference {:file path :page page})))

(defn extract-page (pdf-file-path page-num out-path use-cache)
  (if (and use-cache (file/exists out-path))
    nil # cached
    (exec ["magick" "-density" "300" (string pdf-file-path "[" page-num "]") out-path]))
)

# ------------------

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
      :string  (do
        (if (not (empty-cur)) (array/push acc cur))
        (reset-cur)
        (put cur :label d))
      :tuple   (put         cur :children    (mind-map/create d))
      :struct  (array/push (cur :properties) d)
    ))
  
  (if (not (empty? cur)) (array/push acc cur))
  acc
)

(def bk-path "E:/konkur/Subjects/Network/cnet-8th.pdf")

(defn join-map (lst f)
  (string/join (map f lst)))

(defn mind-map/html-impl (mm out-dir use-cache)
  (join-map mm
    (fn (u) (string
      "<details>
        <summary>" (u :label) "</summary>"
        "<div style=\"padding-left: 20px; padding-bottom: 4px\">"
          "<ul style=\"
            padding-left:16px; 
            padding-bottom: " (if (or (empty? (u :children)) (empty? (u :properties))) 0 6) "px;
          \">"
          
          (join-map (u :properties) 
                     (fn (p) (match (p :kind)
                                    :pdf-reference (let [page-num ((p :data) :page) file-path ((p :data) :file) img-path (string ((p :data) :page) ".png") e (extract-page file-path (- page-num 1) (string out-dir img-path) use-cache)] (string "<li>" "<a target='_blank' href='" "file:///" file-path "#page=" page-num "'>" "page " page-num "</a>" "<br/>" `<img style="max-width: 400px;" src="./` img-path `"/>` "</li>"))
                                    :latex         (string "<li><code>" (p :data) "</li></code>")
                                    :web-url       (string `<li><a target='_blank' href="` ((p :data) :url) `">` ((p :data) :text) `</a></li>`)
                                    :important     "<li>🌟 important</li>"
                                                   (error (string "the attr :" (p :kind) " not implemented")))))
          "</ul>"
          
          (mind-map/html-impl (u :children) out-dir use-cache)
        "</div>"
      "</details>"
    ))
))

(defn mind-map/html (mm out-dir use-cache) 
  (string
    "<style>*{padding:0;margin:0;}</style>"
    (mind-map/html-impl mm out-dir use-cache)))


# --------------

(def bk (pdf-page-ref bk-path))

(def mm (mind-map/create [
  "Intro"

  "Application Layer" [

    "Distribution time for P2P and CS" [
       "formula cs"  (bk 170)
       "formula p2p" (bk 171)
       "figure"      (bk 172)
    ]

    "BitTorrent" (bk 173) (bk 174)
    
    "CDN" [
      "Strategies" (bk 178) [
        "Enter deep :: rent room of computers inside ISP :: costly but efficient"
        "bring home :: build your cluster :: cheap but lower quality"
      ]
    ] 

    "DNS" (bk 180) [
      "Hierarchy" (bk 159)

      "Query" [
        "Recursive" (bk 163)
        "Iterative"
      ]
      "Record Types" (bk 164)
      "Message Format" (bk 165)
    ]

    "Cache" [
      "Formula" (bk 144)
    ]

    "STMP" (bk 154)

    "HTTP" [
      "Structure" (bk 136)

      "DASH" (bk 176)

      "versions" (bk 314) [
        "v1.0"
        "v1.1"
        "v2" [
          "Framing" (bk 146)
        ]
        "v3" [
          "Quic"
        ]
      ]
    ]

    "Socket Programming" [
      "UDP Server" 
      "UDP Client" (bk 188)

      "TCP Server" (bk 193)
      "TCP Client" 
    ]
  ]

  "Transport Layer" [
    "Selective Repeat"
    "Go Back N"


    "UDP" [
      "Segment" (bk 230)
    ]
    "TCP" [
      "Segment" (bk 263)
      "MSS MTU" (bk 261)

      "3-way handshake" (bk 282) [
        "SYNACK flood attack" (bk 281)
      ]

      "Closing" (bk 283)

      "monitoring" [
        "SampleRTT"
        "EstimatedRTT"
        "DevRTT" (bk 268)
      ]

      "Performace with Buffer" (bk 291)

      "Congestion Control" [
        "FSM" (bk 300) [
          "Slow Start" (bk 296)
          "Congestion Aviodance" (bk 296)
          "Fast Recovery" (bk 297)
          "Fast Retransmit" (bk 277)
        ]
        "AIMD" (bk 303) [
          "additive-increase, multiplicative-decrease"
          "Fairness"
        ]
        "Explicit Notification" (bk 307)

        "TCP Reno vs Tahoe" (bk 302)
      ]
    ]
  ]
  
  "Network Layer" [
    "Compare" (bk 386)

    "Data Plane" [
      "Router Architecture" (bk 349) (bk 350) [
        "Bus"
        "RAM"
        "Interconnected"
      ]
      "Input Processing" (bk 346)
      "Ouput Processing" (bk 351)
      
      "suitable Buffering" (bk 355) [
        "other" (latex "B = RTT.C")
        "TCP"   (latex "B = RTT.C/√N")

        "paramters" [
          "B: Buffering"
          "RTT: Round Time Trip of connection"
          "N: number of TCP connections"
          "C: link capacity"
        ]
        "Buffer Bloat" (bk 356)
        
        "HOL Blocking" (bk 353)
      ]
    ]
  
    "DHCP" [
      "interaction" (bk 375)
      "plug-and-play" (bk 373)

      "Stages" (bk 374) [
        "Discovery"
        "Offer"
        "Request"
        "Ack"
      ]
    ]

    "NAT" (bk 377)

    "Forwarding" [
      "Destination Based"

      "Generalized" [
        "OpenFlow" [
          "Match + Action" (bk 389) [
            "Forwarding"
            "Load Balancing"
            "Firewalling"
          ]
        ]
      ]
    ]

    "Control Plane" [
      "Routing Algorithms" [
        "Distance Vector" [
          "Operation" (bk 423)

          "examples" [
            "BGP"
            "RIP"
          ]
          
          "Count to Infinity" (bk 426) [
            "Poisen Reverse"
          ]
        ]

        "Link State" [
          "OSPF" (bk 428)
          "Oscillations with congestion-sensitive routing" (bk 419)
        ]

        "Comparison" (bk 426) [
          "convergence message complexity:: O(V.E)" (bk 427)
        ]
      ]

      "SDN" (bk 450)

      "BGP" [
        "policy based"
        "types" [
          "eBGP"
          "iBGP"
        ]
      ]
    ]

    "IP" [
      "v4" [
        "Classless Interdomain Routing CIDR" (bk 368)
        "Lognest Prefix Match"
      ]
    
      "v6" [
        "Segment"   (bk 381)
        "Tunneling" (bk 384)
        "Does not have segmentation like in v4"
      ]
    ]

    "ICMP" (bk 455)  [
      "TraceRoute" (bk 456) 
    ]
  ]
  
  "Link Layer" [
    "ALLOHA" [
      "Slotted" [
        "formula" (bk 500) (latex "N.p.(1-p)^(N-1)")
      ]
      "Pure" [
        "formula" (bk 500) (latex "N.p.(1-p)^2(N-1)")
      ]
    ]

    "VLAN" [
      "Trunking" (bk 532)
    ]

    "CSMA/CD" (bk 503) (bk 504) [
      "Efficiency" (latex "(1 + 5d_prop/d_trans)^-1") (bk 506)
    ]

    "MPLS" (important) (bk 534) (bk 535)
    
    "ARP" (bk 514) [
      "Address Resolution Protocol"
    ]
  ]

  "Summary" [
    "life of a web request" (important) (web "file:///E:/konkur/Subjects/Network/videos/retrospective%20a%20day%20in%20the%20life%20of%20a%20web%20request.mp4" "https://youtube.com/watch?v=I6twhxwycyM")
  ]
]))

# ---------------------- go

(pp (dyn *args*))

(let [build-dir "./play/" 
      build-file (string build-dir "index.html")]

  (file/put build-file (mind-map/html mm build-dir true))
  (print "success: " build-file))