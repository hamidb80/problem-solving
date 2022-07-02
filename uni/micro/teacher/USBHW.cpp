#include "LPC17xx.h"                        /* LPC17xx definitions */

#include "rtl.h"

#include "usb.h"
#include "usbcfg.h"
#include "usbreg.h"
#include "usbhw.h"
#include "usbhwDef.h"
#include "usbcore.h"
#if POWERDOWN_MODE_USB_WAKEUP
#include "timer.h"
#endif

#pragma diag_suppress 1441


#define EP_MSK_CTRL 0x0001      /* Control Endpoint Logical Address Mask */
#define EP_MSK_BULK 0xC924      /* Bulk Endpoint Logical Address Mask */
#define EP_MSK_INT  0x4492      /* Interrupt Endpoint Logical Address Mask */
#define EP_MSK_ISO  0x1248      /* Isochronous Endpoint Logical Address Mask */


#if USB_DMA

#pragma arm section zidata = "USB_RAM"
uint32_t UDCA[USB_EP_NUM];                     /* UDCA in USB RAM */
uint32_t DD_NISO_Mem[4*DD_NISO_CNT];           /* Non-Iso DMA Descriptor Memory */
uint32_t DD_ISO_Mem [5*DD_ISO_CNT];            /* Iso DMA Descriptor Memory */
#pragma arm section zidata
uint32_t udca[USB_EP_NUM];                     /* UDCA saved values */

uint32_t DDMemMap[2];                          /* DMA Descriptor Memory Usage */

#endif

#if POWERDOWN_MODE_USB_WAKEUP
volatile uint32_t SuspendFlag = 0;
volatile uint32_t USBActivityInterruptFlag = 0;
extern volatile uint32_t timer0_counter;
extern volatile uint32_t WakeupFlag;
#endif

static const unsigned int PowOf2[32] = 
{
	0x00000001, 0x00000002, 0x00000004, 0x00000008, 
	0x00000010, 0x00000020, 0x00000040, 0x00000080, 
	0x00000100, 0x00000200, 0x00000400, 0x00000800, 
	0x00001000, 0x00002000, 0x00004000, 0x00008000, 
	0x00010000, 0x00020000, 0x00040000, 0x00080000, 
	0x00100000, 0x00200000, 0x00400000, 0x00800000, 
	0x01000000, 0x02000000, 0x04000000, 0x08000000, 
	0x10000000, 0x20000000, 0x40000000, 0x80000000 
};

USBHW::USBHW()
{
}

USBHW::~USBHW()
{
}
/*
 *  Get Endpoint Physical Address
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    Endpoint Physical Address
 */

uint32_t USBHW::EPAdr (uint32_t EPNum) {
  uint32_t val;

  val = (EPNum & 0x0F) << 1;
  if (EPNum & 0x80) {
    val += 1;
  }
  return (val);
}


/*
 *  Write Command
 *    Parameters:      cmd:   Command
 *    Return Value:    None
 */

void USBHW::WrCmd (uint32_t cmd) {

  LPC_USB->USBDevIntClr = CCEMTY_INT;
  LPC_USB->USBCmdCode = cmd;
  while ((LPC_USB->USBDevIntSt & CCEMTY_INT) == 0);
}


/*
 *  Write Command Data
 *    Parameters:      cmd:   Command
 *                     val:   Data
 *    Return Value:    None
 */

void USBHW::WrCmdDat (uint32_t cmd, uint32_t val) {

  LPC_USB->USBDevIntClr = CCEMTY_INT;
  LPC_USB->USBCmdCode = cmd;
  while ((LPC_USB->USBDevIntSt & CCEMTY_INT) == 0);
  LPC_USB->USBDevIntClr = CCEMTY_INT;
  LPC_USB->USBCmdCode = val;
  while ((LPC_USB->USBDevIntSt & CCEMTY_INT) == 0);
}


/*
 *  Write Command to Endpoint
 *    Parameters:      cmd:   Command
 *                     val:   Data
 *    Return Value:    None
 */

void USBHW::WrCmdEP (uint32_t EPNum, uint32_t cmd){

  LPC_USB->USBDevIntClr = CCEMTY_INT;
  LPC_USB->USBCmdCode = CMD_SEL_EP(EPAdr(EPNum));
  while ((LPC_USB->USBDevIntSt & CCEMTY_INT) == 0);
  LPC_USB->USBDevIntClr = CCEMTY_INT;
  LPC_USB->USBCmdCode = cmd;
  while ((LPC_USB->USBDevIntSt & CCEMTY_INT) == 0);
}


/*
 *  Read Command Data
 *    Parameters:      cmd:   Command
 *    Return Value:    Data Value
 */

uint32_t USBHW::RdCmdDat (uint32_t cmd) {

  LPC_USB->USBDevIntClr = CCEMTY_INT | CDFULL_INT;
  LPC_USB->USBCmdCode = cmd;
  while ((LPC_USB->USBDevIntSt & CDFULL_INT) == 0);
  return (LPC_USB->USBCmdData);
}


/*
 *  USB Initialize Function
 *   Called by the User to initialize USB
 *    Return Value:    None
 */

void USBHW::Init (void) {

  LPC_PINCON->PINSEL1 &= ~((3<<26)|(3<<28));   /* P0.29 D+, P0.30 D- */
  LPC_PINCON->PINSEL1 |=  ((1<<26)|(1<<28));   /* PINSEL1 26.27, 28.29  = 01 */

  LPC_PINCON->PINSEL3 &= ~((3<< 4)|(3<<28));   /* P1.18 GoodLink, P1.30 VBUS */
  LPC_PINCON->PINSEL3 |=  ((1<< 4)|(2<<28));   /* PINSEL3 4.5 = 01, 28.29 = 10 */

  LPC_PINCON->PINSEL4 &= ~((3<<18)        );   /* P2.9 SoftConnect */
  LPC_PINCON->PINSEL4 |=  ((1<<18)        );   /* PINSEL4 18.19 = 01 */

  LPC_SC->PCONP |= (1UL<<31);                /* USB PCLK -> enable USB Per.       */

  LPC_USB->USBClkCtrl = 0x12;                /* Dev, AHB clock enable */
  while ((LPC_USB->USBClkSt & 0x12) != 0x12); 

  NVIC_EnableIRQ(USB_IRQn);               /* enable USB interrupt */

#if POWERDOWN_MODE_USB_WAKEUP
  NVIC_EnableIRQ(USBActivity_IRQn);       /* enable USB activity interrupt */
#endif

  Reset();
  SetAddress(0);
  return;
}


/*
 *  USB Connect Function
 *   Called by the User to Connect/Disconnect USB
 *    Parameters:      con:   Connect/Disconnect
 *    Return Value:    None
 */

void USBHW::Connect (uint32_t con) {
  WrCmdDat(CMD_SET_DEV_STAT, DAT_WR_BYTE(con ? DEV_CON : 0));
}


/*
 *  USB Reset Function
 *   Called automatically on USB Reset
 *    Return Value:    None
 */

void USBHW::Reset (void) {
#if USB_DMA
  uint32_t n;
#endif

  LPC_USB->USBEpInd = 0;
  LPC_USB->USBMaxPSize = USB_MAX_PACKET0;
  LPC_USB->USBEpInd = 1;
  LPC_USB->USBMaxPSize = USB_MAX_PACKET0;
  while ((LPC_USB->USBDevIntSt & EP_RLZED_INT) == 0);

  LPC_USB->USBEpIntClr  = 0xFFFFFFFF;
  LPC_USB->USBEpIntEn   = 0xFFFFFFFF ^ USB_DMA_EP;
  LPC_USB->USBDevIntClr = 0xFFFFFFFF;
  LPC_USB->USBDevIntEn  = DEV_STAT_INT    | EP_SLOW_INT    |
               (USB_SOF_EVENT   ? FRAME_INT : 0) |
               (USB_ERROR_EVENT ? ERR_INT   : 0);

#if USB_DMA
  LPC_USB->UDCAH   = USB_RAM_ADR;
  LPC_USB->DMARClr = 0xFFFFFFFF;
  LPC_USB->EpDMADis  = 0xFFFFFFFF;
  LPC_USB->EpDMAEn   = USB_DMA_EP;
  LPC_USB->EoTIntClr = 0xFFFFFFFF;
  LPC_USB->NDDRIntClr = 0xFFFFFFFF;
  LPC_USB->SysErrIntClr = 0xFFFFFFFF;
  LPC_USB->DMAIntEn  = 0x00000007;
  DDMemMap[0] = 0x00000000;
  DDMemMap[1] = 0x00000000;
  for (n = 0; n < USB_EP_NUM; n++) {
    udca[n] = 0;
    UDCA[n] = 0;
  }
#endif
}


/*
 *  USB Suspend Function
 *   Called automatically on USB Suspend
 *    Return Value:    None
 */

void USBHW::Suspend (void) {
  /* Performed by Hardware */
#if POWERDOWN_MODE_USB_WAKEUP
  timer0_counter = 0;
  enable_timer( 0 );
  
  if ( SuspendFlag == 0 ) {
	SuspendFlag = 1;
  }
#endif
  return;
}


/*
 *  USB Resume Function
 *   Called automatically on USB Resume
 *    Return Value:    None
 */

void USBHW::Resume (void) {
  /* Performed by Hardware */
#if POWERDOWN_MODE_USB_WAKEUP
  disable_timer( 0 );
  timer0_counter = 0;
  if ( SuspendFlag == 1 ) {
	SuspendFlag = 0;
  }
#endif
  return;
}


/*
 *  USB Remote Wakeup Function
 *   Called automatically on USB Remote Wakeup
 *    Return Value:    None
 */

extern USBCore usb;
void USBHW::WakeUp (void) {

  if (usb.DeviceStatus & USB_GETSTATUS_REMOTE_WAKEUP) {
    WrCmdDat(CMD_SET_DEV_STAT, DAT_WR_BYTE(DEV_CON));
  }
}


/*
 *  USB Remote Wakeup Configuration Function
 *    Parameters:      cfg:   Enable/Disable
 *    Return Value:    None
 */

void USBHW::WakeUpCfg (uint32_t cfg) {
  /* Not needed */
}


/*
 *  USB Set Address Function
 *    Parameters:      adr:   USB Address
 *    Return Value:    None
 */

void USBHW::SetAddress (uint32_t adr) {
  WrCmdDat(CMD_SET_ADDR, DAT_WR_BYTE(DEV_EN | adr)); /* Don't wait for next */
  WrCmdDat(CMD_SET_ADDR, DAT_WR_BYTE(DEV_EN | adr)); /*  Setup Status Phase */
}


/*
 *  USB Configure Function
 *    Parameters:      cfg:   Configure/Deconfigure
 *    Return Value:    None
 */

void USBHW::Configure (uint32_t cfg) {

  WrCmdDat(CMD_CFG_DEV, DAT_WR_BYTE(cfg ? CONF_DVICE : 0));

  LPC_USB->USBReEp = 0x00000003;
  while ((LPC_USB->USBDevIntSt & EP_RLZED_INT) == 0);
  LPC_USB->USBDevIntClr = EP_RLZED_INT;
}


/*
 *  Configure USB Endpoint according to Descriptor
 *    Parameters:      pEPD:  Pointer to Endpoint Descriptor
 *    Return Value:    None
 */

void USBHW::ConfigEP (USB_ENDPOINT_DESCRIPTOR *pEPD) {
  uint32_t num;

  num = EPAdr(pEPD->bEndpointAddress);
  LPC_USB->USBReEp |= (PowOf2[num]);
  LPC_USB->USBEpInd = num;
  LPC_USB->USBMaxPSize = pEPD->wMaxPacketSize;
  while ((LPC_USB->USBDevIntSt & EP_RLZED_INT) == 0);
  LPC_USB->USBDevIntClr = EP_RLZED_INT;
}


/*
 *  Set Direction for USB Control Endpoint
 *    Parameters:      dir:   Out (dir == 0), In (dir <> 0)
 *    Return Value:    None
 */

void USBHW::DirCtrlEP (uint32_t dir) {
  /* Not needed */
}


/*
 *  Enable USB Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USBHW::EnableEP (uint32_t EPNum) {
  WrCmdDat(CMD_SET_EP_STAT(EPAdr(EPNum)), DAT_WR_BYTE(0));
}


/*
 *  Disable USB Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USBHW::DisableEP (uint32_t EPNum) {
  WrCmdDat(CMD_SET_EP_STAT(EPAdr(EPNum)), DAT_WR_BYTE(EP_STAT_DA));
}


/*
 *  Reset USB Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USBHW::ResetEP (uint32_t EPNum) {
  WrCmdDat(CMD_SET_EP_STAT(EPAdr(EPNum)), DAT_WR_BYTE(0));
}


/*
 *  Set Stall for USB Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USBHW::SetStallEP (uint32_t EPNum) {
  WrCmdDat(CMD_SET_EP_STAT(EPAdr(EPNum)), DAT_WR_BYTE(EP_STAT_ST));
}


/*
 *  Clear Stall for USB Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USBHW::ClrStallEP (uint32_t EPNum) {
  WrCmdDat(CMD_SET_EP_STAT(EPAdr(EPNum)), DAT_WR_BYTE(0));
}


/*
 *  Clear USB Endpoint Buffer
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USBHW::ClearEPBuf (uint32_t EPNum) {
  WrCmdEP(EPNum, CMD_CLR_BUF);
}


/*
 *  Read USB Endpoint Data
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *                     pData: Pointer to Data Buffer
 *    Return Value:    Number of bytes read
 */

uint32_t USBHW::ReadEP (uint32_t EPNum, uint8_t *pData) {
  uint32_t cnt, n;

  LPC_USB->USBCtrl = ((EPNum & 0x0F) << 2) | CTRL_RD_EN;

  do {
    cnt = LPC_USB->USBRxPLen;
  } while ((cnt & PKT_RDY) == 0);
  cnt &= PKT_LNGTH_MASK;
	unsigned int _temp = (cnt + 3) >> 2;
  for (n = 0; n < _temp; n++) {
    *((__packed uint32_t *)pData) = LPC_USB->USBRxData;
    pData += 4;
  }
  LPC_USB->USBCtrl = 0;

  if (((EP_MSK_ISO >> EPNum) & 1) == 0) {   /* Non-Isochronous Endpoint */
    WrCmdEP(EPNum, CMD_CLR_BUF);
  }
  return (cnt);
}


/*
 *  Write USB Endpoint Data
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *                     pData: Pointer to Data Buffer
 *                     cnt:   Number of bytes to write
 *    Return Value:    Number of bytes written
 */

uint32_t USBHW::WriteEP (uint32_t EPNum, uint8_t *pData, uint32_t cnt) {
  uint32_t n;

  LPC_USB->USBCtrl = ((EPNum & 0x0F) << 2) | CTRL_WR_EN;

  LPC_USB->USBTxPLen = cnt;
	unsigned int _temp = (cnt + 3) >> 2;
  for (n = 0; n < _temp; n++) {
    LPC_USB->USBTxData = *((__packed uint32_t *)pData);
    pData += 4;
  }
  LPC_USB->USBCtrl = 0;
  WrCmdEP(EPNum, CMD_VALID_BUF);
  return (cnt);
}

#if USB_DMA

/* DMA Descriptor Memory Layout */
const uint32_t DDAdr[2] = { DD_NISO_ADR, DD_ISO_ADR };
const uint32_t DDSz [2] = { 16,          20         };


/*
 *  Setup USB DMA Transfer for selected Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                     pDD: Pointer to DMA Descriptor
 *    Return Value:    TRUE - Success, FALSE - Error
 */

uint32_t USBHW::DMA_Setup(uint32_t EPNum, USB_DMA_DESCRIPTOR *pDD) {
  uint32_t num, ptr, nxt, iso, n;

  iso = pDD->Cfg.Type.IsoEP;                /* Iso or Non-Iso Descriptor */
  num = EPAdr(EPNum);                       /* Endpoint's Physical Address */

  ptr = 0;                                  /* Current Descriptor */
  nxt = udca[num];                          /* Initial Descriptor */
  while (nxt) {                             /* Go through Descriptor List */
    ptr = nxt;                              /* Current Descriptor */
    if (!pDD->Cfg.Type.Link) {              /* Check for Linked Descriptors */
      n = (ptr - DDAdr[iso]) / DDSz[iso];   /* Descriptor Index */
      DDMemMap[iso] &= ~(Utility::PowOf2[n]);           /* Unmark Memory Usage */
    }
    nxt = *((uint32_t *)ptr);                  /* Next Descriptor */
  }

  for (n = 0; n < 32; n++) {                /* Search for available Memory */
    if ((DDMemMap[iso] & (Utility::PowOf2[n])) == 0) {
      break;                                /* Memory found */
    }
  }
  if (n == 32) return (FALSE);              /* Memory not available */

  DDMemMap[iso] |= Utility::PowOf2[n];                  /* Mark Memory Usage */
  nxt = DDAdr[iso] + n * DDSz[iso];         /* Next Descriptor */

  if (ptr && pDD->Cfg.Type.Link) {
    *((uint32_t *)(ptr + 0))  = nxt;           /* Link in new Descriptor */
    *((uint32_t *)(ptr + 4)) |= 0x00000004;    /* Next DD is Valid */
  } else {
    udca[num] = nxt;                        /* Save new Descriptor */
    UDCA[num] = nxt;                        /* Update UDCA in USB */
  }

  /* Fill in DMA Descriptor */
  *(((uint32_t *)nxt)++) =  0;                 /* Next DD Pointer */
  *(((uint32_t *)nxt)++) =  pDD->Cfg.Type.ATLE |
                       (pDD->Cfg.Type.IsoEP << 4) |
                       (pDD->MaxSize <<  5) |
                       (pDD->BufLen  << 16);
  *(((uint32_t *)nxt)++) =  pDD->BufAdr;
  *(((uint32_t *)nxt)++) =  pDD->Cfg.Type.LenPos << 8;
  if (iso) {
    *((uint32_t *)nxt) =  pDD->InfoAdr;
  }

  return (TRUE); /* Success */
}


/*
 *  Enable USB DMA Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USBHW::DMA_Enable (uint32_t EPNum) {
  LPC_USB->EpDMAEn = Utility::PowOf2[EPAdr(EPNum)];
}


/*
 *  Disable USB DMA Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USBHW::DMA_Disable (uint32_t EPNum) {
  LPC_USB->EpDMADis = Utility::PwOf2[EPAdr(EPNum)];
}


/*
 *  Get USB DMA Endpoint Status
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    DMA Status
 */

uint32_t USBHW::DMA_Status (uint32_t EPNum) {
  uint32_t ptr, val;
          
  ptr = UDCA[EPAdr(EPNum)];                 /* Current Descriptor */
  if (ptr == 0) 
	return (USB_DMA_INVALID);

  val = *((uint32_t *)(ptr + 3*4));            /* Status Information */
  switch ((val >> 1) & 0x0F) {
    case 0x00:                              /* Not serviced */
      return (USB_DMA_IDLE);
    case 0x01:                              /* Being serviced */
      return (USB_DMA_BUSY);
    case 0x02:                              /* Normal Completition */
      return (USB_DMA_DONE);
    case 0x03:                              /* Data Under Run */
      return (USB_DMA_UNDER_RUN);
    case 0x08:                              /* Data Over Run */
      return (USB_DMA_OVER_RUN);
    case 0x09:                              /* System Error */
      return (USB_DMA_ERROR);
  }

  return (USB_DMA_UNKNOWN);
}


/*
 *  Get USB DMA Endpoint Current Buffer Address
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    DMA Address (or -1 when DMA is Invalid)
 */

uint32_t USBHW::DMA_BufAdr (uint32_t EPNum) {
  uint32_t ptr, val;

  ptr = UDCA[EPAdr(EPNum)];                 /* Current Descriptor */
  if (ptr == 0)
  {
	return ((uint32_t)(-1));                /* DMA Invalid */
  }

  val = *((uint32_t *)(ptr + 2*4));         /* Buffer Address */
  return (val);                             /* Current Address */
}


/*
 *  Get USB DMA Endpoint Current Buffer Count
 *   Number of transfered Bytes or Iso Packets
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    DMA Count (or -1 when DMA is Invalid)
 */

uint32_t USBHW::DMA_BufCnt (uint32_t EPNum) {
  uint32_t ptr, val;

  ptr = UDCA[EPAdr(EPNum)];                 /* Current Descriptor */
  if (ptr == 0)
  { 
	return ((uint32_t)(-1));                /* DMA Invalid */
  }
  val = *((uint32_t *)(ptr + 3*4));         /* Status Information */
  return (val >> 16);                       /* Current Count */
}


#endif /* USB_DMA */


/*
 *  Get USB Last Frame Number
 *    Parameters:      None
 *    Return Value:    Frame Number
 */

uint32_t USBHW::GetFrame (void) {
  uint32_t val;

  WrCmd(CMD_RD_FRAME);
  val = RdCmdDat(DAT_RD_FRAME);
  val = val | (RdCmdDat(DAT_RD_FRAME) << 8);

  return (val);
}

#define _CALL(object,ptrToMember)  ((object).*(ptrToMember))
void USBHW::handler()
{
  uint32_t disr, val, n, m;
  uint32_t episr, episrCur;

  disr = LPC_USB->USBDevIntSt;       /* Device Interrupt Status */

  /* Device Status Interrupt (Reset, Connect change, Suspend/Resume) */
  if (disr & DEV_STAT_INT) {
    LPC_USB->USBDevIntClr = DEV_STAT_INT;
    WrCmd(CMD_GET_DEV_STAT);
    val = RdCmdDat(DAT_GET_DEV_STAT);       /* Device Status */
    if (val & DEV_RST) {                    /* Reset */
      Reset();
#if   USB_RESET_EVENT
      usb.Reset_Event();
#endif
    }
    if (val & DEV_CON_CH) {                 /* Connect change */
#if   USB_POWER_EVENT
      Power_Event(val & DEV_CON);
#endif
    }
    if (val & DEV_SUS_CH) {                 /* Suspend/Resume */
      if (val & DEV_SUS) {                  /* Suspend */
        Suspend();
#if     USB_SUSPEND_EVENT
        Suspend_Event();
#endif
      } else {                              /* Resume */
        Resume();
#if     USB_RESUME_EVENT
        Resume_Event();
#endif
      }
    }
    goto isr_end;
  }

#if USB_SOF_EVENT
  /* Start of Frame Interrupt */
  if (disr & FRAME_INT) {
    SOF_Event();
  }
#endif

#if USB_ERROR_EVENT
  /* Error Interrupt */
  if (disr & ERR_INT) {
    WrCmd(CMD_RD_ERR_STAT);
    val = RdCmdDat(DAT_RD_ERR_STAT);
    USB_Error_Event(val);
  }
#endif

  /* Endpoint's Slow Interrupt */
  if (disr & EP_SLOW_INT) {
    episrCur = 0;
    episr    = LPC_USB->USBEpIntSt;
    for (n = 0; n < USB_EP_NUM; n++) {      /* Check All Endpoints */
      if (episr == episrCur) break;         /* break if all EP interrupts handled */
      if (episr & PowOf2[n]) {
        episrCur |= (PowOf2[n]);
        m = n >> 1;
  
        LPC_USB->USBEpIntClr = PowOf2[n];
        while ((LPC_USB->USBDevIntSt & CDFULL_INT) == 0);
        val = LPC_USB->USBCmdData;
  
        if ((n & 1) == 0) {                 /* OUT Endpoint */
          if (n == 0) {                     /* Control OUT Endpoint */
            if (val & EP_SEL_STP) {         /* Setup Packet */
              if (usb.P_EP[0]) {
                _CALL(usb, usb.P_EP[0])(USB_EVT_SETUP);
                continue;
              }
            }
          }
          if (usb.P_EP[m]) {
            _CALL(usb, usb.P_EP[m])(USB_EVT_OUT);
          }
        } else {                            /* IN Endpoint */
          if (usb.P_EP[m]) {
            _CALL(usb, usb.P_EP[m])(USB_EVT_IN);
          }
        }
      }
    }
    LPC_USB->USBDevIntClr = EP_SLOW_INT;
  }

#if USB_DMA

  if (LPC_USB->DMAIntSt & 0x00000001) {          /* End of Transfer Interrupt */
    val = LPC_USB->EoTIntSt;
    for (n = 2; n < USB_EP_NUM; n++) {      /* Check All Endpoints */
      if (val & Utility::PowOf2[n]) {
        m = n >> 1;
        if ((n & 1) == 0) {                 /* OUT Endpoint */
          if (USB_P_EP[m]) {
            USB_P_EP[m](USB_EVT_OUT_DMA_EOT);
          }
        } else {                            /* IN Endpoint */
          if (USB_P_EP[m]) {
            USB_P_EP[m](USB_EVT_IN_DMA_EOT);
          }
        }
      }
    }
    LPC_USB->EoTIntClr = val;
  }

  if (LPC_USB->DMAIntSt & 0x00000002) {          /* New DD Request Interrupt */
    val = LPC_USB->NDDRIntSt;
    for (n = 2; n < USB_EP_NUM; n++) {      /* Check All Endpoints */
      if (val & Utility::PowOf2[n]) {
        m = n >> 1;
        if ((n & 1) == 0) {                 /* OUT Endpoint */
          if (USB_P_EP[m]) {
            USB_P_EP[m](USB_EVT_OUT_DMA_NDR);
          }
        } else {                            /* IN Endpoint */
          if (USB_P_EP[m]) {
            USB_P_EP[m](USB_EVT_IN_DMA_NDR);
          }
        }
      }
    }
    LPC_USB->NDDRIntClr = val;
  }

  if (LPC_USB->DMAIntSt & 0x00000004) {          /* System Error Interrupt */
    val = LPC_USB->SysErrIntSt;
    for (n = 2; n < USB_EP_NUM; n++) {      /* Check All Endpoints */
      if (val & Utility::PowOf2[n]) {
        m = n >> 1;
        if ((n & 1) == 0) {                 /* OUT Endpoint */
          if (USB_P_EP[m]) {
						Enable = true;
            USB_P_EP[m](USB_EVT_OUT_DMA_ERR);
          }
        } else {                            /* IN Endpoint */
          if (USB_P_EP[m]) {
						Enable = true;
            USB_P_EP[m](USB_EVT_IN_DMA_ERR);
          }
        }
      }
    }
    LPC_USB->SysErrIntClr = val;
  }

#endif /* USB_DMA */

isr_end:
  return;
}


/*
 *  USB Interrupt Service Routine
 */

void USBHW::ActivityHandler()
{
	#if POWERDOWN_MODE_USB_WAKEUP
		if ( WakeupFlag == 1 )
		{
			WakeupFlag = 0;
			USBActivityInterruptFlag = 1;
		}
	#endif
}
