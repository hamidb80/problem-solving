import std/[strutils, sequtils, math, algorithm]

# echo stdin.readLine.split(" ").mapIt(it.parseInt ^ 2).sorted

echo stdin.
  readLine.
  split(" ").
  mapIt(it.parseInt ^ 2).
  sorted
