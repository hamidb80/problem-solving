#ifndef RTC_H
#define RTC_H

class RTC;
class RTCTime
{
	friend class RTC;
	public:
		RTCTime();
		RTCTime(RTCTime&);
		~RTCTime();

		unsigned char Sec;     /* Second value - [0,59] */
		unsigned char Min;     /* Minute value - [0,59] */
		unsigned char Hour;    /* Hour value - [0,23] */
		unsigned char Mday;    /* Day of the month value - [1,31] */
		unsigned char Mon;     /* Month value - [1,12] */
		unsigned short Year;    /* Year value - [0,4095] */
		unsigned char Wday;    /* Day of week value - [0,6] */
		unsigned short Yday;    /* Day of year value - [1,365] */
};

class RTC
{
	public:
		RTC();
		RTC(RTCTime&);
		~RTC();
		void Init( void );
		void Start( void );
		void Stop( void );
		void CTCReset(void);
		void SetTime(void);
		RTCTime& operator = (RTCTime& rtctime);
		RTCTime& operator = (char* rtctime);
		void GetTime(void);
		void SetAlarm(void);
		void SetAlarmMask( unsigned int AlarmMask );
	
		void InterruptHandler();
		
		RTCTime rtctime;
		unsigned char AlarmOn;

	private:
};


#endif