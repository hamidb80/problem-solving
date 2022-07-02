#include "SpiFlash.h"
#include "gpio.h"
extern GPIO gpio;
extern void Delay(int d);
extern unsigned short strcpy(char* dest, char* src, short count, char UPDOWN);


SpiFlash::SpiFlash()
{
}

SpiFlash::~SpiFlash()
{
}

void SpiFlash::Init(char* port, char* pin)
{
	Spi::Init();
	CEPort = port[0];
	WPPort = port[1];
	RSTPort = port[2];
	CEPin = pin[0];
	WPPin = pin[1];
	RSTPin = pin[2];
	
	gpio.Init(CEPort, CEPin);
	//gpio.Init(WPPort, WPPin);
	//gpio.Init(RSTPort, RSTPin);
	gpio.Set(CEPort, CEPin);
	//gpio.Set(WPPort, WPPin);
	//gpio.Set(RSTPort, RSTPin);
	
	SpiFlash_CSLow();
	ReadWrite(AT45DB_WakeUp);//  send M45P_PowerDown command 0xAB
	SpiFlash_CSHigh();  
	Delay(10000);
	SpiFlash_CSLow();
	ReadWrite(0x3D);
	ReadWrite(0x2A);
	ReadWrite(0x80);
	ReadWrite(0xA6);
	SpiFlash_CSHigh();  
}

inline void SpiFlash::SpiFlash_CSLow()
{
	gpio.Clr(CEPort, CEPin);
}

inline void SpiFlash::SpiFlash_CSHigh()
{
	gpio.Set(CEPort, CEPin);
}

unsigned char SpiFlash::ReadSR(void)
{
	unsigned char ret=0;
	SpiFlash_CSLow();
	ReadWrite(AT45DB_ReadStatusReg);
	ret = ReadWrite(0xFF);
	SpiFlash_CSHigh();
	return ret;
}

void SpiFlash::PowerDown(void)
{
	//Sys.uart << "Down.\n";
// 	SpiFlash_CSLow();                    
// 	ReadWrite(AT45DB_PowerDown);       
// 	SpiFlash_CSHigh(); 
// 	Sys.timer.Wait(50);
}

void SpiFlash::WAKEUP(void)
{
	//Sys.uart << "Wake.\n";
// 	SpiFlash_CSLow();                   
// 	ReadWrite(AT45DB_WakeUp);//  send M45P_PowerDown command 0xAB    
// 	SpiFlash_CSHigh();
// 	Sys.timer.Wait(500);
}

void SpiFlash::WaitBusy(void)
{
	unsigned char result;
	do
	{
		result = ReadSR();
	}while((result & 0x80) == 0);
	
}

void SpiFlash::Read(unsigned char* pBuffer,unsigned int ReadAddr,unsigned int NumByteToRead, bool BufNo)
{
	unsigned int i;                                                        
	SpiFlash_CSLow();                    
	ReadWrite(AT45DB_PageReadContinuous);        
	ReadWrite((unsigned char)((unsigned char*)&ReadAddr)[2]);    
	ReadWrite((unsigned char)((unsigned char*)&ReadAddr)[1]); 
	ReadWrite((unsigned char)((unsigned char*)&ReadAddr)[0]); 
	ReadWrite(0XFF); ReadWrite(0XFF); ReadWrite(0XFF); ReadWrite(0XFF);    
	for(i = 0 ; i < NumByteToRead ; i++)
			pBuffer[i] = ReadWrite(0XFF);
	SpiFlash_CSHigh();
}

void SpiFlash::Write(unsigned char* pBuffer,unsigned int WriteAddr,unsigned int NumByteToWrite, bool BufNo)
{
	unsigned int pageremain;
	unsigned char temp[512];
	unsigned char* ptr = temp;
	unsigned short tempcounter1 = ((unsigned short)WriteAddr & 0x01FF);
	unsigned int tempAddress1;
	pageremain = 512 - tempcounter1;   
	
	if(NumByteToWrite <= pageremain)
	{
		pageremain = NumByteToWrite;
		if (tempcounter1 == 0)
			tempcounter1 = 513;
	}
	while(true)
	{
		if (tempcounter1 > 512)
		{
			if (pageremain != 512)
			{
				tempAddress1 = WriteAddr + pageremain;
				tempcounter1 = 512 - pageremain;
			}
			else
				tempAddress1 = WriteAddr;
			strcpy((char*)temp, (char*)pBuffer, pageremain, 0);
			if (pageremain != 512)
			{
				Read(temp + pageremain, tempAddress1, tempcounter1, BufNo);
				tempcounter1 = ((unsigned short)WriteAddr & 0x01FF);
				tempAddress1 = WriteAddr - tempcounter1;
			}
			ptr = temp;
		}
		else if (tempcounter1 > 0)
		{
			tempAddress1 = WriteAddr - tempcounter1;
			Read(temp, tempAddress1, tempcounter1, BufNo);
			if (pageremain == NumByteToWrite)
				if (((unsigned short)(WriteAddr + pageremain) & 0x01FF) > 0)
				{
					tempAddress1 = WriteAddr + pageremain;
					tempcounter1 = ((unsigned short)tempAddress1 & 0x01FF);
					Read(temp + tempcounter1, tempAddress1, 512 - tempcounter1, BufNo);
					tempcounter1 = ((unsigned short)WriteAddr & 0x01FF);
					tempAddress1 = WriteAddr - tempcounter1;
				}
			strcpy((char*)temp + tempcounter1, (char*)pBuffer, pageremain, 0);
			ptr = temp;
		}
		else
		{
			ptr = pBuffer;
			tempAddress1 = WriteAddr;
		}
		WritePage(ptr, tempAddress1, 512, BufNo);
		if(NumByteToWrite == pageremain)
			break;
		else //NumByteToWrite > pageremain
		{
			pBuffer += pageremain;
			WriteAddr += pageremain;
			NumByteToWrite -= pageremain;
			if(NumByteToWrite > 512)
			{
				pageremain = 512; 
				tempcounter1 = 0;
			}
			else 
			{
				pageremain = NumByteToWrite;
				tempcounter1 = 513;
			}
		}
	}
}

void SpiFlash::WritePage(unsigned char * pBuffer,unsigned int WriteAddr,unsigned int NumByteToWrite, bool BufNo)
{
	unsigned int i;
	SpiFlash_CSLow();  
	if (BufNo)		
		ReadWrite(AT45DB_PageWriteBuffer2ToMain);        
	else
		ReadWrite(AT45DB_PageWriteBuffer1ToMain); 
	ReadWrite((unsigned char)((unsigned char*)&WriteAddr)[2]);     
	ReadWrite((unsigned char)((unsigned char*)&WriteAddr)[1]);   
	ReadWrite((unsigned char)((unsigned char*)&WriteAddr)[0]);   
	for(i=0;i<NumByteToWrite;i++)
		ReadWrite(pBuffer[i]); 
	SpiFlash_CSHigh(); 
	WaitBusy();
}

void SpiFlash::ReadBuffer(unsigned char * pBuffer,unsigned int ReadAddr,unsigned int NumByteToRead, bool BufNo)
{
	unsigned int i;                                                        
	SpiFlash_CSLow();  
	if (BufNo)
		ReadWrite(AT45DB_ReadBuffer2);        
	else
		ReadWrite(AT45DB_ReadBuffer1);

	ReadWrite(AT45DB_PageReadContinuous);        
	ReadWrite((unsigned char)((unsigned char*)&ReadAddr)[2]);    
	ReadWrite((unsigned char)((unsigned char*)&ReadAddr)[1]); 
	ReadWrite((unsigned char)((unsigned char*)&ReadAddr)[0]); 
	ReadWrite(0XFF);    
	for(i=0;i<NumByteToRead;i++)
			pBuffer[i] = ReadWrite(0XFF);
	SpiFlash_CSHigh();
}

void SpiFlash::WriteBuffer(unsigned char * pBuffer,unsigned int WriteAddr,unsigned int NumByteToWrite, bool BufNo)
{
	unsigned int i;  
	SpiFlash_CSLow();   
	if (BufNo)
		ReadWrite(AT45DB_PageWriteBuffer2);        
	else
		ReadWrite(AT45DB_PageWriteBuffer1);
	ReadWrite((unsigned char)((unsigned char*)&WriteAddr)[2]);     
	ReadWrite((unsigned char)((unsigned char*)&WriteAddr)[1]);   
	ReadWrite((unsigned char)((unsigned char*)&WriteAddr)[0]);   
	for(i=0;i<NumByteToWrite;i++)
		ReadWrite(pBuffer[i]); 
	SpiFlash_CSHigh(); 
	WaitBusy();
}
