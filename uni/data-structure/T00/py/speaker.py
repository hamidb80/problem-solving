speech = input()

for i in range(len(speech)):
  print(f"{speech[i] * i}{speech[i:]}")