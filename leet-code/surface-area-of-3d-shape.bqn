# https://leetcode.com/problems/surface-area-of-3d-shapes/description/


Border        ← {(⊢↑˝·≍⟜(𝕨⊸-)(𝕨×2)+≢)𝕩} # appends border of 0 to the 𝕩 matrix with width of 𝕨
SurfaceArea3D ← {                         # problem description
  m ← 1 Border 𝕩
  z  ← +´ ⥊                         0≠m # Z-axis     sides
  h  ← +´|⥊( (2↑≢)⥊⊢)(1(↓-↑)˘(2⊸↕) )˘ m # horizontal sides
  v  ← +´|⥊( (2↑≢)⥊⊢)(1(↓-↑)˘(2⊸↕) )˘⍉m # vertical   sides
  z+z+h+v
}

•Show SurfaceArea3D [[1,2],[3,4]]
•Show SurfaceArea3D [[1,1,1],[1,0,1],[1,1,1]]
•Show SurfaceArea3D [[2,2,2],[2,1,2],[2,2,2]]
'.'