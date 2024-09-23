# https://leetcode.com/problems/valid-mountain-array/description/

IsMountain ← {
  p ← 2↕𝕩
  a ← <´˘p
  b ← >´˘p
  c ← =´˘p
  (0=∨´c) ∧ (0= ∨´ a∧∨`b) ∧ (0⊑a)
}

•Show IsMountain [2,1]
•Show IsMountain [3,5,5]
•Show IsMountain [0,3,2]

•Show IsMountain [0,2,3,4,5,2,1,0]
•Show IsMountain [0,2,3,3,5,2,1,0]
'.'