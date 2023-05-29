func solveNQueens(board, col, n):
  if col >= n:
    print board
    return true
  for row from 0 to n-1:
    if isSafe(board, row, col, n):
      board[row][col] = 1
      if solveNQueens(board, col+1, n):
        return true
      board[row][col] = 0
  return false

func isSafe(board, row, col, n):
  for i from 0 to col-1:
    if board[row][i] == 1:
      return false
  for i,j from row-1, col-1 to 0, 0 by -1:
    if board[i][j] == 1:
      return false
  for i,j from row+1, col-1 to n-1, 0 by 1, -1:
    if board[i][j] == 1:
      return false
  return true

board = empty NxN chessboard
solveNQueens(board, 0, N)