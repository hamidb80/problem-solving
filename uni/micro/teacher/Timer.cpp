#include "timer.h"
#include "lpc17xx.h"
extern int SystemFrequency;

void Timer::Init()
{
	LPC_SC->PCONP |= 1 << 1;
	EnableInterrupt(0);
}

void Timer::Start()
{
	LPC_TIM0->TCR = 3;
	LPC_TIM0->TCR = 1;
}

void Timer::Stop()
{
	LPC_TIM0->TCR = 0;
}

void Timer::EnableInterrupt(char MRNumber)
{
	NVIC_EnableIRQ(TIMER0_IRQn);
	LPC_TIM0->MCR = 1 << (MRNumber * 3);
}

void Timer::SetInterval(char MRNumber, int milisecond)
{
	int pclk = SystemFrequency >> 2;
	int value = (pclk * milisecond) / 1000;
	switch (MRNumber)
	{
		case 0: LPC_TIM0->MR0 = value; break;
		case 1: LPC_TIM0->MR1 = value; break;
		case 2: LPC_TIM0->MR2 = value; break;
		case 3: LPC_TIM0->MR3 = value; break;
	}
}

void Timer::Wait(int milisecond)
{
	WaitDone = false;
	SetInterval(0, milisecond);
	Start();
	while (!WaitDone);
	Stop();
}

void Timer::Handler0()
{
	if (LPC_TIM0->IR & 1)
		WaitDone = true;
}

extern Timer timer;
extern "C"
{
	void TIMER0_IRQHandler()
	{
		timer.Handler0();
	}
	
	void TIMER1_IRQHandler()
	{
	}
}