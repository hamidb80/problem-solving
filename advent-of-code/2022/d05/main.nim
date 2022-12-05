import std/[strutils, strscans]

# def ----------------------------------------

type
  ParserState = enum
    stacks, instructions

  Instruction = tuple
    size, source, dest: int

  Stack[T] = seq[T]

  Data = object
    bars: seq[Stack[char]]
    instructions: seq[Instruction]

# utils --------------------------------------

func pops[T](source, dest: var seq[T], size: int) =
  for i in 1..size:
    dest.add source.pop

# implement ----------------------------------

func parseInstruction(line: string): Instruction =
  discard line.scanf("move $i from $i to $i", result.size, result.source, result.dest)

func parse(data: string): Data =
  var ps = stacks

  for line in data.splitLines:
    case ps
    of stacks:
      if result.bars.len == 0:
        result.bars.setLen line.len div 4 + 1

      elif line.len == 0:
        ps = instructions

      if '[' in line:
        for i in countup(1, line.high, 4): # 1 5 9 ...
          if line[i] != ' ':
            let barIndex = (i-1) div 4
            result.bars[barIndex].insert line[i], 0

    of instructions:
      result.instructions.add parseInstruction line

func part1(data: Data): string =
  result.setlen data.bars.len

  var stacks = data.bars

  for ins in data.instructions:
    pops stacks[ins.source - 1], stacks[ins.dest - 1], ins.size

  for s in stacks:
    result.add s[s.high]

func part2(data: Data): string =
  result.setlen data.bars.len

  var stacks = data.bars

  for ins in data.instructions:
    let
      si = ins.source - 1
      di = ins.dest - 1
    stacks[di].add stacks[si][^ins.size..^1]
    stacks[si].setlen stacks[si].len - ins.size

  for s in stacks:
    result.add s[s.high]


# go -----------------------------------------

let data = parse readFile("./input.txt")
echo part1 data
echo part2 data
