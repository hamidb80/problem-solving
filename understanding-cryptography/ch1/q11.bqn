# implementation of affine cypher in BQN

ModulusInv ← { ⊑ (↕𝕩) /˜ 1 = 26 | 𝕨 × ↕𝕩 }
Decript ← { a‿b 𝕊 y:
  c ← a ModulusInv 26
  'a' + 26 | c × (y - 'a') - b
}

7‿22 Decript "falszztysyjzyjkywjrztyjztyynaryjkyswarztyegyyj"
# "firstthesentenceandthentheevidencesaidthequeen"