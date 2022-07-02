#ifndef	WATCHDOG_H
#define WATCHDOG_H
class WatchDog
{
	public:
		WatchDog();
		~WatchDog();
		void Init();
		void Feed();
		void Handler();

	private:
		unsigned int Counter;
};

#endif
