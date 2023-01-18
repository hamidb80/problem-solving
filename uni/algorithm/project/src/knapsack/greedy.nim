import std/[sequtils, tables, algorithm, sugar]
import ../common



func compareGenertor[N: SomeNumber](fn: proc(a: Item): N): auto =
  result = proc (a, b: Item): int = 
    cmp(fn(a), fn(b))

const
  byWeight = compareGenertor(i => i.weight)
  selectProfit = compareGenertor(i => i.profit)
  selectProfitPerUnit = compareGenertor(i => i.weight/i.profit)

