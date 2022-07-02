#ifndef  SSP_H
#define SSP_H
#include "SspDef.h"
#include "lpc17xx.h"

class Ssp
{
	public:
		Ssp();
		~Ssp();
		void Init(char SspNum = DefaultSSP);
		void Connect(char SspNum = DefaultSSP);
		char ReadWrite(char Data, char SspNum = DefaultSSP);
		void SetClock(int Frequency, char SspNum = DefaultSSP);
	private:
	LPC_SSP_TypeDef* ssp[2];
};

#endif
