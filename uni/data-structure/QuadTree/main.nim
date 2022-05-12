import std/[jsffi, jsconsole, dom, xmltree, strtabs]
import vmath, bumpy, std/random
import spacy, utils, config, glob

var
  entries: seq[Entry]
  space = newQuadSpace(Rect(x: 0, y: 0, w: size, h: size), limit)

proc addToEntries(p: Point) =
  entries.add Entry(id: entries.len, location: p, el: genCircle p)

proc initWrapper: Element =
  newSvgEl "svg"

proc reDraw =
  space.clear

  for e in entries:
    space.insert e

  let svg = initWrapper()
  for (p, v) in {
    "width": $(size + canvasMargin * 2),
    "height": $(size + canvasMargin * 2)}:

    svg.setAttr K p, K v


  for e in space.allEntries:
    e.el = genCircle e.location
    svg.appendChild e.el

  for n in space.allNodes:
    n.el = genBorder n
    svg.appendChild n.el

  console.clear
  console.log space

  document.getElementById("board").innerHTML = ""
  document.getElementById("board").appendChild svg

# ----------------------------------------------

let board = document.getElementById("board")

board.addEventListener(cstring"click") do(ev: Event):
  # let
  #   emouse = MouseEvent ev
  #   p = Point(x: emouse.offsetX.float, y: emouse.offsetY.float)

  # addToEntries p


  reDraw()

# ----------------------------------------------

when isMainModule:
  for i in 1..100:
    addToEntries Point(x: rand size, y: rand size)

  reDraw()
