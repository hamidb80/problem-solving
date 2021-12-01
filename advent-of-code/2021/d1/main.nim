import strutils, sequtils, math

const inputPath = "./input.txt"

proc part1: int =
  var lastRecord = 0

  for record in lines inputPath:
    let currentRecord = parseInt(record)

    if currentRecord > lastRecord:
      result.inc

    lastRecord = currentRecord

  result - 1

proc part2: int = 
  var lastWindowSum = 0
  let measurements = 
    readfile(inputPath)
    .splitLines()
    .map(parseInt)

  for i in 0..(measurements.high - 2):
    let currentWindowSum = measurements[i..(i+2)].sum()

    if currentWindowSum > lastWindowSum:
      inc result

    lastWindowSum = currentWindowSum

  result - 1


echo part1()
echo part2()