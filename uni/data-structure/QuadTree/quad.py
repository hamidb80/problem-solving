from pprint import *
from random import *
from dataclasses import *

from cairosvg import svg2png


@dataclass
class Point:
    x: float
    y: float

    def distance(p1, p2):
        (p1.x - p2.x)**2 + (p1.y - p2.y)**2


@dataclass
class Geometry:
    x: float
    y: float
    w: float
    h: float


@dataclass
class Entry:
    id: int
    location: Point


@dataclass
class QuadNode:
    entries: list
    nodes: list
    geometry: Geometry

    def whichQuadrant(qs, e) -> int:
        xMid = qs.geometry.x + qs.geometry.w/2
        yMid = qs.geometry.y + qs.geometry.h/2

        if e.location.x < xMid:
            if e.location.y < yMid:
                return 0
            else:
                return 1
        else:
            if e.location.y < yMid:
                return 2
            else:
                return 3


class QuadSpace:
    root: QuadNode
    limit: float

    def __init__(self, geo: Geometry, limit: int):
        self.limit = limit
        self.root = QuadNode(geometry=geo, nodes=[], entries=[])

    def split(qs, qn: QuadNode):
        x = qn.geometry.x
        y = qn.geometry.y
        w = qn.geometry.w/2
        h = qn.geometry.h/2

        qn.nodes = [
            QuadNode([], [], Geometry(x=x, y=y, w=w, h=h),),
            QuadNode([], [], Geometry(x=x, y=y+h, w=w, h=h),),
            QuadNode([], [], Geometry(x=x+w, y=y, w=w, h=h),),
            QuadNode([], [], Geometry(x=x+w, y=y+h, w=w, h=h),),
        ]

        for e in qn.entries:
            index = qn.whichQuadrant(e)
            qs._insert(qn.nodes[index], e)

        qn.entries = []

    def insert(self, e: Entry):
        self._insert(self.root, e)

    def _insert(qs, qn: QuadNode, e: Entry):
        if len(qn.nodes) != 0:
            index = qn.whichQuadrant(e)
            qs._insert(qn.nodes[index], e)

        else:
            qn.entries.append(e)

            if len(qn.entries) > qs.limit:
                qs.split(qn)

    def find(qs, p: Point, radius: float):
        result = []
        qs._find(qs.root, p, radius, result)
        return result

    def _find(qs, qn: QuadNode, p, r, acc):
        desiredDistance = r ** 2

        for n in qn.nodes:
          if intersects(n.geometry, Circle(x, y, r)):
            qs._find(n, p, r, acc)

        for e in qn.entries:
          if p.distance(e.location) < desiredDistance:
            acc.append(e)

    def image(qs):
        return svg2png(bytestring=qs.svgrepr())

    def svgrepr(qs):
        HEADER = f"""<?xml version="1.0" standalone="no"?>
          <svg width="{qs.root.geometry.w}" height="{qs.root.geometry.h}" 
          version="1.1" xmlns="http://www.w3.org/2000/svg">
          <rect x="0" y="0" width="{qs.root.geometry.w}" height="{qs.root.geometry.h}" fill="white"/>
        """

        svg_elements = []
        qs._svgrepr(qs.root, svg_elements)

        return "".join([HEADER, *svg_elements, "</svg>"])

    def _svgrepr(qs, qn, acc):
        for n in qn.nodes:
            acc.append(f"""
            <rect x="{n.geometry.x}" y="{n.geometry.y}" width="{n.geometry.w}" height="{n.geometry.h}" stroke="black" fill="transparent" stroke-width="5"/>
          """)
            qs._svgrepr(n, acc)

        for e in qn.entries:
            acc.append(f"""
            <circle cx="{e.location.x}" cy="{e.location.y}" r="3" stroke="red" fill="transparent" stroke-width="5"/>
          """)


if __name__ == "__main__":
    W = 400
    H = 400

    qs = QuadSpace(Geometry(0, 0, W, H), 2)

    for n in range(20):
        x, y = randrange(0, W),  randrange(0, H)
        p = Point(x, y)

        qs.insert(Entry(n, p))
        print(n, p)

    file1 = open("result.png", "wb")
    file1.write(qs.image())
    file1.close()

    print(qs.treerepr())

    pprint(qs)
