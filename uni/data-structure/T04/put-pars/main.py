priority = {'+': 0, '-': 0, '*': 1, '/': 1}
notSet = -1


def toInfix(l, r, o): return [l, r, o]


def lex(line):
    lastIndex = notSet
    result = []

    for i, ch in enumerate(line):
        if ch in "0123456789":
            if lastIndex == notSet:
                lastIndex = i

        else:
            if lastIndex != notSet:
                result.append(int(line[lastIndex:i]))
                lastIndex = notSet

            result.append(ch)

    if lastIndex != notSet:
        result.append(int(line[lastIndex:]))

    return result


def toPostfix(tokens):
    operatorStack = []
    result = []

    for t in tokens:
        if len(result) < 2:
            result.append(t)

        else:
            if isinstance(t, int):
                m = result.pop()
                result.append(t)
                result.append(m)

            else:
                if len(operatorStack) != 0:
                    l = operatorStack[-1]

                    if priority[t] <= priority[l]:
                        result += list(reversed(operatorStack))
                        operatorStack = []

                i = len(result) - 1
                while i != 0:
                    l = result[i]
                    # print("h")
                    if not isinstance(l, int) and (priority[l] < priority[t]):
                        operatorStack.append(result.pop())
                        i -= 1

                    else:
                        result.append(t)
                        break

    return result + list(reversed(operatorStack))


def parseMathExpr(tokens):
    myStack = []

    for t in tokens:
        if isinstance(t, int):
            myStack.append(t)

        else:
            r = myStack.pop()
            l = myStack.pop()

            myStack.append(toInfix(l, r, t))

    return myStack[0]


def tostr(me):
    if isinstance(me, int):
        return str(me)
    else:
        return f"({tostr(me[0])}{me[2]}{tostr(me[1])})"


# expr = "6/3+12-16/12*9+25"
# print(expr)
# print(lex(expr))
# print(toPostfix(lex(expr)))

expr = input()
print(tostr(parseMathExpr(toPostfix(lex(expr)))))
