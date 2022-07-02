#define maxtime 0x1000000 - 1
#define ST_CTRL_ENABLE		((unsigned int)(1<<0))
#define ST_CTRL_TICKINT		((unsigned int)(1<<1))
#define ST_CTRL_CLKSOURCE	((unsigned int)(1<<2))
#define ST_CTRL_COUNTFLAG	((unsigned int)(1<<16))

#define ST_RELOAD_RELOAD(n)		((unsigned int)(n & 0x00FFFFFF))

#define ST_RELOAD_CURRENT(n)	((unsigned int)(n & 0x00FFFFFF))

#define ST_CALIB_TENMS(n)		((unsigned int)(n & 0x00FFFFFF))
#define ST_CALIB_SKEW			((unsigned int)(1<<30))
#define ST_CALIB_NOREF			((unsigned int)(1<<31))

#define CLKSOURCE_EXT			((unsigned int)(0))
#define CLKSOURCE_CPU			((unsigned int)(1))
