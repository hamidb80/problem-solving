import strutils, strformat, deque

type
  UART = object
    port_number: int
    sendQ, recvQ: Deque[string]

proc init_UART(UART_number: range[0 .. 3]): UART = 
  discard
proc send(uart: UART, msg: string) = 
  discard

var 
  xbee_UART = init_UART(0)
  sim900_UART = init_UART(1)


block init:
  for msg in ["AT+CMGF=1","AT+CNMI=1,2,0,0,0"]:
    sim900_UART.send(msg & "\r")

  for msg in ["+++","ATDH [ADDR_H]","ATDL [ADDR_L]","ATCN"]:
    xbee_UART.send(msg & "\r")

block mainLoop:
  while true:

    if sim900_UART.recvQ.len != 0:
      let out = popFirst sim900_UART.recvQ
      
      if out.startsWith("+CMT: "):
        let msg = popFirst sim900_UART.recvQ
        xbee_UART.send(msg & "\r")
