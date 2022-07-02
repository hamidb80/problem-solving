#ifndef SYSTICK_H
#define SYSTICK_H
class Systick
{
	public:
		Systick();
		~Systick();
		void Init(unsigned int time);
		void Init(unsigned int Frequency, unsigned int time);
		unsigned int Get();
		void Handler(void);
		void Run();

		unsigned int Time;
		unsigned int LastTime;
};

#endif
