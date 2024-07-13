FuelRequired ← -2 ⌊ ÷ 3
PartOne ← /+ ∵FuelRequired
FuelRR ← |1 (
  FuelRequired
  .
  <0
  ⨬(+FuelRR.|0)
)

Fact ← |1 ⨬⟨×Fact-1.|1⟩<2.
# -----------------------

# Content ← &fras "./d1.dat"
Content ← "100756"
Masses ← ♭ ⋕ regex "\\d+" &fras "./d1.dat"
PartOne Masses
PartTwo Masses
