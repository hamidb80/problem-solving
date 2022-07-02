#include "RTC.h"
#include "RTCDef.h"
#include "lpc17xx.h"


RTC::RTC()
{
}

RTC::RTC(RTCTime& rtctime)
{
	RTC();
	*this = rtctime;
}

RTC::~RTC()
{
}

void RTC::Init(void)
{
	AlarmOn = 0;
	/* Enable CLOCK into RTC */
	LPC_SC->PCONP |= (1 << 9);
	/* If RTC is stopped, clear STOP bit. */
	if ( LPC_RTC->RTC_AUX & (0x1<<4) )
	LPC_RTC->RTC_AUX |= (0x1<<4);	
	/*--- Initialize registers ---*/    
	LPC_RTC->AMR = 0xFF;
	LPC_RTC->CIIR = 0;
	LPC_RTC->CCR = 0;
	LPC_RTC->CALIBRATION = 0x00;
	LPC_RTC->ILR = 2;
	NVIC_EnableIRQ(RTC_IRQn);
	Start();
	GetTime();
}

void RTC::Start( void )
{
	LPC_RTC->CCR |= CCR_CLKEN;
  LPC_RTC->ILR = ILR_RTCCIF;
}

void RTC::Stop( void )
{
	LPC_RTC->CCR &= ~CCR_CLKEN;
}

void RTC::CTCReset(void)
{
	LPC_RTC->CCR |= CCR_CTCRST;
}

void RTC::SetTime()
{
	*this = rtctime;
}

void RTC::GetTime(void)
{
	rtctime.Sec  = LPC_RTC->SEC;
  rtctime.Min  = LPC_RTC->MIN;
	rtctime.Hour = LPC_RTC->HOUR;
	rtctime.Mday = LPC_RTC->DOM;
	rtctime.Wday = LPC_RTC->DOW;
	rtctime.Yday = LPC_RTC->DOY;
	rtctime.Mon  = LPC_RTC->MONTH;
	rtctime.Year = LPC_RTC->YEAR;
}

void RTC::SetAlarm()
{
	LPC_RTC->ALSEC  = LPC_RTC->SEC + 5;
  LPC_RTC->ALMIN  = LPC_RTC->MIN;
	LPC_RTC->ALHOUR = LPC_RTC->HOUR;
	LPC_RTC->ALDOM  = LPC_RTC->DOM;
	LPC_RTC->ALDOW  = LPC_RTC->DOW;
	LPC_RTC->ALDOY  = LPC_RTC->DOY;
	LPC_RTC->ALMON  = LPC_RTC->MONTH;
	LPC_RTC->ALYEAR = LPC_RTC->YEAR;
}

void RTC::SetAlarmMask( uint32_t AlarmMask )
{
	LPC_RTC->AMR = AlarmMask;
}

RTCTime& RTC::operator = (RTCTime& _rtctime)
{
	LPC_RTC->SEC   = _rtctime.Sec;
  LPC_RTC->MIN   = _rtctime.Min;
	LPC_RTC->HOUR  = _rtctime.Hour;
	LPC_RTC->DOM   = _rtctime.Mday;
	LPC_RTC->DOW   = _rtctime.Wday;
	LPC_RTC->DOY   = _rtctime.Yday;
	LPC_RTC->MONTH = _rtctime.Mon;
	LPC_RTC->YEAR  = _rtctime.Year;
	return _rtctime;
}

RTCTime& RTC::operator = (char* _rtctime)
{
	rtctime.Sec  = LPC_RTC->SEC = _rtctime[0];
  rtctime.Min  = LPC_RTC->MIN = _rtctime[1];
	rtctime.Hour = LPC_RTC->HOUR = _rtctime[2];
	rtctime.Mday = LPC_RTC->DOM = _rtctime[3];
	rtctime.Mon  = LPC_RTC->MONTH = _rtctime[4];
	rtctime.Year = LPC_RTC->YEAR = _rtctime[5] + 2000;
	rtctime.Wday = LPC_RTC->DOW = _rtctime[6];
	rtctime.Yday = LPC_RTC->DOY = _rtctime[7];
	return rtctime;
}

RTCTime::RTCTime()
{
}

RTCTime::~RTCTime()
{
}

RTCTime::RTCTime(RTCTime& t)
{
	Sec = t.Sec;    
	Min = t.Min;    
	Hour = t.Hour;  
	Mday = t.Mday;   
	Mon = t.Mon;     
	Year = t.Year;   
	Wday = t.Wday;    
	Yday = t.Yday;    
}

void RTC::InterruptHandler()
{
	LPC_RTC->ILR |= ILR_RTCCIF;		/* clear interrupt flag */
}