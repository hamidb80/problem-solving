#include "gpio.h"
#include "lpc17xx.h"

void GPIO::Init(int port, int pin, int direction)
{
	//LPC_GPIO0->FIODIR = LPC_GPIO0->FIODIR | 1 << pin;
	if (port == 0)
	{
		LPC_GPIO0->FIODIR &= ~(1 << pin);
		LPC_GPIO0->FIODIR |= direction << pin;
	}
	else if (port == 1)
	{
		LPC_GPIO1->FIODIR &= ~(1 << pin);
		LPC_GPIO1->FIODIR |= direction << pin;
	}
	else if (port == 2)
	{
		LPC_GPIO2->FIODIR &= ~(1 << pin);
		LPC_GPIO2->FIODIR |= direction << pin;
	}
	else if (port == 3)
	{
		LPC_GPIO3->FIODIR &= ~(1 << pin);
		LPC_GPIO3->FIODIR |= direction << pin;
	}
	else if (port == 4)
	{
		LPC_GPIO4->FIODIR &= ~(1 << pin);
		LPC_GPIO4->FIODIR |= direction << pin;
	}
	///
}

void GPIO::Tgl(int port, int pin)
{
	if (port == 0)
		LPC_GPIO0->FIOPIN ^= 1 << pin;
	else if (port == 1)
		LPC_GPIO1->FIOPIN ^= 1 << pin;
	else if (port == 2)
		LPC_GPIO2->FIOPIN ^= 1 << pin;
	else if (port == 3)
		LPC_GPIO3->FIOPIN ^= 1 << pin;
	///
}

void GPIO::InitInterrupt(int port, int pin)
{
	NVIC_EnableIRQ(EINT3_IRQn);
	if (port == 0)
	{
		LPC_GPIOINT->IO0IntEnR |= 1 << pin;
		LPC_GPIOINT->IO0IntEnF |= 1 << pin;
	}
	else if (port == 2)
	{
		LPC_GPIOINT->IO2IntEnR |= 1 << pin;
		LPC_GPIOINT->IO2IntEnF |= 1 << pin;
	}
}

void GPIO::Set(int port, int pin)
{
	if (port == 0)
		LPC_GPIO0->FIOSET |= 1 << pin;
	else if (port == 1)
		LPC_GPIO1->FIOSET |= 1 << pin;
	else if (port == 2)
		LPC_GPIO2->FIOSET |= 1 << pin;
	else if (port == 3)
		LPC_GPIO3->FIOSET |= 1 << pin;
	///
}

void GPIO::Clr(int port, int pin)
{
	if (port == 0)
		LPC_GPIO0->FIOCLR |= 1 << pin;
	else if (port == 1)
		LPC_GPIO1->FIOCLR |= 1 << pin;
	else if (port == 2)
		LPC_GPIO2->FIOCLR |= 1 << pin;
	else if (port == 3)
		LPC_GPIO3->FIOCLR |= 1 << pin;
	///
}

extern GPIO gpio;
extern "C"
{
void EINT3_IRQHandler()
{
	if (LPC_GPIOINT->IO0IntStatR & (1 << 6))
		gpio.Set(2, 0);
	if (LPC_GPIOINT->IO0IntStatF & 0x00000020)
		gpio.Clr(2, 0);
	
	LPC_GPIOINT->IO0IntClr = 0xFFFFFFFF;
	LPC_GPIOINT->IO2IntClr = 0XFFFFFFFF;
}
}