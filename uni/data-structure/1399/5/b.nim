import std/[random, deques]

type
  Queue = Deque
  Client = object

proc answer(c: Client) = discard
template dequeue(q): untyped = q.popFirst
  

var priorityArray: array[4, Queue[Client]]
proc trigger() =
  let
    rnd = rand(1 .. 100)
    index = case rnd:
      of 1 .. 40: 0
      of 41 .. 70: 1
      of 71 .. 90: 2
      else: 3

  let selectedClient = priorityArray[index].dequeue()
  answer selectedClient



when isMainModule:
  trigger()