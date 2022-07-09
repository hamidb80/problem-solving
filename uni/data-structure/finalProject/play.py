H = [0]*50
size = -1

def parent(i): return (i - 1) // 2
def leftChild(i): return ((2 * i) + 1)
def rightChild(i): return ((2 * i) + 2)

def shiftUp(i):
    # Function to shift up the node in order to maintain the heap property
    while (i > 0 and H[parent(i)] < H[i]):
        swap(parent(i), i) # Swap parent and current node
        i = parent(i) # Update i to parent of i

def shiftDown(i):
    # Function to shift down the node in order to maintain the heap property
    maxIndex = i
    
    l = leftChild(i) # Left Child
    
    if (l <= size and H[l] > H[maxIndex]):
        maxIndex = l

    
    r = rightChild(i) # Right Child

    if (r <= size and H[r] > H[maxIndex]):
        maxIndex = r

    if (i != maxIndex): # If i not same as maxIndex
        swap(i, maxIndex)
        shiftDown(maxIndex)


def insert(p):
    global size
    size = size + 1
    H[size] = p

    shiftUp(size) # Shift Up to maintain heap property


def extractMax():
    global size
    result = H[0]

    H[0] = H[size] # Replace the value at the root with the last leaf
    size = size - 1

    shiftDown(0) # Shift down the replaced element to maintain the heap property
    return result


def changePriority(i, p):
    # Function to change the priority f an element

    oldp = H[i]
    H[i] = p

    if (p > oldp):
        shiftUp(i)
    else:
        shiftDown(i)


def getMax():
    # Function to get value of the current maximum element
    return H[0]

def Remove(i):
    # Function to remove the element located at given index

    H[i] = getMax() + 1
    shiftUp(i) # Shift the node to the root of the heap
    extractMax() # Extract the node


def swap(i, j):
    temp = H[i]
    H[i] = H[j]
    H[j] = temp

# --------------------- TEST -------------------------

# Insert the element to the
# priority queue
insert(45)
insert(20)
insert(14)
insert(12)
insert(31)
insert(7)
insert(11)
insert(13)
insert(7)

i = 0

# Priority queue before extracting max
print("Priority Queue : ", end="")
while (i <= size):
    print(H[i], end=" ")
    i += 1

print()
# Node with maximum priority
print("Node with maximum priority :", extractMax())


print("Priority queue after extracting maximum : ",
      end="")  # Priority queue after extracting max
j = 0

while (j <= size):
    print(H[j], end=" ")
    j += 1

print()

# Change the priority of element present at index 2 to 49
changePriority(2, 49)
print("Priority queue after priority change : ", end="")

k = 0
while (k <= size):
    print(H[k], end=" ")
    k += 1

print()

# Remove element at index 3
Remove(3)
print("Priority queue after removing the element : ", end="")
l = 0

while (l <= size):
    print(H[l], end=" ")
    l += 1