ParseData ← (
  regex ".*\n*"
  ♭
  ≡(⍚(⋕ regex "\\d"))
)

PartOne ← (
  ≡(⊢ + ×10 ⊃(⊢|⊢ ⇌) °□)
  /+
)

PartTwo ← (
  # ........
)

# ------------------------------------------

$ 1abc2
$ pqr3stu8vwx
$ a1b2c3d4e5f
$ treb7uchet

ParseData
PartOne
