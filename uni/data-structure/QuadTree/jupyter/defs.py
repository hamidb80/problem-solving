from dataclasses import *

# --- my personal utility functions
from utils import *

# --- Jupyter Notebook things
from IPython.display import Image

# =================================================== Basic Classes


@dataclass
class Range:
    start: float
    end: float

    def size(r):
        return r.end - r.start

    def insersects(r1, r2) -> bool:
        """
        determines wether the ranges `r1` & `r2` have intersection or not

        HAVING INTERSECTION:
        A: (0..4) ~ (2..6)
            +---(2)---+
        +--(1)---+

        B: (2..6) ~ (0..4)
        +---(2)---+
            +--(1)---+

        C: (2..3) ~ (0..6)
        +-----(2)------+
            +-(1)-+

        D: (0..6) ~ (2..3)
            +-(2)-+
        +-----(1)------+


        NO INTERSECTION:
        E: (0..4) ~ (5..9)
                    +--(2)---+
        +--(1)--+

        F: (5..9) ~ (0..4)
        +--(2)--+
                    +--(1)--+
        """

        s = min(r1.end, r2.end) - max(r1.start, r2.start)
        return (s > 0) and (s <= r1.size()) and (s <= r2.size())


@dataclass
class Point:
    x: float
    y: float


@dataclass
class Geometry:
    """
    mimics a rectangle
    """
    x: float
    y: float
    w: float
    h: float

    def intersects(g1, g2) -> bool:
        """
        checks wheter the 2 rectangle `g1` & `g2` intersects with
        each other or not
        """

        ix = Range(g1.x, g1.x + g1.w).insersects(Range(g2.x, g2.x + g2.w))
        iy = Range(g1.y, g1.y + g1.h).insersects(Range(g2.y, g2.y + g2.h))

        return (ix and iy)

    def contains(g, p: Point) -> bool:
        """
        checks wether point `p` is in the area of rectangle `g` or not
        """
        return (
            (p.x >= g.x and p.x <= (g.x + g.w)) and
            (p.y >= g.y and p.y <= (g.y + g.h)))

# =================================================== Main Classes


@dataclass
class Entry:
    """
    this class is used as "main thing" in the QuadSpace
    """
    id: int
    location: Point


@dataclass
class QuadNode:
    level: int
    geometry: Geometry
    nodes: list
    entries: list

    def which_quadrant(qn, p: Point) -> int:
        """
        with assumming point `p` intersects with QuadNode `qn`,
        determines the index of quadrant (sub QuadNode) in which `p` 
        belongs to
        """

        xMid = qn.geometry.x + qn.geometry.w/2
        yMid = qn.geometry.y + qn.geometry.h/2

        if p.x < xMid:
            if p.y < yMid:
                return 0
            else:
                return 1
        else:
            if p.y < yMid:
                return 2
            else:
                return 3

    def is_leaf(qn) -> bool:
        return len(qn.nodes) == 0


class QuadSpace:
    limit: int
    root: QuadNode

    def __init__(self, geo: Geometry, limit: int):
        self.limit = limit
        self.root = QuadNode(geometry=geo, nodes=[], entries=[], level=0)

    def split(qs, qn: QuadNode):
        """
        splits `qn` into 4 sub nodes and devides its entries
        """

        x = qn.geometry.x
        y = qn.geometry.y
        w = qn.geometry.w/2
        h = qn.geometry.h/2
        l = qn.level + 1

        qn.nodes = [
            QuadNode(entries=[], nodes=[], geometry=Geometry(
                x=x, y=y, w=w, h=h), level=l),
            QuadNode(entries=[], nodes=[], geometry=Geometry(
                x=x, y=y+h, w=w, h=h), level=l),
            QuadNode(entries=[], nodes=[], geometry=Geometry(
                x=x+w, y=y, w=w, h=h), level=l),
            QuadNode(entries=[], nodes=[], geometry=Geometry(
                x=x+w, y=y+h, w=w, h=h), level=l),
        ]

        for e in qn.entries:
            index = qn.which_quadrant(e.location)
            qs._insert(qn.nodes[index], e)

        qn.entries = []

    def insert(self, e: Entry):
        self._insert(self.root, e)

    def _insert(qs, qn: QuadNode, e: Entry):
        if not qn.is_leaf():
            index = qn.which_quadrant(e.location)
            qs._insert(qn.nodes[index], e)

        else:
            qn.entries.append(e)

            if len(qn.entries) > qs.limit:
                qs.split(qn)

    def find(qs, query: Geometry, level=-1) -> list:
        """
        if level == -1:
            finds "Point"s that intersect with query

        elif level in 0 .. n:
            finds "QuadNode"s in depth `level` that intersect with query
        """

        result = []
        qs._find(qs.root, query, result, level)
        return result

    def _find(qs, qn: QuadNode, query: Geometry, acc, level):
        if qn.level == level:
            acc.append(qn)

        for n in qn.nodes:
            if n.geometry.intersects(query):
                qs._find(n, query, acc, level)

        if level == -1:
            for e in qn.entries:
                if query.contains(e.location):
                    acc.append(e)

    # --- for sake of visualization

    def snapshot(qs, extra="") -> Image:
        """
        takes an image of `qs` and returns it as `IPython.Image`
        to display it later in "Jupyter Notebook"
        """
        p = "./temp.png"
        f = open(p, 'wb')
        f.write(qs.image(extra))
        f.close()
        return Image(filename=p)

    def image(qs, extra="") -> bytes:
        """
        returns `.PNG` binary of captured QuadSpace `qs`
        """
        return SVG.toPNG(qs.svgrepr(extra))

    def svgrepr(qs, extra) -> str:
        """
        converts QuadSpace `qs` into `.SVG`
        """

        HEADER = f"""<?xml version="1.0" standalone="no"?>
          <svg width="{qs.root.geometry.w}" height="{qs.root.geometry.h}" 
          version="1.1" xmlns="http://www.w3.org/2000/svg">
          <rect x="0" y="0" width="{qs.root.geometry.w}" height="{qs.root.geometry.h}" fill="white"/>
        """

        svg_elements = []
        qs._svgrepr(qs.root, svg_elements)

        return "".join([HEADER, *svg_elements, extra, "</svg>"])

    def _svgrepr(qs, qn, acc):
        for n in qn.nodes:
            acc.append(SVG.toRect(n.geometry))
            qs._svgrepr(n, acc)

        for e in qn.entries:
            acc.append(SVG.toCircle(e.location.x, e.location.y))
