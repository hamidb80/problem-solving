# implementation of affine cypher in BQN

ModInv ← { ⊑ (↕𝕩) /˜ 1 = 𝕩 | 𝕨 × ↕𝕩 }
Decript ← { a‿b 𝕊 y:
  c ← a ModInv 26
  'a' + 26 | c × (y - 'a') - b
}

7‿22 Decript "falszztysyjzyjkywjrztyjztyynaryjkyswarztyegyyj"
# "firstthesentenceandthentheevidencesaidthequeen"
