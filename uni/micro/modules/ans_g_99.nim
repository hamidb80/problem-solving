import deques

type 
  UART = object 
    recvQ: Deque[string]

proc init_UART(uart_number: int): UART = 
  discard
proc save_file(path, content: string) = 
  discard

var 
  bluetooth_UART = init_UART(0)
  