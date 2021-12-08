import strutils, sets, sequtils, algorithm

var patters = """
  0:6      1:2     2:5     3:5      4:4
  aaaa    ....    aaaa    aaaa    ....
  b    c  .    c  .    c  .    c  b    c
  b    c  .    c  .    c  .    c  b    c
  ....    ....    dddd    dddd    dddd
  e    f  .    f  e    .  .    f  .    f
  e    f  .    f  e    .  .    f  .    f
  gggg    ....    gggg    gggg    ....

   5:5     6:6     7:3     8:7     9:6
  aaaa    aaaa    aaaa    aaaa    aaaa
  b    .  b    .  .    c  b    c  b    c
  b    .  b    .  .    c  b    c  b    c
  dddd    dddd    ....    dddd    dddd
  .    f  e    f  .    f  e    f  .    f
  .    f  e    f  .    f  e    f  .    f
  gggg    gggg    ....    gggg    gggg
"""

var nums = """
aaaa  
b    c
b    c
....  
e    f
e    f
gggg  

....   
.    c 
.    c 
....   
.    f 
.    f 
....   

aaaa   
.    c 
.    c 
dddd   
e    . 
e    . 
gggg   

aaaa   
.    c 
.    c 
dddd   
.    f 
.    f 
gggg   

....
b    c
b    c
dddd
.    f
.    f

aaaa  
b    .
b    .
dddd  
.    f
.    f
gggg  

aaaa   
b    . 
b    . 
dddd   
e    f 
e    f 
gggg   

aaaa   
.    c 
.    c 
....   
.    f 
.    f 
....   

aaaa   
b    c 
b    c 
dddd   
e    f 
e    f 
gggg   

aaaa
b    c
b    c
dddd
.    f
.    f
gggg
""".split("\n\n").mapIt(it.strip.toHashSet.difference("\n. ".toHashSet).toseq.sorted.join)

let inter = nums.filterIt(it.len == 6).mapIt(it.toHashSet).foldl a * b

for c in inter:
  patters = patters.replace(c, '.')

echo patters
echo inter