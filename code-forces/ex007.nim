## problem description: https://codeforces.com/contest/847/problem/B

import std/[strutils, sequtils]

discard stdin.readLine
var unUsedNumbers = stdin.readLine.splitWhitespace.map parseInt

while unUsedNumbers.len != 0:
    var usedNumbers: seq[int]

    for un in unUsedNumbers:
        if usedNumbers.len == 0 or un > usedNumbers[^1]:
            usedNumbers.add un

    echo usedNumbers.join " "
    unUsedNumbers = unUsedNumbers.filterit it notin usedNumbers
