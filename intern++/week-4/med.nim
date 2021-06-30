import unpack, strutils, sequtils, sugar, algorithm
# import print

type Message = tuple
  `when`: int
  waitsFor: int

func cmp(a,b: Message): int=
  cmp a.`when`, b.`when`

# preparing data ------------------------------------------

[contactsLen, maxTasks] <- stdin.readLine.split(' ').map parseInt

var contactList = collect newseq:
  for i in 1..contactsLen:
    let values = stdin.readLine.split(' ').map parseInt
    (`when`: values[0], waitsFor: values[1])

# it should sorted by priority rather than just when
contactList.sort cmp

# code  --------------------------------------------------

# print contactList

var 
  tasks: seq[int] ## a seq of task priority
  lastTime = 0

# for i in 0..contactList.high:
for contact in contactList:
  let passedTime = contact.`when` - lastTime
  if passedTime > 0:
    for i in 1..min(passedTime * maxTasks, tasks.len):
      del tasks, minIndex tasks

    lastTime += passedTime 

  tasks.add contact.`when` + contact.waitsFor

  if tasks.len > maxTasks:
    echo "NO"
    quit()

echo "YES"
