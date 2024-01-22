import std/[strutils, tables]

type 
    Repeat = array[2, int]


func `+`(a, b: Repeat): Repeat =
    [a[0] + b[0], a[1] + b[1]]

func n2n3(id: string): Repeat =
    for v in values toCountTable id:
        case v
        of 2: result[0] = 1
        of 3: result[1] = 1
        else: discard

func diff(a, b: string): Natural =
    for i, c1 in a:
        if c1 != b[i]:
            inc result

func common(a, b: string): string =
    for i, c1 in a:
        if c1 == b[i]:
            add result, c1

func part1(boxIds: seq[string]): int =
    var acc: Repeat = [0, 0]
    for id in boxIds:
        acc = acc + n2n3(id)
    acc[0] * acc[1]

func part2(boxIds: seq[string]): string =
    for a in boxIds:
        for b in boxIds:
            if diff(a, b) == 1:
                return common(a, b)

when isMainModule:
    let data = splitLines readFile "input.txt"
    echo part1 data
    echo part2 data
