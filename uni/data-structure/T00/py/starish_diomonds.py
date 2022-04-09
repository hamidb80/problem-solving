diameter = int(input())

for n in range(1, diameter * 2, 2):
    repeat = n if n <= diameter else (diameter - (n - diameter))
    s = ('*' * repeat).center(diameter)
    print(s * 2)
