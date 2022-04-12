import std/json
import ews2json


let nodes = parseLisp readFile "./examples/sample.cl"
# writeFile "play.txt", pretty nodes
writefile "./play.json", pretty toJson(nodes, easRules)

# when isMainModule:
#   ews2json "C:/Users/HamidB80/Desktop/dsd.ews", "C:/Users/HamidB80/Desktop/yyy"
