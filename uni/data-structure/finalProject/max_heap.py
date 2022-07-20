class Empty(Exception):
    "when heap is empty"

class MaxHeap:
    @staticmethod
    def left_child(i: int) -> int:
        return (2 * i)

    @staticmethod
    def right_child(i: int) -> int:
        return (2 * i) + 1

    @staticmethod
    def parent(i: int) -> int:
        if i == 1:
            return 1
        else:
            return i // 2

    # ---------------------------

    def __init__(self):
        self.clear()

    def clear(self):
        self.data = [None]

    # ---------------------------

    def cursor(self):
        return len(self.data)

    def size(self):
        return self.cursor() - 1

    def is_empty(self):
        return self.cursor() == 1

    def is_branch(self, i: int) -> bool:
        return self.left_child(i) < self.cursor()

    def max_child_index(self, i: int):
        l = self.left_child(i)
        r = self.right_child(i)

        if r >= self.cursor() or self.data[l] > self.data[r]:
            return l
        else:
            return r

    def find_max(self):
        return self.data[-1]

    # ---------------------------

    def swap(self, i1, i2):
        self.data[i1], self.data[i2] = self.data[i2], self.data[i1]

    def bubble_up(self, i):
        while self.data[i] > self.data[self.parent(i)]:
            self.swap(i, self.parent(i))

            i = self.parent(i)

    def bubble_down(self, i):
        while self.is_branch(i):
            mc = self.max_child_index(i)

            if self.data[i] < self.data[mc]:
                self.swap(i, mc)

            i = mc

    # ---------------------------

    def push(self, k):
        self.data.append(k)
        self.bubble_up(self.cursor() - 1)

    def pop(self):
        if len(self.data) == 1:
            raise Empty

        max = self.data[1]
        self.data[1] = self.data[self.cursor()-1]
        self.data.pop()
        self.bubble_down(1)
        return max

    def extract_max(self):
        return self.pop()

    # ---------------------------

    def add_to_all(self, delta) -> None:
        for i in range(1, len(self.data)):
            self.data[i] += delta

    def as_list(self):
        return self.data[1:]

    @staticmethod
    def merge(h1, h2):
        new = MaxHeap()

        for n in [*h1.as_list(), *h2.as_list()]:
            new.push(n)

        return new


if __name__ == "__main__":
    h1 = MaxHeap()
    h2 = MaxHeap()

    for n in [15, 7, 9, 4, 13, 12, 99]:
        h1.push(n)
        h2.push(n)

    h2.add_to_all(2)

    print(h1.as_list())
    print(h2.as_list())

    # ---------------------

    m = MaxHeap.merge(h1, h2)
    print(m.as_list())

    while True:
        print(m.pop())
