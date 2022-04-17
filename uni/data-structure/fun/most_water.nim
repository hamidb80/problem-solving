# https://leetcode.com/problems/container-with-most-water/
import std/[algorithm, sequtils, unittest, sugar]

func maxIndexStack[T](s: seq[T], cap: int): seq[int] =
  for i in 0 .. s.high:
    result.add i
    result.sort (ia, ib) => s[ia] - s[ib], Descending

    if result.len == cap + 1:
      discard result.pop

func over[T](mis: seq[int], s: seq[T]): seq[T] =
  mis.mapIt s[it]


func maxArea(heights: seq[int]): int =
  let
    mis = sorted heights.maxIndexStack 2 # min indexes
    h = min mis.over heights

  var
    lefti = mis[0]
    righti = mis[1]

  result = (righti - lefti) * h


  template job(index, thisSideIndex, otherSideIndex): untyped =
    let
      newh = min(heights[index], heights[otherSideIndex])
      newd = abs(otherSideIndex - index)
      area = newh * newd

    if area > result:
      thisSideIndex = index
      result = area


  for i in countdown(lefti-1, 0):
    job i, lefti, righti

  for i in countup(righti+1, heights.high):
    job i, righti, lefti


# --------------------------


test "max indexes stack":
  var mis = maxIndexStack(@[4, 7, 4, 2, 1, 3], 3)
  check mis == @[1, 0, 2]


suite "maxArea":
  test "2 items":
    check maxArea(@[1, 1]) == 1

  test "short":
    check maxArea(@[1, 8, 6, 2, 5, 4, 8, 3, 7]) == 49

  test "short2":
    check maxArea(@[8, 10, 14, 0, 13, 10, 9, 9, 11, 11]) == 80
