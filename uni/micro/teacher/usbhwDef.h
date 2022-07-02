#ifndef __USBHW_H__
#define __USBHW_H__
#include "stdint.h"


/* USB RAM Definitions */
#define USB_RAM_ADR     0x20080000  /* USB RAM Start Address */
#define USB_RAM_SZ      0x00004000  /* USB RAM Size (4kB) */

/* DMA Endpoint Descriptors */
#define DD_NISO_CNT             16  /* Non-Iso EP DMA Descr. Count (max. 32) */
#define DD_ISO_CNT               8  /* Iso EP DMA Descriptor Count (max. 32) */
#define DD_NISO_SZ    (DD_NISO_CNT * 16)    /* Non-Iso DMA Descr. Size */
#define DD_ISO_SZ     (DD_ISO_CNT  * 20)    /* Iso DMA Descriptor Size */
#define DD_NISO_ADR   (USB_RAM_ADR + 128)   /* Non-Iso DMA Descr. Address */
#define DD_ISO_ADR    (DD_NISO_ADR + DD_NISO_SZ) /* Iso DMA Descr. Address */
#define DD_SZ                 (128 + DD_NISO_SZ + DD_ISO_SZ) /* Descr. Size */

/* DMA Buffer Memory Definitions */
#define DMA_BUF_ADR   (USB_RAM_ADR + DD_SZ) /* DMA Buffer Start Address */
#define DMA_BUF_SZ    (USB_RAM_SZ  - DD_SZ) /* DMA Buffer Size */

/* USB Error Codes */
#define USB_ERR_PID         0x0001  /* PID Error */
#define USB_ERR_UEPKT       0x0002  /* Unexpected Packet */
#define USB_ERR_DCRC        0x0004  /* Data CRC Error */
#define USB_ERR_TIMOUT      0x0008  /* Bus Time-out Error */
#define USB_ERR_EOP         0x0010  /* End of Packet Error */
#define USB_ERR_B_OVRN      0x0020  /* Buffer Overrun */
#define USB_ERR_BTSTF       0x0040  /* Bit Stuff Error */
#define USB_ERR_TGL         0x0080  /* Toggle Bit Error */

/* USB DMA Status Codes */
#define USB_DMA_INVALID     0x0000  /* DMA Invalid - Not Configured */
#define USB_DMA_IDLE        0x0001  /* DMA Idle - Waiting for Trigger */
#define USB_DMA_BUSY        0x0002  /* DMA Busy - Transfer in progress */
#define USB_DMA_DONE        0x0003  /* DMA Transfer Done (no Errors)*/
#define USB_DMA_OVER_RUN    0x0004  /* Data Over Run */
#define USB_DMA_UNDER_RUN   0x0005  /* Data Under Run (Short Packet) */
#define USB_DMA_ERROR       0x0006  /* Error */
#define USB_DMA_UNKNOWN     0xFFFF  /* Unknown State */

/* USB DMA Descriptor */
typedef struct _USB_DMA_DESCRIPTOR {
  uint32_t BufAdr;                     /* DMA Buffer Address */
  uint16_t  BufLen;                     /* DMA Buffer Length */
  uint16_t  MaxSize;                    /* Maximum Packet Size */
  uint32_t InfoAdr;                    /* Packet Info Memory Address */
  union {                           /* DMA Configuration */
    struct {
      uint32_t Link   : 1;             /* Link to existing Descriptors */
      uint32_t IsoEP  : 1;             /* Isonchronous Endpoint */
      uint32_t ATLE   : 1;             /* ATLE (Auto Transfer Length Extract) */
      uint32_t Rsrvd  : 5;             /* Reserved */
      uint32_t LenPos : 8;             /* Length Position (ATLE) */
    } Type;
    uint32_t Val;
  } Cfg;
} USB_DMA_DESCRIPTOR;

#endif