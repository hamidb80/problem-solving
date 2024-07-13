FuelCalc ← -2 ⌊ ÷ 3
FuelCalcRec ← |1 (
  FuelCalc
  .
  <0
  ⨬⟨+FuelCalcRec.|0⟩
)

PartOne ← /+ ∵FuelCalc
PartTwo ← /+ FuelCalcRec
# -----------------------

# Content ← &fras "./d1.dat"
Content ← "100756"
Masses ← ♭ ⋕ regex "\\d+" Content

PartOne Masses
PartTwo Masses
