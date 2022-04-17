def maxIndexStack(s, cap):
    result = []

    for i in range(0, len(s)):
        result.append(i)
        result.sort(key= lambda k: s[k], reverse=True)

        if len(result) == cap + 1:
            result.pop()

    return result


def over(mis, s):
    return [s[it] for it in mis]


class Solution:
    def maxArea(self, heights):
        mis = sorted(maxIndexStack(heights, 2))  # min indexes
        h = min(over(mis, heights))
        lefti = mis[0]
        righti = mis[1]
        result = (righti - lefti) * h

        def job(index, otherSideIndex, fn):
            newh = min(heights[index], heights[otherSideIndex])
            newd = abs(otherSideIndex - index)
            area = newh * newd

            if area > result:
                fn(area)

        for i in range(lefti-1, -1, -1):
            def dd(a):
                nonlocal lefti, result
                lefti = i
                result = a

            job(i, righti, dd)

        for i in range(righti+1, len(heights)):
            def dd(a):
                nonlocal righti, result
                righti = i
                result = a

            job(i, lefti, dd)

        return result
