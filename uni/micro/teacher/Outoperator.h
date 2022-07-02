#ifndef OUTOPERATOR_H
#define OUTOPERATOR_H
#include "RTC.h"

class OutOperator
{
	public:
		virtual void Send(char d) = 0;
		OutOperator();
		~OutOperator();
	
		OutOperator& operator << (char d);
		OutOperator& operator << (char* d);
		OutOperator& operator << (const char* d);
		OutOperator& operator << (unsigned char d);
		OutOperator& operator << (int d);
		OutOperator& operator << (unsigned int d);
		OutOperator& operator << (RTCTime& d);
		
		static const unsigned char Symbol[];
	
		int itoa(unsigned int disp, unsigned char *dispbuf);
		void Reverse(unsigned char* inp);
};

#endif