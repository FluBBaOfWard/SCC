/*
*/

#ifndef SCC_HEADER
#define SCC_HEADER

typedef struct {
	ch0Wave[32];
	ch1Wave[32];
	ch2Wave[32];
	ch3Wave[32];
//	ch4Wave[32];
	u16 ch0Frq;
	u16 ch1Frq;
	u16 ch2Frq;
	u16 ch3Frq;
	u16 ch4Frq;
	u8 ch0Volume;
	u8 ch1Volume;
	u8 ch2Volume;
	u8 ch3Volume;
	u8 ch4Volume;
	u8 chControl;

	u16 ch0Freq;
	u16 ch0Addr;
	u16 ch1Freq;
	u16 ch1Addr;
	u16 ch2Freq;
	u16 ch2Addr;
	u16 ch3Freq;
	u16 ch3Addr;
	u16 ch4Freq;
	u16 ch4Addr;

} scc;


void SCCReset(scc *chip);
void SCCMixer(scc *chip, int len, void *dest);
void SCCWrite(scc *chip, u8 value);
void SCCRead(scc *chip, u8 value);


#endif
