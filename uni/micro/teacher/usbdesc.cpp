#include "usbdesc.h"
#include "HIDDescriptors.h"


USBDesc::USBDesc()
{
	USB_DeviceDescriptor = USB_DeviceDescriptor1;
	USB_ConfigDescriptor = USB_ConfigDescriptor1;
	USB_StringDescriptor = USB_StringDescriptor1;

	HID_ReportDescriptor = HID_ReportDescriptor1;
	HID_ReportDescSize = HID_REPORT_DESC_SIZE;
}

USBDesc::~USBDesc()
{
}

