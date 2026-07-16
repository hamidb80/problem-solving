CountFreq ← (/⁼∘⊐≍˘⍷)  # stolen from https://mlochbaum.github.io/bqncrate/
CountDNA ← {1 -˜ 0⊏⍉ CountFreq "ACGT" ∾ 𝕩}

CountDNA "AGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC"
# 20 12 17 21
