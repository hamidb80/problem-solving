# AoC 2015 day 4

import std/strutils
import checksums/md5

template str(smth): untyped = $smth

proc smallestMd5startsWith(head, starter: string): int = 
  for n in 1..100000000:
    if toMD5(head & $n).str.startsWith starter:
      return n

echo smallestMd5startsWith("ckczppom", "00000")  # part 1
echo smallestMd5startsWith("ckczppom", "000000") # part 2
