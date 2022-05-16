let n = 17

let answer =
  if n mod 2 == 0: "yay"
  elif n mod 3 == 0: "bad"
  elif n mod 5 == 0: "good"
  else:
    echo "What Are You Doing?"
    "nothing"

# --------------------

let c = block:
  var temp = 10 * 30
  temp -= 1
  # ...
  temp
