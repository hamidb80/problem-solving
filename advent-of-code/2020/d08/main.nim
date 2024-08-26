import strutils, sugar

# functionalitites ------------------------------------------

type Instruction = object
  command: string
  value: int

func parseInstruction(line: string): Instruction =
  Instruction(command: line[0..<3], value: line[4..^1].parseInt)

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

func run(instructions: var seq[Instruction], loopDetector: static[bool]): tuple[
    isFinished: bool, acc: int] =

  when loopDetector:
    var visitedLines: seq[int]

  var
    line = 0
    acc = 0

  while line <= instructions.high:
    when loopDetector:
      visitedLines.add line

    let ins = instructions[line]
    case ins.command:
    of "jmp":
      line.inc ins.value
    of "acc":
      acc.inc ins.value
      line.inc
    else: # "nop"
      line.inc

    when loopDetector:
      if line in visitedLines:
        return (false, acc)

  (true, acc)

block part1: # stop the app before loop
  echo run(instructions, true).acc

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

  while line < instructions.len: # until end of the app
    if line in lineHistory: # if you've seen this line before
      template ins: untyped = instructions[changedInsLine]

      if changedInsLine != -1: # if you tried to fix the code before
        ins.command = ins.command.reverse
        lineHistory = lineHistory[
          0 ..< (lineHistory.findIndexIt it == changedInsLine)]

      changedInsLine = lineHistory.pop
      while changedInsLine > 0: # select an earlier line
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

  echo run(instructions, false).acc