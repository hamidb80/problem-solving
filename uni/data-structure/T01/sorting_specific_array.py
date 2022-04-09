limit = 200000


def getNumbers():
    list(map(int, input().split()))


(mn, mx) = getNumbers()
numbers = getNumbers()

nTable = [0 for _ in range(0, 200)]

for n in numbers:
    nTable[n-mn] += 1

c = 0
for i, r in enumerate(nTable):
    for _ in range(0, r):
        if c < limit:
            print(mn+i, end=" ")
        else:
            quit()

        c += 1
