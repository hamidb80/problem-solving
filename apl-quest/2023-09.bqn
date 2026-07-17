FlipPairs ← {
  o ← 2|≠𝕩 # is odd
  t ← ⥊⌽˘⌊‿2 ⥊ 𝕩 # result for even case
  f ← ⊏⌽𝕩
  {o ? t ∾ f ; t}
}



•Show FlipPairs 1+↕10
# 2 1 4 3 6 5 8 7 10 9

•Show FlipPairs 1+↕9
# 2 1 4 3 6 5 8 7 9

•Show FlipPairs⎉1 4‿2⥊1+↕8
# 2 1
# 4 3
# 6 5
# 8 7

•Show FlipPairs⎉1 4‿3⥊1+↕12
#  2  1  3
#  5  4  6
#  8  7  9
# 11 10 12

•Show FlipPairs⎉1 3‿3‿3⥊1+↕27
# 2  1  3
# 5  4  6
# 8  7  9
# 
# 11 10 12
# 14 13 15
# 17 16 18
# 
# 20 19 21
# 23 22 24
# 26 25 27

•Show FlipPairs⎉1 2‿3 ⥊ "donald"‿"duck"‿"wrote"‿"some"‿"good"‿"APL"
#┌────┬──────┬─────┐
#│duck│donald│wrote│
#├────┼──────┼─────┤
#│good│some  │APL  │
#└────┴──────┴─────┘

--------------
