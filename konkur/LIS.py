"""
LIS in O(n.log n)

thank to https://phind.com
prettified by me
"""

from bisect import bisect_left

def longest_increasing_subsequence(nums):
    dp = []
    
    for num in nums:
        idx              = bisect_left(dp, num)
        print((idx, num, dp))
        if idx == len(dp): dp.append(num)
        else             : dp[idx] = num
    
    return dp

nums = [10, 9, 2, 5, 3, 7, 0, 1] # it just gives you correct length, not correct sequesnce
print(longest_increasing_subsequence(nums))