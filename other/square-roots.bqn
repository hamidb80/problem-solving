
SquareRoots ← {
  a‿b‿c ← 𝕩
  d ← (b×b) - 4×a×c
  {0 ≤ d ? (b (-∾+) √d) ÷ 2×a ; ⟨⟩} 
}

•Show SquareRoots 1‿5‿6
•Show SquareRoots 1‿1‿2
'.'