# SCC V0.2.5

Konami SCC/K051649 sound chip emulator for ARM32.

## Usage

First alloc chip struct, call SCCReset.
Call SCCMixer with length, destination and chip struct.
Produces signed 16bit mono.
You can define SCCMULT to a number, this is how much more is added to the
frequency counters, this affects the highest possible frequency. You can add
"-SCCMULT=32" to the "make" file to make the count 32 times higher. Default is
16. You can define SCC_UPSHIFT to a number, this is how many times the internal
sampling is doubled. You can also define SCCFILTER to a value between 0 & 8 or
so to filter out higher frequencies, default is 1.

The code uses self modifying code so you can only instantiate one chip at a
time.

## Projects that use this code

* https://github.com/FluBBaOfWard/S8DS
* https://github.com/wavemotion-dave/ColecoDS

## Credits

Fredrik Ahlström

X/Twitter @TheRealFluBBa

https://www.github.com/FluBBaOfWard
