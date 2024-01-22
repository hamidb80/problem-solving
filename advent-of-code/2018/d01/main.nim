import std/[strutils, math, sets]

func parseInput(s: string): seq[int] =
    for line in splitLines s:
        add result, parseint line

func part1(freqs: seq[int]): int =
    sum freqs

func part2(freqs: seq[int]): int =
    var
        seen = initHashSet[int]()
        acc = 0

    while true:
        for f in freqs:
            inc acc, f
            if acc in seen:
                return acc
            else:
                incl seen, acc

when isMainModule:
    let data = parseInput readFile "input.txt"
    echo part1 data
    echo part2 data
