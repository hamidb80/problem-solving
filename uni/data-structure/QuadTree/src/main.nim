import std/[jsffi, jsconsole, dom, xmltree, strtabs, strformat, strutils]
import vmath, bumpy, std/random
import spacy, utils, config, glob

type
  AppMode = enum
    amAdd, amSearch

var
  mode = amAdd
  entries: seq[Entry]
  limit = 4
  radius: int

proc genSpace: QuadSpace =
  newQuadSpace(Rect(x: 0, y: 0, w: size, h: size), limit)

var space = genSpace()

proc addToEntries(p: Point) =
  var e = Entry(id: entries.len, location: p)
  entries.add e

proc initWrapper: Element =
  newSvgEl "svg"

proc buildSpace =
  for e in entries:
    e.isFound = false
    space.insert e


proc reDraw =
  let svg = initWrapper()
  for (p, v) in {
    "width": $(size + canvasMargin * 2),
    "height": $(size + canvasMargin * 2)}:

    svg.setAttr K p, K v

  for e in entries:
    e.el = genCircle e
    svg.appendChild e.el

  for n in space.allNodes:
    n.el = genBorder n
    svg.appendChild n.el


  console.clear
  console.log space

  document.getElementById("board").innerHTML = ""
  document.getElementById("board").appendChild svg


# ----------------------------------------------

let
  cursor = document.getElementById("pointer")
  board = document.getElementById("board")
  limitInput = document.getElementById("limit")
  radiusInput = document.getElementById("radius")

proc setRadius(r: int) =
  radius = r
  cursor.style.padding = K fmt"{r}px"

board.addEventListener(K"click") do(ev: Event):
  let
    emouse = MouseEvent ev
    p = Point(x: emouse.offsetX.float, y: emouse.offsetY.float)

  space.clear

  case mode:
  of amAdd:
    addToEntries p
    buildSpace()
    reDraw()

  of amSearch:
    buildSpace()
    space.findInRange(p, radius.toFloat)
    reDraw()

board.addEventListener(K"mousemove") do(ev: Event):
  let
    emouse = MouseEvent ev
    x = emouse.pageX
    y = emouse.pageY

  cursor.style.top = K fmt"{y}px"
  cursor.style.left = K fmt"{x}px"

limitInput.addEventListener(K"change") do(_: Event):
  limit = parseInt $limitInput.value

radiusInput.addEventListener(K"change") do(_: Event):
  setRadius parseInt $radiusInput.value


setRadius 30
radiusInput.value = K $radius
limitInput.value = K $limit

# ----------------------------------------------

proc render =
  buildSpace()
  reDraw()

proc resetApp {.exportc.} =
  entries.setlen 0
  space = genSpace()
  render()

proc addMode {.exportc.} =
  mode = amAdd

proc searchMode {.exportc.} =
  mode = amSearch

proc genRandom {.exportc.} =
  for i in 1..100:
    addToEntries Point(x: rand size, y: rand size)

  render()


render()
