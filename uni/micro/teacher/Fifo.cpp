#include "Fifo.h"

Fifo::Fifo()
{
}

Fifo::~Fifo()
{
}

void Fifo::Init()
{
	Top = Rear = Count = 0;
}

void Fifo::Add(char d)
{
	if (Count >= UARTBufferSize)
		return;
	
	Buffer[Rear] = d;
	
	Rear++;
	if (Rear >= UARTBufferSize)
		Rear = 0;
	Count++;
}

char Fifo::Remove()
{
	if (Count <= 0)
		return 255;
	
	char result = Buffer[Top];
	Top++;
	if (Top >= UARTBufferSize)
		Top = 0;
	Count--;
	
	return result;
}

bool Fifo::HasData()
{
	if (Count > 0)
		return true;
	else
		return false;
}