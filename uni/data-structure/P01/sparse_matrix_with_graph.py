class SparseMatrix:
    data = None
    max_y = 0
    max_x = 0

    def __init__(self):
        self.data = {}

    def set(self, index, value):
        self.data[index] = value

        self.max_x = max(self.max_x, index[0])
        self.max_y = max(self.max_y, index[1])

    def get(self, index):
        if index in self.data:
            return self.data[index]
        else:
            return 0

    def delete(self, index):
        del self.data[index]

    def __add__(left, right):
        result = SparseMatrix()

        for index in left.data.keys():
            result.set(index, left.get(index) + right.get(index))

        for index in right.data.keys():
            if index not in result.data:
                result.set(index, right.get(index))

        return result

    def to_array(self):
        result = []

        for y in range(self.max_y + 1):
            row = []

            for x in range(self.max_x + 1):
                row.append(0)

            result.append(row)

        for index in self.data.keys():
            (x, y) = index
            result[y][x] = self.get(index)

        return result

# m1 = SparseMatrix()
# m1.set((1, 1), 5)
# m1.set((2, 1), 3)

# m2 = SparseMatrix()
# m2.set((2, 1), 7)
# m2.set((2, 2), 9)

# m3 = m1 + m2


class Graph:
    matrix = None

    def __init__(self):
        self.matrix = SparseMatrix()

    def addRel(self, head, tail):
        self.matrix.set((tail, head), 1)

    def removeRel(self, head, tail):
        self.matrix.delete((tail, head))

    def get_relations_with(self, head):
        relations = []

        for (x, y) in self.matrix.data.keys():
            if y == head:
                relations.append(x)

        return relations


# g = Graph()

# g.addRel(1, 2)
# g.addRel(1, 3)
# g.addRel(2, 3)
# g.addRel(2, 4)

# g.addRel(3, 4)
# g.removeRel(3, 4)

# g.get_relations_with(1)


class StringGraph:
    g = None
    names_to_numbers = None
    numbers_to_names = None

    def __init__(self):
        self.g = Graph()
        self.names_to_numbers = {}
        self.numbers_to_names = {}

    def getNumber(self, name):
        if name in self.names_to_numbers:
            return self.names_to_numbers[name]

        else:
            number = len(self.names_to_numbers)
            self.names_to_numbers[name] = number
            self.numbers_to_names[number] = name
            return number

    def getName(self, number):
        return self.numbers_to_names[number]

    def addRel(self, head, tail):
        h_number = self.getNumber(head)
        t_number = self.getNumber(tail)

        self.g.addRel(h_number, t_number)

    def removeRel(self, head, tail):
        h_number = self.getNumber(head)
        t_number = self.getNumber(tail)

        self.g.removeRel(h_number, t_number)

    def get_relations_with(self, head):
        n = self.getNumber(head)
        rel_numbers = self.g.get_relations_with(n)

        result = []
        for number in rel_numbers:
            result.append(self.numbers_to_names[number])

        return result


gs = StringGraph()

# 1 -> 2, 3
# 2 -> 3, 4

# 1: "Ali"
# 2: "Hamid"
# 3: "Reza"
# 4: "Mahdi"

gs.addRel("Ali", "Hamid")
gs.addRel("Ali", "Reza")
gs.addRel("Hamid", "Reza")
gs.addRel("Hamid", "Mahdi")

# gs.get_relations_with("Hamid")