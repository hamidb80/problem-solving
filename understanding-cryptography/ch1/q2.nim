func shift(t: string, shift: int): string = 
  for c in t:
    add result, chr 'a'.int + ((shift + c.int - 'a'.int) mod 26)

for i in 1..25:
  echo i, " :: ", shift("xultpaajcxitltlxaarpjhtiwtgxktghidhipxciwtvgtpilpitghlxiwiwtxgqadds", i)
