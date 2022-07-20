# =================================================== Imports

from random import randrange

# --- Jupyter Notebook things
from IPython.display import display

# --- my codes
from defs import *
from utils import *


# =================================================== Process

def gen_random_entries(n: int, max_width, max_height) -> list[Entry]:
    """
    Generates `n` random Entries to insert in `QuadSpace`
    """

    result = []

    for i in range(n):
        x, y = randrange(0, max_width),  randrange(0, max_height)
        e = Entry(i, Point(x, y))
        result.append(e)

    return result


def gen_search_process(qs: QuadSpace, query: Geometry) -> list[Image]:
    """
    Visualizes the step-by-step process of searching in `qs`
    """

    result = []
    final_qnodes = []

    query_rect = SVG.toRect(query, "rgba(30, 200, 30, 0.3)")

    for n in range(0, 10):
        nodes = qs.find(query, n)

        ss1 = "".join([SVG.toRect(n.geometry, "rgba(0,0,0, 0.3)")
                      for n in final_qnodes])

        end = len(nodes) == 0
        if end:
            points = qs.find(query, -1)
            ss2 = "".join(
                [SVG.toCircle(p.location.x, p.location.y, 5, "purple") for p in points])
        else:
            ss2 = "".join([SVG.toRect(n.geometry, "rgba(0,0,150,0.3)")
                          for n in nodes])

        result.append(qs.snapshot(ss1 + ss2 + query_rect))

        if end:
            break

        for n in nodes:
            if n.is_leaf():
                final_qnodes.append(n)

    return result


def gen_add_process(qs: QuadSpace, entries: list[Entry]) -> list[Image]:
    """
    Visualizes the step-by-step process of inserting to `qs`

    The new point in each step is visualized differently
    e.g. bolder or different color
    """

    result = []

    for e in entries:
        qs.insert(e)
        newPoint = SVG.toCircle(e.location.x, e.location.y, 4, "purple")
        result.append(qs.snapshot(newPoint))

    return result

# =================================================== Go!

if __name__ == "__main__":
    W = 400
    H = 400

    qs = QuadSpace(Geometry(0, 0, W, H), 2)

    
    display(*gen_add_process(qs, gen_random_entries(40, W, H)))
    
    query = Geometry(
        randrange(0, int(W*2/3)), randrange(0, int(H*2/3)),
        randrange(20, int(W/3)), randrange(20, int(H/3)))
    display(*gen_search_process(qs, query))

