(DATABASE_VERSION 17)
(ENTITY_FILE
  (ENTITY
    (OBID "{obid}")
    (PROPERTIES
      (PROPERTY "STAMP_PLATFORM" "PC")
      (PROPERTY "STAMP_REVISION" "Revision 4")
      (PROPERTY "STAMP_TIME" "Wed May 04 16:34:31 2022")
      (PROPERTY "STAMP_TOOL" "Ease")
      (PROPERTY "STAMP_VERSION" "8.0")
    )
    
    (HDL_IDENT
      (NAME "{name}")
      (USERNAME 1)
    )
    
    (GEOMETRY 0 0 {width} {height}) ;; must match when instantiating
    (HDL 1)
    (EXTERNAL 0)
    (OBJSTAMP
      (DESIGNER "HamidB80")
      (CREATED 1651677890 "Wed May 04 19:54:50 2022")
      (MODIFIED 1651677907 "Wed May 04 19:55:07 2022")
    )

    { PORTs def }

    (ARCH_DECLARATION 1 "{RANDOM_ID}" "{TAG}")
  )
  (ARCH_DEFINITION
    (OBID "{RANDOM_ID}")
    (HDL_IDENT
      (NAME "{TAG}")
      (USERNAME 1)
    )

    (TYPE 1)
    (SCHEMATIC
      (OBID "{genoid()}")
      (PROPERTIES
        (PROPERTY "SheetInfoFontSize" "8")
      )
      (SHEETSIZE 0 0 {sheetWidth} {sheetHeight})
      { PORTs }
      { COMPONENTs }
      { NETs }
    )
  )
)
(END_OF_FILE)
