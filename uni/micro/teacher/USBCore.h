#ifndef USBCOR1_H
#define USBCOR1_H
#include "USBCoreDef.h"
#include "usb.h"
#include "hiduser.h"
#include "USBDesc.h"
#include "usbcfg.h"
#include "USBHW.h"

class USBCore
{
	public:
		USBCore();
		~USBCore();
		void Init();
		void Run();
		void ResetCore (void);
		void SetupStage (void);
		void DataInStage (void);
		void DataOutStage (void);
		void StatusInStage (void);
		void StatusOutStage (void);
		__inline uint32_t ReqGetStatus (void);
		__inline uint32_t ReqSetClrFeature (uint32_t sc);
		__inline uint32_t ReqSetAddress (void);
		__inline uint32_t ReqGetDescriptor (void);
		__inline uint32_t ReqGetConfiguration (void);
		__inline uint32_t ReqSetConfiguration (void);
		__inline uint32_t ReqGetInterface (void);
		__inline uint32_t ReqSetInterface (void);

		void EndPoint0 (uint32_t event);
		void EndPoint1 (uint32_t event);
		void EndPoint2 (uint32_t event);
		void EndPoint3 (uint32_t event);
		void EndPoint4 (uint32_t event);
		void EndPoint5 (uint32_t event);
		void EndPoint6 (uint32_t event);
		void EndPoint7 (uint32_t event);
		void EndPoint8 (uint32_t event);
		void EndPoint9 (uint32_t event);
		void EndPoint10 (uint32_t event);
		void EndPoint11 (uint32_t event);
		void EndPoint12 (uint32_t event);
		void EndPoint13 (uint32_t event);
		void EndPoint14 (uint32_t event);
		void EndPoint15 (uint32_t event);

		#if USB_FEATURE_EVENT
		void Feature_Event (void);
		#endif
		#if USB_INTERFACE_EVENT
		void Interface_Event (void);
		#endif
		#if USB_CONFIGURE_EVENT
		void Configure_Event (void);
		#endif
		#if USB_ERROR_EVENT
		void Error_Event (uint32_t error);
		#endif
		#if USB_WAKEUP_EVENT
		void WakeUp_Event (void);
		#endif
		#if USB_SOF_EVENT
		void SOF_Event (void);
		#endif
		#if USB_RESET_EVENT
		void Reset_Event (void);
		#endif
		#if USB_SUSPEND_EVENT
		void Suspend_Event (void);
		#endif
		#if USB_RESUME_EVENT
		void Resume_Event (void);
		#endif
		#if USB_POWER_EVENT
		void Power_Event (uint32_t  power);
		#endif
		void (USBCore::* P_EP[16]) (uint32_t event);
		unsigned short DataAvailable;
	
		/* USB Core Global Variables */
		uint16_t DeviceStatus;
		uint8_t  DeviceAddress;
		uint8_t  Configuration;
		uint32_t EndPointMask;
		uint32_t EndPointHalt;
		uint32_t EndPointStall;
		uint8_t  NumInterfaces;
		uint8_t  AltSetting[USB_IF_NUM];
		
		/* USB Endpoint 0 Buffer */
		uint8_t  EP0Buf[USB_MAX_PACKET0];
		uint8_t  EP0Bufout[USB_MAX_PACKET0];
		
		/* USB Endpoint 0 Data Info */
		USB_EP_DATA EP0Data;
		
		/* USB Setup Packet */
		USB_SETUP_PACKET SetupPacket;
		
		USBHW usbhw;		
		HIDUser hiduser;
		USBDesc usbdesc;
};

#endif