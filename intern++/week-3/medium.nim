# https://quera.ir/problemset/contest/3432/

import sets, strutils, sequtils, sugar

discard stdin.readLine

let jobs = collect newSeq:
  for i in 1..2:
    (stdin.readLine.splitWhitespace.map parseInt).toHashSet

echo:
  if (jobs[0] -+- jobs[1]).len == 0: "Both"
  elif (jobs[0] * jobs[1]).len < min(jobs[0].len , jobs[1].len): "None"
  elif (jobs[0] - jobs[1]).len == 0: "Mohammad Javad"
  else: "Mostafa"