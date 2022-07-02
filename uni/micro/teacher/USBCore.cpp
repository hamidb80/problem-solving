#include "rtl.h"
#include "usb.h"
#include "usbcfg.h"
#include "usbhw.h"
#include "usbhwDef.h"
#include "usbcore.h"
#include "usbdescDef.h"
#include "usbdesc.h"
#include "types.h"


#if (USB_CLASS)

#if (USB_AUDIO)
#include "audio.h"
#include "adcuser.h"
#endif

#include "hid.h"
#include "hiduser.h"

#if (USB_CDC)
#include "cdc.h"
#include "cdcuser.h"
#endif

#endif

#if (USB_VENDOR)
#include "vendor.h"
#endif

#pragma diag_suppress 111,177,1441

/*
 *  Reset USB Core
 *    Parameters:      None
 *    Return Value:    None
 */
#include "stdint.h"

USBCore::USBCore()
{
	P_EP[0] = &USBCore::EndPoint0;
	P_EP[1] = &USBCore::EndPoint1;
	P_EP[2] = &USBCore::EndPoint2;
	P_EP[3] = &USBCore::EndPoint3;
	P_EP[4] = &USBCore::EndPoint4;
	P_EP[5] = &USBCore::EndPoint5;
	P_EP[6] = &USBCore::EndPoint6;
	P_EP[7] = &USBCore::EndPoint7;
	P_EP[8] = &USBCore::EndPoint8;
	P_EP[9] = &USBCore::EndPoint9;
	P_EP[10] = &USBCore::EndPoint10;
	P_EP[11] = &USBCore::EndPoint11;
	P_EP[12] = &USBCore::EndPoint12;
	P_EP[13] = &USBCore::EndPoint13;
	P_EP[14] = &USBCore::EndPoint14;
	P_EP[15] = &USBCore::EndPoint15;
	DataAvailable = 0;
}

USBCore::~USBCore()
{
}

void USBCore::Init()
{
	usbhw.Init();
	usbhw.Connect(TRUE);
}

void USBCore::Run()
{
	if (!DataAvailable)
		return;
	hiduser.ParseBuffer((char*)EP0Bufout);
	DataAvailable = 0;
}

void USBCore::ResetCore (void) {

  DeviceStatus  = USB_POWER;
  DeviceAddress = 0;
  Configuration = 0;
  EndPointMask  = 0x00010001;
  EndPointHalt  = 0x00000000;
  EndPointStall = 0x00000000;
}


/*
 *  USB Request - Setup Stage
 *    Parameters:      None (global SetupPacket)
 *    Return Value:    None
 */

void USBCore::SetupStage (void) {
  usbhw.ReadEP(0x00, (uint8_t *)&SetupPacket);
}


/*
 *  USB Request - Data In Stage
 *    Parameters:      None (global EP0Data)
 *    Return Value:    None
 */

void USBCore::DataInStage (void) {
  uint32_t cnt;

  if (EP0Data.Count > USB_MAX_PACKET0) {
    cnt = USB_MAX_PACKET0;
  } else {
    cnt = EP0Data.Count;
  }
  cnt = usbhw.WriteEP(0x80, EP0Data.pData, cnt);
  EP0Data.pData += cnt;
  EP0Data.Count -= cnt;
}


/*
 *  USB Request - Data Out Stage
 *    Parameters:      None (global EP0Data)
 *    Return Value:    None
 */

void USBCore::DataOutStage (void) {
  uint32_t cnt;

  cnt = usbhw.ReadEP(0x00, EP0Data.pData);
  EP0Data.pData += cnt;
  EP0Data.Count -= cnt;
}


/*
 *  USB Request - Status In Stage
 *    Parameters:      None
 *    Return Value:    None
 */

void USBCore::StatusInStage (void) {
  usbhw.WriteEP(0x80, (uint8_t*)NULL, 0);
}


/*
 *  USB Request - Status Out Stage
 *    Parameters:      None
 *    Return Value:    None
 */

void USBCore::StatusOutStage (void) {
  usbhw.ReadEP(0x00, EP0Buf);
}


/*
 *  Get Status USB Request
 *    Parameters:      None (global SetupPacket)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

__inline uint32_t USBCore::ReqGetStatus (void) {
  uint32_t n, m;

  switch (SetupPacket.bmRequestType.BM.Recipient) {
    case REQUEST_TO_DEVICE:
      EP0Data.pData = (uint8_t *)&DeviceStatus;
      break;
    case REQUEST_TO_INTERFACE:
      if ((Configuration != 0) && (SetupPacket.wIndex.WB.L < NumInterfaces)) {
        *((__packed uint16_t *)EP0Buf) = 0;
        EP0Data.pData = EP0Buf;
      } else {
        return (FALSE);
      }
      break;
    case REQUEST_TO_ENDPOINT:
      n = SetupPacket.wIndex.WB.L & 0x8F;
      m = (n & 0x80) ? ((1 << 16) << (n & 0x0F)) : (1 << n);
      if (((Configuration != 0) || ((n & 0x0F) == 0)) && (EndPointMask & m)) {
        *((__packed uint16_t *)EP0Buf) = (EndPointHalt & m) ? 1 : 0;
        EP0Data.pData = EP0Buf;
      } else {
        return (FALSE);
      }
      break;
    default:
      return (FALSE);
  }
  return (TRUE);
}


/*
 *  Set/Clear Feature USB Request
 *    Parameters:      sc:    0 - Clear, 1 - Set
 *                            (global SetupPacket)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

__inline uint32_t USBCore::ReqSetClrFeature (uint32_t sc) {
  uint32_t n, m;

  switch (SetupPacket.bmRequestType.BM.Recipient) {
    case REQUEST_TO_DEVICE:
      if (SetupPacket.wValue.W == USB_FEATURE_REMOTE_WAKEUP) {
        if (sc) {
          usbhw.WakeUpCfg(TRUE);
          DeviceStatus |=  USB_GETSTATUS_REMOTE_WAKEUP;
        } else {
          usbhw.WakeUpCfg(FALSE);
          DeviceStatus &= ~USB_GETSTATUS_REMOTE_WAKEUP;
        }
      } else {
        return (FALSE);
      }
      break;
    case REQUEST_TO_INTERFACE:
      return (FALSE);
    case REQUEST_TO_ENDPOINT:
      n = SetupPacket.wIndex.WB.L & 0x8F;
      m = (n & 0x80) ? ((1 << 16) << (n & 0x0F)) : (1 << n);
      if ((Configuration != 0) && ((n & 0x0F) != 0) && (EndPointMask & m)) {
        if (SetupPacket.wValue.W == USB_FEATURE_ENDPOINT_STALL) {
          if (sc) {
            usbhw.SetStallEP(n);
            EndPointHalt |=  m;
          } else {
            if ((EndPointStall & m) != 0) {
              return (TRUE);
            }
            usbhw.ClrStallEP(n);
#if (PROJECT_USE_USB_MSC)
            if ((n == MSC_EP_IN) && ((EndPointHalt & m) != 0)) {
              /* Compliance Test: rewrite CSW after unstall */
              if (mscuser.CSW.dSignature == MSC_CSW_Signature) {
                usbhw.WriteEP(MSC_EP_IN, (uint8_t *)&mscuser.CSW, sizeof(mscuser.CSW));
              }
            }
#endif
            EndPointHalt &= ~m;
          }
        } else {
          return (FALSE);
        }
      } else {
        return (FALSE);
      }
      break;
    default:
      return (FALSE);
  }
  return (TRUE);
}


/*
 *  Set Address USB Request
 *    Parameters:      None (global SetupPacket)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

__inline uint32_t USBCore::ReqSetAddress (void) {

  switch (SetupPacket.bmRequestType.BM.Recipient) {
    case REQUEST_TO_DEVICE:
      DeviceAddress = 0x80 | SetupPacket.wValue.WB.L;
      break;
    default:
      return (FALSE);
  }
  return (TRUE);
}


/*
 *  Get Descriptor USB Request
 *    Parameters:      None (global SetupPacket)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

__inline uint32_t USBCore::ReqGetDescriptor (void) {
  uint8_t  *pD;
  uint32_t len, n;

  switch (SetupPacket.bmRequestType.BM.Recipient) {
    case REQUEST_TO_DEVICE:
      switch (SetupPacket.wValue.WB.H) {
        case USB_DEVICE_DESCRIPTOR_TYPE:
          EP0Data.pData = (uint8_t *)usbdesc.USB_DeviceDescriptor;
          len = USB_DEVICE_DESC_SIZE;
          break;
        case USB_CONFIGURATION_DESCRIPTOR_TYPE:
          pD = (uint8_t *)usbdesc.USB_ConfigDescriptor;
          for (n = 0; n != SetupPacket.wValue.WB.L; n++) {
            if (((USB_CONFIGURATION_DESCRIPTOR *)pD)->bLength != 0) {
              pD += ((USB_CONFIGURATION_DESCRIPTOR *)pD)->wTotalLength;
            }
          }
          if (((USB_CONFIGURATION_DESCRIPTOR *)pD)->bLength == 0) {
            return (FALSE);
          }
          EP0Data.pData = pD;
          len = ((USB_CONFIGURATION_DESCRIPTOR *)pD)->wTotalLength;
          break;
        case USB_STRING_DESCRIPTOR_TYPE:
          pD = (uint8_t *)usbdesc.USB_StringDescriptor;
          for (n = 0; n != SetupPacket.wValue.WB.L; n++) {
            if (((USB_STRING_DESCRIPTOR *)pD)->bLength != 0) {
              pD += ((USB_STRING_DESCRIPTOR *)pD)->bLength;
            }
          }
          if (((USB_STRING_DESCRIPTOR *)pD)->bLength == 0) {
            return (FALSE);
          }
          EP0Data.pData = pD;
          len = ((USB_STRING_DESCRIPTOR *)EP0Data.pData)->bLength;
          break;
        default:
          return (FALSE);
      }
      break;
    case REQUEST_TO_INTERFACE:
      switch (SetupPacket.wValue.WB.H) {
#if PROJECT_USE_USB_HID
        case HID_HID_DESCRIPTOR_TYPE:
          if (SetupPacket.wIndex.WB.L != USB_HID_IF_NUM) {
            return (FALSE);    /* Only Single HID Interface is supported */
          }
          EP0Data.pData = (uint8_t *)usbdesc.USB_ConfigDescriptor + HID_DESC_OFFSET;
          len = HID_DESC_SIZE;
          break;
        case HID_REPORT_DESCRIPTOR_TYPE:
          if (SetupPacket.wIndex.WB.L != USB_HID_IF_NUM) {
            return (FALSE);    /* Only Single HID Interface is supported */
          }
          EP0Data.pData = (uint8_t *)usbdesc.HID_ReportDescriptor;
          len = usbdesc.HID_ReportDescSize;
          break;
        case HID_PHYSICAL_DESCRIPTOR_TYPE:
          return (FALSE);      /* HID Physical Descriptor is not supported */
#endif
        default:
          return (FALSE);
      }
      break;
    default:
      return (FALSE);
  }

  if (EP0Data.Count > len) {
    EP0Data.Count = len;
  }

  return (TRUE);
}


/*
 *  Get Configuration USB Request
 *    Parameters:      None (global SetupPacket)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

__inline uint32_t USBCore::ReqGetConfiguration (void) {

  switch (SetupPacket.bmRequestType.BM.Recipient) {
    case REQUEST_TO_DEVICE:
      EP0Data.pData = &Configuration;
      break;
    default:
      return (FALSE);
  }
  return (TRUE);
}


/*
 *  Set Configuration USB Request
 *    Parameters:      None (global SetupPacket)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

__inline uint32_t USBCore::ReqSetConfiguration (void) {
  USB_COMMON_DESCRIPTOR *pD;
  uint32_t alt = 0;
  uint32_t n, m;

  switch (SetupPacket.bmRequestType.BM.Recipient) {
    case REQUEST_TO_DEVICE:

      if (SetupPacket.wValue.WB.L) {
        pD = (USB_COMMON_DESCRIPTOR *)usbdesc.USB_ConfigDescriptor;
        while (pD->bLength) {
          switch (pD->bDescriptorType) {
            case USB_CONFIGURATION_DESCRIPTOR_TYPE:
              if (((USB_CONFIGURATION_DESCRIPTOR *)pD)->bConfigurationValue == SetupPacket.wValue.WB.L) {
                Configuration = SetupPacket.wValue.WB.L;
                NumInterfaces = ((USB_CONFIGURATION_DESCRIPTOR *)pD)->bNumInterfaces;
                for (n = 0; n < USB_IF_NUM; n++) {
                  AltSetting[n] = 0;
                }
                for (n = 1; n < 16; n++) {
                  if (EndPointMask & (1 << n)) {
                    usbhw.DisableEP(n);
                  }
                  if (EndPointMask & ((1 << 16) << n)) {
                    usbhw.DisableEP(n | 0x80);
                  }
                }
                EndPointMask = 0x00010001;
                EndPointHalt = 0x00000000;
                EndPointStall= 0x00000000;
                usbhw.Configure(TRUE);
                if (((USB_CONFIGURATION_DESCRIPTOR *)pD)->bmAttributes & USB_CONFIG_POWERED_MASK) {
                  DeviceStatus |=  USB_GETSTATUS_SELF_POWERED;
                } else {
                  DeviceStatus &= ~USB_GETSTATUS_SELF_POWERED;
                }
              } else {
                (uint8_t *)pD += ((USB_CONFIGURATION_DESCRIPTOR *)pD)->wTotalLength;
                continue;
              }
              break;
            case USB_INTERFACE_DESCRIPTOR_TYPE:
              alt = ((USB_INTERFACE_DESCRIPTOR *)pD)->bAlternateSetting;
              break;
            case USB_ENDPOINT_DESCRIPTOR_TYPE:
              if (alt == 0) {
                n = ((USB_ENDPOINT_DESCRIPTOR *)pD)->bEndpointAddress & 0x8F;
                m = (n & 0x80) ? ((1 << 16) << (n & 0x0F)) : (1 << n);
                EndPointMask |= m;
                usbhw.ConfigEP((USB_ENDPOINT_DESCRIPTOR *)pD);
                usbhw.EnableEP(n);
                usbhw.ResetEP(n);
              }
              break;
          }
          (uint8_t *)pD += pD->bLength;
        }
      }
      else {
        Configuration = 0;
        for (n = 1; n < 16; n++) {
          if (EndPointMask & (1 << n)) {
            usbhw.DisableEP(n);
          }
          if (EndPointMask & ((1 << 16) << n)) {
            usbhw.DisableEP(n | 0x80);
          }
        }
        EndPointMask  = 0x00010001;
        EndPointHalt  = 0x00000000;
        EndPointStall = 0x00000000;
        usbhw.Configure(FALSE);
      }

      if (Configuration != SetupPacket.wValue.WB.L) {
        return (FALSE);
      }
      break;
    default:
      return (FALSE);
  }
  return (TRUE);
}


/*
 *  Get Interface USB Request
 *    Parameters:      None (global SetupPacket)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

__inline uint32_t USBCore::ReqGetInterface (void) {

  switch (SetupPacket.bmRequestType.BM.Recipient) {
    case REQUEST_TO_INTERFACE:
      if ((Configuration != 0) && (SetupPacket.wIndex.WB.L < NumInterfaces)) {
        EP0Data.pData = AltSetting + SetupPacket.wIndex.WB.L;
      } else {
        return (FALSE);
      }
      break;
    default:
      return (FALSE);
  }
  return (TRUE);
}


/*
 *  Set Interface USB Request
 *    Parameters:      None (global SetupPacket)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

__inline uint32_t USBCore::ReqSetInterface (void) {
  USB_COMMON_DESCRIPTOR *pD;
  uint32_t ifn = 0, alt = 0, old = 0, msk = 0;
  uint32_t n, m;
  uint32_t set;

  switch (SetupPacket.bmRequestType.BM.Recipient) {
    case REQUEST_TO_INTERFACE:
      if (Configuration == 0) return (FALSE);
      set = FALSE;
      pD  = (USB_COMMON_DESCRIPTOR *)usbdesc.USB_ConfigDescriptor;
      while (pD->bLength) {
        switch (pD->bDescriptorType) {
          case USB_CONFIGURATION_DESCRIPTOR_TYPE:
            if (((USB_CONFIGURATION_DESCRIPTOR *)pD)->bConfigurationValue != Configuration) {
              (uint8_t *)pD += ((USB_CONFIGURATION_DESCRIPTOR *)pD)->wTotalLength;
              continue;
            }
            break;
          case USB_INTERFACE_DESCRIPTOR_TYPE:
            ifn = ((USB_INTERFACE_DESCRIPTOR *)pD)->bInterfaceNumber;
            alt = ((USB_INTERFACE_DESCRIPTOR *)pD)->bAlternateSetting;
            msk = 0;
            if ((ifn == SetupPacket.wIndex.WB.L) && (alt == SetupPacket.wValue.WB.L)) {
              set = TRUE;
              old = AltSetting[ifn];
              AltSetting[ifn] = (uint8_t)alt;
            }
            break;
          case USB_ENDPOINT_DESCRIPTOR_TYPE:
            if (ifn == SetupPacket.wIndex.WB.L) {
              n = ((USB_ENDPOINT_DESCRIPTOR *)pD)->bEndpointAddress & 0x8F;
              m = (n & 0x80) ? ((1 << 16) << (n & 0x0F)) : (1 << n);
              if (alt == SetupPacket.wValue.WB.L) {
                EndPointMask |=  m;
                EndPointHalt &= ~m;
                usbhw.ConfigEP((USB_ENDPOINT_DESCRIPTOR *)pD);
                usbhw.EnableEP(n);
                usbhw.ResetEP(n);
                msk |= m;
              }
              else if ((alt == old) && ((msk & m) == 0)) {
                EndPointMask &= ~m;
                EndPointHalt &= ~m;
                usbhw.DisableEP(n);
              }
            }
           break;
        }
        (uint8_t *)pD += pD->bLength;
      }
      break;
    default:
      return (FALSE);
  }

  return (set);
}


/*
 *  USB Endpoint 0 Event Callback
 *    Parameters:      event
 *    Return Value:    none
 */

void USBCore::EndPoint0 (uint32_t event) {

  switch (event) {
    case USB_EVT_SETUP:
      SetupStage();
      usbhw.DirCtrlEP(SetupPacket.bmRequestType.BM.Dir);
      EP0Data.Count = SetupPacket.wLength;     /* Number of bytes to transfer */
      switch (SetupPacket.bmRequestType.BM.Type) {

        case REQUEST_STANDARD:
          switch (SetupPacket.bRequest) {
            case USB_REQUEST_GET_STATUS:
              if (!ReqGetStatus()) {
                goto stall_i;
              }
              DataInStage();
              break;

            case USB_REQUEST_CLEAR_FEATURE:
              if (!ReqSetClrFeature(0)) {
                goto stall_i;
              }
              StatusInStage();
#if USB_FEATURE_EVENT
              Feature_Event();
#endif
              break;

            case USB_REQUEST_SET_FEATURE:
              if (!ReqSetClrFeature(1)) {
                goto stall_i;
              }
              StatusInStage();
#if USB_FEATURE_EVENT
              Feature_Event();
#endif
              break;

            case USB_REQUEST_SET_ADDRESS:
              if (!ReqSetAddress()) {
                goto stall_i;
              }
              StatusInStage();
              break;

            case USB_REQUEST_GET_DESCRIPTOR:
              if (!ReqGetDescriptor()) {
                goto stall_i;
              }
              DataInStage();
              break;

            case USB_REQUEST_SET_DESCRIPTOR:
/*stall_o:*/  usbhw.SetStallEP(0x00);            /* not supported */
              EP0Data.Count = 0;
              break;

            case USB_REQUEST_GET_CONFIGURATION:
              if (!ReqGetConfiguration()) {
                goto stall_i;
              }
              DataInStage();
              break;

            case USB_REQUEST_SET_CONFIGURATION:
              if (!ReqSetConfiguration()) {
                goto stall_i;
              }
              StatusInStage();
#if USB_CONFIGURE_EVENT
              Configure_Event();
#endif
              break;

            case USB_REQUEST_GET_INTERFACE:
              if (!ReqGetInterface()) {
                goto stall_i;
              }
              DataInStage();
              break;

            case USB_REQUEST_SET_INTERFACE:
              if (!ReqSetInterface()) {
                goto stall_i;
              }
              StatusInStage();
#if USB_INTERFACE_EVENT
              Interface_Event();
#endif
              break;

            default:
              goto stall_i;
          }
          break;  /* end case REQUEST_STANDARD */

#if USB_CLASS
        case REQUEST_CLASS:
          switch (SetupPacket.bmRequestType.BM.Recipient) {

            case REQUEST_TO_DEVICE:
              goto stall_i;                                              /* not supported */

            case REQUEST_TO_INTERFACE:
#if PROJECT_USE_USB_HID
              if (SetupPacket.wIndex.WB.L == USB_HID_IF_NUM) {           /* IF number correct? */
                switch (SetupPacket.bRequest) {
                  case HID_REQUEST_GET_REPORT:
                    if (hiduser.HID_GetReport()) {
                      EP0Data.pData = EP0Buf;                            /* point to data to be sent */
                      DataInStage();                                 /* send requested data */
                      goto setup_class_ok;
                    }
                    break;
                  case HID_REQUEST_SET_REPORT:
                    EP0Data.pData = EP0Buf;                              /* data to be received */ 
                    goto setup_class_ok;
                  case HID_REQUEST_GET_IDLE:
                    if (hiduser.HID_GetIdle()) {
                      EP0Data.pData = EP0Buf;                            /* point to data to be sent */
                      DataInStage();                                 /* send requested data */
                      goto setup_class_ok;
                    }
                    break;
                  case HID_REQUEST_SET_IDLE:
                    if (hiduser.HID_SetIdle()) {
                      StatusInStage();                               /* send Acknowledge */
                      goto setup_class_ok;
                    }
                    break;
                  case HID_REQUEST_GET_PROTOCOL:
                    if (hiduser.HID_GetProtocol()) {
                      EP0Data.pData = EP0Buf;                            /* point to data to be sent */
                      DataInStage();                                 /* send requested data */
                      goto setup_class_ok;
                    }
                    break;
                  case HID_REQUEST_SET_PROTOCOL:
                    if (hiduser.HID_SetProtocol()) {
                      StatusInStage();                               /* send Acknowledge */
                      goto setup_class_ok;
                    }
                    break;
                }
              }
#endif  /* PROJECT_USE_USB_HID */
#if PROJECT_USE_USB_MSC
              if (SetupPacket.wIndex.WB.L == USB_MSC_IF_NUM) {           /* IF number correct? */
                switch (SetupPacket.bRequest) {
                  case MSC_REQUEST_RESET:
                    if ((SetupPacket.wValue.W == 0) &&	                 /* RESET with invalid parameters -> STALL */
                        (SetupPacket.wLength  == 0)) {
                      if (mscuser.Reset()) {
                        StatusInStage();
                        goto setup_class_ok;
                      }
                    }
                    break;
                  case MSC_REQUEST_GET_MAX_LUN:
                    if ((SetupPacket.wValue.W == 0) &&	                 /* GET_MAX_LUN with invalid parameters -> STALL */
                        (SetupPacket.wLength  == 1)) { 
                      if (mscuser.GetMaxLUN()) {
                        EP0Data.pData = EP0Buf;
                        DataInStage();
                        goto setup_class_ok;
                      }
                    }
                    break;
                }
              }
#endif  /* PROJECT_USE_USB_MSC */
#if USB_AUDIO
              if ((SetupPacket.wIndex.WB.L == USB_ADC_CIF_NUM)  ||       /* IF number correct? */
                  (SetupPacket.wIndex.WB.L == USB_ADC_SIF1_NUM) ||
                  (SetupPacket.wIndex.WB.L == USB_ADC_SIF2_NUM)) {
                switch (SetupPacket.bRequest) {
                  case AUDIO_REQUEST_GET_CUR:
                  case AUDIO_REQUEST_GET_MIN:
                  case AUDIO_REQUEST_GET_MAX:
                  case AUDIO_REQUEST_GET_RES:
                    if (ADC_IF_GetRequest()) {
                      EP0Data.pData = EP0Buf;                            /* point to data to be sent */
                      USB_DataInStage();                                 /* send requested data */
                      goto setup_class_ok;
                    }
                    break;
                  case AUDIO_REQUEST_SET_CUR:
//                case AUDIO_REQUEST_SET_MIN:
//                case AUDIO_REQUEST_SET_MAX:
//                case AUDIO_REQUEST_SET_RES:
                    EP0Data.pData = EP0Buf;                              /* data to be received */ 
                    goto setup_class_ok;
                }
              }
#endif  /* USB_AUDIO */
#if USB_CDC
              if ((SetupPacket.wIndex.WB.L == USB_CDC_CIF_NUM)  ||       /* IF number correct? */
                  (SetupPacket.wIndex.WB.L == USB_CDC_DIF_NUM)) {
                switch (SetupPacket.bRequest) {
                  case CDC_SEND_ENCAPSULATED_COMMAND:
                    EP0Data.pData = EP0Buf;                              /* data to be received, see USB_EVT_OUT */
                    goto setup_class_ok;
                  case CDC_GET_ENCAPSULATED_RESPONSE:
                    if (CDC_GetEncapsulatedResponse()) {
                      EP0Data.pData = EP0Buf;                            /* point to data to be sent */
                      USB_DataInStage();                                 /* send requested data */
                      goto setup_class_ok;
                    }
                    break;
                  case CDC_SET_COMM_FEATURE:
                    EP0Data.pData = EP0Buf;                              /* data to be received, see USB_EVT_OUT */
                    goto setup_class_ok;
                  case CDC_GET_COMM_FEATURE:
                    if (CDC_GetCommFeature(SetupPacket.wValue.W)) {
                      EP0Data.pData = EP0Buf;                            /* point to data to be sent */
                      USB_DataInStage();                                 /* send requested data */
                      goto setup_class_ok;
                    }
                    break;
                  case CDC_CLEAR_COMM_FEATURE:
                    if (CDC_ClearCommFeature(SetupPacket.wValue.W)) {
                      USB_StatusInStage();                               /* send Acknowledge */
                      goto setup_class_ok;
                    }
                    break;
                  case CDC_SET_LINE_CODING:
                    EP0Data.pData = EP0Buf;                              /* data to be received, see USB_EVT_OUT */
                    goto setup_class_ok;
                  case CDC_GET_LINE_CODING:
                    if (CDC_GetLineCoding()) {
                      EP0Data.pData = EP0Buf;                            /* point to data to be sent */
                      USB_DataInStage();                                 /* send requested data */
                      goto setup_class_ok;
                    }
                    break;
                  case CDC_SET_CONTROL_LINE_STATE:
                    if (CDC_SetControlLineState(SetupPacket.wValue.W)) {
                      USB_StatusInStage();                               /* send Acknowledge */
                      goto setup_class_ok;
                    }
                    break;
                  case CDC_SEND_BREAK:
                    if (CDC_SendBreak(SetupPacket.wValue.W)) {
                      USB_StatusInStage();                               /* send Acknowledge */
                      goto setup_class_ok;
                    }
                    break;
                }
              }
#endif  /* USB_CDC */
              goto stall_i;                                              /* not supported */
              /* end case REQUEST_TO_INTERFACE */

            case REQUEST_TO_ENDPOINT:
#if USB_AUDIO
              switch (SetupPacket.bRequest) {
                case AUDIO_REQUEST_GET_CUR:
                case AUDIO_REQUEST_GET_MIN:
                case AUDIO_REQUEST_GET_MAX:
                case AUDIO_REQUEST_GET_RES:
                  if (ADC_EP_GetRequest()) {
                    EP0Data.pData = EP0Buf;                              /* point to data to be sent */
                    USB_DataInStage();                                   /* send requested data */
                    goto setup_class_ok;
                  }
                  break;
                case AUDIO_REQUEST_SET_CUR:
//              case AUDIO_REQUEST_SET_MIN:
//              case AUDIO_REQUEST_SET_MAX:
//              case AUDIO_REQUEST_SET_RES:
                  EP0Data.pData = EP0Buf;                                /* data to be received */ 
                  goto setup_class_ok;
              }
#endif  /* USB_AUDIO */
              goto stall_i;
              /* end case REQUEST_TO_ENDPOINT */

            default:
              goto stall_i;
          }
setup_class_ok:                                                          /* request finished successfully */
          break;  /* end case REQUEST_CLASS */
#endif  /* USB_CLASS */

#if USB_VENDOR
        case REQUEST_VENDOR:
          switch (SetupPacket.bmRequestType.BM.Recipient) {

            case REQUEST_TO_DEVICE:
              if (!USB_ReqVendorDev(TRUE)) {
                goto stall_i;                                            /* not supported */               
              }
              break;

            case REQUEST_TO_INTERFACE:
              if (!USB_ReqVendorIF(TRUE)) {
                goto stall_i;                                            /* not supported */               
              }
              break;

            case REQUEST_TO_ENDPOINT:
              if (!USB_ReqVendorEP(TRUE)) {
                goto stall_i;                                            /* not supported */               
              }
              break;

            default:
              goto stall_i;
          }

          if (SetupPacket.wLength) {
            if (SetupPacket.bmRequestType.BM.Dir == REQUEST_DEVICE_TO_HOST) {
              USB_DataInStage();
            }
          } else {
            USB_StatusInStage();
          }

          break;  /* end case REQUEST_VENDOR */ 
#endif  /* USB_VENDOR */

        default:
stall_i:  usbhw.SetStallEP(0x80);
          EP0Data.Count = 0;
          break;
      }
      break;  /* end case USB_EVT_SETUP */

    case USB_EVT_OUT:
      if (SetupPacket.bmRequestType.BM.Dir == REQUEST_HOST_TO_DEVICE) {
        if (EP0Data.Count) {                                             /* still data to receive ? */
          DataOutStage();                                            /* receive data */
          if (EP0Data.Count == 0) {                                      /* data complete ? */
            switch (SetupPacket.bmRequestType.BM.Type) {

              case REQUEST_STANDARD:
                goto stall_i;                                            /* not supported */

#if (USB_CLASS) 
              case REQUEST_CLASS:
                switch (SetupPacket.bmRequestType.BM.Recipient) {
                  case REQUEST_TO_DEVICE:
                    goto stall_i;                                        /* not supported */

                  case REQUEST_TO_INTERFACE:
#if PROJECT_USE_USB_HID
                    if (SetupPacket.wIndex.WB.L == USB_HID_IF_NUM) {     /* IF number correct? */
                      switch (SetupPacket.bRequest) {
                        case HID_REQUEST_SET_REPORT:
                          if (hiduser.HID_SetReport()) {
                            StatusInStage();                         /* send Acknowledge */
                            goto out_class_ok;
                          }
                          break;
                      }
                    }
#endif  /* PROJECT_USE_USB_HID */  
#if USB_AUDIO
                    if ((SetupPacket.wIndex.WB.L == USB_ADC_CIF_NUM)  || /* IF number correct? */
                        (SetupPacket.wIndex.WB.L == USB_ADC_SIF1_NUM) ||
                        (SetupPacket.wIndex.WB.L == USB_ADC_SIF2_NUM)) {
                      switch (SetupPacket.bRequest) {
                        case AUDIO_REQUEST_SET_CUR:
//                      case AUDIO_REQUEST_SET_MIN:
//                      case AUDIO_REQUEST_SET_MAX:
//                      case AUDIO_REQUEST_SET_RES:
                          if (ADC_IF_SetRequest()) {
                            USB_StatusInStage();                         /* send Acknowledge */
                            goto out_class_ok;
                          }
                          break;
                      }
                    }
#endif  /* USB_AUDIO */
#if USB_CDC
                    if ((SetupPacket.wIndex.WB.L == USB_CDC_CIF_NUM)  || /* IF number correct? */
                        (SetupPacket.wIndex.WB.L == USB_CDC_DIF_NUM)) {
                      switch (SetupPacket.bRequest) {
                        case CDC_SEND_ENCAPSULATED_COMMAND:
                          if (CDC_SendEncapsulatedCommand()) {
                            USB_StatusInStage();                         /* send Acknowledge */
                            goto out_class_ok;
                          }
                          break;
                        case CDC_SET_COMM_FEATURE:
                          if (CDC_SetCommFeature(SetupPacket.wValue.W)) {
                            USB_StatusInStage();                         /* send Acknowledge */
                            goto out_class_ok;
                          }
                          break;
                        case CDC_SET_LINE_CODING:
                          if (CDC_SetLineCoding()) {
                            USB_StatusInStage();                         /* send Acknowledge */
                            goto out_class_ok;
                          }
                          break;
                      }
                    } 
#endif  /* USB_CDC */
                    goto stall_i;
                    /* end case REQUEST_TO_INTERFACE */

                  case REQUEST_TO_ENDPOINT:
#if USB_AUDIO
                    switch (SetupPacket.bRequest) {
                      case AUDIO_REQUEST_SET_CUR:
//                    case AUDIO_REQUEST_SET_MIN:
//                    case AUDIO_REQUEST_SET_MAX:
//                    case AUDIO_REQUEST_SET_RES:
                        if (ADC_EP_SetRequest()) {
                          USB_StatusInStage();                           /* send Acknowledge */
                          goto out_class_ok;
                        }
                        break;
                    }
#endif  /* USB_AUDIO */
                    goto stall_i;
                    /* end case REQUEST_TO_ENDPOINT */

                  default:
                    goto stall_i;
                }
out_class_ok:                                                            /* request finished successfully */
                break; /* end case REQUEST_CLASS */
#endif  /* USB_CLASS */

#if USB_VENDOR
              case REQUEST_VENDOR:
                switch (SetupPacket.bmRequestType.BM.Recipient) {
      
                  case REQUEST_TO_DEVICE:
                    if (!USB_ReqVendorDev(FALSE)) {
                      goto stall_i;                                      /* not supported */               
                    }
                    break;
      
                  case REQUEST_TO_INTERFACE:
                    if (!USB_ReqVendorIF(FALSE)) {
                      goto stall_i;                                      /* not supported */               
                    }
                    break;
      
                  case REQUEST_TO_ENDPOINT:
                    if (!USB_ReqVendorEP(FALSE)) {
                      goto stall_i;                                      /* not supported */               
                    }
                    break;
      
                  default:
                    goto stall_i;
                }
      
                USB_StatusInStage();
      
                break;  /* end case REQUEST_VENDOR */ 
#endif  /* USB_VENDOR */

              default:
                goto stall_i;
            }
          }
        }
      } else {
        StatusOutStage();                                            /* receive Acknowledge */
      }
      break;  /* end case USB_EVT_OUT */

    case USB_EVT_IN :
      if (SetupPacket.bmRequestType.BM.Dir == REQUEST_DEVICE_TO_HOST) {
        DataInStage();                                               /* send data */
      } else {
        if (DeviceAddress & 0x80) {
          DeviceAddress &= 0x7F;
          usbhw.SetAddress(DeviceAddress);
        }
      }
      break;  /* end case USB_EVT_IN */

    case USB_EVT_OUT_STALL:
      usbhw.ClrStallEP(0x00);
      break;

    case USB_EVT_IN_STALL:
      usbhw.ClrStallEP(0x80);
      break;

  }
}

#if USB_POWER_EVENT
void USBCore::Power_Event (uint32_t  power) {
}
#endif


/*
 *  USB Reset Event Callback
 *   Called automatically on USB Reset Event
 */

#if USB_RESET_EVENT
void USBCore::Reset_Event (void) {
  ResetCore();
}
#endif


/*
 *  USB Suspend Event Callback
 *   Called automatically on USB Suspend Event
 */

#if USB_SUSPEND_EVENT
void USBCore::Suspend_Event (void) {
}
#endif


/*
 *  USB Resume Event Callback
 *   Called automatically on USB Resume Event
 */

#if USB_RESUME_EVENT
void USBCore::Resume_Event (void) {
}
#endif


/*
 *  USB Remote Wakeup Event Callback
 *   Called automatically on USB Remote Wakeup Event
 */

#if USB_WAKEUP_EVENT
void USBCore::WakeUp_Event (void) {
}
#endif


/*
 *  USB Start of Frame Event Callback
 *   Called automatically on USB Start of Frame Event
 */

#if USB_SOF_EVENT
void USBCore::SOF_Event (void) {
}
#endif


/*
 *  USB Error Event Callback
 *   Called automatically on USB Error Event
 *    Parameter:       error: Error Code
 */

#if USB_ERROR_EVENT
void USBCore::Error_Event (uint32_t error) {
}
#endif


/*
 *  USB Set Configuration Event Callback
 *   Called automatically on USB Set Configuration Request
 */
extern uint8_t InReport;
#if USB_CONFIGURE_EVENT
void USBCore::Configure_Event (void) 
{
#if (PROJECT_USE_USB_HID == 1)
  if (Configuration) {
  	uint8_t temp[64] = {5};                  /* Check if USB is configured */
    usbhw.WriteEP(HID_EP_IN, temp, 64);
  }
#elif (PROJECT_USE_USB_MSC == 1)
	// do related work
#endif
}
#endif


/*
 *  USB Set Interface Event Callback
 *   Called automatically on USB Set Interface Request
 */

#if USB_INTERFACE_EVENT
void USBCore::Interface_Event (void) {
}
#endif


/*
 *  USB Set/Clear Feature Event Callback
 *   Called automatically on USB Set/Clear Feature Request
 */

#if USB_FEATURE_EVENT
void USBCore::Feature_Event (void) {
}
#endif

void USBCore::EndPoint1 (uint32_t event)
{
	switch (event)
	{
		case USB_EVT_IN:
			hiduser.Send();
			usbhw.WriteEP(HID_EP_IN, EP0Data.pData, EP0Data.Count);
			break;
		case USB_EVT_OUT:
			DataAvailable = usbhw.ReadEP(HID_EP_Out, EP0Bufout);
			break;
	}
}

void USBCore::EndPoint2 (uint32_t event)
{
	#if (PROJECT_USE_USB_MSC == 1)
	switch (event)
	{
		case USB_EVT_IN:
			mscuser.BulkIn();
			break;
		case USB_EVT_OUT:
			mscuser.BulkOut();
			break;
	}
	#endif
}

void USBCore::EndPoint3 (uint32_t event)
{
}

void USBCore::EndPoint4 (uint32_t event)	 
{
}

void USBCore::EndPoint5 (uint32_t event)	 
{
}

void USBCore::EndPoint6 (uint32_t event)	
{
}

void USBCore::EndPoint7 (uint32_t event)	
{
}

void USBCore::EndPoint8 (uint32_t event)	
{
}

void USBCore::EndPoint9 (uint32_t event)	
{
}

void USBCore::EndPoint10 (uint32_t event)
{
}

void USBCore::EndPoint11 (uint32_t event)
{
}

void USBCore::EndPoint12 (uint32_t event)
{
}

void USBCore::EndPoint13 (uint32_t event)
{
}

void USBCore::EndPoint14 (uint32_t event)
{
}

void USBCore::EndPoint15 (uint32_t event)
{
}

extern USBCore usb;
extern "C" {
		void USB_IRQHandler (void) 
	{
		usb.usbhw.handler();	
	}
}