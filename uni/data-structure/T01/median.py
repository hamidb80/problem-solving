def getNumberList():
    list(map(int, input().split()))

size = int(input())
n1 = getNumberList()
n2 = getNumberList()

i1 = 0
i2 = 0
acc = 0


def check(target):
    global size
    global acc, i1, i2
    isum = i1 + i2

    if isum == size-1:
        acc += target

    elif isum == size:
        acc += target
        quit(acc/2)


while True:
    # echo (i1,i2)
    if i1 != size and i2 != size:
        if n1[i1] < n2[i2]:
            check(n1[i1])
            i1 += 1

        else:
            check(n2[i2])
            i2 += 1

    elif i2 == size:
        check(n1[i1])
        i1 += 1

    else:  # i1 == size
        check(n2[i2])
        i2 += 1
