// #if (BoardType_DATALOGER_V1 == 1)
// 	#define SpiFlash_CSLow() Sys.gpio.Clr(0, 6, 1)
// 	#define SpiFlash_CSHigh() Sys.gpio.Set(0, 6, 1)



#define AT45DB_ReadStatusReg            0xD7
#define AT45DB_PowerDown                0xB9
#define AT45DB_WakeUp                   0xAB
#define AT45DB_JedecDeviceID            0x9F
#define AT45DB_PageErase                0x81
#define AT45DB_PageReadContinuous       0xE8
#define AT45DB_PageReadContinuous1      0xE8
#define AT45DB_PageWriteBuffer1ToMain   0x82
#define AT45DB_PageWriteBuffer2ToMain   0x85
#define AT45DB_PageWriteBuffer1         0x84
#define AT45DB_PageWriteBuffer2         0x87
#define AT45DB_ReadBuffer1         			0xD4
#define AT45DB_ReadBuffer2         			0xD6
