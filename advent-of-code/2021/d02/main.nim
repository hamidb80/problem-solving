import strutils

const inputPath = "./input.txt"

func parseRecord(rec: string): tuple[command: string, value: int] =
  let params = rec.split(" ")
  (params[0], parseInt params[1])

# -------------------------------------------


proc test1: int =
  var state = (x: 0, depth: 0)

  for line in inputPath.lines:
    let (command, value) = parseRecord line
    
    case command:
    of "down": state.depth += value
    of "up": state.depth -= value
    of "forward": state.x += value
    else: discard

  state.x * state.depth


proc test2: int =
  var state = (x: 0, depth: 0, aim: 0)

  for line in inputPath.lines:
    let (command, value) = parseRecord line

    case command:
    of "down": state.aim += value
    of "up": state.aim -= value
    of "forward": 
      state.x += value
      state.depth += state.aim * value
    else: discard

  state.x * state.depth


# ------------------------------

echo test1()
echo test2()
