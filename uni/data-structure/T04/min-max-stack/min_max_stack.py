from typing import *
from custom_exceptions import *

class MinMaxStack:
    max_size = 0
    raw_stack = None
    min_stack = None
    max_stack = None

    def __init__(self, max_size):
        self.max_size = max_size

        self.raw_stack = []
        self.min_stack = []
        self.max_stack = []

    def push(self, value: Any) -> None:  # Time Complexity: O(1)
        """
        Get an value and push it into stack
        :param value: Any value
        :return: None
        """

        if self.is_full():
            raise StackOverFlowError

        else:
            if self.is_empty():
                self.min_stack.append(value)
                self.max_stack.append(value)

            else:
                self.min_stack.append(min(self.get_min(), value))
                self.max_stack.append(max(self.get_max(), value))

            self.raw_stack.append(value)

    def pop(self) -> Any:  # Time Complexity: O(1)
        """
        Removes the last in value
        :return: last in value
        """

        if self.is_empty():
            raise StackEmptyError
        else:
            self.max_stack.pop()
            self.min_stack.pop()
            return self.raw_stack.pop()

    def size(self) -> int:
        """
        Gives num of existed values in stack
        :return: num of existed values in stack
        """
        return len(self.raw_stack)

    def top(self) -> bool:  # Time Complexity: O(1)
        """
        Gives last in value.(Only gives, does not take out)
        :return: last in value
        """
        
        if self.is_empty():
            raise StackEmptyError
        else:
            return self.raw_stack[-1]

    def is_empty(self) -> bool:  # Time Complexity: O(1)
        """
        Check if an stack is empty or no.
        :return: if stack is empty, return True, else return False.
        """
        return self.size() == 0

    def is_full(self) -> bool:  # Time Complexity: O(1)
        """
        Check if an stack is full or no.
        :return: if stack is full, return True, else return False.
        """
        return self.size() == self.max_size

    def get_min(self) -> Any:  # Time Complexity: O(1)
        """
        Gives min value of stack
        :return: max value of stack
        """
        if self.is_empty():
            raise StackEmptyError
        else:
            return self.min_stack[-1]

    def get_max(self) -> Any:  # Time Complexity: O(1)
        """
        Gives max value of stack
        :return: max value of stack
        """

        if self.is_empty():
            raise StackEmptyError
        else:
            return self.max_stack[-1]
