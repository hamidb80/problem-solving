import std/[xmltree, strtabs, tables, strformat, random, lenientops, sugar]
import labeledtypes, chroma # nimble install ...

# Data Structures --------------------------------------------

type
  Movement = tuple
    element: int
    path: Slice[int]

  Transition = tuple
    order: int
    beneath: int
    movement: Movement

  ReducedTransition = seq[(element_index: int) !> (transitions: seq[Transition])]

  Disk = object
    x, y, w, h: int
    fill: string

# Utils ------------------------------------------------------

proc randomRGB: ColorRGB =
  rgb rand(255).uint8, rand(255).uint8, rand(255).uint8

proc add(x: var XmlNode, nodes: openArray[XmlNode]) =
  for n in nodes:
    x.add n

# Main -------------------------------------------------------

func hanoiImpl(i, start, dest, aux: int, result: var seq[Movement]) =
  if i != -1:
    hanoiImpl i-1, start, aux, dest, result
    result.add (i, start..dest)
    hanoiImpl i-1, aux, dest, start, result

func hanoi(n: int): seq[Movement] =
  hanoiImpl n-1, 0, 2, 1, result

func reduced(ms: seq[Movement], n: int): ReducedTransition =
  result.setLen n
  var stacks = [n, 0, 0]

  for i, m in ms:
    result[m.element].add (i, stacks[m.path.b], m)
    dec stacks[m.path.a]
    inc stacks[m.path.b]

# Visulazation -----------------------------------------------

func svgAnime[T](attr: string, t: Slice[T], s, d: float): XmlNode =
  result = <>animate(
    attributeType = "XML",
    attributeName = attr,
    begin = $s & "s",
    to = $t.b,
    fill = "freeze",
    dur = $d & "s")

  result.attrs["from"] = $t.a

func svgRect(x, y, w, h: int, color: string): XmlNode =
  <>rect(
    x = $x,
    y = $y,
    width = $w,
    height = $h,
    fill = color)

func svgWrapper(w, h: int): XmlNode =
  <>svg(
    viewBox = fmt"0 0 {w} {h}",
    xmlns = "http://www.w3.org/2000/svg")

proc visualize(ts: ReducedTransition): XmlNode =
  const
    # screen
    screenWidth = 400
    screenHeight = 300

    # towers
    ty = 40
    th = 200
    tw = 20
    tc = "#666"

    txs = [100, 200, 300]

    # footer
    fy = 240
    fh = 30
    fc = "#ccc"
    fpadx = 20

    # disks
    dh = 20
    dtop = 20
    dMinW = 40
    dMaxW = 120
    dad = 0.4

  let
    n = ts.len
    dwIncStep = (dmaxw - dminw) div ts.len


  func setx(tx, dw: int): int =
    tx - dw div 2 + tw div 2

  func sety(beneath: int): int =
    fy - dh * beneath


  var
    disks = collect:
      for i in 0..ts.high:
        let w = dminw + i*dwIncStep
        Disk(
          x: setx(txs[0], w),
          y: sety(n-i),
          w: w,
          h: dh,
          fill: randomRGB().asColor.toHtmlHex)


  result = svgWrapper(screenWidth, screenHeight)
  result.add svgRect(fpadx, fy, screenWidth - 2 * fpadx, fh, fc)

  for x in txs:
    result.add svgRect(x, ty, tw, th, tc)

  for i, d in disks.mpairs:
    var r = svgRect(d.x, d.y, d.w, d.h, d.fill)

    for a in ts[i]:
      let
        p = a.movement.path
        newy = sety(a.beneath+1)

      r.add [
        svgAnime("y", d.y..dtop, a.order * 5 * dad, dad),
        svgAnime("x", setx(txs[p.a], d.w)..setx(txs[p.b], d.w), (a.order*5+1)*dad, dad),
        svgAnime("y", dtop..newy, (a.order * 5 + 2) * dad, dad)]

      d.y = newy

    result.add r

# GO! --------------------------------------------------------

when isMainModule:
  randomize()
  writeFile "play.svg", $ hanoi(6).reduced(6).visualize
