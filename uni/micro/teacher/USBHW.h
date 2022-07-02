#ifndef USBHW1_H
#define USBHW1_H
#include "stdint.h"
#include "usb.h"
#include "usbhwDef.h"
class USBHW
{
	public:
		USBHW();
		~USBHW();
		uint32_t EPAdr (uint32_t EPNum);
		void WrCmd (uint32_t cmd);
		void WrCmdDat (uint32_t cmd, uint32_t val);
		void WrCmdEP (uint32_t EPNum, uint32_t cmd);
		uint32_t RdCmdDat (uint32_t cmd);
		void Init (void);
		void Connect (uint32_t con);
		void Reset (void);
		void Suspend (void);
		void Resume (void);
		void WakeUp (void);
		void WakeUpCfg (uint32_t cfg);
		void SetAddress (uint32_t adr);
		void Configure (uint32_t cfg);
		void ConfigEP (USB_ENDPOINT_DESCRIPTOR *pEPD);
		void DirCtrlEP (uint32_t dir);
		void EnableEP (uint32_t EPNum);
		void DisableEP (uint32_t EPNum);
		void ResetEP (uint32_t EPNum);
		void SetStallEP (uint32_t EPNum);
		void ClrStallEP (uint32_t EPNum);
		void ClearEPBuf (uint32_t EPNum);
		uint32_t ReadEP (uint32_t EPNum, uint8_t *pData);
		uint32_t WriteEP (uint32_t EPNum, uint8_t *pData, uint32_t cnt);
		uint32_t DMA_Setup(uint32_t EPNum, USB_DMA_DESCRIPTOR *pDD);
		void DMA_Enable (uint32_t EPNum);
		void DMA_Disable (uint32_t EPNum);
		uint32_t DMA_Status (uint32_t EPNum);
		uint32_t DMA_BufAdr (uint32_t EPNum);
		uint32_t DMA_BufCnt (uint32_t EPNum);
		uint32_t GetFrame (void);
		void handler();
		void ActivityHandler();

	private:
};

#endif