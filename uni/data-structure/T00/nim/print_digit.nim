import std/strutils


proc toNumber(c: char): int =
  c.ord - '0'.ord

when isMainModule:
  for c in stdin.readLine:
    echo c, ": ", repeat(c, c.toNumber)