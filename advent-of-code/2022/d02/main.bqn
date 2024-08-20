# Advent of Code year 2022 day 02 
# ideas from https://www.youtube.com/watch?v=aMm5aionsw8

inp ← "
A Y
B X
C Z
"

Parse ← {
 {'A'‿'X' -˜ 1‿3 ⊏ 𝕩}˘ ⌊‿4 ⥊ 𝕩
}

data       ← Parse              inp
gameRule   ←       (3|1+ -) ⌜˜  ↕3
matchTable ← ⍉     1‿2‿3    + gameRule×3

Part1 ← {⊑⟜matchTable ˘ 𝕩}
Part2 ← {Part1 3| +`˘ 0‿¯1 ⊸+ ˘ 𝕩}

⟨Part1 data, Part2 data⟩
