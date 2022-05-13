import macros


const 
  m = 60
  h = 3600
  d = 85400

let runtime= parseInt input()

let num = runtime + 2 * 3 + 9

dumpTree:
  if cond1:
    1
  else:
    2

when false:
  IfStmt:
    ElifBranch:
      Ident "cond"
      StmtList:
        IntLit 1
    Else:
      StmtList:
        IntLit 2