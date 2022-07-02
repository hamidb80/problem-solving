#include "Ssp.h"

Ssp::Ssp()
{
	ssp[0] = LPC_SSP0;
	ssp[1] = LPC_SSP1;
}

Ssp::~Ssp()
{
}

void Ssp::Init(char SspNum)
{
	Connect(SspNum);
	LPC_SC->PCONP = 1 << (21 - (SspNum * 11));
	if (SspNum == 1)
		LPC_SC->PCLKSEL0 = 1 << 20;
	else if (SspNum == 0)
		LPC_SC->PCLKSEL1 = 1 << 10;
	ssp[SspNum]->CR0  = 0x0007;                    /* 8Bit, CPOL=0, CPHA=0        */
	//Utility::SetBits(&ssp[SspNum]->CR0, 2, 3, 2);
	ssp[SspNum]->CR1  = 0x0002;                    /* SSP0 enable, master         */
	SetClock(12000000, SspNum);
}

extern int SystemFrequency;
void Ssp::SetClock(int Frequency, char SspNum)
{
	uint32_t prescale, cr0_div, cmp_clk, ssp_clk;
	ssp_clk = SystemFrequency;// >> 2;
	cr0_div = 0;
	cmp_clk = 0xFFFFFFFF;
	prescale = 2;
	while (cmp_clk > Frequency)
	{
		cmp_clk = ssp_clk / ((cr0_div + 1) * prescale);
		if (cmp_clk > Frequency)
		{
			cr0_div++;
			if (cr0_div > 0xFF)
			{
				cr0_div = 0;
				prescale += 2;
			}
		}
	}
	ssp[SspNum]->CR0 &= (~SSP_CR0_SCR(0xFF)) & SSP_CR0_BITMASK;
	ssp[SspNum]->CR0 |= (SSP_CR0_SCR(cr0_div)) & SSP_CR0_BITMASK;
	ssp[SspNum]->CPSR = prescale & SSP_CPSR_BITMASK;
}

void Ssp::Connect(char SspNum)
{
	if (SspNum == 1)
		LPC_PINCON->PINSEL0 = 0x000C8000;
	else if (SspNum == 0)
	{
		LPC_PINCON->PINSEL0 = 0x80000000;
		LPC_PINCON->PINSEL1 = 0x0000000C;
	}
}

char Ssp::ReadWrite(char Data, char SspNum)
{
	ssp[SspNum]->DR = Data;
	while (ssp[SspNum]->SR & 0x10);                 /* Wait for transfer to finish */
	return ssp[SspNum]->DR;                      /* Return received value       */
}