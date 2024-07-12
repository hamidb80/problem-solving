# AoC 2015 day 2 https://adventofcode.com/2015/day/2

# --- prepare ---------------------

ParseData ← (
  regex "\\d+"
  ⋕
  ↯ [∞ 3]
)

Data ← ParseData "2x3x4\n1x1x10"
# Data ← ParseData &fras "aoc2015d2.dat"

# --- part 1 ----------------------

SurfaceAreas ← ≡(≡/× ◫ 2 ↯ [4]) Data

≡/+ × 2 SurfaceAreas # whole area
≡/↧ SurfaceAreas     # min area
+
/+

# --- part 2 ----------------------

SmallestRound ← (
  ⊏ ⍏ .
  ↙ 2
  × 2
  /+
)

≡SmallestRound Data # ribbon length
≡/× Data            # volume
+
/+
