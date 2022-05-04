(COMPONENT ;; component instantiation in other entities
  (OBID "{OBID}") 
  (ENTITY "{Lib_Dir}" "{Entry_Path_Without_Ext}") ;; reference

  (HDL_IDENT 
    (NAME "{NAME}")
    (USERNAME 1)
  )

  ;; graphical properties
  (GEOMETRY {x} {y} {x + width} {y + height})
  (SIDE 0)
  (LABEL
    (POSITION {x + width div 2} {y})
    (SCALE 100)
    (COLOR_LINE 0)
    (SIDE 3)
    (ALIGNMENT 7)
    (FORMAT 13)
    (TEXT {Label})
  )
  
  { PORTs }
)