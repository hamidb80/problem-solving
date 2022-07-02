#ifndef FIFO_H
#define FIFO_H

#define UARTBufferSize 2000

class Fifo
{
	public:
		Fifo();
		~Fifo();
		void Init();
		void Add(char d);
		char Remove();
		bool HasData();
	
		unsigned short Count;
	private:
		char Buffer[UARTBufferSize + 1];
		unsigned short Top;
		unsigned short Rear;
	
};

#endif