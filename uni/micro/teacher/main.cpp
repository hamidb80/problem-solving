#include "gpio.h"
#include "uart.h"
#include "lpc17xx.h"
#include "RTC.h"
#include "USBCore.h"
#include "SpiFlash.h"
#include "Watchdog.h"
#include "timer.h"
#include "SysTick.h"

GPIO gpio;
UART uart;
RTC rtc;
USBCore usb;
SpiFlash flash;
WatchDog watchdog;
Timer timer;
Systick systick;

char OutReport;
void Delay(int d)
{
	int i = 0;
	for (; i < d; i++);
}

unsigned short strcpy(char* dest, char* src, short count, char UPDOWN)
{
  unsigned short i = 0;
	if (count == 0)
	{		   
		for (; src[i]; i++)
			dest[i] = src[i];
		dest[i] = 0;
		return i + 1;
	}
	if (UPDOWN == 0)
		for (; i < count; i++)
			dest[i] = src[i];
	else
	{
		for (; i < count; i++)
			dest[i] = src[count - i - 1];
	}
	return count;
}

void GPIOPollingTest()
{
//	GPIO t1; //stack
//	t1.Set(2, 1);
//	
//	GPIO* t2 = new GPIO(); //heap
//	t2->Set(2, 1);
//	delete t2;
	
	gpio.Init(0, 6, 0); //Button
	gpio.Init(2, 0, 1); //LED
	while(true)
	{
		if (LPC_GPIO0->FIOPIN & (1 << 6))
			gpio.Set(2, 0);
		else
			gpio.Clr(2, 0);
		
		//task 1	100ms
		//task 2	200ms
		//task 3	300ms
		//task 4	200ms
		//task 5	200ms
	}
}

void GPIOInterruptTest()
{
	gpio.Init(0, 6, 0); //Button
	gpio.InitInterrupt(0, 6);
	gpio.Init(2, 0, 1); //LED
	while(true)
	{
		//task 1	100ms
		//task 2	200ms
		//task 3	300ms
		//task 4	200ms
		//task 5	200ms
	}
}

void GPIOTest()
{
	for (int i = 0; i < 8; i++)
		gpio.Init(2, i);
	
	while(true)
	{
		for (int i = 0; i < 8; i++)
		{
			gpio.Tgl(2, i);
			Delay(40000);
		}
	}
}

void UARTTest2()
{
	uart.Init();
	char ch;
	while(true)
	{
		if (uart.RecieveBuf.HasData())
		{
			ch = uart.Get();
			uart.Send(ch + 1);
		}
		else
			ch = -1;
		if (ch == 'A')
		{
			uart.Send("SALAM\r\n");
			uart << "salam" << 5 << "\r\n" << -10 << "Hello\r\n";
		}
	}
}

void UARTTest()
{
	gpio.Init(2, 0);
	gpio.Init(2, 1);
	gpio.Clr(2, 0);
	gpio.Clr(2, 1);
	uart.Init();
	while (true)
	{
		if (uart.Get() == 'D')
			gpio.Tgl(2, 0);
		gpio.Set(2, 1);
		uart.Send('B');
		uart.Send('B');
		uart.Send('B');
		uart.Send('B');
		uart.Send('B');
		uart.Send('B');
		uart.Send('B');
		uart.Send('B');
		uart.Send('B');
		uart.Send('B');
		gpio.Clr(2, 1);
		uart.Send('C');
	}
}

void test()
{
	gpio.Init(2, 0);
	gpio.Init(2, 1);
	gpio.Clr(2, 0);
	gpio.Clr(2, 1);
	uart.Init();
	
	for (int i = 0; i < 10; i++)
	{
		uart << 'Q' << "   " << (unsigned char)0xA7 << "  Micro\n";
	}
	
	while (true)
	{
		gpio.Set(2, 0);
		gpio.Set(2, 1);
		Delay(8000000);
		gpio.Clr(2, 0);
		gpio.Clr(2, 1);
		Delay(8000000);
		if (uart.RecieveBuf.HasData())
		{
			char d = uart.RecieveBuf.Remove();
			if (d == '1')
				uart << "Micro\n";
			else if (d == '2')
				uart << "LPC 1768\n";
			else
				uart << "Nothing\n";
		}
	}
}

void RTCTest()
{
	uart.Init();
	rtc.Init();
	RTCTime time;
	time.Year = 2016;
	time.Mon = 12;
	time.Mday = 31;
	time.Hour = 23;
	time.Min = 59;
	time.Sec = 55;
	rtc = time;
	
	while(true)
	{
		rtc.GetTime();
		uart << rtc.rtctime;
		Delay(8000000);
	}
}

void USBTest()
{
	gpio.Init(2, 0);
	gpio.Init(2, 1);
	gpio.Clr(2, 0);
	gpio.Clr(2, 1);
	//uart.Init();
	usb.Init();
	rtc.Init();
	RTCTime time;
	time.Year = 2016;
	time.Mon = 12;
	time.Mday = 31;
	time.Hour = 23;
	time.Min = 59;
	time.Sec = 55;
	rtc = time;
	
	usb.hiduser << "Salam. This is usb test.\n";
	while (true)
	{
		rtc.GetTime();
		usb.hiduser << rtc.rtctime << "\r\n";
		//uart << "salam\n";
		usb.Run();
		gpio.Tgl(2, 0);
		Delay(19990000);
	}
}

void SPIFlashTest()
{
	gpio.Init(2, 0);
	gpio.Init(2, 1);
	gpio.Clr(2, 0);
	gpio.Clr(2, 1);
	uart.Init();
	usb.Init();
	char port[3] = {0, 255, 255};
	char pin[3] = {16, 255, 255};
	flash.Init(port, pin);
	char s[] = "salam\n";
	char d[6];
	flash.Write((unsigned char*)s, 1000, 6, 1);
	flash.Read((unsigned char*)d, 1000, 6, 0);
	usb.hiduser << d;
	while (true)
	{
		
	}
}

void WatchDogTest()
{
	uart.Init();
	watchdog.Init();
	uart << "Test is strated ...\r\n";
	int counter = 0;
	while(true)
	{
		uart << "This is a watchdog test number " << counter++ << ".\r\nshahed university\r\n" << "nik fekr\r\n";
		Delay(0x1ffffff);
		//task2
		//task3
		watchdog.Feed();
		//task4
		watchdog.Feed();
		//task5
		watchdog.Feed();
	}
}

void TimerTest()
{
	timer.Init();
	uart.Init();
	uart << "Timer test ...\r\n";
	while (true)
	{
		uart << "Shahed university.\r\n";
		timer.Wait(1000);
		//task 1
		//task 2
	}
}

void SysTickTest()
{
	uart.Init();
	uart << "Systick test ...\r\n";
	systick.Init(100);
	int iteration = 0;
	int iteration2 = 0;
	//timer.Init();
	while (true)
	{
		systick.Run();
		//task 1
		//task 2
	}
}

int timePeriod1 = 0;
int iteration1 = 0;
void Task1(int interval)
{
	timePeriod1 += interval;
	if (timePeriod1 >= 10)
	{
		uart << "Iteration " << iteration1++ << "\r\n";
		timePeriod1 = 0;
	}
}

int timePeriod2 = 0;
int iteration2 = 0;
void Task2(int interval)
{
	timePeriod2 += interval;
	if (timePeriod2 >= 15)
	{
		uart << "Hello " << iteration2++ << "\r\n";
		timePeriod2 = 0;
	}
}

int main()
{
	SystemInit();
	//SysTickTest();
	//WatchDogTest();
	//GPIOTest();
	//UARTTest();
	//RTCTest();
	//test();
	USBTest();
	//SPIFlashTest();
	return 0;
}



