(GEOMETRY offset-x offset-y width height) ;; the "thing" IS placned in the center of rectangle
(POSITION x y)
(SCALE n)
(SIDE 
  ;; for INPUT
  0 ;; top to bottom
  1 ;; right to left
  2 ;; bottom to top
  3 ;; left to right
  
    0
  3   1
    2
) 
(ALIGNMENT 
  8 7 6
  5 4 3 
  2 1 0

  ;; 8 -> top left
  ;; 4 -> center
)

;; (FORMAT ???)

(ATTRIBUTES
  (MODE 
    1 ;; |> input
    2 ;; <| output
    3 ;; <> inout
    4 ;; [] buffer
    5 ;; <> ???
  )

  (COLOR_LINE 0..71)
  (TEXT "") 
)