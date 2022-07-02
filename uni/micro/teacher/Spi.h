#ifndef SPI_H
#define SPI_H
class Spi
{
	public:
		Spi();
		void Init();
		void Connect();
		char ReadWrite(char TxData);	
};

#endif
