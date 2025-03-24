import std/[strutils, algorithm]

func onlyLetters(t: string): string =
  for ch in t:
    if ch in Letters:
      add result, ch

func norm(t: auto)   : auto = sorted tolower onlyLetters t
func fn(a, b: string): bool = a.norm == b.norm

echo "anagram"   .fn "Nag A Ram" # 1
echo "Dyalog APL".fn "Dog Pay All" # 1
echo ""          .fn "  !#!" # 1
echo "abcde"     .fn "zyxwvu" # 0
