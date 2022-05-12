when false:
  [
    type
      Point = object
        x, y: float

      Photo = object
        id: int
        location: Point

      # DataBase = seq[seq[Collection]]
      
      DataBase = seq[Collection]
      Collection = seq[Photo]
    
    DataBase = QuadTree

    QuadTree = object
      geometry: tuple[x,y, w,h: float]
      data: seq[Entry]
      nodes: seq[QuadTree]

  ]


DataBase
