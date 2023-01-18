type
  Item* = object
    profit*: int
    weight*: int

func newItem*(p, w: int): Item =
  Item(profit: p, weight: w)
