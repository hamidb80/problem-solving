Split ← { 
  i ← 𝕨 = 𝕩
  𝕩 ⊔˜ ¯1 + (¬i) ∧ 1+ +` i
}

F ← {
  sep‿asgn 𝕊 text:
  >˘ asgn Split¨ sep Split text
}

•Show " =" F "language=APL dialect=Dyalog"
•Show ";:" F "duck:donald"
•Show "/:"F "name:Morten/name:Brian/name:Adám"
------------