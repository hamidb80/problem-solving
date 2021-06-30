# https://quera.ir/problemset/contest/20258/

import unpack, strutils, sequtils, sugar, algorithm
# import print

type Message = tuple
  `when`: int
  until: int

func cmp(a,b: Message): int=
  cmp a.`when`, b.`when`

# preparing data ------------------------------------------

[contactsLen, maxTasks] <- stdin.readLine.split(' ').map parseInt

var contactList: seq[Message] = collect newseq:
  for i in 1..contactsLen:
    let values = stdin.readLine.split(' ').map parseInt
    (values[0], values[1])

contactList.sort cmp
# print contactList

# code  --------------------------------------------------

var 
  tasks: seq[int] ## a seq of task priority
  lastTime = 0

for contact in contactList:
  let passedTime = contact.`when` - lastTime
  if passedTime > 0:
    for i in 1..min(passedTime * maxTasks, tasks.len):
      del tasks, minIndex tasks

    
    if tasks.anyIt it < lastTime + passedTime:
      echo "NO"
      quit()

    lastTime += passedTime 

  tasks.add contact.until + 1

echo "YES"
