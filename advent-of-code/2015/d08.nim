import std/[strutils, sequtils, json, math]


const content = """
""
"abc"
"aaa\"aaa"
"\x27"
"""

proc inspect[T](val: T): T =
  echo val
  val

when isMainModule:
  let part1 = 
    readfile"./d08.dat"
    # content
    .strip
    .splitLines
    # .mapit((it, it.replace("\\x", "\\u00").parseJson.getStr))
    # .inspect
    .mapit(it.len - it.replace("\\x", "\\u00").parseJson.getStr.len)
    .sum
  
  part1.echo