import std/threadpool

proc sayHi(i: int) {.thread.} =
  echo "Hi from " & $num


for i in 0..9:
  spawn sayHi(i)
