# https://leetcode.com/problems/projection-area-of-3d-shapes/description/

ProjArea ← {
 x ← +´ ⌈˝   𝕩
 y ← +´ ⌈˝  ⍉𝕩
 z ← +´ ×   ⥊𝕩
 x+y+z
}

•Show ProjArea [[1,2],[3,4]]
•Show ProjArea [[2]]
•Show ProjArea [[1,0],[0,2]]
'.'