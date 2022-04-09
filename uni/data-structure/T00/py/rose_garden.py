[garden_width, months] = [int(n) for n in input().split(" ")]

white_roses_count = [0 for _ in range(garden_width)]

for _ in range(months):
    for (i, roseKind) in enumerate(input()):
        if roseKind == 'W':
            white_roses_count[i] += 1

print(''.join(['F' if n % 2 == 0 else 'B' for n in white_roses_count]))
