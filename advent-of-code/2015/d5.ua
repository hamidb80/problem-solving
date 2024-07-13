Text ← "ugknbfddgicrmopn aaa jchzalrnumimnmhp haegwjzuvuyypxyu dvszwmarrgswjxmb"
Text ← &fras "./d5.dat"
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

High ← - 1 ⧻ # similar to high function in Nim
Last ← ⊏ High .

IsHeadAndTailEq ← (
  ⊢ .
  Last
  =
)

HasRepeativeChars ← (
  °□
  ◫ 2
  ≡IsHeadAndTailEq
  /+
  /×
  ≠ 0
)

# --- part 1 ----------------------------

PartOne ← (
  ≡(
    .

    CountVowels
    >2

    ,
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
)

PartOne Words
## ".\\d5.ua:2:8: Opening files is not supported in this environment" 

# --- part 2 ----------------------------

# could not make it work
