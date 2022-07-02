#ifndef USBDESC_H
#define USBDESC_H
#include "stdint.h"

extern const uint8_t USB_DeviceDescriptor1[];
extern const uint8_t USB_ConfigDescriptor1[];
extern const uint8_t USB_StringDescriptor1[];

extern const uint8_t HID_ReportDescriptor1[];

class USBDesc
{
	public:	
		USBDesc();
		~USBDesc();	

		const uint8_t* USB_DeviceDescriptor;
		const uint8_t* USB_ConfigDescriptor;
		const uint8_t* USB_StringDescriptor;
		
		const uint8_t* HID_ReportDescriptor;
		uint16_t HID_ReportDescSize;
		
};

#endif
