import strutils, sugar

# functionalitites ------------------------------------------

type Inctruction = object
  command: string
  value: int

func parseInstruction(line: string): Inctruction =
  let sl = line.splitWhitespace
  Inctruction(command: sl[0], value: sl[1].parseInt)


template findIndexIt(s: typed, pred: untyped): int =
  var result = -1

  for i, it{.inject.} in s:
    if pred:
      result = i
      break

  result
# preparing data -------------------------------------------

var instructions = collect newSeq: # i just learned collect
  for line in "./input.txt".readFile.splitLines:
    line.parseInstruction

# code ----------------------------------------------------

block part1:
  var
    visitedLines: seq[int]
    line = 0
    accumulator = 0

  while true:
    visitedLines.add line
    let ins = instructions[line]

    case ins.command:
    of "jmp":
      line.inc ins.value
    of "acc":
      accumulator.inc ins.value
      line.inc
    of "nop":
      line.inc
    else:
      raise newException(ValueError, "undefined command")

    if line in visitedLines:
      echo accumulator
      break part1

block part2:

  func isReversable(lastCommand: string): bool =
    lastCommand in ["jmp", "nop"]
  func reverse(lastCommand: string): string =
    case lastCommand:
    of "jmp": "nop"
    of "nop": "jmp"
    else:
      raise newException(ValueError, "the command is not in 'jmp' or 'nop'")

  # fix the app ------------------------
  var
    lineHistory: seq[int]
    line = 0
    changedInsLine = -1

  while line < instructions.len:
    if line in lineHistory:
      template ins: untyped = instructions[changedInsLine]

      if changedInsLine != -1:
        ins.command = ins.command.reverse
        lineHistory = lineHistory[0 ..< (lineHistory.findIndexIt it ==
            changedInsLine)]

      changedInsLine = lineHistory.pop
      while changedInsLine > 0:
        if ins.command.isReversable:
          ins.command = ins.command.reverse
          break

        changedInsLine = lineHistory.pop
      line = changedInsLine

    lineHistory.add line

    let ins = instructions[line]
    line.inc:
      if ins.command == "jmp": ins.value
      else: 1 # "nop", "acc"

  # run the app ------------------------

  var accumulator = 0
  line = 0
  while line < instructions.len:
    let ins = instructions[line]
    case ins.command:
    of "jmp":
      line.inc ins.value
    of "nop":
      line.inc
    of "acc":
      accumulator.inc ins.value
      line.inc
    else: discard

  echo accumulator

