(NET
  (OBID "{SOME RANDOM ID}")
  (HDL_IDENT
    (NAME "{YOUR NAME}")
  )
  
  ;; 1 (PART ...) is removed

  (PART
    (OBID "{ANOTHER RANDOM ID}")
    
    ;; (LABEL ...) is removed 
    
    (WIRE x1 y1 x2 y2)
    (WIRE ...)
    (WIRE ...)

    (PORT ;; from
      (OBID "{PORT ID INSIDE COMPONENT INSTANTIATION}")
      (NAME "{PORT NAME INSIDE COMPONENT}")
    )
    (PORT ;; to
      (OBID "*")
      (NAME "*")
    )
  )
)
