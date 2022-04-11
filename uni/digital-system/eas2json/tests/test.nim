import ews2json


# let nodes = parseLisp readFile "./examples/sample.cl"
# writeFile "out.rkt", pretty nodes
# writefile "./temp/out.json", pretty toJson(nodes, rules)

when isMainModule:
  ews2json "C:/Users/HamidB80/Desktop/dsd.ews", "C:/Users/HamidB80/Desktop/yyy"
