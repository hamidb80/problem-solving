# Advent of Code 2016 day 2 -- Uiua

Moves ← map "UDRL" [[¯1 0] [1 0] [0 1] [0 ¯1]]

# 1 2 3
# 4 5 6
# 7 8 9
SquareGridPoints ← map [
  [¯1 ¯1]
  [¯1 0]
  [¯1 1]
  [0 ¯1]
  [0 0]
  [0 1]
  [1 ¯1]
  [1 0]
  [1 1]] "123456789"

#     1
#   2 3 4
# 5 6 7 8 9
#   A B C
#     D
KeyPadGridPoints ← map [
  [¯2 0]
  [¯1 ¯1]
  [¯1 0]
  [¯1 1]
  [0 ¯2]
  [0 ¯1]
  [0 0]
  [0 1]
  [0 2]
  [1 ¯1]
  [1 0]
  [1 1]
  [2 0]] "123456789ABCD"

⇅ ← ↥⊙↧ # min max or clamp
GridLimiter ← ⇅ ¯1 1
AddInsideSquare ← ∵GridLimiter +
AddInsideKeypad ← (
  ⊃(+|⇌⊂¤+⟜:) # sum [sum orig]
  ##
  ⌵
  ##
  /+
  ##
  ≤2
  ⊏
  ##
)

# ------------------------------------------

ParseData ← (
  ♭ regex "\\w+"
  ⍚∵(get : Moves)
)

PartOne ← (
  .
  ≡◇⧻
  ##
  -1 \+
  ##
  :
  /◇⊂
  ##

  \AddInsideSquare
  ##
  ≡(get :SquareGridPoints)
  ##

  :
  ##
  ⊏
  ##
)

PartTwo ← (
  .
  ≡◇⧻
  ##
  \+
  ##
  :
  /◇⊂
  ##

  ⊂ [0 ¯2]
  ##
  \AddInsideKeypad

  ##
  ≡(get : KeyPadGridPoints)
  ##

  :
  ##
  ⊏
  ##
)

# ---------------------------------------

# "ULL\nRRDDD\nLURDL\nUUUUD"
&fras "./d2.dat"
ParseData
##

PartOne .
##
PartTwo :
##
