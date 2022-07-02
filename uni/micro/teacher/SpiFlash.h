#ifndef SPIFLASH_H
#define SPIFLASH_H
#include "SpiFlashDef.h"
#include "Spi.h"

class SpiFlash : Spi
{
	public:
		SpiFlash();
		~SpiFlash();
		void Init(char* port, char* pin); 
		void PowerDown(void);
		void WAKEUP(void);
		void Read(unsigned char * pBuffer,unsigned int ReadAddr,unsigned int NumByteToRead, bool BufNo);
		void Write(unsigned char * pBuffer,unsigned int WriteAddr,unsigned int NumByteToWrite, bool BufNo);
		unsigned char ReadSR(void);	
		void ReadBuffer(unsigned char * pBuffer,unsigned int ReadAddr,unsigned int NumByteToRead, bool BufNo);
		void WriteBuffer(unsigned char * pBuffer,unsigned int WriteAddr,unsigned int NumByteToWrite, bool BufNo);
	private: 
		void SpiFlash_CSLow();
		void SpiFlash_CSHigh();
		void WaitBusy(void);
		void WritePage(unsigned char * pBuffer,unsigned int WriteAddr,unsigned int NumByteToWrite, bool BufNo);
		unsigned int ChipSelect;  
		char CEPort, CEPin;
		char WPPort, WPPin;
		char RSTPort, RSTPin;
};

#endif
