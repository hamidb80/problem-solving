(GEOMETRY crop-x crop-y width height) ;; the "thing" IS placned in the center of cropped rectangle
(POSITION x y)
(SCALE n)
(SIDE
  0 ;; down to up
  1 ;; left to right
  2 ;; up to down
  3 ;; right to left
  
    2
  1   3
    0
) 
(ALIGNMENT 
  8 7 6
  5 4 3 
  2 1 0 
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
)