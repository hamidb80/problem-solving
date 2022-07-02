#include "SysTick.h"
#include "SysTickDef.h"
#include "lpc17xx.h"

Systick::Systick()
{
	Time = 0;
	LastTime = 0;
}

Systick::~Systick()
{
}

extern int SystemFrequency;
void Systick::Init(unsigned int time)
{
	if (time > maxtime)
	{
		while (true);
	}
	else
	{
		SysTick->CTRL = ST_CTRL_CLKSOURCE | ST_CTRL_ENABLE | ST_CTRL_TICKINT;
		SysTick->LOAD = (SystemFrequency / 1000) * time - 1;
	}
}

void Systick::Init(unsigned int Frequency, unsigned int time)
{
	if (time > maxtime)
	{
		while(true);
	}
	else
	{
		SysTick->CTRL = ST_CTRL_CLKSOURCE | ST_CTRL_ENABLE | ST_CTRL_TICKINT;
		SysTick->LOAD = (Frequency/1000)*time - 1;
	}
}

unsigned int Systick::Get()
{
	return SysTick->VAL;
}

void Task1(int interval);
void Task2(int interval);

void Systick::Run()
{
	short TimeInterval = Time - LastTime;
	if (TimeInterval <= 0)
	{
		LastTime = Time;
		return;
	}
	//Do tasks with TimeInterval
	Task1(TimeInterval);
	Task2(TimeInterval);
	//
	LastTime = Time;
}

void Systick::Handler(void)
{
	SysTick->CTRL &= ~ST_CTRL_COUNTFLAG;
	Time++;
}

extern Systick systick;
extern "C"
{
	void SysTick_Handler()
	{
		systick.Handler();
	}
}
