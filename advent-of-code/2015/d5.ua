Text ← "ugknbfddgicrmopn aaa jchzalrnumimnmhp haegwjzuvuyypxyu dvszwmarrgswjxmb"
# Text ← &fras "./d5.dat"
Words ← ♭ regex "\\w+" Text

CountChar ← /+ °□ =
CountVowels ← (
  "auieo"
  ∵CountChar
  /+
)

CountOfDisAllowed ← (
  ["ab" "cd" "pq" "xy"]
  ≡(⌕ : °□ :)
  /+
  /+
)

Last ← ⊏ -1 ⧻ .

IsHeadAndTailEq ← (
  .
  ⊢
  Last
  =
)

HasRepeativeChars ← (
  ## ⌜ugknbfddgicrmopn⌟ ⌜aaa⌟ ⌜jchzalrnumimnmhp⌟ ⌜haegwjzuvuyypxyu⌟ ⌜dvszwmarrgswjxmb⌟ 
  °□
  ## "ugknbfddgicrmopn" "aaa" "jchzalrnumimnmhp" "haegwjzuvuyypxyu" "dvszwmarrgswjxmb" 
  ◫ 2
  ## ╭─       ╭─       ╭─       ╭─       ╭─       
  ## ╷ "ug"   ╷ "aa"   ╷ "jc"   ╷ "ha"   ╷ "dv"   
  ##   "gk"     "aa"     "ch"     "ae"     "vs"   
  ##   "kn"          ╯   "hz"     "eg"     "sz"   
  ##   "nb"              "za"     "gw"     "zw"   
  ##   "bf"              "al"     "wj"     "wm"   
  ##   "fd"              "lr"     "jz"     "ma"   
  ##   "dd"              "rn"     "zu"     "ar"   
  ##   "dg"              "nu"     "uv"     "rr"   
  ##   "gi"              "um"     "vu"     "rg"   
  ##   "ic"              "mi"     "uy"     "gs"   
  ##   "cr"              "im"     "yy"     "sw"   
  ##   "rm"              "mn"     "yp"     "wj"   
  ##   "mo"              "nm"     "px"     "jx"   
  ##   "op"              "mh"     "xy"     "xm"   
  ##    ⋮⋮                ⋮⋮       ⋮⋮       ⋮⋮    
  ≡IsHeadAndTailEq
  /+
  /×
  ≠ 0
)

# --- part 1 ----------------------------

Words
≡(
  .
  .

  CountVowels
  >2

  :
  CountOfDisAllowed
  =0

  +

  :
  HasRepeativeChars ♭
  ≠0

  +
)
=3
⊚
⧻

# --- part 2 ----------------------------

# Words
# ≡(
#   ◫ 3
#   IsHeadAndTailEq
# )
