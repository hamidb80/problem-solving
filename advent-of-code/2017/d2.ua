ParseLineByLine ← (
  .
  ⌕ @\n
  \+
  ⊕(□)
  ≡(□ ♭ ⋕ regex "\\d+")
)

MinMax ← ⊃/↧/↥
PartOne ← /+≡(- MinMax °□)

PartTwo ← (
  ≡(
    . . °□
    ## [5 9 2 8] [9 4 7 3] [3 8 6 5] 
    ⊞(=0 ◿1 ÷)
    ## ╭─          ╭─          ╭─          
    ## ╷ 1 0 0 0   ╷ 1 0 0 0   ╷ 1 0 1 0   
    ##   0 1 0 0     0 1 0 0     0 1 0 0   
    ##   0 0 1 1     0 0 1 0     0 0 1 0   
    ##   0 0 0 1     1 0 0 1     0 0 0 1   
    ##           ╯           ╯           ╯ 
    . ≡(□ ⊚)
    ## {[0] [1] [2 3] [3]} {[0] [1] [2] [0 3]} {[0 2] [1] [2] [3]} 
    ≡(=2⧻ °□)
    ## [0 0 1 0] [0 0 0 1] [1 0 0 0] 
    ⊚
    ## [2] [3] [0] 
    ⊢
    ## 2 3 0 
    ⊏
    ## ⟦2 3⟧ ⟦0 3⟧ ⟦0 2⟧ 
    °□
    ## [2 3] [0 3] [0 2] 
    ⊏
    ## [2 8] [9 3] [3 6] 
    ⊏⍏.
    ## [2 8] [3 9] [3 6] 
    /÷
    ## 4 3 2 
  )
  /+
  ## 9 
)

# ---------------------------------

# $ 5 1 9 5
# $ 7 5 3
# $ 2 4 6 8

$ 5 9 2 8
$ 9 4 7 3
$ 3 8 6 5

# &fras "./d2.dat"

⊃PartOne PartTwo ParseLineByLine
# 47623 312
