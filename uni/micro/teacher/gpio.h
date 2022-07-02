class GPIO
{
	public:
		void Init(int port, int pin, int direction = 1);
		void Set(int port, int pin);
		void Clr(int port, int pin);
		void Tgl(int port, int pin);
	
		void InitInterrupt(int port, int pin);
};