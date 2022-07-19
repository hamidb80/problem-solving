from PIL import Image
from pprint import *
from random import *
from dataclasses import *

from cairosvg import svg2png
from numpy import save


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

    def intersects(g1, g2):
        ...

    def contains(g, p):
        return (
            (p.x >= g.x and p.x <= (g.x + g.w)) and
            (p.y >= g.y and p.y <= (g.y + g.h))
        )


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

    def find(qs, p: Point,  query: Geometry):
        result = []
        qs._find(qs.root, p, radius, result)
        return result

    def _find(qs, qn: QuadNode, query: Geometry, acc):
        for n in qn.nodes:
            if n.geometry.intersects(query):
                qs._find(n, query, acc)

        for e in qn.entries:
            if query.contains(e.location):
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
            print(e)
            acc.append(f"""
            <circle cx="{e.location.x}" cy="{e.location.y}" r="3" stroke="red" fill="transparent" stroke-width="5"/>
          """)


def save_fileb(path, content):
    file1 = open(path, "wb")
    file1.write(content)
    file1.close()


def generate_gif(qs, entries, path):
    frames = []
    for e in entries:
        qs.insert(e)
        save_fileb("./temp.png", qs.image())
        frames.append(Image.open("./temp.png"))

    frame_one = frames[0]
    frame_one.save(path, format="GIF", append_images=frames,
                   save_all=True, duration=300, loop=0)


def gen_random_entries(n):
    result = []

    for i in range(n):
        x, y = randrange(0, W),  randrange(0, H)
        e = Entry(i, Point(x, y))
        result.append(e)

    return result


if __name__ == "__main__":
    W = 400
    H = 400

    qs = QuadSpace(Geometry(0, 0, W, H), 2)
    generate_gif(qs, gen_random_entries(20), "./ss.gif")

    pprint(qs)
