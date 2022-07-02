#include "rtl.h"
#include "usb.h"
#include "hid.h"
#include "usbdescdef.h"
#include "usbcfg.h"
#include "usbcore.h"
#include "hiduser.h"
#include "types.h"

extern USBCore usb;

HIDUser::HIDUser()
{
	RecieveBuffer.Init();
	SendBuffer.Init();
}

HIDUser::~HIDUser()
{
}

void HIDUser::Send(char input)
{
	SendBuffer.Add(input);
}

#include "gpio.h"
extern GPIO gpio;
void HIDUser::Send()
{
	unsigned char i = 0;
	for (; i < USB_MAX_PACKET0; i++)
		if (SendBuffer.HasData())
			usb.EP0Buf[i] = SendBuffer.Remove();
		else
			usb.EP0Buf[i] = 0;
	usb.EP0Data.pData = usb.EP0Buf;
	usb.EP0Data.Count = i;
}

void HIDUser::ParseBuffer(char* buf)
{
}

uint32_t HIDUser::HID_GetReport (void) {

  /* ReportID = SetupPacket.wValue.WB.L; */
  switch (usb.SetupPacket.wValue.WB.H) {
    case HID_REPORT_INPUT:
	  	
      break;
    case HID_REPORT_OUTPUT:
      return (FALSE);          /* Not Supported */
    case HID_REPORT_FEATURE:
      /* EP0Buf[] = ...; */
      /* break; */
      return (FALSE);          /* Not Supported */
  }
  return (TRUE);
}

extern char OutReport;
uint32_t HIDUser::HID_SetReport (void) {
  switch (usb.SetupPacket.wValue.WB.H) {
    case HID_REPORT_INPUT:
      return (FALSE);          /* Not Supported */
    case HID_REPORT_OUTPUT:
      OutReport = usb.EP0Buf[0];
      break;
    case HID_REPORT_FEATURE:
      return (FALSE);          /* Not Supported */
  }
  return (TRUE);
}

uint32_t HIDUser::HID_GetIdle (void) {

  usb.EP0Buf[0] = HID_IdleTime[usb.SetupPacket.wValue.WB.L];
  return (TRUE);
}

uint32_t HIDUser::HID_SetIdle (void) {

  HID_IdleTime[usb.SetupPacket.wValue.WB.L] = usb.SetupPacket.wValue.WB.H;
  return (TRUE);
}

uint32_t HIDUser::HID_GetProtocol (void) {

  usb.EP0Buf[0] = HID_Protocol;
  return (TRUE);
}

uint32_t HIDUser::HID_SetProtocol (void) {

  HID_Protocol = usb.SetupPacket.wValue.WB.L;
  return (TRUE);
}