import unittest, strutils
import main

const 
  body = """
    ...#.
    .   #
    #   #
    #   .
    .#..#
  """.strip.unindent 4

  edges = [
    "...#.",   # Up
    ".##.#",   # Right
    ".#..#",   # Down
    "..##."   # Left
  ]

  tile = Tile(edges: edges)

## I knew it there a very high chance that I was implemented these function incorrectly,
## so I'm going to write test for it to make sure :)
suite "tranformation":
  test "flip vertical":
    check flippedVertical(tile).edges == 
    [
      ".#...",
      "..##.",
      "#..#.",
      ".##.#",
    ]
  test "flip horizontal":
    check flippedHorizontal(tile).edges == 
    [
      ".#..#",
      "#.##.",
      "...#.",
      ".##..",
    ]

  test "rotate left":
    check rotatedLeft(tile).edges == 
    [
      ".##.#",
      "#..#.",
      "..##.",
      ".#...",
    ]

  test "rotate right":
    check rotatedRight(tile).edges == 
    [
      ".##..",
      "...#.",
      "#.##.",
      ".#..#",
    ]

suite "other functionalities":
  test "reverse":
    check reversed"sal" == "las"