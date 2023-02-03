import std/[sequtils, strutils, nre, tables]

# def ----------------------------------------

type
  Valve = object
    flowRate: int
    leadsTo: seq[string]

# utils --------------------------------------

func parseValve(s: string): tuple[name: string, valve: Valve] =
  let f = s.findall re"[A-Z]{2}|\d+"
  (f[0], Valve(flowRate: f[1].parseInt, leadsTo: f[2..^1]))

func parseValves(s: string): Table[string, Valve] =
  for l in s.splitLines:
    let (n, v) = parseValve l
    result[n] = v

# implement ----------------------------------

func bestRelease(vtab: Table[string, Valve], time: int, start: string): int =
  discard

# go -----------------------------------------

let vtab = "./test.txt".readFile.parseValves
echo vtab.bestRelease(30, "AA")
