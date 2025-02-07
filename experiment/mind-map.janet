"""
tiny mind-tree creator.
"""

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

(defn latex (code) 
  (prop :latex code))

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
        "<div style=\"padding-left: 20px; padding-bottom: 4px\">"
          "<ul style=\"
            padding-left:16px; 
            padding-bottom: " (if (or (empty? (u :children)) (empty? (u :properties))) 0 6) "px;
          \">"
          
          (string/join (map 
            (fn (p) (match (p :kind)
                           :pdf-reference (string 
                              "<li>" "<a target='_blank' href='" 
                              ((p :data) :file) 
                              "#page=" ((p :data) :page) 
                              "'>"
                              "page " ((p :data) :page)
                              "</a>" "</li>")
                            :latex (string "<li><code>" (p :data) "</li></code>")))
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
  "Intro"

  "Application Layer" [

    "Distribution time for P2P and CS" [
       "formula cs"  (bk 170)
       "formula p2p" (bk 171)
       "figure"      (bk 172)
    ]

    "BitTorrent" (bk 173)
    "CDN" 

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
        "additive-increase, multiplicative-decrease (AIMD)" (bk 303) [
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
      "Router Architecture" (bk 343) [

        "Switching" (bk 349) [
          "Bus"
          "RAM"
          "Interconnected"
        ]

        "Input Processing" (bk 346)
        "Ouput Processing" (bk 351)
        
        "suitable Buffering" (bk 355) [
          "other" (latex "B = RTT.C")
          "TCP"   (latex "B = RTT.C/√N")
        ]
        "Buffer Bloat" (bk 356)
        
        "HOL Blocking" (bk 353)
      ]

      "DHCP" [
        "interaction" (bk 375)

        "Stages" (bk 374) [
          "Discovery"
          "Offer"
          "Request"
          "Ack"
        ]

        "NAT" (bk 377)
      ]

      "Forwarding" [
        "Destination Based"

        "Generalized" [
          "OpenFlow" [
            "Usages" [
              "Forwarding"
              "Load Balancing"
              "Firewalling"
            ]
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
          
          "Count to Infinity & Poisen Reverse" (bk 426)
        ]

        "Link State" [
          "OSPF" (bk 428)
          "Oscillations with congestion-sensitive routing" (bk 419)
        ]

        "Comparison" (bk 426) [
          "convergence message complexity:: O(V.E)" (bk 427)
        ]
      ]

      "BGP" [
        "policy based"
        "types" [
          "eBGP"
          "iBGP"
        ]
      ]

      "SDN" (bk 450)
    ]

    "IPv4" [
      "Classless Interdomain Routing CIDR" (bk 368)
      "Lognest Prefix Match"
    ]


    "IPv6" [
      "Segment"   (bk 381)
      "Tunneling" (bk 384)
    ]

  ]
  
  "Link Layer" (bk 339) [
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
    "CSMA/CD" 

    "MPLS" (bk 534)
    
    "ARP"
  ]
]))

# (pp mm)
(fwrite "play.html" (mind-map/html mm))