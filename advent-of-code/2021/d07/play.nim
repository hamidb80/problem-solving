import sequtils, strutils, tables, algorithm
import plotly

#[
  i though i have to do something with staticstics :D
  thats just examining my assumption, nothing more [it didn't work btw]
]#

type Point = tuple[x, y: int]

proc showInDiagram*(lines: varargs[seq[Point]]) =
  show Plot[int](
    layout: Layout(width: 1200, height: 400),
    traces: lines.mapit(Trace[int](
      mode: PlotMode.LinesMarkers,
      `type`: PlotType.Scatter,
      marker: Marker[int](size: @[16]),
      xs: it.mapit it[0],
      ys: it.mapit it[1]
  )))


proc sortByNumber(p1, p2: Point): int = 
  cmp(p1[0], p2[0])

let 
  numbers =
    readFile("./input.txt")
    .strip()
    .split(',')
    .map(parseint)

  numFreq = 
    numbers
    .toCountTable()
    .pairs()
    .toSeq()
    .sorted(sortByNumber)


showInDiagram numFreq

