# SSF (shortest seek time) Algorithm

SsfImpl ← {
  acc ← 𝕨
  r‿c ← 𝕩

  •Show 𝕩

  {0=≠r ? acc ; 
    m ← ⊑⍋|r-c
    v ← m⊑r
    (acc+|c-v) SsfImpl ⟨r /˜ m≠↕≠r, v⟩
  }
}

SSF ← { 0 SsfImpl 𝕨‿𝕩 }

# ------------------------ 

c ← 20 # cursor
r ← [5,25,18,3,39,8,35] # list of requests

•Show "as ⟨list, curr⟩"
r SSF c
