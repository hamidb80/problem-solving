# ------ Attemp 0 (Verbose)
SolveQuad ← {
  ⟨a,b,c⟩ ← 𝕩
  deltasq ← (b×b) - (4×a×c)
  
  {
    deltasq > 0 ? 
     ⟨(-b + √deltasq) ÷ (2×a), 
      (-b - √deltasq) ÷ (2×a)⟩ ;
    
    deltasq = 0 ? ⟨-b ÷ 2×a, -b ÷ 2×a⟩ ; 
    
    ⟨⟩}
}

# ------ Attemp 1 (Clean)

SquareRoots ← {
  a‿b‿c ← 𝕩
  d ← (b×b) - 4×a×c
  {0 ≤ d ? (b (-∾+) √d) ÷ 2×a ; ⟨⟩} 
}

•Show SquareRoots 1‿5‿6
•Show SquareRoots 1‿1‿2
'.'
