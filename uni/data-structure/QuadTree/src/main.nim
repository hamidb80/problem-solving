import std/[jsconsole, dom, strformat, strutils, options]
import bumpy, std/random
import spacy, utils, config, glob

type
  AppMode = enum
    amAdd, amSearch

  CursorInfo = object
    radius: int
    position: Point

var
  mode = amAdd
  entries: seq[Entry]
  limit = 4
  radius: int
  lastSearchCursor: Option[CursorInfo]

template `%`(id): untyped =
  document.getElementById(id)

let
  cursor = %"pointer"
  board = %"board"
  limitInput = %"limit"
  radiusInput = %"radius"
  boardStyles = %"board-styles"


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

  block:
    let v = K $(size + canvasMargin * 2)
    svg.setAttr K"width", v
    svg.setAttr K"height", v

  for n in space.allNodes:
    n.el = genBorder n
    svg.appendChild n.el

  for e in entries:
    e.el = genCircle e
    svg.appendChild e.el

  if issome lastSearchCursor:
    let 
      cr = lastSearchCursor.get
      p = cr.position

    svg.appendChild:
      var cEl = newSvgEl "circle"

      for (p, v) in {"cx": $p.x, "cy": $p.y, "r": $cr.radius, "class": "last-cursor"}:
        cEl.setAttr p.K, v.K

      cEl


  console.clear
  console.log space

  board.innerHTML = ""
  board.appendChild svg


# ----------------------------------------------


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
    lastSearchCursor = some CursorInfo(position: p, radius: radius)
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

# ----------------------------------------------

proc resetDepthShow =
  boardStyles.innerHTML = K""

proc showDepth(n: int) {.exportc.} =
  resetDepthShow()

  var r: seq[string]

  if n != -1:
    for l in 1 .. 5:
      r.add:
        if l < n:
          fmt""".level-{l}:not(.final) {{
            fill: transparent !important;
          }}"""

        elif l > n:
          fmt""".level-{l} {{
            fill: transparent !important;
          }}"""
        
        else:
          ""

  boardStyles.innerHTML = K r.join

proc render =
  buildSpace()
  reDraw()

proc resetApp {.exportc.} =
  setlen entries, 0
  space = genSpace()
  
  reset lastSearchCursor
  resetDepthShow()
  render()

proc addMode {.exportc.} =
  mode = amAdd

proc searchMode {.exportc.} =
  mode = amSearch

proc genRandom {.exportc.} =
  for i in 1..100:
    addToEntries Point(x: rand size, y: rand size)

  render()

# ----------------

block init:
  setRadius 30
  radiusInput.value = K $radius
  limitInput.value = K $limit
  render()
