class SparseMatrix:
  data = {}

  def __init__(_, _): ...

  def insert(self, row, col, value):
    if row in self.data:
      self.data[row] = {col: value}
    else:
      self.data[row][col] = value

  def remove(self, row, col):
    if row in self.data:
      del self.data[row][col]

  def get(self, row, col):
    return self.data[row][col]

  def size(self):
    return sum(len(row) for row in self.data)

  def array_to_sparse(array):
    ...

  def sparse_to_array(sm):
    ...

  def __add__(sm1, sm2):
    ...

  def __sub__(sm1, sm2):
    ...

  def __mul__(sm1, sm2):
    ...

  def get_similars(row, col):
    ...

  def remove_problem(row):
    ...


