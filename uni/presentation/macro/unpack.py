holder = [1, 2, 3, 4, 5]

a, b, *c = holder

a = holder[0]
b = holder[1]
c = holder[2:-1]

print("a = ", a)
print("b = ", b)
print("c = ", c)
