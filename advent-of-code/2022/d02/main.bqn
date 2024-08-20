# Advent of Code year 2022 day 02 
# ideas from https://www.youtube.com/watch?v=aMm5aionsw8
# thanks to https://rosettacode.org/wiki/Read_entire_file

gameRule   ←       (3|1+ -) ⌜˜  ↕3
matchTable ← ⍉     1‿2‿3    + gameRule×3

Parse ← {{"AX" -˜ 0‿2 ⊏ 𝕩}˘ ↑‿4 ⥊ 𝕩}
Part1 ← {+´ ⊑⟜matchTable ˘ 𝕩}
Part2 ← {Part1 3| +`˘ 0‿¯1 ⊸+ ˘ 𝕩}
Solve ← {⟨Part1 𝕩, Part2 𝕩⟩}

# ---------------------------

inp ← "A Y
B X
C Z"
Solve Parse inp # •FChars "input.txt"
