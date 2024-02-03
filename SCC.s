;@
;@  SCC.s
;@  Konami SCC/K051649 sound chip emulator for arm32.
;@
;@  Created by Fredrik Ahlström on 2006-04-01.
;@  Copyright © 2006-2024 Fredrik Ahlström. All rights reserved.
;@
#ifdef __arm__

#include "SCC.i"

#define SCCDIVIDE 16
#define SCCADDITION 0x00004000*SCCDIVIDE

	.global SCCReset
	.global SCCMixer
	.global SCCWrite
	.global SCCRead


	.syntax unified
	.arm

	.section .itcm
	.align 2
;@----------------------------------------------------------------------------
;@ r0  = Mix length.
;@ r1  = Mixerbuffer.
;@ r2  = sccptr.
;@ r3 -> r7 = pos+freq.
;@ r8  = Sample reg/volume.
;@ r9  = Mixer reg.
;@ r10 = Sample ptr.
;@ r12 = Scrap
;@ lr  = Scrap.
;@----------------------------------------------------------------------------
//IIIIIVCCCCCCCCCCCC10FFFFFFFFFFFF
//I=sampleindex, V=overflow, C=counter, F=frequency
;@----------------------------------------------------------------------------
SCCMixer:					;@ r0=len, r1=dest, r2=pointer to SCC struct
	.type   SCCMixer STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r11,lr}
	add r8,r2,#sccCh0Freq	;@ counters
	ldmia r8,{r3-r7}
;@----------------------------------------------------------------------------
sccMixLoop:
	add r3,r3,#SCCADDITION
	movs r10,r3,lsr#27
	mov r12,r3,lsl#18
	subcs r3,r3,r12,asr#4
vol0:
	movs r9,#0x00				;@ volume
	ldrsbne r12,[r2,r10]		;@ Channel 0
	mulne r9,r12,r9


	add r4,r4,#SCCADDITION
	movs r10,r4,lsr#27
	add r10,r10,#0x20
	mov r12,r4,lsl#18
	subcs r4,r4,r12,asr#4
vol1:
	movs r8,#0x00				;@ volume
	ldrsbne r12,[r2,r10]		;@ Channel 1
	mlane r9,r8,r12,r9


	add r5,r5,#SCCADDITION
	movs r10,r5,lsr#27
	add r10,r10,#0x40
	mov r12,r5,lsl#18
	subcs r5,r5,r12,asr#4
vol2:
	movs r8,#0x00				;@ volume
	ldrsbne r12,[r2,r10]		;@ Channel 2
	mlane r9,r8,r12,r9


	add r6,r6,#SCCADDITION
	movs r10,r6,lsr#27
	add r10,r10,#0x60
	mov r12,r6,lsl#18
	subcs r6,r6,r12,asr#4
vol3:
	movs r8,#0x00				;@ volume
	ldrsbne r12,[r2,r10]		;@ Channel 3
	mlane r9,r8,r12,r9


	add r7,r7,#SCCADDITION
	movs r10,r7,lsr#27
	add r10,r10,#0x60
	mov r12,r7,lsl#18
	subcs r7,r7,r12,asr#4
vol4:
	movs r8,#0x00				;@ volume
	ldrsbne r12,[r2,r10]		;@ Channel 4, same waveform as ch3
	mlane r9,r8,r12,r9


	subs r0,r0,#1
	strhpl r9,[r1],#2
	bhi sccMixLoop

	add r8,r2,#sccCh0Freq		;@ counters
	stmia r8,{r3-r7}

	ldmfd sp!,{r4-r11,lr}
	bx lr
;@----------------------------------------------------------------------------

	.section .text
	.align 2
;@----------------------------------------------------------------------------
SCCReset:					;@ r0=pointer to SCC struct
	.type   SCCReset STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r0,lr}
	mov r1,#0
	mov r2,#sccSize				;@ 144
	bl memset					;@ clear variables
	ldmfd sp!,{r0,lr}
	mov r1,#0x20
	strb r1,[r0,#sccCh0Freq+1]	;@ counters
	strb r1,[r0,#sccCh1Freq+1]	;@ counters
	strb r1,[r0,#sccCh2Freq+1]	;@ counters
	strb r1,[r0,#sccCh3Freq+1]	;@ counters
	strb r1,[r0,#sccCh4Freq+1]	;@ counters
	bx lr
;@----------------------------------------------------------------------------
SCCSaveState:				;@ In r0=destination, r1=snptr. Out r0=state size.
	.type   SCCSaveState STT_FUNC
;@----------------------------------------------------------------------------
	mov r2,#sccStateEnd-sccStateStart
	stmfd sp!,{r2,lr}

	bl memcpy

	ldmfd sp!,{r0,lr}
	bx lr
;@----------------------------------------------------------------------------
SCCLoadState:				;@ In r0=snptr, r1=source. Out r0=state size.
	.type   SCCLoadState STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r0,lr}

	mov r2,#sccStateEnd-sccStateStart
	bl memcpy
	ldmfd sp!,{r0,lr}

;@----------------------------------------------------------------------------
SCCGetStateSize:			;@ Out r0=state size.
	.type   SCCGetStateSize STT_FUNC
;@----------------------------------------------------------------------------
	mov r0,#sccStateEnd-sccStateStart
	bx lr
;@----------------------------------------------------------------------------
SCCVolume:
	.byte 0,3,7,10,14,17,20,24,27,31,34,37,41,44,48,51
;@----------------------------------------------------------------------------
SCCRead:					;@ 0x9800-0x9FFF, r0=adr, r1=SCC
	.type   SCCRead STT_FUNC
;@----------------------------------------------------------------------------
	movs r0,r0,lsl#24
	ldrbpl r0,[r1,r0,lsr#24]
	movmi r0,#0xFF
	bx lr
;@----------------------------------------------------------------------------
SCCWrite:					;@ 0x9800-0x9FFF, r0=val, r1=adr, r2=SCC
	.type   SCCWrite STT_FUNC
;@----------------------------------------------------------------------------
	and r1,r1,#0xFF				;@ 0x00-0x7F wave ram.
	cmp r1,#0x90				;@ 0x80-0x8F registers, 0x90-0x9F mirror.
	subpl r1,r1,#0x10			;@ 0xE0-0xFF test register, all mirrors.
	cmp r1,#0x90
	strbmi r0,[r2,r1]
	strbpl r0,[r2,#sccTestReg]
	bxpl lr
	subs r1,r1,#0x80
	ldrpl pc,[pc,r1,lsl#2]
	bx lr
	.long sccCh0FreqLW			;@ 0x80
	.long sccCh0FreqHW			;@ 0x81
	.long sccCh1FreqLW			;@ 0x82
	.long sccCh1FreqHW			;@ 0x83
	.long sccCh2FreqLW			;@ 0x84
	.long sccCh2FreqHW			;@ 0x85
	.long sccCh3FreqLW			;@ 0x86
	.long sccCh3FreqHW			;@ 0x87
	.long sccCh4FreqLW			;@ 0x88
	.long sccCh4FreqHW			;@ 0x89
	.long sccCh0VolW			;@ 0x8A
	.long sccCh1VolW			;@ 0x8B
	.long sccCh2VolW			;@ 0x8C
	.long sccCh3VolW			;@ 0x8D
	.long sccCh4VolW			;@ 0x8E
	.long sccKeyOnW				;@ 0x8F

;@----------------------------------------------------------------------------
sccCh0FreqLW:
;@----------------------------------------------------------------------------
	strb r0,[r2,#sccCh0Freq]
	bx lr
;@----------------------------------------------------------------------------
sccCh0FreqHW:
;@----------------------------------------------------------------------------
	ldrb r1,[r2,#sccCh0Freq+1]
	and r0,r0,#0x0F
	and r1,r1,#0xF0
	orr r0,r0,r1
	strb r0,[r2,#sccCh0Freq+1]
	bx lr
;@----------------------------------------------------------------------------
sccCh1FreqLW:
;@----------------------------------------------------------------------------
	strb r0,[r2,#sccCh1Freq]
	bx lr
;@----------------------------------------------------------------------------
sccCh1FreqHW:
;@----------------------------------------------------------------------------
	ldrb r1,[r2,#sccCh1Freq+1]
	and r0,r0,#0x0F
	and r1,r1,#0xF0
	orr r0,r0,r1
	strb r0,[r2,#sccCh1Freq+1]
	bx lr
;@----------------------------------------------------------------------------
sccCh2FreqLW:
;@----------------------------------------------------------------------------
	strb r0,[r2,#sccCh2Freq]
	bx lr
;@----------------------------------------------------------------------------
sccCh2FreqHW:
;@----------------------------------------------------------------------------
	ldrb r1,[r2,#sccCh2Freq+1]
	and r0,r0,#0x0F
	and r1,r1,#0xF0
	orr r0,r0,r1
	strb r0,[r2,#sccCh2Freq+1]
	bx lr
;@----------------------------------------------------------------------------
sccCh3FreqLW:
;@----------------------------------------------------------------------------
	strb r0,[r2,#sccCh3Freq]
	bx lr
;@----------------------------------------------------------------------------
sccCh3FreqHW:
;@----------------------------------------------------------------------------
	ldrb r1,[r2,#sccCh3Freq+1]
	and r0,r0,#0x0F
	and r1,r1,#0xF0
	orr r0,r0,r1
	strb r0,[r2,#sccCh3Freq+1]
	bx lr
;@----------------------------------------------------------------------------
sccCh4FreqLW:
;@----------------------------------------------------------------------------
	strb r0,[r2,#sccCh4Freq]
	bx lr
;@----------------------------------------------------------------------------
sccCh4FreqHW:
;@----------------------------------------------------------------------------
	ldrb r1,[r2,#sccCh4Freq+1]
	and r0,r0,#0x0F
	and r1,r1,#0xF0
	orr r0,r0,r1
	strb r0,[r2,#sccCh4Freq+1]
	bx lr
;@----------------------------------------------------------------------------
sccCh0VolW:
;@----------------------------------------------------------------------------
	ands r0,r0,#0x0F
	ldrbne r1,[r2,#sccChControl]
	andsne r1,r1,#0x01
	adrne r1,SCCVolume
	ldrbne r0,[r1,r0]
	ldr r1,=vol0
	strb r0,[r1]
	bx lr
;@----------------------------------------------------------------------------
sccCh1VolW:
;@----------------------------------------------------------------------------
	ands r0,r0,#0x0F
	ldrbne r1,[r2,#sccChControl]
	andsne r1,r1,#0x02
	adrne r1,SCCVolume
	ldrbne r0,[r1,r0]
	ldr r1,=vol1
	strb r0,[r1]
	bx lr
;@----------------------------------------------------------------------------
sccCh2VolW:
;@----------------------------------------------------------------------------
	ands r0,r0,#0x0F
	ldrbne r1,[r2,#sccChControl]
	andsne r1,r1,#0x04
	adrne r1,SCCVolume
	ldrbne r0,[r1,r0]
	ldr r1,=vol2
	strb r0,[r1]
	bx lr
;@----------------------------------------------------------------------------
sccCh3VolW:
;@----------------------------------------------------------------------------
	ands r0,r0,#0x0F
	ldrbne r1,[r2,#sccChControl]
	andsne r1,r1,#0x08
	adrne r1,SCCVolume
	ldrbne r0,[r1,r0]
	ldr r1,=vol3
	strb r0,[r1]
	bx lr
;@----------------------------------------------------------------------------
sccCh4VolW:
;@----------------------------------------------------------------------------
	ands r0,r0,#0x0F
	ldrbne r1,[r2,#sccChControl]
	andsne r1,r1,#0x10
	adrne r1,SCCVolume
	ldrbne r0,[r1,r0]
	ldr r1,=vol4
	strb r0,[r1]
;@----------------------------------------------------------------------------
sccKeyOnW:
;@----------------------------------------------------------------------------
	bx lr
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
