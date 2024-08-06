ParseInput ← (
  regex "\\w \\w"
  ≡(
    ⊢
    °□
    ⊏ [0 2]
  )
  ∵(↧⊃(⊗ : "ABC"|⊗ : "XYZ"))
  +1
)

# [1 1] => draw  | 0
# [1 2] => win   | 1
# [1 3] => loose | 2

# [2 1] => loose | -1
# [2 2] => draw  |  0
# [2 3] => win   |  1

# [3 1] => win   | -2
# [3 2] => loose | -1
# [3 3] => draw  |  0

map [0 1 ¯2 ¯1 2] [1 2 2 0 0]
Rule ←

PartOne ← (
  ≡(
    ⊂ ⊃(⊏ 1|×3get /- : Rule)
  )
  ≡/+
  /+
)

# 1 1 => 3
# 2 1 => 1
# 3 1 => 2

# 1 2 => 1
# 2 2 => 2
# 3 2 => 3

# 1 3 => 2
# 2 3 => 3
# 3 3 => 1

PartTwo ← (
  ∘
  ## ╭─      
  ## ╷ 1 2   
  ##   2 1   
  ##   3 3   
  ##       ╯ 
)

# ---------------------------

$ A Y
$ B Xs
$ C Z
# $ A Z

# &fras "./input.txt"

ParseInput
## ╭─      
## ╷ 1 2   
##   2 1   
##   3 3   
##       ╯ 

⊃PartOne PartTwo
