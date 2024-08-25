# Advent of Code year 2019 day 2 in BQN
# ideas taken from https://www.youtube.com/watch?v=NqMmkLgV9lc

Parse ← {{(>⟜«0≤𝕩)/0(0⊸≤××⟜10⊸+)`𝕩}∘-⟜'0' 𝕩} # stolen from https://mlochbaum.github.io/bqncrate/

Exec ← {
  i‿mem      ← 𝕩
  cmd‿a‿b‿c ← mem ⊏˜ i+↕4 
  (i+4)‿{
    1= cmd ? (+´ a‿b ⊏ mem)⌾(c⊸⊑)mem ;
    2= cmd ? (×´ a‿b ⊏ mem)⌾(c⊸⊑)mem ;
                                   mem
  }
}

RunWhileLoop ← {
  While ← {𝕩•_while_𝕨@}´

  i   ← 0
  mem ← 𝕩

  While {𝕤⋄ 99 ≠ i⊑mem}‿{𝕤  
    i‿mem ↩ Exec i‿mem
  }

  mem
}

RunRecursive ← {
  i‿mem ← Exec 𝕨‿𝕩
  {99= i⊑mem ?  mem ; 
                i RunRecursive mem}
}

# RunWhileLoop & RunRecursive are identical, I just wanted to explore the possiblities

GoImpl ← {0 RunWhileLoop 𝕨⌾(1‿2⊸⊏) 𝕩}
Go ← {⊑ 𝕨 GoImpl 𝕩}

Part1 ← {12‿2 Go 𝕩}
Part2 ← {
  mem            ← 𝕩
  valueRange     ← 100
  specialValue   ← 19690720
  possibleValues ← ∾⌜˜ ↕valueRange
  i2             ← ⊑[specialValue] ⊐˜ ⥊ {𝕨‿𝕩 Go mem} ⌜˜ ↕valueRange
  init           ← ⟨⌊i2÷valueRange, valueRange|i2⟩
  a‿b           ← 1‿2 ⊏ init GoImpl mem
  b+a×100
}

Solve ← (Part1 ∾ Part2) # ⟨ 2782414 9820 ⟩
Solve Parse "1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,1,6,19,23,1,23,13,27,2,6,27,31,1,5,31,35,2,10,35,39,1,6,39,43,1,13,43,47,2,47,6,51,1,51,5,55,1,55,6,59,2,59,10,63,1,63,6,67,2,67,10,71,1,71,9,75,2,75,10,79,1,79,5,83,2,10,83,87,1,87,6,91,2,9,91,95,1,95,5,99,1,5,99,103,1,103,10,107,1,9,107,111,1,6,111,115,1,115,5,119,1,10,119,123,2,6,123,127,2,127,6,131,1,131,2,135,1,10,135,0,99,2,0,14,0"


# -------------------------- quote from https://mlochbaum.github.io/BQN/community/aoc.html
# BQN did do okay in terms of performance. 
# At times programmers on the forum commented about having slow solutions (tens of seconds) or having to rewrite an obviously unsatisfactory algorithm. 
# I don't think anyone mentioned having to switch languages for performance reasons, which is good news for an implementation as young as CBQN. 
# But also not a surprise, as it's pretty fast with scalar code for an interpreter: about 10 times slower than C when I've measured it. 
# Array code is usually faster, but can be slower. 
# A particular problem was that in-place mutation ⌾(i⊸⊑) is only fast for very simple cases. 
# Of course, this problem only arises because BQN's arrays are immutable, highlighting that immutable arrays, despite being perfect in every way, can be a pain.
# In a serious application you might be willing to endure more pain and use a mutable array object, to ensure good performance.

# me: was amazing !