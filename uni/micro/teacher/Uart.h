#ifndef UART_H
#define UART_H
#include "Fifo.h"
#include "Outoperator.h"
#include "lpc17xx.h"

class UART : public OutOperator
{
	public:
		UART();
		void Send(char* a);
		void Init();
		char Get1();
		void Send1(char data);
		char Get();
		void Send(char d);
		void SetBaudRate(int Baudrate);
		void FrameSetting(int WordLen, int StopBit, int ParityEn, int ParityType);
		void Handler();
	
		Fifo RecieveBuf;
		Fifo SendBuf;
	
		Fifo RecieveBuf1;
		Fifo SendBuf1;
	
		LPC_UART_TypeDef* uarts[4];
};

#endif