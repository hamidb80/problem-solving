def maxArea(h):
    i, j = 0, len(h)-1
    area = min(h[i], h[j]) * (j-i)

    while j > i:
        if h[i] < h[j]:
            i += 1

        else:
            j -= 1

        newArea = min(h[i], h[j]) * (j-i)
        if area < newArea:
            area = newArea

    return area


print(maxArea([1, 1]), " == ",  1)
print(maxArea([1, 8, 6, 2, 5, 4, 8, 3, 7]), " == ", 49)
print(maxArea([8, 10, 14, 0, 13, 10, 9, 9, 11, 11]), " == ", 80)
