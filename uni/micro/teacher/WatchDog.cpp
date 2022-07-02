#include "WatchDog.h"
#include "WatchDogDef.h"
#include "lpc17xx.h"

WatchDog::WatchDog()
{
	Counter = 0;
}

WatchDog::~WatchDog()
{
}

void WatchDog::Init()
{
	//NVIC_EnableIRQ(WDT_IRQn);
	LPC_WDT->WDTC = WDT_FEED_VALUE;	/* once WDEN is set, the WDT will start after feeding */
	LPC_WDT->WDMOD = WDEN | WDRESET;
	LPC_WDT->WDCLKSEL = 0x80000001;
	
	LPC_WDT->WDFEED = 0xAA;		/* Feeding sequence */
	LPC_WDT->WDFEED = 0x55; 
}

void WatchDog::Feed()
{
	LPC_WDT->WDFEED = 0xAA;		/* Feeding sequence */
  LPC_WDT->WDFEED = 0x55;
}

void WatchDog::Handler()
{
	LPC_WDT->WDMOD &= ~WDTOF;		/* clear the time-out terrupt flag */
	Counter++;
}
