#include "Outoperator.h"

const unsigned char OutOperator::Symbol[16] = 
{
	'0', '1', '2', '3', '4', '5', '6', '7', 
	'8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
};

OutOperator::OutOperator()
{
}

OutOperator::~OutOperator()
{
}

OutOperator& OutOperator::operator << (char d)
{
	Send(d);
	return *this;
}

OutOperator& OutOperator::operator << (char* d)
{
	while (*d)
		Send(*d++);
	return *this;
}

OutOperator& OutOperator::operator << (const char* d)
{
	while (*d)
		Send(*d++);
	return *this;
}

OutOperator& OutOperator::operator << (unsigned char d)
{
	Send(Symbol[(d & 0xF0) >> 4]);	
	Send(Symbol[d & 0x0F]);
	return *this;
}

OutOperator& OutOperator::operator << (int input)
{
	unsigned char buf[10];
		if (input < 0)
		{
			Send('-');
			input = -input;
		}
		itoa((unsigned int)input, buf);
		*this << (char*)buf;
	return *this;
}

OutOperator& OutOperator::operator << (RTCTime& d)
{
	*this << (int)d.Year << '/' << (int)d.Mon << '/' << (int)d.Mday << ' ' << (int)d.Hour << ':' << (int)d.Min << ':' << (int)d.Sec << '\n';
	return *this;
}

OutOperator& OutOperator::operator << (unsigned int d)
{
	unsigned char* buf = (unsigned char*)&d;
	*this << buf[3] << buf[2] << buf[1] << buf[0];
	return *this;
}

int OutOperator::itoa(unsigned int disp, unsigned char *dispbuf)
{
	unsigned char i = 0;
	
	if (disp == 0)
	{
		dispbuf[0] = '0';
		dispbuf[1] = 0;
		return 1;
	}
	while(disp > 0)
	{
		dispbuf[i] = disp % 10 + '0';
		disp /= 10;
		i++;
	}
	dispbuf[i] = 0;
	Reverse(dispbuf);
	return i;
}

void OutOperator::Reverse(unsigned char* inp)
{
	unsigned short len = 0;
	while(*(inp + len++));
	len--;
	unsigned short count = len >> 1;
	char temp;
	for (int i = 0; i < count; i++)
	{
		temp = inp[i];
		inp[i] = inp[len-i-1];
		inp[len-i-1] = temp;
	}
}