from pprint import pprint

class SparseMatrix:
    # SparseMatrix = Table[int, Table[int, int]]
    data = None
    cap = None

    def __init__(sm): 
      sm.data = {}
      sm.cap = 0

    def insert(sm, row, col, value):
        if row not in sm.data:
            sm.data[row] = {}

        sm.cap = max(sm.cap, row, col)
        sm.data[row][col] = value

    def remove(sm, row, col):
        if row in sm.data:
            if col in sm.data[row]:
                del sm.data[row][col]

    def put(sm, row, col, val):
        if val == 0:
            sm.remove(row, col)
        else:
            sm.insert(row, col, val)

    def get(sm, row, col):
        if row in sm.data:
            if col in sm.data[row]:
                return sm.data[row][col]

        return 0

    def toArray(sm):
        size = sm.cap
        result = []

        for _ in range(size):
          result.append([0] * size) 

        for y in sm.data:
            for x, val in sm.data[y].items():
                result[y][x] = val

        return result

    def elementWiseOperation(sm1, sm2, fn):
        assert(sm1.cap == sm2.cap)
        result = SparseMatrix()
        result.cap = sm1.cap

        for y in sm1.data:
            for x in sm1.data[y]:
                result.put(y, x, fn(sm1.get(y, x), sm2.get(y, x)))

        return result

    def __add__(sm1, sm2):
        return sm1.elementWiseOperation(sm2, lambda a, b: a + b)

    def __mul__(sm1, sm2):
        return sm1.elementWiseOperation(sm2, lambda a, b: a * b)

    def __sub__(sm1, sm2):
        return sm1.elementWiseOperation(sm2, lambda a, b: a - b)


def fromArray(arr2d):
    assert(len(arr2d) == len(arr2d[0]))
    
    result = SparseMatrix()
    result.cap = len(arr2d)

    for y in range(len(arr2d)):
        for x in range(len(arr2d[y])):
            v = arr2d[y][x]
            if v != 0:
                result.put(y, x, v)

    return result


class Graph:
    # Graph = object
    #   nameIdMap: Table[string, int]
    #   idNameMap: Table[int, string]
    #   matrix[bool]
    #   idTracker

    nameIdMap = {}
    idNameMap = {}
    matrix = SparseMatrix()
    idTracker = 0

    def __init__(self): pass

    def genId(g, node):
        result = g.idTracker
        g.idTracker += 1
        g.idNameMap[result] = node

        return result

    def getId(g, node):
        return g.nameIdMap[node]

    def put(g, n1, n2, v):
        id1, id2 = g.getId(n1), g.getId(n2)
        g.matrix.put(id1, id2, v)

    def addRel(g, n1, n2):
        g.put(n1, n2, 1)

    def delRel(g, n1, n2):
        g.put(n1, n2, 0)

    def insert(g, node):
        id = g.genId(node)
        g.nameIdMap[node] = id
        g.addRel(node, node)

    def rels(g, node):  # AKA get_similars
        result = []

        nid = g.getId(node)
        for rid, row in g.matrix:
            if row[nid]:
                result.append(g.idNameMap[rid])

        return result

    def allRels(g):
        result = []
        for yid, row in g.matrix.data.items():
            for xid in row:
                if yid != xid:
                    result.append((g.idNameMap[yid], g.idNameMap[xid]))

        return result

    def remove(g, node):
        id = g.getId(node)

        for yid in g.matrix.data:
            g.put(yid, id, 0)


if __name__ == "__main__":
    m1 = fromArray([
        [0, 0, 0, 0],
        [2, 0, 1, 0],
        [0, 0, 0, 0],
        [0, 0, 1, 0],
    ])
    m2 = fromArray([
        [0, 0, 0, 0],
        [0, 0, 7, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
    ])

    pprint(m1.toArray())
    pprint(m2.toArray())
    pprint((m1 - m2).toArray())

    g = Graph()
    for node in ["A", "B", "C", "D", "E", "F"]:
        g.insert(node)

    for (a, b) in [("A", "B"), ("B", "C"), ("B", "D")]:
        g.addRel(a, b)

    g.delRel("B", "D")

    for (a, b) in g.allRels():
        print(a, " -> ", b)
