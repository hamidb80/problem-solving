acc = ""
c = 1

while len(acc) <= 4000:
    acc += str(c)
    c += 1


index = int(input())
print(acc[index-1])
