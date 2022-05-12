import std/[random, dom, jscore, jsconsole]
import vmath, bumpy
import spacy, config, glob


proc randVec2*(max: float): Vec2 =
  vec2 rand(max), rand(max)

proc newSvgEl*(tag: string): Element =
  document.createElementNS(K"http://www.w3.org/2000/svg", K tag)
