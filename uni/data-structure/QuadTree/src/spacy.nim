import std/[dom, math]
import bumpy, vmath, glob, config, utils


type
  Entry* = ref object
    id*: int
    el*: Element
    location*: Point
    isFound*: bool

  QuadSpace* = ref object
    root*: QuadNode
    maxData*: int

  QuadNode* = ref object
    data*: seq[Entry]
    nodes*: seq[QuadNode]
    geometry*: Rect
    level*: int
    isProbed*: bool
    el*: Element


converter toVec2(p: Point): Vec2 =
  vec2 p.x, p.y


proc genCircle*(e: Entry): Element =
  result = newSvgEl "circle"
  for (p, v) in {"cx": $e.location.x, "cy": $e.location.y, "class": "point"}:
    result.setAttr p.K, v.K

  
  if e.isFound:
    result.classList.add K"special"


proc genBorder*(qn: QuadNode): Element =
  result = newSvgEl "rect"

  for (p, v) in {
    "x": qn.geometry.x + canvasMargin,
    "y": qn.geometry.y + canvasMargin,
    "width": qn.geometry.w,
    "height": qn.geometry.h}:

    result.setAttr K(p), K($v)

  result.setAttr K"class", K"border"
  if qn.isProbed:
    result.classList.add: 
      if qn.data.len != 0: K"final"
      else: K"special"


proc newQuadNode(geometry: Rect, level = 0): QuadNode =
  result = QuadNode()
  result.geometry = geometry
  result.level = level

proc newQuadSpace*(geometry: Rect, maxData: int): QuadSpace =
  result = QuadSpace()
  result.root = newQuadNode(geometry)
  result.maxData = maxData

proc insert*(qs: QuadSpace, e: Entry)
proc insert*(qs: QuadSpace, qn: var QuadNode, e: Entry)

proc whichQuadrant(qs: QuadNode, e: Entry): int =
  let
    xMid = qs.geometry.x + qs.geometry.w/2
    yMid = qs.geometry.y + qs.geometry.h/2

  if e.location.x < xMid:
    if e.location.y < yMid: 0
    else: 1
  else:
    if e.location.y < yMid: 2
    else: 3

proc split(qs: QuadSpace, qn: var QuadNode) =
  let
    x = qn.geometry.x
    y = qn.geometry.y
    w = qn.geometry.w/2
    h = qn.geometry.h/2

  let lvl = qn.level+1

  qn.nodes = @[
    newQuadNode(Rect(x: x, y: y, w: w, h: h), lvl),
    newQuadNode(Rect(x: x, y: y+h, w: w, h: h), lvl),
    newQuadNode(Rect(x: x+w, y: y, w: w, h: h), lvl),
    newQuadNode(Rect(x: x+w, y: y+h, w: w, h: h), lvl)]

  for e in qn.data:
    let index = qn.whichQuadrant(e)
    qs.insert(qn.nodes[index], e)

  qn.data.setLen(0)

proc insert(qs: QuadSpace, qn: var QuadNode, e: Entry) =
  if qn.nodes.len != 0:
    let index = qn.whichQuadrant(e)
    qs.insert(qn.nodes[index], e)

  else:
    qn.data.add e
    if qn.data.len > qs.maxData:
      qs.split(qn)

proc insert*(qs: QuadSpace, e: Entry) =
  qs.insert(qs.root, e)

proc clear*(qs: QuadSpace) {.inline.} =
  qs.root.nodes.setLen(0)
  qs.root.data.setLen(0)

iterator allNodes*(qs: QuadSpace): QuadNode =
  var nodeStack = @[qs.root]
  while nodeStack.len > 0:
    var qs = nodeStack.pop()
    yield qs

    for node in qs.nodes:
      nodeStack.add node

iterator allEntries*(qs: QuadSpace): Entry =
  var nodes = @[qs.root]
  while nodes.len > 0:
    var qs = nodes.pop()
    if qs.nodes.len == 4:
      for node in qs.nodes:
        nodes.add(node)
    else:
      for e in qs.data:
        yield e

iterator findInRangeApprox*(qs: QuadSpace, p: Point, radius: float): Entry =
  ## Iterates all entries in range of an entry but does not cull them.
  ## Useful if you need distance anyways and will compute other computations.
  var nodes = @[qs.root]
  while nodes.len > 0:
    var qs = nodes.pop()
    if qs.nodes.len == 4:
      for node in qs.nodes:
        if circle(p, radius).overlaps(node.geometry):
          node.isProbed = true
          nodes.add(node)
    else:
      for e in qs.data:
        yield e

proc findInRange*(qs: QuadSpace, p: Point, radius: float) =
  let radiusSq = radius ^ 2
  for thing in qs.findInRangeApprox(p, radius):
    if thing.location.distSq(p) < radiusSq:
      thing.isFound = true
