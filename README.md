# SCC
Konami SCC/K051649 sound chip emulator for ARM32.

First alloc chip struct, call init then set in/out function pointers.
Call SCCMixer with chip struct, length and destination.
Produces 16bit mono.
