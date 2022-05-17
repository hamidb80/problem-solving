import std/[tables]

type
  Matrix = seq[seq[int]]

  SparseMatrix = Table[tuple[x, y: int], int]


var spm = toTable {
  (1, 2): 7,
  (6, 4): 3
}

del spm, (1, 2)
echo spm[(6, 4)]
