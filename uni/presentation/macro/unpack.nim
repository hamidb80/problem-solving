import std/macros

macro `<..`(containers, value) =
  # expectKind containers, nnkTupleConstr
  result = newStmtList()

  var i = 0
  for name in containers:

    result.add:
      if name.kind == nnkPrefix:
        let id = name[1]
        quote:
          let `id` = `value`[`i` .. ^1]

      else:
        quote:
          let `name` = `value`[`i`]

    i += 1

  echo repr result

# --------------------------------

let holder = [1, 2, 3, 4, 5]

(a, b, ..c) <.. holder

echo "a = ", a
echo "b = ", b
echo "c = ", c
