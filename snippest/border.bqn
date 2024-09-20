# improved version of 
# (⊢↑˝·≍⟜¬2+≢)y ::	Pad y with a layer of fill elements on all sides
# stolen from https://mlochbaum.github.io/bqncrate/

Border ← {(⊢↑˝·≍⟜(𝕨⊸-)(𝕨×2)+≢)𝕩}
2 Border 3‿4 ⥊ 1+↕12