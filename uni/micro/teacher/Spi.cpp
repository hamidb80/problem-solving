#include "Spi.h"
#include "lpc17xx.h"

Spi::Spi()
{
}

void Spi::Init()
{
	Connect();
	LPC_SPI->SPCCR = 0x40;	// Clock Setting
	LPC_SPI->SPCR  = (0 << 2) |	// BitEnable; 8 bit data transfer
 					 (0 << 3) |	// CPHA = 0, transfer start and end with SSEL
 					 (0 << 4) |	// CPOL = 0, SCK is active high
 					 (1 << 5) |	// MSTR = 1, SPI operate in master mode
 					 (0 << 6) |	// LSBF = 0, SPI data is transmited MSB first
 					 (0 << 7);	// SPIE = 0, interrupt is diasble
}

void Spi::Connect()
{
	LPC_PINCON->PINSEL0 |= 3 << 28;
	LPC_PINCON->PINSEL1 |= 0xF << 2;
}

char Spi::ReadWrite(char TxData)
{
	LPC_SPI->SPDR = TxData;					//write data to data register
    while ( 0 == (LPC_SPI->SPSR & 0x80));	//wait until data transfer is complete
    return LPC_SPI->SPDR;					//				    
}
