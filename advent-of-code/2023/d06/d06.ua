⊬ ← ⊏ 1  # second
² ← ×.   # square
⊶ ← +1/- # length of a range  |[a b]| = b - a + 1

# calculates Delta
# Δ =  b² - 4(a)(c)
Δ ← (
  # input: a b c
  # b² - 4ac
  ⊃(∘|⋅⋅∘|²⋅∘)
  -××4
)

# solves quadradic equation
# ax² + bx + c = 0  -->  x₁₂ = -b±√Δ/2a
# returns [x₁ x₂]
⊍ ← (
  ⊃(√Δ|¯⋅∘|×2∘) # √Δ -b 2a
  ⊂⊃(+|-)
  ÷:
)

# ways to win:
#     speed     x time      > record
# ==> time_Hold x Time_rest > Distance
# ==>  T x (T-H)   > D
# ==> -H² + TH - D > 0
⏣ ← (
  # [total_Time Distance] : [T D]

  # solve quadradic equation with coefficients of ¯1 T ¯D
  ⊍ ¯1 ⊃(⊢|¯⊬)
  # add a tiny number to satisfy `>` condition
  +[∘ ¯ . ¯1e-13]
  # [ceil first, floor second] to
  [⌈⊢ : ⌊⊬ .]
  # calculate length
  ⊶
)

PartOne ← (
  ## ╭─         ╭─
  ## ╷  71530   ╷ 7 15  30
  ##   940200     9 40 200
  ##          ╯            ╯
  ⍉
  ## ╭─               ╭─
  ## ╷ 71530 940200   ╷  7   9
  ##                ╯   15  40
  ##                    30 200
  ##                           ╯
  ≡⏣
  ## [71503] [4 8 9]
  /×
  ## 71503 288
)

PartTwo ← (
  ## ╭─
  ## ╷ 7 15  30
  ##   9 40 200
  ##            ╯
  °⋕
  ≡/⍚⊂
  ⋕
  ## [71530 940200]
  ¤
  ⍉
  ## ╭─
  ## ╷  71530
  ##   940200
  ##          ╯
  PartOne
  ## 71503
)

"Go! ----------------------------------"

# &fras "./d06.dat"
"Time:      7  15   30\nDistance:  9  40  200"
⋕ regex ♭ "\\d+" # array of [time record]
↯ [2 ∞]

⊃PartOne PartTwo # 288 71503

"Tests --------------------------------"

# x² + 5x + 6 ==> (x+3)(x+2) ==> x=-3 x=-2
⊍ 1 5 6
## [¯2 ¯3]

# (1)x² + (5)x + (6) => 5² - 4(1)(6) = 25 - 24 = 1
Δ 1 5 6

⏣ [7 9] ## 1
⏣ [30 200] ## 4
