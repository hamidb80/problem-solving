"""
LIS in O(n.log n)

thank to Duck Duck Go AI
prettified by me
"""

from bisect import bisect_left

def longest_increasing_subsequence(nums):
    tails        = [] # This will store the smallest tail for all increasing subsequences
    indices      = [] # This will store the indices of the elements in the original array
    prev_indices = [-1] * len(nums) # This will store the previous index for each element

    for i, num in enumerate(nums):
        index     = bisect_left(tails, num) # Use binary search to find the insertion point

        print((index, num, i, tails, indices))

        if index == len(tails):
            tails  .append(num)
            indices.append(i) 
        else:
            tails  [index]  = num
            indices[index]  = i

        if index > 0:
            prev_indices[i] = indices[index - 1]

    # Reconstruct the longest increasing subsequence
    lis_length = len(tails)
    lis        = []
    k          = indices[-1]

    while k >= 0:
        lis .append(  nums[k])
        k   = prev_indices[k]

    lis.reverse() # The sequence is constructed in reverse order
    return lis


nums = [3, 10, 9, 2, 5, 3, 7, 3, 1, 0, 2] # it just gives you correct length, not correct sequesnce
print(longest_increasing_subsequence(nums))