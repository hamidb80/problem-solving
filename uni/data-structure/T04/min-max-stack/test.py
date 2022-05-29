from unittest import TestCase
from min_max_stack import MinMaxStack
from custom_exceptions import *

class MinMaxStackTest(TestCase):

    def test_push(self):
        s = MinMaxStack(3)
        s.push(1)
        s.push(2)
        s.push(3)
        with self.assertRaises(StackOverFlowError):
            s.push(4)
        with self.assertRaises(StackOverFlowError):
            s.push(5)
        s = MinMaxStack(0)
        with self.assertRaises(StackOverFlowError):
            s.push(1)

    def test_pop(self):
        s = MinMaxStack(3)
        s.push(1)
        s.push(2)
        s.push(3)
        self.assertEqual(s.pop(), 3)
        self.assertEqual(s.pop(), 2)
        self.assertEqual(s.pop(), 1)
        with self.assertRaises(StackEmptyError):
            s.pop()

    def test_size(self):
        s = MinMaxStack(3)
        self.assertEqual(s.size(), 0)
        s.push(1)
        s.push(2)
        self.assertEqual(s.size(), 2)
        s.pop()
        self.assertEqual(s.size(), 1)
        s.pop()
        self.assertEqual(s.size(), 0)
        with self.assertRaises(StackEmptyError):
            s.pop()
        self.assertEqual(s.size(), 0)

    def test_top(self):
        s = MinMaxStack(3)
        s.push(1)
        s.push(2)
        s.push(3)
        self.assertEqual(s.top(), 3)
        self.assertEqual(s.top(), 3)
        s.pop()
        self.assertEqual(s.top(), 2)
        s.push(4)
        self.assertEqual(s.top(), 4)
        s.pop()
        s.pop()
        s.pop()
        with self.assertRaises(StackEmptyError):
            s.top()

    def test_is_empty(self):
        s = MinMaxStack(0)
        self.assertTrue(s.is_empty())
        s = MinMaxStack(2)
        self.assertTrue(s.is_empty())
        s.push(1)
        self.assertFalse(s.is_empty())
        s.push(2)
        s.pop()
        self.assertFalse(s.is_empty())
        s.pop()
        self.assertTrue(s.is_empty())

    def test_is_full(self):
        s = MinMaxStack(0)
        self.assertTrue(s.is_full())
        s = MinMaxStack(2)
        s.push(1)
        s.push(1)
        self.assertTrue(s.is_full())
        s.pop()
        self.assertFalse(s.is_full())
        s.push(2)
        self.assertTrue(s.is_full())
        s.pop()
        s.pop()
        self.assertFalse(s.is_full())

    def test_get_min(self):
        s = MinMaxStack(3)
        with self.assertRaises(StackEmptyError):
            s.get_min()
        s.push(1)
        self.assertEqual(s.get_min(), 1)
        s.push(2)
        self.assertEqual(s.get_min(), 1)
        s.push(-1)
        self.assertEqual(s.get_min(), -1)
        s.pop()
        self.assertEqual(s.get_min(), 1)
        s.pop()
        self.assertEqual(s.get_min(), 1)
        s.pop()
        with self.assertRaises(StackEmptyError):
            s.get_min()

        s = MinMaxStack(10)
        s.push(3)
        s.push(2)
        s.push(12)
        s.push(5)
        s.push(1)
        self.assertEqual(s.get_min(), 1)
        s.pop()
        self.assertEqual(s.get_min(), 2)
        s.pop()
        self.assertEqual(s.get_min(), 2)
        s.pop()
        self.assertEqual(s.get_min(), 2)
        s.pop()
        self.assertEqual(s.get_min(), 3)
        s.pop()
        with self.assertRaises(StackEmptyError):
            s.get_min()

    def test_get_max(self):
        s = MinMaxStack(3)
        with self.assertRaises(StackEmptyError):
            s.get_max()
        s.push(1)
        self.assertEqual(s.get_max(), 1)
        s.push(2)
        self.assertEqual(s.get_max(), 2)
        s.push(-1)
        self.assertEqual(s.get_max(), 2)
        s.pop()
        self.assertEqual(s.get_max(), 2)
        s.pop()
        self.assertEqual(s.get_max(), 1)
        s.pop()
        with self.assertRaises(StackEmptyError):
            s.get_max()

        s = MinMaxStack(10)
        s.push(2)
        s.push(4)
        s.push(1)
        s.push(2)
        s.push(113.12)
        self.assertEqual(s.get_max(), 113.12)
        s.pop()
        self.assertEqual(s.get_max(), 4)
        s.pop()
        self.assertEqual(s.get_max(), 4)
        s.pop()
        self.assertEqual(s.get_max(), 4)
        s.pop()
        self.assertEqual(s.get_max(), 2)
        s.pop()
        with self.assertRaises(StackEmptyError):
            s.get_max()


t = MinMaxStackTest()
t.test_push()
t.test_pop()
t.test_size()
t.test_top()
t.test_is_empty()
t.test_is_full()
t.test_get_min()
t.test_get_max()