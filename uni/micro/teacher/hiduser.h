#ifndef HIDUSER_H
#define HIDUSER_H
#include "hiduserDef.h"
#include "stdint.h"
#include "OutOperator.h"
#include "Fifo.h"

class HIDUser : public OutOperator
{
	friend class USBCore;
	public:
		HIDUser();
		~HIDUser();
		void Send();
		void Send(char input);
		void ParseBuffer(char* buf);

		uint32_t HID_GetReport (void);
		uint32_t HID_SetReport (void);
		uint32_t HID_GetIdle (void);
		uint32_t HID_SetIdle (void);
		uint32_t HID_GetProtocol (void);
		uint32_t HID_SetProtocol (void);

	private:
		uint8_t HID_Protocol;
		uint8_t HID_IdleTime[HID_REPORT_NUM];
	
		Fifo RecieveBuffer;
		Fifo SendBuffer;
		
};

#endif
