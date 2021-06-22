import unittest
import med


test "tests":
  for (inp, res) in [
    (1, 6),
    (4, 16),
    (3, 14),
    (5913, 2790)
  ]:
    
    check minArea(inp) == res
  