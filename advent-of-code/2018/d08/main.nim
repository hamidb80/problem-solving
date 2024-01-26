import std/[
    strutils, 
    sequtils, 
    math]


type
    Node = ref object
        children: seq[Node]
        metadata: seq[int]


func extractNumbers(s: string): seq[int] =
    map splitWhitespace s, parseInt

func parseTreeImpl(numbers: seq[int], start: int, acc: var Node): int =
    let
        nchildren = numbers[start]
        nmeta = numbers[start+1]
    var
        index = start + 2

    for i in 1..nchildren:
        var temp = new Node
        index = parseTreeImpl(numbers, index, temp)
        add acc.children, temp

    acc.metadata = numbers[index ..< index + nmeta]
    index + nmeta

func parseTree(numbers: seq[int]): Node =
    result = new Node
    discard parseTreeImpl(numbers, 0, result)

func sumOfMeta(node: Node): int =
    (sum node.metadata) +
    sum map(node.children, sumOfMeta)

func sumOfMetaIndexed(node: Node): int =
    if node.children.len == 0:
        result = sum node.metadata
    else:
        for m in node.metadata:
            let i = m - 1
            if i in 0 .. high node.children:
                inc result, sumOfMetaIndexed node.children[i]

when isMainModule:
    let 
        content = 
            readFile "./input.txt"
            # "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
        node = parseTree extractNumbers content

    echo sumOfMeta node # part 1 :: 41454
    echo sumOfMetaIndexed node # part 2 :: 25752
