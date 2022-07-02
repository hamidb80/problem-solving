class Timer
{
	public:
		void Init();
		void SetInterval(char MRNumber, int milisecond);
		void EnableInterrupt(char MRNumber);
		void Wait(int milisecond);
		void Start();
		void Stop();
		void Handler0();
	
	private:
		bool WaitDone;
		
};