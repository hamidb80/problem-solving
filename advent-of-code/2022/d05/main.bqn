# Advent of Code 2022 day 5 in BQN

Split ← {𝕨((¬-˜⊢×·+`»⊸>)∘≠⊔⊢)𝕩}
SplitLines ← {'
'Split𝕩}

ExtractInts← {•ParseFloat ¨ ' ' Split 𝕩}

ParseStack  ← {
 lines ← SplitLines 𝕩
 stackItemsIndexes ← 1+ 4× ↕ ⌊ 3 ÷˜ ⊑≢⊑lines
 d ← ⍉⌽> ¯1 ↓ stackItemsIndexes⊸⊏ ¨lines
}

ParseCommands ← {∘‿3 ⥊ ExtractInts {" 0123456789" ∊˜ 𝕩}⊸/𝕩}
Part1 ← ⋈

initialStack ← "
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 
"
commands ← "
move 1 from 2 to 1 
move 3 from 1 to 3 
move 2 from 2 to 1 
move 1 from 1 to 2 
"

(ParseStack initialStack) Part1 (ParseCommands commands)

# ------ not completed ---------