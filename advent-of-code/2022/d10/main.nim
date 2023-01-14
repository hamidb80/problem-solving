import std/[sequtils, strutils]

# def ----------------------------------------

type
  Command = enum
    noop
    addx

  Instruction = object
    command: Command
    value: int

  Cycle = tuple
    clock: int
    reg: int

# utils --------------------------------------

func `+`[T](s: Slice[T], v: T): Slice[T] =
  s.a+v .. s.b+v

func delay(c: Command): int =
  case c
  of addx: 2
  of noop: 1

func parseInstruction(line: string): Instruction =
  let
    c = parseEnum[Command](line[0..3])
    v =
      case c
      of addx: parseInt line[5..^1]
      of noop: 0

  Instruction(command: c, value: v)

iterator instructions(d: string): Instruction =
  for l in d.splitLines:
    yield parseInstruction l

# implement ----------------------------------

iterator cycles(ins: seq[Instruction]): Cycle =
  var
    reg = 1
    cycle = 0

  for i in ins:
    for adj in 1..i.command.delay:
      cycle.inc
      yield (cycle, reg)

    reg.inc i.value

func signalStrength(clock, reg: int): int =
  clock * reg

func sumOfSignalStrength(ins: seq[Instruction], analytic: Slice[int], interval: int): int =
  for clock, reg in ins.cycles:
    if (clock-analytic.a) mod interval == 0:
      result.inc signalStrength(clock, reg)

func display(ins: seq[Instruction], width, height: int): string =
  let spritPos = -1..1

  for cycle, reg in ins.cycles:
    result.add:
      if ((cycle-1) mod width) in (spritPos+reg): '#'
      else: '.'

    if cycle mod width == 0:
      result.add '\n'

# go -----------------------------------------

let data = "./input.txt".readFile.instructions.toseq
echo data.sumOfSignalStrength(20 .. 220, 40) # 12980
echo data.display(40, 6) # BRJLFULP
