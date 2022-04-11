
const
  InfixOp* = 0
  InfixLeft* = 1
  InfixRight* = 2


template err*(msg: string): untyped =
  raise newException(ValueError, msg)


template withDir*(dir: string, body: untyped): untyped =
  let curDir = getCurrentDir()
  setCurrentDir(dir)
  body
  setCurrentDir(curDir)
