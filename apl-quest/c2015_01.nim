import std/[strutils, algorithm]


template norm(t): untyped = sorted tolower onlyLetters t

func onlyLetters(t: string): string =
  for ch in t:
    if ch in Letters:
      add result, ch

func fn(a, b: string): bool =
  a.norm == b.norm

echo fn("anagram", "Nag A Ram") # 1
echo fn("Dyalog APL", "Dog Pay All") # 1
echo fn("", "  !#!") # 1
echo fn("abcde", "zyxwvu") # 0
