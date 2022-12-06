import std/[setutils]

# utils --------------------------------------

func uniqueChars(s: string): bool =
  s.toSet.len == s.len

# implement ----------------------------------

iterator window(s: string, size: int): tuple[content: string, indexes: Slice[int]] =
  for i in 0..s.len-size:
    let indexes = i .. i + size - 1
    yield (s[indexes], indexes)

func endOfnotRepeatedSeq(data: string, size: int): int =
  for (sub, indexes) in window(data, size):
    if sub.uniqueChars:
      return indexes.b + 1

# go -----------------------------------------

let data = readFile "./input.txt"
echo endOfnotRepeatedSeq(data, 4) # 1140
echo endOfnotRepeatedSeq(data, 14) # 3495
