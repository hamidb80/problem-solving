#include <stdexcept>

class Column {
public:
  int index, value;
  Column* next;
};

class Row {
public:
  int index;
  Column *firstColumn;
  Row* next;
};

class Matrix {
public:
  Row *firstRow;
  int get(int row_index, int column_index);
};

int Matrix::get(int row_index, int column_index) {
  auto currentRow = firstRow;
  while (currentRow != nullptr)
  {
    if (currentRow->index == row_index)
    {
      auto currentColumn = currentRow->firstColumn;

      while (currentColumn->next != nullptr)
        if (currentColumn->index == column_index)
          return currentColumn->value;
        else
          currentColumn = currentColumn->next;
    }
    else
      currentRow = currentRow->next;
  }

  throw std::invalid_argument("not found");
}

int main() {
  Matrix m;
  m.get(1, 1);
}