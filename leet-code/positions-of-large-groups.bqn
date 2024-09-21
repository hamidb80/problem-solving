# https://leetcode.com/problems/positions-of-large-groups/description/
# Positions of Large Groups

PostionOfLargestGroups ← {
  a ← 0 ∾ ⥊1(⌽≡⊢) ˘ 2↕' '∾𝕩
  b ← (↕¯1+≠a) ∧ (≠´)˘2↕a
  c ← ↑‿2⥊×⊸/b
  ¯1+c/˜(¯2≥-´)˘c
}

PostionOfLargestGroups "abbxxxxzzy"
PostionOfLargestGroups "abc"
PostionOfLargestGroups "abcdddeeeeaabbbcd"
