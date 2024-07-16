Sort ← ⊏⍖.
ToCountTable ← Sort ⊕(⊂⊃(⧻|□⊢)) ⊛.
ToCountTable "Salama"

IsValid ← = ⧻ ◴ ⟜⧻
IsVVVVV ← (
  ## {"iiii" "oiii" "ooii"} {"oiii" "ioii" "iioi"}
  ≡(□ ToCountTable °□)
  ## ╭─                                ╭─
  ##             ╓─        ╓─            ╓─        ╓─        ╓─
  ##   ╓─        ╟ □3 ⌞i   ╟ □2 ⌞o       ╟ □3 ⌞i   ╟ □3 ⌞i   ╟ □3 ⌞i
  ##   ╟ □4 ⌞i     □1 ⌞o     □2 ⌞i         □1 ⌞o     □1 ⌞o     □1 ⌞o
  ##           ╜         ╜         ╜             ╜         ╜         ╜
  ##                                 ╯                                 ╯
  .
  ## ╭─                                ╭─
  ##             ╓─        ╓─            ╓─        ╓─        ╓─
  ##   ╓─        ╟ □3 ⌞i   ╟ □2 ⌞o       ╟ □3 ⌞i   ╟ □3 ⌞i   ╟ □3 ⌞i
  ##   ╟ □4 ⌞i     □1 ⌞o     □2 ⌞i         □1 ⌞o     □1 ⌞o     □1 ⌞o
  ##           ╜         ╜         ╜             ╜         ╜         ╜
  ##                                 ╯                                 ╯
  ⊞=
  ## ╭─        ╭─
  ## ╷ 1 0 0   ╷ 1 1 1
  ##   0 1 0     1 1 1
  ##   0 0 1     1 1 1
  ##         ╯         ╯
  ≡/+
  ## [1 1 1] [3 3 3]
  /×
  ## 1 27
  =1
)

PartOne ← /+≡(IsValid °□)
PartTwo ← /+≡(IsVVVVV °□)

# --------------------------------

# $ aa bb cc dd ee
# $ aa bb cc dd aa
# $ aa bb cc dd aaa
# $ abcde fghij
# $ abcde xyz ecdab
# $ a ab abc abd abf abj

# $ iiii oiii ooii oooi oooo
# $ oiii ioii iioi iiio

$ iiii oiii ooii
$ oiii ioii iioi

# &fras "./d4.dat"

♭ regex "[^\n]+"
≡(□ ♭regex "\\w+")
## {{"iiii" "oiii" "ooii"} {"oiii" "ioii" "iioi"}}

⊃PartOne PartTwo # 466 251
