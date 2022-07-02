#include "Uart.h"
#include "UartDef.h"
#include "lpc17xx.h"

UART::UART()
{
	uarts[0] = LPC_UART0;
	uarts[1] = (LPC_UART_TypeDef *)LPC_UART1;
	uarts[2] = LPC_UART2;
	uarts[3] = LPC_UART3;
}

void UART::Init()
{
	RecieveBuf.Init();
	SendBuf.Init();
	LPC_SC->PCONP |= 1 << 24;
	LPC_PINCON->PINSEL0 |= 0x00500000; // 5 << 4 = 01010000; 80;    (binary)0101 = (decimal)5
	FrameSetting(Char8Bit, OneStopBit, 0, 0);
	SetBaudRate(38400);
	NVIC_EnableIRQ(UART2_IRQn);
	LPC_UART2->FCR = 0x07; // reset RX and TX FIFO
	LPC_UART2->IER = 3;

	// uarts[2]->IER = 3;
}

void UART::Send(char *s)
{
	int index = 0;
	while (s[index] != 0)
	{
		Send(s[index]);
		index++;
	}
	//	while(*s != 0)
	//		Send(*s++);
}

char UART::Get1()
{
	while (!(LPC_UART2->LSR & 1))
		;
	char result = LPC_UART2->RBR;
	return result;
}

void UART::Send1(char data)
{
	while (!(LPC_UART2->LSR & 0x20))
		;
	LPC_UART2->THR = data;
}

char UART::Get()
{
	char result;
	LPC_UART2->IER &= ~((unsigned int)1);
	result = RecieveBuf.Remove();
	LPC_UART2->IER |= 1;
	return result;
}

void UART::Send(char data)
{
	if ((LPC_UART2->LSR & 0x20) && !SendBuf.HasData())
		LPC_UART2->THR = data;
	else
	{
		LPC_UART2->IER &= ~((unsigned int)2);
		SendBuf.Add(data);
		LPC_UART2->IER |= 2;
	}
}

void UART::FrameSetting(int WordLen, int StopBit, int ParityEn, int ParityType)
{
	LPC_UART2->LCR = WordLen | (StopBit << 2) | (ParityEn << 3) | (ParityType << 4);
}

extern int SystemFrequency;
void UART::SetBaudRate(int Baudrate)
{
	unsigned int uClk = SystemFrequency >> 2;
	unsigned int d, m, bestd, bestm, tmp;
	uint64_t best_divisor, divisor;
	unsigned int current_error, best_error;
	unsigned int recalcbaud;
	best_error = 0xFFFFFFFF; /* Worst case */
	bestd = 0;
	bestm = 0;
	best_divisor = 0;
	for (m = 1; m <= 15; m++)
	{
		for (d = 0; d < m; d++)
		{
			divisor = ((uint64_t)uClk * 268435456) * m / (Baudrate * (m + d));
			current_error = divisor & 0xFFFFFFFF;

			tmp = divisor / 4294967296;

			/* Adjust error */
			if (current_error > ((unsigned int)0x80000000))
			{
				current_error = -current_error;
				tmp++;
			}

			/* Out of range */
			if (tmp < 1 || tmp > 65536)
				continue;

			if (current_error < best_error)
			{
				best_error = current_error;
				best_divisor = tmp;
				bestd = d;
				bestm = m;

				if (best_error == 0)
					break;
			}
		} /* end of inner for loop */

		if (best_error == 0)
			break;
	} /* end of outer for loop  */
	recalcbaud = (uClk >> 4) * bestm / (best_divisor * (bestm + bestd));
	/* reuse best_error to evaluate baud error*/
	if (Baudrate > recalcbaud)
		best_error = Baudrate - recalcbaud;
	else
		best_error = recalcbaud - Baudrate;
	best_error = best_error * 100 / Baudrate;
	if (best_error < 3)
	{
		LPC_UART2->LCR |= 0x80;
		LPC_UART2->DLM = (best_divisor >> 8) & 0xFF;
		LPC_UART2->DLL = best_divisor & 0xFF;
		/* Then reset DLAB bit */
		LPC_UART2->LCR &= ~0x80;
		LPC_UART2->FDR = ((bestm << 4) & 0xF0) | (bestd & 0x0F);
	}
}

void UART::Handler() // IER
{
	int state = (LPC_UART2->IIR >> 1) & 0x00000007;

	if (state & 2)
	{
		LPC_UART2->IER &= ~((unsigned int)1);
		RecieveBuf.Add(LPC_UART2->RBR);
		LPC_UART2->IER |= 1;
	}
	if (state & 1)
	{
		LPC_UART2->IER &= ~((unsigned int)2);
		if (SendBuf.HasData())
			LPC_UART2->THR = SendBuf.Remove();
		LPC_UART2->IER |= 2;
	}
}

extern UART uart;
extern "C"
{
	void UART2_IRQHandler()
	{
		uart.Handler();
	}
}