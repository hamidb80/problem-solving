const
  InfixOp* = 0
  InfixLeft* = 1
  InfixRight* = 2


template err*(msg: string): untyped =
  raise newException(ValueError, msg)
