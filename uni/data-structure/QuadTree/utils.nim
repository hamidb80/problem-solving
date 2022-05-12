import std/[dom]
import glob

proc newSvgEl*(tag: string): Element =
  document.createElementNS(K"http://www.w3.org/2000/svg", K tag)
