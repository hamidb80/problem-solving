def calc_steps_impl(n, cache):
    if n <= 0:
        return 0

    elif n not in cache:
        cache[n] = sum(calc_steps_impl(n-step, cache) for step in [1, 2, 5])

    return cache[n]


"""
1: 1
2: 11, 2
5: 
  11111
  2111
  1211
  1121
  1112
  221
  122
  212
  5
"""


def calc_steps(n):
    return calc_steps_impl(n, {1: 1, 2: 2, 5: 9})

# -------------------------


if __name__ == "__main__":
    stairs_len = int(input())
    print(calc_steps(stairs_len))
