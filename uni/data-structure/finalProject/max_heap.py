from typing import *


class MaxHeap:
    heap: List

    def __init__(self):
        """
        Initialize new MaxHeap object.
        """
        self.heap = [None]

    @staticmethod
    def parent(i: int) -> int:
        """
            This method is static.
            Takes an index and returns the index of the parent of this index.
            :param i: int
        """
        return (i - 1) // 2

    @staticmethod
    def left_child(i: int) -> int:
        """
            This method is static.
            Takes an index and returns the index of the left child of this index.
            :param i: int
        """
        return ((2 * i) + 1)

    @staticmethod
    def right_child(i: int) -> int:
        """
            This method is static.
            Takes an index and returns the index of the left child of this index.
            :param i: int
        """
        return ((2 * i) + 2)

    def size(self) -> int:
        """
        Returns the max-heap size.
        """
        pass

    def bubble_up(self, index: int) -> None:
        """
        Take an index and bubble up this index.
        :param index: int
        """
        pass

    def bubble_down(self, index: int) -> None:
        """
            Take an index and bubble down this index.
            :param index: int
        """
        pass

    def insert(self, item: Any) -> None:
        """
        Insert new item in max-heap.
        :param item:
        """
        pass

    def extract_max(self) -> Any:
        """
        Return max element of the heap and remove it.
        """
        pass

    def find_max(self) -> Any:
        """
        Just return max element of the heap.
        """
        pass

    @staticmethod
    def build_heap_with_bubble_up(arr: list[Any]) -> None:
        """
        This method is static.
        Take a list and create a max heap with this elements by bubble-up operation.
        """
        pass

    @staticmethod
    def build_heap_with_bubble_down(arr: list[Any]) -> None:
        """
            This method is static.
            Take a list and create a max heap with this elements by bubble-up operation.
        """
        pass

    def clear(self) -> None:
        """
        Clear max-heap.
        """
        pass

    @staticmethod
    def merge(h1, h2):
        """
        This method is static.
        Takes 2 objects of MaxHeap, merge theirs and returns new MaxHeap object.
        :param h1: MaxHeap object.
        :param h2: MaxHeap object.
        :return: MaxHeap object.
        """
        pass

    def add_to_all(self, delta: Any) -> None:
        """
        Add delta to each elements in the max-heap.
        """