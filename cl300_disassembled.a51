$NOMOD51
$INCLUDE (mcu/83c552.mcu)

; bit definitions
ACC0		BIT	0E0h
ACC3		BIT	0E3h
ACC4		BIT	0E4h
ACC6		BIT	0E6h
ACC7		BIT	0E7h

BCC0		BIT	0F0h
BCC1		BIT	0F1h
BCC2		BIT	0F2h
BCC3		BIT	0F3h
BCC6		BIT	0F6h
BCC7		BIT	0F7h


; heat pump definitions
CMPRSR_RLY	BIT	CT1I			; P1.1
WW_RLY		BIT	T2			; P1.4
EXT_RLY		BIT	CT0I			; P1.0
H_PUMP_RLY	BIT	CT2I			; P1.2
C_PUMP_RLY	BIT	RT2			; P1.5
CMPRSR_CHK	BIT	CT3I			; P1.3

EXT_SW		BIT	CMT1			; P4.7
PRESSO_L_SW	BIT	CMT0			; P4.6
PRESSO_H_SW	BIT	CMSR5			; P4.5

; panel
PANEL_DOUT	BIT	CMSR4			; P4.4
PANEL_PL	BIT	CMSR3			; P4.3
PANEL_CLK	BIT	CMSR2			; P4.2
PANEL_DIN	BIT	CMSR1			; P4.1
PANEL_STROBE	BIT	CMSR0			; P4.0

; serial flash

FLASH_DOUT	BIT	T0			; P3.4
FLASH_DIN	BIT	T1			; P3.5
FLASH_CLK	BIT	WR			; P3.6
FLASH_CS	BIT	RD			; P3.7


; some constants?
iram_start	EQU	008h		; 
vars_start	EQU	048h		; assuming here are some important variables
sp_init		EQU	054h		; start address for SP

; known functions:
; call_0091	; arguments in registers:	none
		; arguments after function:	none
		; function: 			resets watchdog timer
		; output: 			none
; call_094c	; arguments in registers:	none
		; arguments after function:	none
		; function: 			init IRAM
		; output: 			none
; call_099c	; arguments in registers:	R1 - start address
		;				A - end address
		; arguments after function:	none
		; function: 			clears IRAM from R1 to A (without A)
		; output:			none
; call_09a5	; arguments in registers:	DPTR - first word
		;				R2/R3 - second word
		; arguments after function:	none
		; function:			returns if words are the same
		; output:			A==0 if the same, otherwise A<>0
; call_09e0	; arguments in registers:	DPTR - ???
		; arguments after function:	none
		; function: 			???
		; output:			???
; call_09ae	; arguments in registers:	none
		; arguments after function:	2 bytes - start source address
		; 				2 bytes - end source address
		;				2 bytes - destination address
		; function:			copy content from start source address till end address to the destination address
		; output:			none


; interrupt vector table
ORG RESET
		SJMP	START
ORG EXTI0
		RETI
ORG TIMER0
		LJMP	TMR0_ROUTINE
ORG EXTI1
		RETI
ORG TIMER1
		RETI
ORG SINT
		LJMP	SIO_ROUTINE
ORG I2CBUS
		RETI
ORG T2CAP0
		RETI
ORG T2CAP1
		RETI
ORG T2CAP2
		RETI
ORG T2CAP3
		RETI
ORG ADCONV
		RETI
ORG T2CMP0
		RETI
ORG T2CMP1
		RETI
ORG T2CMP2
		RETI
ORG T2OVER
		RETI

; Start

START:
		MOV	A, #000h
		MOV	C, ACC3
		MOV	RS0, C
		MOV	C, ACC4
		MOV	RS1, C
		
		MOV	SP, #sp_init
		LCALL	call_0091

		LCALL	call_094c



		SETB	EA
		MOV	R1, #000h
		LCALL	call_3b4f
		LJMP	START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; function: reset watchdog
;;;; arguments taken: none
;;;; output: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_0091:
		ORL	PCON, #010h
		MOV	T3, #000h
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


TMR0_ROUTINE:
		PUSH	ACC
		PUSH	B
		PUSH	PSW
		PUSH	DPH
		PUSH	DPL
		PUSH	AR0
		PUSH	AR1
		PUSH	AR2
		PUSH	AR3
		PUSH	AR4
		PUSH	AR5
		PUSH	AR6
		PUSH	AR7
		MOV	PSW, #000h
		MOV	R1, #000h
		LCALL	TMR0_SUBCALL
		POP	AR7
		POP	AR6
		POP	AR5
		POP	AR4
		POP	AR3
		POP	AR2
		POP	AR1
		POP	AR0
		POP	DPL
		POP	DPH
		POP	PSW
		POP	B
		POP	ACC
		RETI

SIO_ROUTINE:
		PUSH	ACC
		PUSH	B
		PUSH	PSW
		PUSH	DPH
		PUSH	DPL
		PUSH	AR0
		PUSH	AR1
		PUSH	AR2
		PUSH	AR3
		PUSH	AR4
		PUSH	AR5
		PUSH	AR6
		PUSH	AR7
		MOV	PSW, #000h
		MOV	R1, #000h
		LCALL	SIO_SUBCALL
		POP	AR7
		POP	AR6
		POP	AR5
		POP	AR4
		POP	AR3
		POP	AR2
		POP	AR1
		POP	AR0
		POP	DPL
		POP	DPH
		POP	PSW
		POP	B
		POP	ACC
		RETI

;;;;;;;;;

call_0112:
		MOV	A, S0BUF
		MOV	048h, A
		MOV	C, P
		JC	jump_0120
		JB	RB8, jump_0123
jump_011d:
		MOV	R3, #000h
		RET
jump_0120:
		JB	RB8, jump_011d
jump_0123:
		MOV	R3, #001h
		RET

call_0126:
		MOV	A, R3
		MOV	C, P
		MOV	TB8, C
		CLR	ES0
		MOV	S0BUF, A
jump_012f:
		JNB	TI, jump_012f
		CLR	TI
		CLR	RI
		SETB	ES0
		RET

;;;;;;;;;;;;;;;;
call_0139:
		LCALL	call_0142
		LCALL	call_06bd
		LJMP	jump_014b
call_0142:
		MOV	DPH, R3
		MOV	003h, R5
		MOV	R0, DPH
		MOV	005h, @R0
		RET
jump_014b:
		MOV	R0, DPH
		MOV	@R0, AR3
		MOV	A, R3
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_0151:
		DB	063h, 002h, 080h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_0154:
		MOV	R6, #0F7h
		MOV	007h, DPH
		LCALL	call_0417
		CJNE	R3, #000h, jump_0162
		LJMP	jump_01e2
jump_0162:
		CJNE	R2, #000h, jump_016b
		LCALL	call_01f3
		LJMP	jump_01e2
jump_016b:
		MOV	A, R2
		CLR	C
		SUBB	A, R3
		JNC	jump_0176
		LCALL	call_01f3
		MOV	A, R2
		CLR	C
		SUBB	A, R3
jump_0176:
		MOV	R4, A
		CLR	C
		SUBB	A, #019h
		JC	jump_017f
		LJMP	jump_01e2
jump_017f:
		MOV	A, R4
		JZ	jump_019b
		MOV	A, SP
		ADD	A, #0F9h
		MOV	R5, A
jump_0187:
		MOV	000h, R5
		MOV	R1, #004h
		CLR	C
jump_018c:
		MOV	A, @R0
		RRC	A
		MOV	@R0, A
		INC	R0
		DJNZ	R1, jump_018c
		JNC	jump_0199
		DEC	R0
		MOV	A, @R0
		SETB	ACC0
		MOV	@R0, A
jump_0199:
		DJNZ	R4, jump_0187
jump_019b:
		MOV	R0, SP
		MOV	A, R0
		ADD	A, #0FCh
		MOV	R1, A
		MOV	R4, #004h
		CLR	C
		JB	BCC2, jump_01c2
jump_01a7:
		MOV	A, @R0
		ADDC	A, @R1
		MOV	@R0, A
		DEC	R0
		DEC	R1
		DJNZ	R4, jump_01a7
		JNC	jump_01ba
		INC	R2
		INC	R0
		MOV	R1, #004h
jump_01b4:
		MOV	A, @R0
		RRC	A
		MOV	@R0, A
		INC	R0
		DJNZ	R1, jump_01b4
jump_01ba:
		MOV	R0, SP
		LCALL	call_046c
		LJMP	jump_01e2
jump_01c2:
		MOV	A, @R0
		SUBB	A, @R1
		MOV	@R0, A
		DEC	R0
		DEC	R1
		DJNZ	R4, jump_01c2
		JNC	jump_01da
		MOV	C, BCC0
		MOV	BCC1, C
		MOV	R0, SP
		MOV	R1, #004h
		CLR	C
jump_01d4:
		CLR	A
		SUBB	A, @R0
		MOV	@R0, A
		DEC	R0
		DJNZ	R1, jump_01d4
jump_01da:
		MOV	R0, SP
		LCALL	call_046c
		LJMP	jump_01e2
jump_01e2:
		POP	ACC
		POP	005h
		POP	004h
		POP	003h
		MOV	A, SP
		ADD	A, #0FCh
		MOV	SP, A
		LJMP	jump_04b1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


call_01f3:
		MOV	A, SP
		ADD	A, #0FEh
		MOV	R1, A
		ADD	A, #0FCh
		MOV	R0, A
		MOV	DPL, #004h
jump_01fe:
		MOV	A, @R0
		XCH	A, @R1
		MOV	@R0, A
		DEC	R0
		DEC	R1
		DJNZ	DPL, jump_01fe
		MOV	A, R2
		XCH	A, R3
		MOV	R2, A
		MOV	C, BCC1
		RRC	A
		MOV	C, BCC0
		MOV	BCC1, C
		RLC	A
		MOV	BCC0, C
		RET

;;;;;;;;;;;;;;;
call_0214:
		CLR	A
		PUSH	ACC
		PUSH	ACC
		PUSH	ACC
		PUSH	ACC
		MOV	R6, #0F3h
		MOV	007h, DPH
		LCALL	call_0417
		MOV	A, R3
		JNZ	jump_022b
		MOV	R2, A
		SJMP	jump_02a4
jump_022b:
		MOV	A, R2
		JZ	jump_02a4
		CLR	C
		SUBB	A, #07Fh
		MOV	BCC3, C
		MOV	A, R3
		CLR	C
		SUBB	A, #07Fh
		ANL	C, BCC3
		MOV	BCC3, C
		MOV	A, R2
		ADD	A, R3
		CLR	C
		SUBB	A, #07Fh
		MOV	R2, A
		ANL	C, BCC3
		JNC	jump_0249
		MOV	R2, #000h
		SJMP	jump_02a4
jump_0249:
		MOV	A, SP
		MOV	R5, A
		ADD	A, #0FCh
		MOV	R4, A
		ADD	A, #0FCh
		MOV	R3, A
		PUSH	002h
		PUSH	B
		MOV	000h, R4
		MOV	R1, #004h
		CLR	C
jump_025b:
		INC	R0
		MOV	A, @R0
		RRC	A
		MOV	@R0, A
		DJNZ	R1, jump_025b
call_0261:
		MOV	R2, #018h
jump_0263:
		MOV	A, R3
		ADD	A, #0FCh
		MOV	R0, A
		MOV	R1, #004h
		CLR	C
jump_026a:
		INC	R0
		MOV	A, @R0
		RRC	A
		MOV	@R0, A
		DJNZ	R1, jump_026a
		JNC	jump_0278
		MOV	B, A
		MOV	BCC0, C
		MOV	@R0, B
jump_0278:
		MOV	A, R4
		ADD	A, #0FCh
		MOV	R0, A
		MOV	R1, #004h
		CLR	C
jump_027f:
		INC	R0
		MOV	A, @R0
		RRC	A
		MOV	@R0, A
		DJNZ	R1, jump_027f
		JNB	ACC7, jump_0298
		MOV	000h, R3
		MOV	001h, R5
		MOV	DPL, #004h
		CLR	C
jump_0290:
		MOV	A, @R0
		ADDC	A, @R1
		MOV	@R0, A
		DEC	R0
		DEC	R1
		DJNZ	DPL, jump_0290
jump_0298:
		DJNZ	R2, jump_0263
		POP	B
		POP	002h
		INC	R2
		MOV	000h, R3
		LCALL	call_046c
jump_02a4:
		MOV	A, SP
		ADD	A, #0F8h
		MOV	SP, A
		POP	ACC
		POP	005h
		POP	004h
		POP	003h
		MOV	C, BCC2
		MOV	BCC1, C
		LJMP	jump_04b1


call_02b9:
		CLR	A
		PUSH	ACC
		PUSH	ACC
		PUSH	ACC
		PUSH	ACC
		MOV	R6, #0F3h
		MOV	007h, DPH
		LCALL	call_0417
		MOV	A, R3
		JZ	jump_02d2
		MOV	A, R2
		JZ	jump_02d2
		SJMP	jump_02d5
jump_02d2:
		LJMP	jump_0361
jump_02d5:
		CLR	C
		SUBB	A, #07Fh
		MOV	BCC3, C
		MOV	A, R3
		CLR	C
		SUBB	A, #07Fh
		ANL	C, BCC3
		MOV	BCC3, C
		MOV	A, R2
		ADD	A, #07Fh
		CLR	C
		SUBB	A, R3
		MOV	R2, A
		ANL	C, BCC3
		JNC	jump_02f0
		MOV	R2, #000h
		SJMP	jump_0361
jump_02f0:
		MOV	A, SP
		MOV	R5, A
		ADD	A, #0FCh
		MOV	R4, A
		ADD	A, #0FCh
		MOV	R3, A
		PUSH	002h
		PUSH	B
		MOV	DPL, #020h
		MOV	000h, R3
		INC	R0
		MOV	R1, #008h
		CLR	C
jump_0306:
		MOV	A, @R0
		RRC	A
		MOV	@R0, A
		INC	R0
		DJNZ	R1, jump_0306
jump_030c:
		MOV	000h, R5
		MOV	001h, R4
		MOV	R2, #004h
		CLR	C
jump_0313:
		MOV	A, @R0
		SUBB	A, @R1
		MOV	@R0, A
		DEC	R0
		DEC	R1
		DJNZ	R2, jump_0313
		JNC	jump_032b
		MOV	000h, R5
		MOV	001h, R4
		MOV	R2, #004h
		CLR	C
jump_0323:
		MOV	A, @R0
		ADDC	A, @R1
		MOV	@R0, A
		DEC	R0
		DEC	R1
		DJNZ	R2, jump_0323
		SETB	C
jump_032b:
		CPL	C
		MOV	000h, R3
		MOV	R1, #004h
jump_0330:
		MOV	A, @R0
		RLC	A
		MOV	@R0, A
		DEC	R0
		DJNZ	R1, jump_0330
		MOV	000h, R5
		MOV	R1, #004h
		CLR	C
jump_033b:
		MOV	A, @R0
		RLC	A
		MOV	@R0, A
		DEC	R0
		DJNZ	R1, jump_033b
		DJNZ	DPL, jump_030c
		MOV	000h, R5
		MOV	R1, #004h
jump_0348:
		MOV	A, @R0
		JNZ	jump_0350
		DEC	R0
		DJNZ	R1, jump_0348
		SJMP	jump_0358
jump_0350:
		MOV	000h, R3
		MOV	A, @R0
		CLR	C
		CPL	C
		MOV	ACC0, C
		MOV	@R0, A
jump_0358:
		POP	B
		POP	002h
		MOV	000h, R3
		LCALL	call_046c
jump_0361:
		MOV	A, SP
		ADD	A, #0F8h
		MOV	SP, A
		POP	ACC
		POP	005h
		POP	004h
		POP	003h
		MOV	C, BCC2
		MOV	BCC1, C
		LJMP	jump_04b1

;;;;;;;;;;;;;;;;

call_0376:
		MOV	A, R3
		MOV	C, ACC7
		SETB	ACC7
		MOV	R3, A
		MOV	A, R2
		RLC	A
		MOV	BCC0, C
		CLR	C
		SUBB	A, #07Fh
		JNC	jump_038c
		CLR	A
		MOV	R2, A
		MOV	R3, A
		MOV	R4, A
		MOV	R5, A
		SJMP	jump_03c8
jump_038c:
		MOV	R1, A
		ADD	A, #0E0h
		JNC	jump_03a0
		MOV	R2, #080h
		CLR	A
		MOV	R3, A
		MOV	R4, A
		MOV	R5, A
		JB	BCC0, jump_03c8
		DEC	R2
		DEC	R3
		DEC	R4
		DEC	R5
		SJMP	jump_03c8
jump_03a0:
		CLR	A
		XCH	A, R5
		XCH	A, R4
		XCH	A, R3
		XCH	A, R2
		MOV	A, #01Fh
		SUBB	A, R1
		MOV	R1, A
		JZ	jump_03ba
jump_03ab:
		MOV	R0, #002h
		MOV	DPL, #004h
		CLR	C
jump_03b1:
		MOV	A, @R0
		RRC	A
		MOV	@R0, A
		INC	R0
		DJNZ	DPL, jump_03b1
		DJNZ	R1, jump_03ab
jump_03ba:
		JNB	BCC0, jump_03c8
		MOV	R0, #005h
		MOV	R1, #004h
		CLR	C
jump_03c2:
		CLR	A
		SUBB	A, @R0
		MOV	@R0, A
		DEC	R0
		DJNZ	R1, jump_03c2
jump_03c8:
		MOV	A, R2
		ORL	A, R3
		ORL	A, R4
		ORL	A, R5
		RET

;;;;;;;;;;;;;;;

call_03cd:
		MOV	DPL, #01Fh
		CLR	BCC0
		MOV	A, R2
		JNB	ACC7, jump_03ea
		SETB	BCC0
		MOV	R0, #005h
		MOV	R1, #004h
		CLR	C
jump_03dd:
		CLR	A
		SUBB	A, @R0
		MOV	@R0, A
		DEC	R0
		DJNZ	R1, jump_03dd
		SJMP	jump_03ea
		MOV	DPL, #01Fh
		CLR	BCC0
jump_03ea:
		MOV	A, R2
		ORL	A, R3
		ORL	A, R4
		ORL	A, R5
		JNZ	jump_03f1
		RET
jump_03f1:
		MOV	A, R2
		JB	ACC7, jump_0404
		MOV	R0, #005h
		MOV	R1, #004h
		DEC	DPL
		CLR	C
jump_03fc:
		MOV	A, @R0
		RLC	A
		MOV	@R0, A
		DEC	R0
		DJNZ	R1, jump_03fc
		SJMP	jump_03ea
jump_0404:
		MOV	A, R2
		XCH	A, R3
		XCH	A, R4
		XCH	A, R5
		MOV	A, DPL
		ADD	A, #07Fh
		MOV	C, BCC0
		RRC	A
		MOV	R2, A
		MOV	A, R3
		MOV	ACC7, C
		MOV	R3, A
		MOV	A, #001h
		RET


;;;;;;;;;;;;;;;


call_0417:
		MOV	A, R3
		MOV	C, ACC7
		SETB	ACC7
		MOV	R3, A
		MOV	A, R2
		RLC	A
		MOV	R2, A
		MOV	BCC0, C
		POP	000h
		POP	001h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		CLR	A
		PUSH	ACC
		PUSH	002h
		PUSH	001h
		PUSH	000h
		MOV	A, SP
		ADD	A, R6
		MOV	R1, A
		MOV	R0, #005h
		MOV	R6, #004h
jump_043d:
		MOV	A, @R1
		MOV	@R0, A
		DEC	R0
		DEC	R1
		DJNZ	R6, jump_043d
		MOV	A, R3
		MOV	C, ACC7
		SETB	ACC7
		MOV	R3, A
		MOV	A, R2
		RLC	A
		MOV	R2, A
		MOV	BCC1, C
		MOV	BCC2, C
		MOV	C, BCC0
		JNC	jump_0456
		CPL	BCC2
jump_0456:
		POP	DPL
		POP	DPH
		POP	001h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		CLR	A
		PUSH	ACC
		PUSH	DPH
		PUSH	DPL
		MOV	R3, AR1
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_046c:
		MOV	DPL, R0
		MOV	R1, #004h
jump_0470:
		MOV	A, @R0
		JNZ	jump_0478
		DEC	R0
		DJNZ	R1, jump_0470
		MOV	R2, A
		RET
jump_0478:
		MOV	R0, DPL
		DEC	R0
		DEC	R0
		DEC	R0
		MOV	A, @R0
		JNB	ACC7, jump_049d
		MOV	R0, DPL
		MOV	A, @R0
		CLR	C
		RLC	A
		JNC	jump_048f
		JNZ	jump_048f
		DEC	R0
		MOV	A, @R0
		INC	R0
		MOV	C, ACC0
jump_048f:
		MOV	R1, #003h
jump_0491:
		DEC	R0
		MOV	A, @R0
		ADDC	A, #000h
		MOV	@R0, A
		DJNZ	R1, jump_0491
		MOV	A, R2
		ADDC	A, #000h
		MOV	R2, A
		RET
jump_049d:
		CJNE	R2, #001h, jump_04a3
		MOV	R2, #000h
		RET
jump_04a3:
		DEC	R2
		MOV	R0, DPL
		MOV	R1, #004h
		CLR	C
jump_04a9:
		MOV	A, @R0
		RLC	A
		MOV	@R0, A
		DEC	R0
		DJNZ	R1, jump_04a9
		SJMP	jump_0478

;;;;;;;;;;;;;;;;

jump_04b1:
		MOV	DPH, R7
		POP	006h
		POP	007h
		MOV	A, SP
		ADD	A, #0FCh
		MOV	SP, A
		PUSH	007h
		PUSH	006h
		MOV	A, R2
		JNZ	jump_04ca
		MOV	R2, A
		MOV	R3, A
		MOV	R4, A
		MOV	R5, A
		CLR	C
		RET
jump_04ca:
		MOV	R1, A
		MOV	C, BCC1
		RRC	A
		MOV	R2, A
		MOV	A, R3
		MOV	ACC7, C
		MOV	R3, A
		MOV	A, R1
		MOV	C, BCC1
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_04d7:
		DW	0EB33h, 0E495h, 0E0FAh, 0ED33h, 0E495h, 0E0FCh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_04e3:
		MOV	A, R4
		RLC	A
		MOV	A, R2
		XRL	A, R4
		RRC	A
		PUSH	ACC
		LCALL	call_0831
		POP	B
		JZ	jump_04fd
		JNB	BCC6, jump_04f6
		MOV	R2, B
jump_04f6:
		MOV	A, R2
		RLC	A
		CPL	C
		CLR	A
		MOV	R2, A
		RLC	A
		MOV	R3, A
jump_04fd:
		RET

;;;;;;

call_04fe:
		MOV	R2, #000h
		MOV	R4, #000h
		LCALL	call_0831
		JZ	jump_050c
		CPL	C
		CLR	A
		MOV	R2, A
		RLC	A
		MOV	R3, A
jump_050c:
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_050d:
		DW	0EB33h, 0E495h, 0E0FAh, 0ED33h, 0E495h, 0E0FCh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_0519:
		MOV	A, R4
		RLC	A
		MOV	A, R2
		XRL	A, R4
		RRC	A
		PUSH	ACC
		LCALL	call_0831
		POP	ACC
		JNB	ACC6, jump_0529
		MOV	R2, A
jump_0529:
		CLR	A
		XCH	A, R2
		RL	A
		ANL	A, #001h
		MOV	R3, A
		RET


call_0530:
		MOV	R2, #000h
		MOV	R4, #000h
		LCALL	call_0831
		CLR	A
		MOV	R2, A
		RLC	A
		MOV	R3, A
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_053c:
		DW	0EB33h, 0E495h, 0E0FAh, 0ED33h, 0E495h, 0E0FCh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


call_0548:
		MOV	A, R4
		RLC	A
		MOV	A, R2
		XRL	A, R4
		RRC	A
		PUSH	ACC
		LCALL	call_0831
		POP	ACC
		JNB	ACC6, jump_0558
		MOV	R2, A
jump_0558:
		CLR	A
		XCH	A, R2
		CPL	A
		RL	A
		ANL	A, #001h
		MOV	R3, A
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_0560:
		DW	0EB33h, 0E495h, 0E0FAh, 0ED33h, 0E495h, 0E0FCh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


call_056c:
		MOV	A, R4
		RLC	A
		MOV	A, R2
		XRL	A, R4
		RRC	A
		PUSH	ACC
		LCALL	call_0831
		POP	B
		INC	R3
		JZ	jump_0586
		JNB	BCC6, jump_0580
		MOV	R2, B
jump_0580:
		CLR	A
		XCH	A, R2
		RLC	A
		CLR	A
		RLC	A
		MOV	R3, A
jump_0586:
		MOV	A, R3
		RET

call_0588:
		MOV	R2, #000h
		MOV	R4, #000h
		LCALL	call_0831
		JZ	jump_0595
		CLR	A
		MOV	R2, A
		INC	A
		MOV	R3, A
jump_0595:
		MOV	A, R3
		RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_0597:
		DW	0D083h, 0D082h, 01206h, 01980h, 00ED0h, 083D0h, 08212h, 00619h
		DW	0C3E4h, 09FFFh, 0E49Eh, 0FEC0h, 082C0h, 0838Bh, 0018Bh, 08380h
		DW	0247Eh, 0007Fh, 00180h, 0047Eh, 0FF7Fh, 0FFD0h, 083D0h, 082E4h
		DW	093A3h, 0C082h, 0C083h, 08B01h, 0B401h, 005E7h, 02FFBh, 0F722h
		DW	08983h, 0B402h, 01187h, 00209h, 0E72Fh, 0FBEAh, 03EFAh, 0A983h
		DW	0F709h, 0A703h, 04B22h, 075F0h, 00478h, 002E7h, 0F608h, 009D5h
		DW	0F0F9h, 02FFDh, 075F0h, 00378h, 004E6h, 03EF6h, 018D5h, 0F0F9h
		DW	0A983h, 075F0h, 00478h, 002E6h, 0F709h, 008D5h, 0F0F9h, 04C4Bh
		DW	04A22h, 0E493h, 0FEA3h, 0E493h, 0FFA3h, 022D0h, 083D0h, 08212h
		DW	00619h, 0800Eh, 0D083h, 0D082h, 01206h, 019C3h, 0E49Fh, 0FFE4h
		DW	09EFEh, 0C082h, 0C083h, 08B01h, 08B83h, 08026h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_0643:
		MOV	R6, #000h
		MOV	R7, #001h
		SJMP	jump_064d
call_0649:
		MOV	R6, #0FFh
		MOV	R7, #0FFh
jump_064d:
		POP	DPH
		POP	DPL
		CLR	A
		MOVC	A, @A+DPTR
		INC	DPTR
		PUSH	DPL
		PUSH	DPH
		MOV	001h, R3
		CJNE	A, #001h, jump_0664
		MOV	A, @R1
		ADD	A, R7
		MOV	@R1, A
		CLR	C
		SUBB	A, R7
		MOV	R3, A
		RET
jump_0664:
		MOV	DPH, R1
		CJNE	A, #002h, jump_0681
		MOV	002h, @R1
		INC	R1
		MOV	A, @R1
		ADD	A, R7
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R6
		MOV	R2, A
		MOV	R1, DPH
		MOV	@R1, A
		INC	R1
		MOV	@R1, AR3
		CLR	C
		MOV	A, R3
		SUBB	A, R7
		MOV	R3, A
		MOV	A, R2
		SUBB	A, R6
		MOV	R2, A
		ORL	A, R3
		RET
jump_0681:
		MOV	B, #004h
		MOV	R0, #002h
jump_0686:
		MOV	A, @R1
		MOV	@R0, A
		INC	R0
		INC	R1
		DJNZ	B, jump_0686
		ADD	A, R7
		MOV	R5, A
		MOV	B, #003h
		MOV	R0, #004h
jump_0694:
		MOV	A, @R0
		ADDC	A, R6
		MOV	@R0, A
		DEC	R0
		DJNZ	B, jump_0694
		MOV	R1, DPH
		MOV	B, #004h
		MOV	R0, #002h
jump_06a2:
		MOV	A, @R0
		MOV	@R1, A
		INC	R1
		INC	R0
		DJNZ	B, jump_06a2
		CLR	C
		MOV	A, R5
		SUBB	A, R7
		MOV	R5, A
		MOV	B, #003h
		MOV	R0, #004h
jump_06b2:
		MOV	A, @R0
		SUBB	A, R6
		MOV	@R0, A
		DEC	R0
		DJNZ	B, jump_06b2
		ORL	A, R4
		ORL	A, R3
		ORL	A, R2
		RET

;;;;;;;;;;;;;

call_06bd:
		MOV	A, R3
		JZ	jump_06cf
		ADD	A, #0F8h
		JNC	jump_06c8
		MOV	R3, #000h
		MOV	A, R3
		RET
jump_06c8:
		MOV	A, R5
jump_06c9:
		CLR	C
		RLC	A
		DJNZ	R3, jump_06c9
		MOV	R3, A
		RET
jump_06cf:
		MOV	003h, R5
		MOV	A, R3
		RET

;;;;;;;;;;;;;;;;;;;;;;

call_06d3:
		MOV	A, R3
		JZ	jump_06ef
		ADD	A, #0F1h
		JNC	jump_06e5
		MOV	B, R4
		CLR	A
		JNB	BCC7, jump_06e2
		MOV	A, #0FFh
jump_06e2:
		MOV	R2, A
		MOV	R3, A
		RET
jump_06e5:
		MOV	A, R4
		MOV	C, ACC7
		RRC	A
		MOV	R4, A
		MOV	A, R5
		RRC	A
		MOV	R5, A
		DJNZ	R3, jump_06e5
jump_06ef:
		MOV	002h, R4
		MOV	003h, R5
		MOV	A, R2
		ORL	A, R3
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;

call_06f6:
		MOV	A, R3
		JZ	jump_070a
		ADD	A, #0F0h
		JNC	jump_0701
		CLR	A
		MOV	R2, A
		MOV	R3, A
		RET
jump_0701:
		MOV	A, R4
		CLR	C
		RRC	A
		MOV	R4, A
		MOV	A, R5
		RRC	A
		MOV	R5, A
		DJNZ	R3, jump_0701
jump_070a:
		MOV	002h, R4
		MOV	003h, R5
		MOV	A, R2
		ORL	A, R3
		RET

;;;;;;;;;;;;;;;;;;;;;;;;

call_0711:
		MOV	A, R3
		JZ	jump_0725
		ADD	A, #0F0h
		JNC	jump_071c
		CLR	A
		MOV	R2, A
		MOV	R3, A
		RET
jump_071c:
		MOV	A, R5
		CLR	C
		RLC	A
		MOV	R5, A
		MOV	A, R4
		RLC	A
		MOV	R4, A
		DJNZ	R3, jump_071c
jump_0725:
		MOV	002h, R4
		MOV	003h, R5
		MOV	A, R2
		ORL	A, R3
		RET

;;;;;;;;;;;;;;;;;;;;;;;;

call_072c:
		MOV	AR1, R3
		MOV	AR2, @R1
		INC	R1
		MOV	AR3, @R1
		POP	DPH
		POP	DPL
		CLR	A
		MOVC	A, @A+DPTR
		ANL	A, R2
		MOV	R2, A
		INC	DPTR
		CLR	A
		MOVC	A, @A+DPTR
		ANL	A, R3
		MOV	R3, A
		INC	DPTR
		CLR	A
		MOVC	A, @A+DPTR
		JZ	jump_0751
		MOV	B, A
jump_0747:
		MOV	A, R2
		CLR	C
		RRC	A
		MOV	R2, A
		MOV	A, R3
		RRC	A
		MOV	R3, A
		DJNZ	B, jump_0747
jump_0751:
		INC	DPTR
		PUSH	DPL
		PUSH	DPH
		CLR	A
		MOV	A, R2
		ORL	A, R3
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_075a:
		POP	DPH
		POP	DPL
		CLR	A
		MOVC	A, @A+DPTR
		MOV	B, A
		INC	DPTR
		CLR	A
		MOVC	A, @A+DPTR
		MOV	R6, A
		INC	DPTR
		CLR	A
		MOVC	A, @A+DPTR
		MOV	R7, A
		INC	DPTR
		PUSH	DPL
		PUSH	DPH
		MOV	AR1, R3
		PUSH	AR4
		PUSH	AR5
		MOV	A, B
		JZ	jump_0783
		CLR	C
jump_077a:
		MOV	A, R5
		RLC	A
		MOV	R5, A
		MOV	A, R4
		RLC	A
		MOV	R4, A
		DJNZ	B, jump_077a
jump_0783:
		MOV	A, R5
		ANL	A, R7
		MOV	R5, A
		MOV	A, R4
		ANL	A, R6
		MOV	R4, A
		POP	AR3
		POP	AR2
		MOV	A, R7
		CPL	A
		MOV	R7, A
		MOV	A, R6
		CPL	A
		MOV	R6, A
		MOV	A, @R1
		ANL	A, R6
		ORL	A, R4
		MOV	@R1, A
		INC	R1
		MOV	A, @R1
		ANL	A, R7
		ORL	A, R5
		MOV	@R1, A
		CLR	A
		MOV	A, R2
		ORL	A, R3
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_07a0:
		DW	07803h, 07E01h, 08008h, 07E02h, 08002h, 07E04h, 07802h, 0D083h
		DW	0D082h, 0E493h, 02BF9h, 0A3E4h, 0933Ah, 0A3C0h, 082C0h, 08360h
		DW	011F5h, 08389h, 0827Fh, 000E4h, 093F6h, 04207h, 008A3h, 0DEF7h
		DW	0EF22h
		DB	0FFh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

jump_07d3:
		MOV	A, @R1
		MOV	@R0, A
		INC	R1
		INC	R0
		ORL	007h, A
		DJNZ	R6, jump_07d3
		MOV	A, R7
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_07dd:
		DW	07803h, 07E01h, 08014h, 07805h, 07E01h, 0800Eh, 07E02h, 08008h
		DW	07804h, 07E02h, 08004h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


call_07f3:
		MOV	R6, #004h
		MOV	R0, #002h
		POP	DPH
		POP	DPL
		CLR	A
		MOVC	A, @A+DPTR
		ADD	A, SP
		INC	DPTR
		PUSH	DPL
		PUSH	DPH
		MOV	R7, #000h
		MOV	R1, A
		SJMP	jump_07d3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_0809:
		DW	07803h, 07E01h, 08008h, 07E02h, 08002h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


call_0813:
		MOV	R6, #004h
		MOV	R0, #002h
		POP	DPH
		POP	DPL
		CLR	A
		MOVC	A, @A+DPTR
		ADD	A, SP
		INC	DPTR
		PUSH	DPL
		PUSH	DPH
		MOV	R1, A
		MOV	R7, #000h
jump_0827:
		MOV	A, @R0
		MOV	@R1, A
		INC	R1
		INC	R0
		ORL	007h, A
		DJNZ	R6, jump_0827
		MOV	A, R7
		RET

;;;;;;;;;;;;;;;;;;;;;

call_0831:
		MOV	A, R5
		CLR	C
		SUBB	A, R3
		MOV	R3, A
		MOV	A, R4
		SUBB	A, R2
		MOV	R2, A
		ORL	A, R3
		RET

;;;;;;;;;;;;;;;;;;;;;;;
call_083a:
		MOV	A, R3
		MOV	B, R4
		MUL	AB
		XCH	A, R2
		MOV	B, R5
		MUL	AB
		ADD	A, R2
		MOV	R2, A
		MOV	A, R3
		MOV	B, R5
		MUL	AB
		MOV	R3, A
		MOV	A, B
		ADD	A, R2
		MOV	R2, A
		ORL	A, R3
		RET

;;;;;;;;;;;;;;;;;;;;;;;

call_084f:
		MOV	R1, #000h
		MOV	A, R2
		JNB	ACC7, jump_085c
		MOV	R1, #001h
		MOV	R0, #003h
		LCALL	call_08b8
jump_085c:
		MOV	A, R4
		JNB	ACC7, jump_0868
		XRL	001h, #01H
		MOV	R0, #005h
		LCALL	call_08b8
jump_0868:
		PUSH	001h
		LCALL	call_087e
		POP	001h
		CJNE	R1, #001h, jump_0877
		MOV	R0, #005h
		LCALL	call_08b8
jump_0877:
		MOV	002h, R4
		MOV	003h, R5
		MOV	A, R2
		ORL	A, R3
		RET

;;;;;;;;;;;;;;;;;;;;;;;

call_087e:
		CJNE	R3, #000h, jump_0885
		CJNE	R2, #000h, jump_0885
		RET
jump_0885:
		MOV	R0, #000h
		MOV	R1, #000h
		MOV	A, #010h
		PUSH	ACC
jump_088d:
		CLR	C
		MOV	A, R5
		RLC	A
		MOV	R5, A
		MOV	A, R4
		RLC	A
		MOV	R4, A
		MOV	A, R1
		RLC	A
		MOV	R1, A
		MOV	A, R0
		RLC	A
		MOV	R0, A
		CLR	C
		MOV	A, R1
		SUBB	A, R3
		MOV	B, A
		MOV	A, R0
		SUBB	A, R2
		JC	jump_08ae
		MOV	R0, A
		MOV	R1, B
		MOV	A, R5
		ADD	A, #001h
		MOV	R5, A
		MOV	A, R4
		ADDC	A, #000h
		MOV	R4, A
jump_08ae:
		POP	ACC
		DEC	A
		PUSH	ACC
		JNZ	jump_088d
		POP	ACC
		RET


;;;;;;;;;;;;;;;;;;;;;;;

call_08b8:
		CLR	A
		CLR	C
		SUBB	A, @R0
		MOV	@R0, A
		DEC	R0
		CLR	A
		SUBB	A, @R0
		MOV	@R0, A
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_08c1:
		DW	0D083h, 0D082h, 0C3E4h, 093A3h, 0CD9Dh, 0FDE4h, 093A3h, 0CC9Ch
		DW	0FC93h, 0A3CBh, 09B70h, 049E4h, 093A3h, 0CA9Ah, 07043h, 0EDFBh
		DW	0ECFAh, 08011h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


call_08e5:
		POP	DPH
		POP	DPL
		CLR	C
		CLR	A
		MOVC	A, @A+DPTR
		INC	DPTR
		XCH	A, R3
		SUBB	A, R3
		MOV	R3, A
		CLR	A
		MOVC	A, @A+DPTR
		INC	DPTR
		XCH	A, R2
		SUBB	A, R2
		MOV	R2, A
		JB	ACC7, jump_0922
		CLR	C
		CLR	A
		MOVC	A, @A+DPTR
		INC	DPTR
		SUBB	A, R3
		CLR	A
		MOVC	A, @A+DPTR
		INC	DPTR
		SUBB	A, R2
		JB	ACC7, jump_0917
		INC	DPTR
		INC	DPTR
		MOV	A, R3
		ADD	A, R3
		JNC	jump_090d
		INC	DPH
jump_090d:
		ADD	A, DPL
		MOV	DPL, A
		MOV	A, DPH
		ADDC	A, R2
		ADD	A, R2
		MOV	DPH, A
jump_0917:
		MOV	A, #001h
		MOVC	A, @A+DPTR
		PUSH	ACC
		CLR	A
		MOVC	A, @A+DPTR
		PUSH	ACC
		RET
		INC	DPTR
jump_0922:
		INC	DPTR
		INC	DPTR
		SJMP	jump_0917

;;;;;;; SIO routine - case switch implementation?
;;;;;;; (select proper call for cmd)
call_0926:
		POP	DPH
		POP	DPL
jump_092a:
		CLR	A
		MOVC	A, @A+DPTR
		JNZ	jump_0937
		MOV	A, #001h
		MOVC	A, @A+DPTR
		JNZ	jump_0937
		INC	DPTR
		INC	DPTR
		SJMP	jump_0942
jump_0937:
		MOV	A, #002h
		MOVC	A, @A+DPTR
		XRL	A, R3
		JZ	jump_0942
		INC	DPTR
		INC	DPTR
		INC	DPTR
		SJMP	jump_092a
jump_0942:
		MOV	A, #001h
		MOVC	A, @A+DPTR
		PUSH	ACC
		CLR	A
		MOVC	A, @A+DPTR
		PUSH	ACC
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; function: init RAM (clears RAM, copies some content from ROM to RAM)
;;;; arguments taken: none
;;;; output: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_094c:
		MOV	R1, #vars_start
		MOV	A, #sp_init
		LCALL	call_099c

		MOV	DPTR, #const_end
		MOV	R2, DPH
		MOV	R3, DPL
		MOV	DPTR, #const_end
jump_095d:
		LCALL	call_09a5
		JZ	jump_0989



		PUSH	AR2
		PUSH	AR3
		PUSH	DPL
		PUSH	DPH
		MOV	R0, #002h
		MOV	R1, #004h
jump_096e:
		CLR	A
		MOVC	A, @A+DPTR
		MOV	@R0, A
		INC	DPTR
		INC	R0
		DJNZ	R1, jump_096e
		MOV	AR1, R3
		MOV	A, R5
		LCALL	call_099c
		POP	DPH
		POP	DPL
		POP	AR3
		POP	AR2
		INC	DPTR
		INC	DPTR
		INC	DPTR
		INC	DPTR
		SJMP	jump_095d
jump_0989:
		LCALL	call_09ae
		DW	const_end
		DW	const_start
		DW	iram_start

		LCALL	call_09ae
		DW	const_end
		DW	const_end
		DW	sp_init

		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; function: clear IRAM
;;;; arguments taken: R1 - start address, A - end address
;;;; output: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_099c:
		CJNE	A, AR1, jump_09a0
		RET
jump_09a0:
		MOV	@R1, #000h
		INC	R1
		SJMP	call_099c

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; function: compare two words
;;;; arguments taken: DPTR, R2-R3
;;;; output: A==0 if equar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_09a5:
		MOV	A, R3
		XRL	A, DPL
		JNZ	jump_09ad
		MOV	A, R2
		XRL	A, DPH
jump_09ad:
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; function: copy content from X1 to X2 under address Y
;;;; arguments taken: (6 bytes after function call)
;;;;       2 bytes: X1, 2 bytes: X2, 2 bytes: Y
;;;; output: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_09ae:
		POP	DPH
		POP	DPL
		MOV	R0, #002h
		MOV	R1, #006h
jump_09b6:
		CLR	A
		MOVC	A, @A+DPTR
		MOV	@R0, A
		INC	DPTR
		INC	R0
		DJNZ	R1, jump_09b6
		PUSH	DPL
		PUSH	DPH
jump_09c1:
		MOV	DPL, R5
		MOV	DPH, R4
		LCALL	call_09a5
		JZ	jump_09df
		CLR	A
		MOVC	A, @A+DPTR
		INC	DPTR
		MOV	R5, DPL
		MOV	R4, DPH
		MOV	DPL, R7
		MOV	DPH, R6
		MOV	AR1, R7
		MOV	@R1, A
		INC	DPTR
		MOV	R7, DPL
		MOV	R6, DPH
		SJMP	jump_09c1
jump_09df:
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_09e0:
		POP	B
		POP	AR0
		POP	AR6
		POP	AR7
		MOV	A, DPH
		JZ	jump_0a04
		DEC	A
		JNZ	jump_09f3
		PUSH	003h
		SJMP	jump_0a04
jump_09f3:
		DEC	A
		JNZ	jump_09fc
		PUSH	002h
		PUSH	003h
		SJMP	jump_0a04
jump_09fc:
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
jump_0a04:
		MOV	A, SP
		ADD	A, R1
		MOV	R5, A
		MOV	A, SP
		ADD	A, DPL
		MOV	SP, A
		PUSH	AR5
		PUSH	AR7
		PUSH	AR6
		PUSH	AR0
		PUSH	B
		RET


jump_0a19:
		POP	AR6
		POP	AR7
		POP	ACC
		MOV	SP, A
		PUSH	AR7
		PUSH	AR6
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_0a26:
		DW	0E473h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


call_0a28:
		MOV	DPTR, #0101h
		LCALL	call_09e0
		MOV	R3, #000h
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
		CLR	EA
		SETB	FLASH_CS
		SETB	FLASH_CLK
		CLR	FLASH_CLK
		SETB	FLASH_CLK
		SETB	FLASH_DIN
		SETB	FLASH_CLK
		CLR	FLASH_CLK
		SETB	FLASH_CLK
		SETB	FLASH_CLK
		CLR	FLASH_CLK
		SETB	FLASH_CLK
		CLR	FLASH_DIN
		SETB	FLASH_CLK
		CLR	FLASH_CLK
		SETB	FLASH_CLK
		SETB	FLASH_CLK
		CLR	FLASH_CLK
		SETB	FLASH_CLK
		SETB	FLASH_CLK
		CLR	FLASH_CLK
		SETB	FLASH_CLK
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FFh
		LCALL	call_0b79
		SETB	FLASH_CLK
		CLR	FLASH_CLK
		SETB	FLASH_CLK
		MOV	R3, #000h
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
jump_0a7e:
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #008h
		LCALL	call_0530
		JZ	jump_0aba
		MOV	R5, #001h
		MOV	R3, #008h
		MOV	R2, #000h
		LCALL	call_0139
		MOV	R3, #000h
		JNB	FLASH_DOUT, jump_0a9b
		INC	R3
jump_0a9b:
		MOV	005h, R3
		MOV	R3, #008h
		MOV	R2, #000h
		MOV	001h, R3
		MOV	A, @R1
		ADD	A, R5
		MOV	@R1, A
		MOV	R3, A
		SETB	FLASH_CLK
		CLR	FLASH_CLK
		SETB	FLASH_CLK
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_0643
		DB	001h
		SJMP	jump_0a7e
jump_0aba:
		MOV	R3, #000h
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
jump_0ac3:
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #008h
		LCALL	call_0530
		JZ	jump_0aff
		MOV	R5, #001h
		MOV	R3, #009h
		MOV	R2, #000h
		LCALL	call_0139
		MOV	R3, #000h
		JNB	FLASH_DOUT, jump_0ae0
		INC	R3
jump_0ae0:
		MOV	005h, R3
		MOV	R3, #009h
		MOV	R2, #000h
		MOV	001h, R3
		MOV	A, @R1
		ADD	A, R5
		MOV	@R1, A
		MOV	R3, A
		SETB	FLASH_CLK
		CLR	FLASH_CLK
		SETB	FLASH_CLK
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_0643
		DB	001h
		SJMP	jump_0ac3
jump_0aff:
		CLR	FLASH_CS
		SETB	EA
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;;

call_0b06:
		MOV	DPTR, #0102h
		LCALL	call_09e0
		MOV	R3, #080h
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
		MOV	R3, #000h
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
jump_0b1e:
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #008h
		LCALL	call_0530
		JZ	jump_0b74
		MOV	A, #0FBh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R5, A
		MOV	R4, #000h
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_0b4a
		SETB	FLASH_DIN
		SJMP	jump_0b4c
jump_0b4a:
		CLR	FLASH_DIN
jump_0b4c:
		SETB	FLASH_CLK
		CLR	FLASH_CLK
		SETB	FLASH_CLK
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	R4, #000h
		LCALL	call_06f6
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_0643
		DB	001h
		SJMP	jump_0b1e
jump_0b74:
		CLR	FLASH_DIN
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;;;;;;;

call_0b79:
		MOV	DPTR, #0102h
		LCALL	call_09e0
		MOV	R3, #008h
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
		MOV	R3, #000h
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
jump_0b91:
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #004h
		LCALL	call_0530
		JZ	jump_0be7
		MOV	A, #0FBh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R5, A
		MOV	R4, #000h
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_0bbd
		SETB	FLASH_DIN
		SJMP	jump_0bbf
jump_0bbd:
		CLR	FLASH_DIN
jump_0bbf:
		SETB	FLASH_CLK
		CLR	FLASH_CLK
		SETB	FLASH_CLK
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	R4, #000h
		LCALL	call_06f6
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_0643
		DB	001h
		SJMP	jump_0b91
jump_0be7:
		CLR	FLASH_DIN
		LJMP	jump_0a19

;;;

call_0bec:
		MOV	DPTR, #0100h
		LCALL	call_09e0
		CLR	EA
		SETB	FLASH_CS
		MOV	R3, #004h
		MOV	R1, #0FFh
		LCALL	call_0b06
		MOV	R3, #0C0h
		MOV	R1, #0FFh
		LCALL	call_0b06
		CLR	FLASH_CS
		SETB	FLASH_CS
		MOV	R3, #014h
		MOV	R1, #0FFh
		LCALL	call_0b06
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FFh
		LCALL	call_0b79
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FFh
		LCALL	call_0b06
		MOV	A, #0FBh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FFh
		LCALL	call_0b06
		CLR	FLASH_CS
		SETB	FLASH_CS
jump_0c37:
		JB	FLASH_DOUT, jump_0c3c
		SJMP	jump_0c37
jump_0c3c:
		CLR	FLASH_CS
		SETB	FLASH_CS
		MOV	R3, #008h
		MOV	R1, #0FFh
		LCALL	call_0b06
		MOV	R3, #000h
		MOV	R1, #0FFh
		LCALL	call_0b06
		CLR	FLASH_CS
		SETB	EA
		LJMP	jump_0a19

call_0c55:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		CLR	EA
		SETB	FLASH_CS
		MOV	R3, #008h
		MOV	R1, #0FFh
		LCALL	call_0b06
		MOV	R3, #000h
		MOV	R1, #0FFh
		LCALL	call_0b06
		CLR	FLASH_CS
		SETB	EA
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;;;;;;

call_0c74:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		CLR	ES0
		MOV	R3, #052h
		MOV	S0CON, R3
		MOV	R3, TMOD
		MOV	AR5, R3
		MOV	R3, #020h
		MOV	A, R3
		ORL	A, R5
		MOV	R3, A
		MOV	TMOD, R3
		MOV	R3, #080h
		MOV	PCON, R3
		MOV	R3, #0FDh
		MOV	TH1, R3
		SETB	TR1
		SETB	PS0
		SETB	ES0
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;;;;;;;;

call_0c9c:
		MOV	DPTR, #0201h
		LCALL	call_09e0
		MOV	A, #0FBh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #007h
		LCALL	call_06d3
		MOV	R1, #0FFh
		LCALL	call_0126
		MOV	R3, #000h
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
jump_0cbf:
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #019h
		LCALL	call_0530
		JZ	jump_0cdf
		MOV	R1, #000h
		LCALL	call_0091
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_0643
		DB	001h
		SJMP	jump_0cbf
jump_0cdf:
		MOV	A, #0FBh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #07Fh
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	R1, #0FFh
		LCALL	call_0126
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; not found any reference to this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noref_0cf6:
		DW	09002h, 00212h, 009E0h, 07B00h, 074FCh, 02581h, 0F9EBh, 0F77Bh
		DW	00074h, 0FD25h, 081F9h, 0EBF7h, 07900h, 01200h, 0917Bh, 00074h
		DW	0FD25h, 081F9h, 0EBF7h, 074FDh, 02581h, 0F9E7h, 0FD7Bh, 00A12h
		DW	00530h, 0600Dh, 074FDh, 02581h, 0FB7Ah, 00012h, 00643h, 00180h
		DW	0E574h, 0FA25h, 081F9h, 0E7FCh, 009E7h, 0FD7Bh, 00712h, 006D3h
		DW	074FCh, 02581h, 0F9EBh, 0F774h, 0FC25h, 081F9h, 0E7FBh, 079FFh
		DW	01201h, 0267Bh, 00074h, 0FD25h, 081F9h, 0EBF7h, 074FDh, 02581h
		DW	0F9E7h, 0FD7Bh, 00A12h, 00530h, 0600Dh, 074FDh, 02581h, 0FB7Ah
		DW	00012h, 00643h, 00180h, 0E574h, 0FA25h, 081F9h, 0E7FCh, 009E7h
		DW	0FD7Bh, 07FEBh, 05DFBh, 074FCh, 02581h, 0F9EBh, 0F774h, 0FC25h
		DW	081F9h, 0E7FBh, 079FFh, 01201h, 0267Bh, 00074h, 0FD25h, 081F9h
		DW	0EBF7h, 074FDh, 02581h, 0F9E7h, 0FD7Bh, 01912h, 00530h, 0600Dh
		DW	074FDh, 02581h, 0FB7Ah, 00012h, 00643h, 00180h, 0E502h, 00A19h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



; Here is the SIO interrupt procedure
SIO_SUBCALL:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		JBC	RI, jump_0dd2
		LJMP	jump_0f86
jump_0dd2:
		MOV	R1, #000h
		LCALL	call_0112
		MOV	R1, #048h
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_0926
		DW	jump_0e2a
		DB	001h
		DW	jump_0e39
		DB	002h
		DW	jump_0e48
		DB	003h
		DW	jump_0e57
		DB	004h
		DW	jump_0e66
		DB	005h
		DW	jump_0e75
		DB	006h
		DW	jump_0e84
		DB	007h
		DW	jump_0e93
		DB	008h
		DW	jump_0ea2
		DB	009h
		DW	jump_0eb1
		DB	00Ah
		DW	jump_0ec0
		DB	00Bh
		DW	jump_0ecf
		DB	00Ch
		DW	jump_0ede
		DB	00Dh
		DW	jump_0eed
		DB	00Eh
		DW	jump_0efc
		DB	00Fh
		DW	jump_0f0b
		DB	010h
		DW	jump_0f19
		DB	011h
		DW	jump_0f27
		DB	012h
		DW	jump_0f35
		DB	013h
		DW	jump_0f43
		DB	014h
		DW	jump_0f50
		DB	015h
		DW	jump_0f5d
		DB	016h
		DW	jump_0f6b
		DB	017h
		DW	jump_0f79
		DB	0FAh
		DW	0000h
		DW	jump_0f84
;;	SIO: cmd number 01 
jump_0e2a:
		MOV	R1, #016h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number 2
jump_0e39:
		MOV	R1, #00Ch
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number 3
jump_0e48:
		MOV	R1, #010h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number 4
jump_0e57:
		MOV	R1, #012h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number 5
jump_0e66:
		MOV	R1, #014h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number 6
jump_0e75:
		MOV	R1, #018h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number 7
jump_0e84:
		MOV	R1, #00Eh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number 8
jump_0e93:
		MOV	R1, #01Ah
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number 9
jump_0ea2:
		MOV	R1, #01Ch
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number A
jump_0eb1:
		MOV	R1, #01Eh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number B
jump_0ec0:
		MOV	R1, #020h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number C
jump_0ecf:
		MOV	R1, #022h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number D
jump_0ede:
		MOV	R1, #024h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number E
jump_0eed:
		MOV	R1, #026h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number F
jump_0efc:
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		LJMP	jump_0f84
;;	SIO: cmd number 10
jump_0f0b:
		MOV	R1, #038h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		SJMP	jump_0f84
;;	SIO: cmd number 11
jump_0f19:
		MOV	R1, #032h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		SJMP	jump_0f84
;;	SIO: cmd number 12
jump_0f27:
		MOV	R1, #034h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		SJMP	jump_0f84
;;	SIO: cmd number 13
jump_0f35:
		MOV	R1, #03Bh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		SJMP	jump_0f84
;;	SIO: cmd number 14
jump_0f43:
		MOV	R1, #03Ah
		MOV	A, @R1
		MOV	R3, A
		MOV	R2, #000h
		MOV	R1, #0FEh
		LCALL	call_0c9c
		SJMP	jump_0f84
;;	SIO: cmd number 15
jump_0f50:
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R3, A
		MOV	R2, #000h
		MOV	R1, #0FEh
		LCALL	call_0c9c
		SJMP	jump_0f84
;;	SIO: cmd number 16
jump_0f5d:
		MOV	R1, #036h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		SJMP	jump_0f84
;;	SIO: cmd number 17
jump_0f6b:
		MOV	R1, #030h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FEh
		LCALL	call_0c9c
		SJMP	jump_0f84
;;	SIO: cmd number FA
jump_0f79:
		MOV	R3, #00Ah
		MOV	R2, #000h
		MOV	R1, #0FEh
		LCALL	call_0c9c
		SJMP	jump_0f84
;;	SIO: common ending for commands?
jump_0f84:
		SJMP	jump_0f88
jump_0f86:
		CLR	TI
jump_0f88:
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_0f8b:
		MOV	DPTR, #0102h
		LCALL	call_09e0
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	A, #0FBh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #008h
		MOV	A, R3
		ORL	A, R5
		MOV	R3, A
		MOV	ADCON, R3
jump_0fad:
		MOV	R3, ADCON
		MOV	R2, #000h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #010h
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JNZ	jump_0fc3
		SJMP	jump_0fad
jump_0fc3:
		MOV	R3, ADCh
		MOV	R2, #000h
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #002h
		LCALL	call_0711
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, ADCON
		MOV	R2, #000h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #003h
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		MOV	R2, A
		MOV	005h, R3
		MOV	004h, R2
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #000h
		MOV	ADCON, R3
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;;;;;;;;;;

call_102b:
		MOV	DPTR, #010Eh
		LCALL	call_09e0
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	A, #0F2h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	A, #0F4h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	A, #0F6h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		CLR	A
		MOV	R5, A
		MOV	R4, A
		MOV	R3, A
		MOV	R2, A
		LCALL	call_0813
		DB	0F8h
		MOV	R3, #002h
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
		MOV	R3, #000h
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	A, #0F2h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1092:
		MOV	A, #0F2h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #00Ah
		MOV	R2, #000h
		LCALL	call_0519
		JZ	jump_110a
		MOV	A, #0EFh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #0FFh
		LCALL	call_0f8b
		MOV	005h, R3
		MOV	004h, R2
		MOV	A, #0F6h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	A, #0F6h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	A, #0F4h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_10dd:
		MOV	A, #0F4h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #064h
		MOV	R2, #000h
		LCALL	call_0519
		JZ	jump_10fd
		MOV	A, #0F4h
		ADD	A, SP
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_0643
		DB	002h
		SJMP	jump_10dd
jump_10fd:
		MOV	A, #0F2h
		ADD	A, SP
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_0643
		DB	002h
		SJMP	jump_1092
jump_110a:
		MOV	A, #0F6h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #00Ah
		MOV	R2, #000h
		LCALL	call_084f
		MOV	A, #0F6h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	A, #0F6h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0E8h
		MOV	R2, #003h
		LCALL	call_0519
		PUSH	002h
		PUSH	003h
		MOV	A, #0F4h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #012h
		MOV	R2, #000h
		LCALL	call_04e3
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JNZ	jump_115a
		LJMP	jump_17a4
jump_115a:
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		JZ	jump_1165
		LJMP	jump_16d3
jump_1165:
		MOV	R1, #000h
		LCALL	call_0091
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_08e5
		DW	0000h
		DW	2600h
		DW	jump_1630
		DW	jump_11ca
		DW	jump_11e7
		DW	jump_1204
		DW	jump_1221
		DW	jump_123e
		DW	jump_125b
		DW	jump_1278
		DW	jump_1295
		DW	jump_12b2
		DW	jump_12cf
		DW	jump_12ec
		DW	jump_1309
		DW	jump_1326
		DW	jump_1343
		DW	jump_1360
		DW	jump_137d
		DW	jump_139a
		DW	jump_13b7
		DW	jump_13d4
		DW	jump_13f1
		DW	jump_140e
		DW	jump_142b
		DW	jump_1448
		DW	jump_1465
		DW	jump_1482
		DW	jump_149f
		DW	jump_14bc
		DW	jump_14d9
		DW	jump_14f6
		DW	jump_1513
		DW	jump_1530
		DW	jump_154d
		DW	jump_156a
		DW	jump_1587
		DW	jump_15a4
		DW	jump_15c0
		DW	jump_15dc
		DW	jump_15f8
		DW	jump_1614
jump_11ca:
		MOV	R3, #026h
		MOV	R2, #002h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0CDh
		MOV	R4, #04Ch
		MOV	R3, #01Ah
		MOV	R2, #043h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_11e7:
		MOV	R3, #058h
		MOV	R2, #002h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #066h
		MOV	R4, #066h
		MOV	R3, #0DFh
		MOV	R2, #042h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1204:
		MOV	R3, #08Ah
		MOV	R2, #002h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0A4h
		MOV	R4, #070h
		MOV	R3, #0A3h
		MOV	R2, #042h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1221:
		MOV	R3, #0BCh
		MOV	R2, #002h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #09Ah
		MOV	R4, #099h
		MOV	R3, #071h
		MOV	R2, #042h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_123e:
		MOV	R3, #0EEh
		MOV	R2, #002h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0AEh
		MOV	R4, #047h
		MOV	R3, #034h
		MOV	R2, #042h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_125b:
		MOV	R3, #020h
		MOV	R2, #003h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0CDh
		MOV	R4, #0CCh
		MOV	R3, #007h
		MOV	R2, #042h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1278:
		MOV	R3, #052h
		MOV	R2, #003h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #066h
		MOV	R4, #066h
		MOV	R3, #0CEh
		MOV	R2, #041h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1295:
		MOV	R3, #084h
		MOV	R2, #003h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0F6h
		MOV	R4, #028h
		MOV	R3, #09Eh
		MOV	R2, #041h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_12b2:
		MOV	R3, #0B6h
		MOV	R2, #003h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0E1h
		MOV	R4, #07Ah
		MOV	R3, #074h
		MOV	R2, #041h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_12cf:
		MOV	R3, #0E8h
		MOV	R2, #003h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #066h
		MOV	R4, #066h
		MOV	R3, #03Eh
		MOV	R2, #041h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_12ec:
		MOV	R3, #01Ah
		MOV	R2, #004h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #010h
		MOV	R4, #058h
		MOV	R3, #015h
		MOV	R2, #041h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1309:
		MOV	R3, #04Ch
		MOV	R2, #004h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0CFh
		MOV	R4, #0F7h
		MOV	R3, #0EBh
		MOV	R2, #040h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1326:
		MOV	R3, #07Eh
		MOV	R2, #004h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #00Ah
		MOV	R4, #0D7h
		MOV	R3, #0BBh
		MOV	R2, #040h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1343:
		MOV	R3, #0B0h
		MOV	R2, #004h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #066h
		MOV	R4, #066h
		MOV	R3, #096h
		MOV	R2, #040h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1360:
		MOV	R3, #0E2h
		MOV	R2, #004h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #098h
		MOV	R4, #06Eh
		MOV	R3, #072h
		MOV	R2, #040h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_137d:
		MOV	R3, #014h
		MOV	R2, #005h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0A6h
		MOV	R4, #09Bh
		MOV	R3, #044h
		MOV	R2, #040h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_139a:
		MOV	R3, #046h
		MOV	R2, #005h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #04Eh
		MOV	R4, #062h
		MOV	R3, #020h
		MOV	R2, #040h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_13b7:
		MOV	R3, #078h
		MOV	R2, #005h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #01Fh
		MOV	R4, #085h
		MOV	R3, #003h
		MOV	R2, #040h
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_13d4:
		MOV	R3, #0AAh
		MOV	R2, #005h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0C3h
		MOV	R4, #0F5h
		MOV	R3, #0D8h
		MOV	R2, #03Fh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_13f1:
		MOV	R3, #0DCh
		MOV	R2, #005h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #00Ah
		MOV	R4, #0D7h
		MOV	R3, #0B3h
		MOV	R2, #03Fh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_140e:
		MOV	R3, #00Eh
		MOV	R2, #006h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #08Fh
		MOV	R4, #0C2h
		MOV	R3, #095h
		MOV	R2, #03Fh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_142b:
		MOV	R3, #040h
		MOV	R2, #006h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #048h
		MOV	R4, #0E1h
		MOV	R3, #07Ah
		MOV	R2, #03Fh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1448:
		MOV	R3, #072h
		MOV	R2, #006h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #01Ch
		MOV	R4, #0EBh
		MOV	R3, #052h
		MOV	R2, #03Fh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1465:
		MOV	R3, #0A4h
		MOV	R2, #006h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #09Ch
		MOV	R4, #033h
		MOV	R3, #032h
		MOV	R2, #03Fh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1482:
		MOV	R3, #0D6h
		MOV	R2, #006h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0E7h
		MOV	R4, #01Dh
		MOV	R3, #017h
		MOV	R2, #03Fh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_149f:
		MOV	R3, #008h
		MOV	R2, #007h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #00Eh
		MOV	R4, #0BEh
		MOV	R3, #000h
		MOV	R2, #03Fh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_14bc:
		MOV	R3, #03Ah
		MOV	R2, #007h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #048h
		MOV	R4, #050h
		MOV	R3, #0DCh
		MOV	R2, #03Eh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_14d9:
		MOV	R3, #06Ch
		MOV	R2, #007h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #01Bh
		MOV	R4, #02Fh
		MOV	R3, #0BDh
		MOV	R2, #03Eh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_14f6:
		MOV	R3, #09Eh
		MOV	R2, #007h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #053h
		MOV	R4, #005h
		MOV	R3, #0A3h
		MOV	R2, #03Eh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1513:
		MOV	R3, #0D0h
		MOV	R2, #007h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #03Bh
		MOV	R4, #001h
		MOV	R3, #08Dh
		MOV	R2, #03Eh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1530:
		MOV	R3, #002h
		MOV	R2, #008h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #06Ah
		MOV	R4, #0BCh
		MOV	R3, #074h
		MOV	R2, #03Eh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_154d:
		MOV	R3, #034h
		MOV	R2, #008h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #061h
		MOV	R4, #032h
		MOV	R3, #055h
		MOV	R2, #03Eh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_156a:
		MOV	R3, #066h
		MOV	R2, #008h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0FEh
		MOV	R4, #043h
		MOV	R3, #03Ah
		MOV	R2, #03Eh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_1587:
		MOV	R3, #098h
		MOV	R2, #008h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0C1h
		MOV	R4, #039h
		MOV	R3, #023h
		MOV	R2, #03Eh
		LCALL	call_0813
		DB	0F8h
		LJMP	jump_1630
jump_15a4:
		MOV	R3, #0CAh
		MOV	R2, #008h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #097h
		MOV	R4, #090h
		MOV	R3, #00Fh
		MOV	R2, #03Eh
		LCALL	call_0813
		DB	0F8h
		SJMP	jump_1630
jump_15c0:
		MOV	R3, #0FCh
		MOV	R2, #008h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #0FFh
		MOV	R4, #021h
		MOV	R3, #0FDh
		MOV	R2, #03Dh
		LCALL	call_0813
		DB	0F8h
		SJMP	jump_1630
jump_15dc:
		MOV	R3, #02Eh
		MOV	R2, #009h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #040h
		MOV	R4, #0A4h
		MOV	R3, #0DFh
		MOV	R2, #03Dh
		LCALL	call_0813
		DB	0F8h
		SJMP	jump_1630
jump_15f8:
		MOV	R3, #060h
		MOV	R2, #009h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #082h
		MOV	R4, #073h
		MOV	R3, #0C6h
		MOV	R2, #03Dh
		LCALL	call_0813
		DB	0F8h
		SJMP	jump_1630
jump_1614:
		MOV	R3, #092h
		MOV	R2, #009h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #032h
		MOV	R4, #055h
		MOV	R3, #0B0h
		MOV	R2, #03Dh
		LCALL	call_0813
		DB	0F8h
		SJMP	jump_1630
jump_1630:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #0A0h
		MOV	R2, #040h
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		LCALL	call_07f3
		DB	0F4h
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		MOV	R5, #066h
		MOV	R4, #066h
		MOV	R3, #096h
		MOV	R2, #040h
		LCALL	call_0154
		LCALL	call_02b9
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		LCALL	call_07f3
		DB	0F4h
		LCALL	call_0214
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		MOV	R5, #052h
		MOV	R4, #027h
		MOV	R3, #0A0h
		MOV	R2, #03Bh
		LCALL	call_02b9
		LCALL	call_0376
		MOV	003h, R5
		MOV	002h, R4
		MOV	A, #0F4h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	A, #0F6h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	A, #0F4h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_0519
		JZ	jump_16c7
		MOV	A, #0F4h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, #0F2h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_0643
		DB	001h
		SJMP	jump_16d0
jump_16c7:
		MOV	R3, #001h
		MOV	A, #0FDh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R3
		MOV	@R1, A
jump_16d0:
		LJMP	jump_115a
jump_16d3:
		MOV	R5, #088h
		MOV	R4, #013h
		MOV	A, #0F2h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		PUSH	004h
		PUSH	005h
		MOV	005h, R3
		MOV	004h, R2
		MOV	A, #0F2h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		CLR	C
		MOV	A, R5
		SUBB	A, R3
		MOV	R3, A
		MOV	A, R4
		SUBB	A, R2
		MOV	R2, A
		POP	005h
		POP	004h
		LCALL	call_084f
		MOV	A, R2
		MOV	R4, A
		RLC	A
		CLR	A
		SUBB	A, ACC
		MOV	005h, R3
		MOV	R3, A
		MOV	R2, A
		LCALL	call_03cd
		LCALL	call_0813
		DB	0F8h
		MOV	A, #0F2h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	A, #0F6h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		CLR	C
		MOV	A, R5
		SUBB	A, R3
		MOV	R3, A
		MOV	A, R4
		SUBB	A, R2
		MOV	R2, A
		MOV	A, R2
		MOV	R4, A
		RLC	A
		CLR	A
		SUBB	A, ACC
		MOV	005h, R3
		MOV	R3, A
		MOV	R2, A
		LCALL	call_03cd
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		LCALL	call_07f3
		DB	0F4h
		LCALL	call_0214
		LCALL	call_0813
		DB	0F8h
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R2
		MOV	R4, A
		RLC	A
		CLR	A
		SUBB	A, ACC
		MOV	005h, R3
		MOV	R3, A
		MOV	R2, A
		LCALL	call_03cd
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		LCALL	call_07f3
		DB	0F4h
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #0C8h
		MOV	R2, #042h
		LCALL	call_02b9
		LCALL	call_0154
		LCALL	call_0376
		MOV	003h, R5
		MOV	002h, R4
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	A, #0F0h
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LJMP	jump_0a19
jump_17a4:
		MOV	R3, #000h
		MOV	R2, #000h
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_17ab:
		MOV	DPTR, #0004h
		LCALL	call_09e0
		CLR	A
		MOV	R5, A
		MOV	R4, A
		MOV	R3, A
		MOV	R2, A
		LCALL	call_0813
		DB	0FAh
		MOV	R1, #040h
		MOV	A, @R1
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_08e5
		DW	0000h
		DW	0700h
		DW	jump_1ed2
		DW	jump_17d9
		DW	jump_1811
		DW	jump_1ed2
		DW	jump_18cf
		DW	jump_1d10
		DW	jump_1d79
		DW	jump_1e37
		DW	jump_1e7e

jump_17d9:
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0f8b
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #0F4h
		MOV	R2, #001h
		LCALL	call_04e3
		JZ	jump_17fd
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
		SJMP	jump_180b
jump_17fd:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
jump_180b:
		MOV	R1, #040h
		INC	@R1
		LJMP	jump_1ed2
jump_1811:
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0f8b
		MOV	R1, #01Ah
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #01Ah
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #008h
		MOV	R2, #002h
		LCALL	call_04e3
		JZ	jump_1846
		MOV	R1, #01Ah
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #021h
		MOV	R2, #000h
		LCALL	call_084f
		MOV	R1, #01Ah
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_1869
jump_1846:
		MOV	R1, #01Ah
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #032h
		MOV	R2, #000h
		LCALL	call_084f
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #005h
		MOV	R2, #000h
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #01Ah
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1869:
		MOV	R1, #01Ah
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #01Eh
		MOV	R2, #000h
		LCALL	call_04e3
		JZ	jump_1884
		MOV	R3, #01Eh
		MOV	R2, #000h
		MOV	R1, #01Ah
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1884:
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0f8b
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #010h
		MOV	R2, #000h
		LCALL	call_084f
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #014h
		MOV	R2, #000h
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #01Ch
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #01Ch
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_04e3
		JZ	jump_18c6
		MOV	R3, #050h
		MOV	R2, #000h
		MOV	R1, #01Ch
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_18c6:
		MOV	R1, #040h
		INC	@R1
		MOV	R1, #040h
		INC	@R1
		LJMP	jump_1ed2
jump_18cf:
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R3, A
		PUSH	003h
		MOV	R5, #001h
		LCALL	call_0588
		POP	003h
		JZ	jump_18e1
		LJMP	jump_1a0a
jump_18e1:
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0f8b
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #004h
		MOV	R2, #000h
		LCALL	call_084f
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #01Ah
		MOV	R2, #004h
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #01Eh
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #01Eh
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #014h
		MOV	R2, #005h
		LCALL	call_04e3
		JZ	jump_1923
		MOV	R3, #014h
		MOV	R2, #005h
		MOV	R1, #01Eh
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1923:
		MOV	R1, #01Ah
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #002h
		MOV	R2, #000h
		LCALL	call_084f
		CLR	C
		CLR	A
		SUBB	A, R3
		MOV	R3, A
		CLR	A
		SUBB	A, R2
		MOV	R2, A
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #01Eh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #020h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #01Ah
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #004h
		MOV	R2, #000h
		LCALL	call_084f
		CLR	C
		CLR	A
		SUBB	A, R3
		MOV	R3, A
		CLR	A
		SUBB	A, R2
		MOV	R2, A
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #01Eh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #022h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #01Ah
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #002h
		MOV	R2, #000h
		LCALL	call_084f
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #01Eh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #024h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #01Ah
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #008h
		MOV	R2, #000h
		LCALL	call_084f
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #01Eh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #026h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 040h, 006h
		PUSH	002h
		PUSH	003h
		MOV	R1, #026h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0BEh
		MOV	R2, #005h
		LCALL	call_04e3
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_1a07
		MOV	R3, #0BEh
		MOV	R2, #005h
		MOV	R1, #026h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #0B4h
		MOV	R2, #005h
		MOV	R1, #022h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1a07:
		LJMP	jump_1d0a
jump_1a0a:
		PUSH	003h
		MOV	R5, #002h
		LCALL	call_0588
		POP	003h
		JZ	jump_1a18
		LJMP	jump_1c7a
jump_1a18:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #048h
		MOV	R2, #044h
		LCALL	call_0813
		DB	0FAh
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0f8b
		MOV	A, R2
		MOV	R4, A
		RLC	A
		CLR	A
		SUBB	A, ACC
		MOV	005h, R3
		MOV	R3, A
		MOV	R2, A
		LCALL	call_03cd
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		LCALL	call_07f3
		DB	0F6h
		LCALL	call_0214
		LCALL	call_0813
		DB	0FAh
		LCALL	call_07f3
		DB	0FAh
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #07Fh
		MOV	R2, #044h
		LCALL	call_02b9
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		CLR	A
		MOV	R5, A
		MOV	R4, A
		MOV	R3, A
		MOV	R2, A
		LCALL	call_0154
		LCALL	call_0813
		DB	0FAh
		LCALL	call_07f3
		DB	0FAh
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #0FAh
		MOV	R2, #043h
		LCALL	call_02b9
		LCALL	call_0813
		DB	0FAh
		MOV	R1, #012h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0B0h
		MOV	R2, #004h
		LCALL	call_056c
		JZ	jump_1af2
		MOV	R5, #0B0h
		MOV	R4, #004h
		MOV	R1, #012h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		CLR	C
		MOV	A, R5
		SUBB	A, R3
		MOV	R3, A
		MOV	A, R4
		SUBB	A, R2
		MOV	R2, A
		MOV	A, R2
		MOV	R4, A
		RLC	A
		CLR	A
		SUBB	A, ACC
		MOV	005h, R3
		MOV	R3, A
		MOV	R2, A
		LCALL	call_03cd
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		LCALL	call_07f3
		DB	0F6h
		LCALL	call_0214
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #096h
		MOV	R2, #044h
		LCALL	call_0154
		LCALL	call_0376
		MOV	003h, R5
		MOV	002h, R4
		MOV	R1, #01Eh
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_1afd
jump_1af2:
		MOV	R3, #0B0h
		MOV	R2, #004h
		MOV	R1, #01Eh
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1afd:
		MOV	R1, #00Eh
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0E8h
		MOV	R2, #003h
		LCALL	call_056c
		JZ	jump_1b52
		MOV	R5, #0E8h
		MOV	R4, #003h
		MOV	R1, #00Eh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		CLR	C
		MOV	A, R5
		SUBB	A, R3
		MOV	R3, A
		MOV	A, R4
		SUBB	A, R2
		MOV	R2, A
		MOV	A, R2
		MOV	R4, A
		RLC	A
		CLR	A
		SUBB	A, ACC
		MOV	005h, R3
		MOV	R3, A
		MOV	R2, A
		LCALL	call_03cd
		LCALL	call_0813
		DB	0FAh
		LCALL	call_07f3
		DB	0FAh
		LCALL	call_0376
		MOV	003h, R5
		MOV	002h, R4
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #01Eh
		MOV	R2, #000h
		MOV	001h, R3
		INC	R1
		MOV	A, @R1
		CLR	C
		SUBB	A, R5
		MOV	R3, A
		MOV	@R1, A
		DEC	R1
		MOV	A, @R1
		SUBB	A, R4
		MOV	@R1, A
		MOV	R2, A
		SJMP	jump_1b93
jump_1b52:
		MOV	R1, #00Eh
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #018h
		MOV	R2, #0FCh
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	A, R2
		MOV	R4, A
		RLC	A
		CLR	A
		SUBB	A, ACC
		MOV	005h, R3
		MOV	R3, A
		MOV	R2, A
		LCALL	call_03cd
		LCALL	call_0813
		DB	0FAh
		LCALL	call_07f3
		DB	0FAh
		LCALL	call_0376
		MOV	003h, R5
		MOV	002h, R4
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #01Eh
		MOV	R2, #000h
		MOV	001h, R3
		INC	R1
		MOV	A, @R1
		ADD	A, R5
		MOV	R3, A
		MOV	@R1, A
		DEC	R1
		MOV	A, @R1
		ADDC	A, R4
		MOV	@R1, A
		MOV	R2, A
jump_1b93:
		MOV	R1, #01Ch
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #002h
		MOV	R2, #000h
		LCALL	call_084f
		CLR	C
		CLR	A
		SUBB	A, R3
		MOV	R3, A
		CLR	A
		SUBB	A, R2
		MOV	R2, A
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #01Eh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #020h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #01Ch
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #004h
		MOV	R2, #000h
		LCALL	call_084f
		CLR	C
		CLR	A
		SUBB	A, R3
		MOV	R3, A
		CLR	A
		SUBB	A, R2
		MOV	R2, A
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #01Eh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #022h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #01Ch
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #002h
		MOV	R2, #000h
		LCALL	call_084f
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #01Eh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #024h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #01Ch
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #008h
		MOV	R2, #000h
		LCALL	call_084f
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #01Eh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #026h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 040h, 006h
		PUSH	002h
		PUSH	003h
		MOV	R1, #026h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0BEh
		MOV	R2, #005h
		LCALL	call_04e3
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_1c77
		MOV	R3, #0BEh
		MOV	R2, #005h
		MOV	R1, #026h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #0B4h
		MOV	R2, #005h
		MOV	R1, #022h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1c77:
		LJMP	jump_1d0a
jump_1c7a:
		MOV	R5, #003h
		LCALL	call_0588
		JZ	jump_1c84
		LJMP	jump_1d0a
jump_1c84:
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0f8b
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #00Ah
		MOV	R2, #000h
		LCALL	call_084f
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #064h
		MOV	R2, #005h
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #024h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #024h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0C8h
		MOV	R2, #005h
		LCALL	call_04e3
		JZ	jump_1cc6
		MOV	R3, #0C8h
		MOV	R2, #005h
		MOV	R1, #024h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1cc6:
		MOV	R1, #024h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0ECh
		MOV	R2, #0FFh
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #026h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #024h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0CEh
		MOV	R2, #0FFh
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #020h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #022h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	R1, #01Eh
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_1d0a
jump_1d0a:
		MOV	R1, #040h
		INC	@R1
		LJMP	jump_1ed2
jump_1d10:
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0f8b
		MOV	A, R2
		MOV	R4, A
		RLC	A
		CLR	A
		SUBB	A, ACC
		MOV	005h, R3
		MOV	R3, A
		MOV	R2, A
		LCALL	call_03cd
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		MOV	R5, #033h
		MOV	R4, #033h
		MOV	R3, #0CBh
		MOV	R2, #040h
		LCALL	call_02b9
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #066h
		MOV	R2, #044h
		LCALL	call_0154
		LCALL	call_0376
		MOV	003h, R5
		MOV	002h, R4
		MOV	R1, #00Eh
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #00Eh
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #038h
		MOV	R2, #004h
		LCALL	call_04e3
		JZ	jump_1d73
		MOV	R3, #038h
		MOV	R2, #004h
		MOV	R1, #00Eh
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1d73:
		MOV	R1, #040h
		INC	@R1
		LJMP	jump_1ed2
jump_1d79:
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0f8b
		MOV	R1, #032h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #032h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #008h
		MOV	R2, #002h
		LCALL	call_04e3
		JZ	jump_1dce
		MOV	R1, #032h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R2
		MOV	R4, A
		RLC	A
		CLR	A
		SUBB	A, ACC
		MOV	005h, R3
		MOV	R3, A
		MOV	R2, A
		LCALL	call_03cd
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		MOV	R5, #0CDh
		MOV	R4, #0CCh
		MOV	R3, #004h
		MOV	R2, #041h
		LCALL	call_02b9
		LCALL	call_0376
		MOV	003h, R5
		MOV	002h, R4
		MOV	R1, #032h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_1e16
jump_1dce:
		MOV	R1, #032h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R2
		MOV	R4, A
		RLC	A
		CLR	A
		SUBB	A, ACC
		MOV	005h, R3
		MOV	R3, A
		MOV	R2, A
		LCALL	call_03cd
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		MOV	R5, #033h
		MOV	R4, #033h
		MOV	R3, #01Bh
		MOV	R2, #041h
		LCALL	call_02b9
		PUSH	002h
		PUSH	003h
		PUSH	004h
		PUSH	005h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #020h
		MOV	R2, #041h
		LCALL	call_0154
		LCALL	call_0376
		MOV	003h, R5
		MOV	002h, R4
		MOV	R1, #032h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1e16:
		MOV	R1, #032h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #078h
		MOV	R2, #000h
		LCALL	call_04e3
		JZ	jump_1e31
		MOV	R3, #078h
		MOV	R2, #000h
		MOV	R1, #032h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1e31:
		MOV	R1, #040h
		INC	@R1
		LJMP	jump_1ed2
jump_1e37:
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0f8b
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #00Ah
		MOV	R2, #000h
		LCALL	call_084f
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #078h
		MOV	R2, #005h
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #018h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #018h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0DCh
		MOV	R2, #005h
		LCALL	call_04e3
		JZ	jump_1e79
		MOV	R3, #0DCh
		MOV	R2, #005h
		MOV	R1, #018h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1e79:
		MOV	R1, #040h
		INC	@R1
		SJMP	jump_1ed2
jump_1e7e:
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		JZ	jump_1ebf
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		JZ	jump_1ebd
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0f8b
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #012h
		MOV	R2, #000h
		LCALL	call_083a
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #0A0h
		MOV	R2, #005h
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		MOV	R1, #030h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1ebd:
		SJMP	jump_1eca
jump_1ebf:
		MOV	R3, #010h
		MOV	R2, #027h
		MOV	R1, #030h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_1eca:
		MOV	R3, #000h
		MOV	R1, #040h
		MOV	A, R3
		MOV	@R1, A
		SJMP	jump_1ed2
jump_1ed2:
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_1ed5:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		MOV	R1, #041h
		MOV	A, @R1
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_08e5
		DW	0100h
		DW	0900h
		DW	jump_1f71
		DW	jump_1efe
		DW	jump_1f0e
		DW	jump_1f15
		DW	jump_1f25
		DW	jump_1f2c
		DW	jump_1f3c
		DW	jump_1f43
		DW	jump_1f53
		DW	jump_1f5a
		DW	jump_1f6a

jump_1efe:
		MOV	R3, #000h
		MOV	R1, #0FFh
		LCALL	call_102b
		MOV	R1, #016h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_1f71
jump_1f0e:
		MOV	R1, #000h
		LCALL	call_17ab
		SJMP	jump_1f71
jump_1f15:
		MOV	R3, #004h
		MOV	R1, #0FFh
		LCALL	call_102b
		MOV	R1, #00Ch
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_1f71
jump_1f25:
		MOV	R1, #000h
		LCALL	call_17ab
		SJMP	jump_1f71
jump_1f2c:
		MOV	R3, #001h
		MOV	R1, #0FFh
		LCALL	call_102b
		MOV	R1, #014h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_1f71
jump_1f3c:
		MOV	R1, #000h
		LCALL	call_17ab
		SJMP	jump_1f71
jump_1f43:
		MOV	R3, #003h
		MOV	R1, #0FFh
		LCALL	call_102b
		MOV	R1, #012h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_1f71
jump_1f53:
		MOV	R1, #000h
		LCALL	call_17ab
		SJMP	jump_1f71
jump_1f5a:
		MOV	R3, #005h
		MOV	R1, #0FFh
		LCALL	call_102b
		MOV	R1, #010h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_1f71
jump_1f6a:
		MOV	R1, #000h
		LCALL	call_17ab
		SJMP	jump_1f71
jump_1f71:
		MOV	R1, #041h
		INC	@R1
		MOV	R1, #041h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #00Ah
		LCALL	call_04fe
		JZ	jump_1f85
		MOV	R3, #001h
		MOV	R1, #041h
		MOV	A, R3
		MOV	@R1, A
jump_1f85:
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;

call_1f88:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	008h, 000h, 00Bh
		JNZ	jump_1f9d
		LJMP	jump_2126
jump_1f9d:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	006h, 000h, 040h
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
		MOV	R1, #053h
		MOV	A, @R1
		JZ	jump_1ff9
		LJMP	jump_2123
jump_1ff9:
		MOV	R3, #00Ah
		MOV	R1, #053h
		MOV	A, R3
		MOV	@R1, A
		MOV	R1, #02Dh
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_200b
		MOV	A, #0FFh
jump_200b:
		INC	A
		JZ	jump_203a
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		JZ	jump_202a
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
		SJMP	jump_2038
jump_202a:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
jump_2038:
		SJMP	jump_2048
jump_203a:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
jump_2048:
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_2054
		MOV	A, #0FFh
jump_2054:
		INC	A
		JZ	jump_2083
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	004h, 000h, 00Ah
		JZ	jump_2073
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ah, 004h, 000h
		SJMP	jump_2081
jump_2073:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ah, 004h, 000h
jump_2081:
		SJMP	jump_2091
jump_2083:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ah, 004h, 000h
jump_2091:
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #002h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_209d
		MOV	A, #0FFh
jump_209d:
		INC	A
		JZ	jump_20cc
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 080h, 007h
		JZ	jump_20bc
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
		SJMP	jump_20ca
jump_20bc:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
jump_20ca:
		SJMP	jump_20da
jump_20cc:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
jump_20da:
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #003h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_20e6
		MOV	A, #0FFh
jump_20e6:
		INC	A
		JZ	jump_2115
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	002h, 000h, 009h
		JZ	jump_2105
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	009h, 002h, 000h
		SJMP	jump_2113
jump_2105:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	009h, 002h, 000h
jump_2113:
		SJMP	jump_2123
jump_2115:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	009h, 002h, 000h
jump_2123:
		LJMP	jump_2440
jump_2126:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 001h, 000h
		JZ	jump_2142
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
		SJMP	jump_2150
jump_2142:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
jump_2150:
		MOV	R1, #053h
		MOV	A, @R1
		JZ	jump_2158
		LJMP	jump_22e5
jump_2158:
		MOV	R3, #00Ah
		MOV	R1, #053h
		MOV	A, R3
		MOV	@R1, A
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 080h, 007h
		MOV	AR5, R3
		MOV	AR4, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	001h, 000h, 008h
		MOV	A, R3
		ORL	A, R5
		MOV	R3, A
		MOV	A, R2
		ORL	A, R4
		MOV	R2, A
		PUSH	AR2
		PUSH	AR3
		MOV	R1, #038h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		MOV	R2, #000h
		LCALL	call_04e3
		POP	AR5
		POP	AR4
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		MOV	R2, A
		MOV	AR5, R3
		MOV	AR4, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	004h, 000h, 00Ah
		MOV	A, R3
		ORL	A, R2
		JZ	jump_21ac
		MOV	A, #0FFh
jump_21ac:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_21e4
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		JZ	jump_21d4
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		SJMP	jump_21e2
jump_21d4:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
jump_21e2:
		SJMP	jump_2221
jump_21e4:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #001h
		MOV	R2, #000h
		MOV	A, R5
		XRL	A, R3
		JNZ	jump_21fc
		MOV	A, R4
		XRL	A, R2
jump_21fc:
		JZ	jump_2200
		MOV	A, #0FFh
jump_2200:
		INC	A
		JZ	jump_2213
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		SJMP	jump_2221
jump_2213:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
jump_2221:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	080h, 000h, 00Fh
		JZ	jump_2259
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	001h, 000h, 008h
		JZ	jump_2249
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
		SJMP	jump_2257
jump_2249:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
jump_2257:
		SJMP	jump_2283
jump_2259:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	040h, 000h, 00Eh
		JZ	jump_2275
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
		SJMP	jump_2283
jump_2275:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
jump_2283:
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		JZ	jump_22bb
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		JZ	jump_22ab
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
		SJMP	jump_22b9
jump_22ab:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
jump_22b9:
		SJMP	jump_22e5
jump_22bb:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	002h, 000h, 009h
		JZ	jump_22d7
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
		SJMP	jump_22e5
jump_22d7:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
jump_22e5:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 001h, 000h
		JZ	jump_2301
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
		SJMP	jump_230f
jump_2301:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
jump_230f:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 040h, 006h
		JZ	jump_232b
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
		SJMP	jump_2339
jump_232b:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
jump_2339:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	010h, 000h, 00Ch
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		MOV	A, R3
		ORL	A, R2
		JZ	jump_2357
		MOV	A, #0FFh
jump_2357:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		MOV	R2, A
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #02Fh
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		JZ	jump_236e
		MOV	A, #0FFh
jump_236e:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_238a
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
		SJMP	jump_2398
jump_238a:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
jump_2398:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	020h, 000h, 00Dh
		JZ	jump_23b4
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ah, 004h, 000h
		SJMP	jump_23c2
jump_23b4:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ah, 004h, 000h
jump_23c2:
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 001h, 000h
		JZ	jump_23de
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	006h, 000h, 040h
		SJMP	jump_23ec
jump_23de:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	006h, 000h, 040h
jump_23ec:
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		JZ	jump_2408
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
		SJMP	jump_2416
jump_2408:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
jump_2416:
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 004h, 002h
		JZ	jump_2432
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	009h, 002h, 000h
		SJMP	jump_2440
jump_2432:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	009h, 002h, 000h
jump_2440:
		LJMP	jump_0a19


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_2443:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		MOV	R1, #000h
		LCALL	call_1f88
		CLR	PANEL_PL
		JNB	PANEL_DOUT, jump_2463
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
		SJMP	jump_2471
jump_2463:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
jump_2471:
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 080h, 007h
		JZ	jump_2481
		SETB	PANEL_DIN
		SJMP	jump_2483
jump_2481:
		CLR	PANEL_DIN
jump_2483:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		JNB	PANEL_DOUT, jump_249a
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
		SJMP	jump_24a8
jump_249a:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
jump_24a8:
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	004h, 000h, 00Ah
		JZ	jump_24b8
		SETB	PANEL_DIN
		SJMP	jump_24ba
jump_24b8:
		CLR	PANEL_DIN
jump_24ba:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		JNB	PANEL_DOUT, jump_24d1
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
		SJMP	jump_24df
jump_24d1:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
jump_24df:
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		JZ	jump_24ef
		SETB	PANEL_DIN
		SJMP	jump_24f1
jump_24ef:
		CLR	PANEL_DIN
jump_24f1:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		JNB	PANEL_DOUT, jump_2508
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		SJMP	jump_2516
jump_2508:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
jump_2516:
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 008h, 003h
		JZ	jump_2526
		SETB	PANEL_DIN
		SJMP	jump_2528
jump_2526:
		CLR	PANEL_DIN
jump_2528:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		JNB	PANEL_DOUT, jump_253f
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
		SJMP	jump_254d
jump_253f:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
jump_254d:
		CLR	PANEL_DIN
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		JNB	PANEL_DOUT, jump_2566
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
		SJMP	jump_2574
jump_2566:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
jump_2574:
		MOV	R1, #040h
		MOV	A, @R1
		MOV	R5, A
		MOV	R4, #000h
		MOV	R3, #004h
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_258a
		SETB	PANEL_DIN
		SJMP	jump_258c
jump_258a:
		CLR	PANEL_DIN
jump_258c:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		JNB	PANEL_DOUT, jump_25a3
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	006h, 000h, 040h
		SJMP	jump_25b1
jump_25a3:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_075a
		DB	006h, 000h, 040h
jump_25b1:
		MOV	R1, #040h
		MOV	A, @R1
		MOV	R5, A
		MOV	R4, #000h
		MOV	R3, #002h
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_25c7
		SETB	PANEL_DIN
		SJMP	jump_25c9
jump_25c7:
		CLR	PANEL_DIN
jump_25c9:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		JB	PANEL_DOUT, jump_25d5
		MOV	R1, #045h
		INC	@R1
		SJMP	jump_25db
jump_25d5:
		MOV	R3, #000h
		MOV	R1, #045h
		MOV	A, R3
		MOV	@R1, A
jump_25db:
		MOV	R1, #040h
		MOV	A, @R1
		MOV	R5, A
		MOV	R4, #000h
		MOV	R3, #001h
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_25f1
		SETB	PANEL_DIN
		SJMP	jump_25f3
jump_25f1:
		CLR	PANEL_DIN
jump_25f3:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		JZ	jump_2607
		SETB	PANEL_DIN
		SJMP	jump_2609
jump_2607:
		CLR	PANEL_DIN
jump_2609:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		JZ	jump_261d
		SETB	PANEL_DIN
		SJMP	jump_261f
jump_261d:
		CLR	PANEL_DIN
jump_261f:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 001h, 000h
		JZ	jump_2633
		SETB	PANEL_DIN
		SJMP	jump_2635
jump_2633:
		CLR	PANEL_DIN
jump_2635:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		CLR	PANEL_DIN
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 040h, 006h
		JZ	jump_264f
		SETB	PANEL_DIN
		SJMP	jump_2651
jump_264f:
		CLR	PANEL_DIN
jump_2651:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	001h, 000h, 008h
		JZ	jump_2665
		SETB	PANEL_DIN
		SJMP	jump_2667
jump_2665:
		CLR	PANEL_DIN
jump_2667:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	002h, 000h, 009h
		JZ	jump_267b
		SETB	PANEL_DIN
		SJMP	jump_267d
jump_267b:
		CLR	PANEL_DIN
jump_267d:
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		CLR	PANEL_DIN
		SETB	PANEL_CLK
		CLR	PANEL_CLK
		CLR	PANEL_STROBE
		SETB	PANEL_STROBE
		SETB	PANEL_PL
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_2690:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		SETB	EA
		SETB	ET0
		MOV	R3, #001h
		MOV	TMOD, R3
		CLR	TR0
		MOV	R3, #04Ch
		MOV	TH0, R3
		MOV	R3, #00Bh
		MOV	TL0, R3
		SETB	TR0
		MOV	R1, #000h
		LCALL	call_0c74
		MOV	R1, #000h
		LCALL	call_0c55
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

call_26b7:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		SETB	CMPRSR_RLY
		SETB	WW_RLY
		CLR	EXT_RLY
		SETB	H_PUMP_RLY
		SETB	C_PUMP_RLY
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	R1, #03Bh
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	R1, #034h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #00Ah
		MOV	R1, #053h
		MOV	A, R3
		MOV	@R1, A
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 00, 004h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	006h, 000h, 040h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	009h, 002h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ah, 004h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ch, 010h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Dh, 020h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Eh, 040h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Fh, 080h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	006h, 000h, 040h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	009h, 002h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ah, 004h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
		LJMP	jump_0a19




; Here is the TMR0 interrupt procedure
TMR0_SUBCALL:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		CLR	ET0
		MOV	R3, #04Ch
		MOV	TH0, R3
		MOV	R3, #00Bh
		MOV	TL0, R3
		SETB	ET0
		SETB	TR0
		MOV	R3, #00Ah
		MOV	R1, #046h
		MOV	A, R3
		MOV	@R1, A
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 001h, 00
		JNZ	jump_28cf
		LJMP	jump_296f
jump_28cf:
		MOV	R1, #043h
		INC	@R1
		MOV	R1, #043h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #003h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_28de
		MOV	A, #0FFh
jump_28de:
		INC	A
		JZ	jump_28fc
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 001h, 000h
		JZ	jump_28fc
		MOV	R3, #000h
		PUSH	003h
		MOV	R3, #000h
		PUSH	003h
		MOV	R3, #004h
		MOV	R1, #0FDh
		LCALL	call_0bec
jump_28fc:
		MOV	R1, #043h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #005h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_2908
		MOV	A, #0FFh
jump_2908:
		INC	A
		JZ	jump_296d
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 001h, 000h
		JZ	jump_2936
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
		MOV	R3, #000h
		PUSH	003h
		MOV	R3, #000h
		PUSH	003h
		MOV	R3, #006h
		MOV	R1, #0FDh
		LCALL	call_0bec
		SJMP	jump_296d
jump_2936:
		MOV	R3, #084h
		MOV	R2, #003h
		MOV	R1, #038h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
		MOV	R3, #001h
		PUSH	003h
		MOV	R3, #000h
		PUSH	003h
		MOV	R3, #004h
		MOV	R1, #0FDh
		LCALL	call_0bec
		MOV	R3, #001h
		PUSH	003h
		MOV	R3, #000h
		PUSH	003h
		MOV	R3, #006h
		MOV	R1, #0FDh
		LCALL	call_0bec
jump_296d:
		SJMP	jump_2975
jump_296f:
		MOV	R3, #000h
		MOV	R1, #043h
		MOV	A, R3
		MOV	@R1, A
jump_2975:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 001h, 000h
		JNZ	jump_2984
		LJMP	jump_2bf5
jump_2984:
		MOV	R1, #03Eh
		INC	@R1
		MOV	R1, #03Eh
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #014h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_2993
		MOV	A, #0FFh
jump_2993:
		INC	A
		JNZ	jump_2999
		LJMP	jump_2aae
jump_2999:
		MOV	R3, #000h
		MOV	R1, #03Eh
		MOV	A, R3
		MOV	@R1, A
		MOV	R1, #03Fh
		INC	@R1
		MOV	R1, #038h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		MOV	R2, #000h
		LCALL	call_04e3
		JZ	jump_29ba
		MOV	R3, #038h
		MOV	R2, #000h
		LCALL	call_0649
		DB	002h
jump_29ba:
		MOV	R1, #02Fh
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		LCALL	call_04fe
		JZ	jump_29c8
		MOV	R1, #02Fh
		DEC	@R1
jump_29c8:
		MOV	R1, #02Eh
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		LCALL	call_04fe
		JZ	jump_29d6
		MOV	R1, #02Eh
		DEC	@R1
jump_29d6:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	008h, 000h, 00Bh
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 004h, 002h
		MOV	A, R3
		ORL	A, R5
		MOV	R3, A
		MOV	A, R2
		ORL	A, R4
		ORL	A, R3
		JZ	jump_2a0e
		MOV	R1, #03Bh
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		MOV	R2, #000h
		LCALL	call_04e3
		JZ	jump_2a0e
		MOV	R3, #03Bh
		MOV	R2, #000h
		LCALL	call_0649
		DB	002h
jump_2a0e:
		MOV	R1, #034h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		MOV	R2, #000h
		LCALL	call_04e3
		JZ	jump_2a26
		MOV	R3, #034h
		MOV	R2, #000h
		LCALL	call_0649
		DB	002h
jump_2a26:
		MOV	R1, #036h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		MOV	R2, #000h
		LCALL	call_04e3
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	001h, 000h, 008h
		MOV	A, R3
		ORL	A, R2
		JZ	jump_2a48
		MOV	A, #0FFh
jump_2a48:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_2a5c
		MOV	R3, #036h
		MOV	R2, #000h
		LCALL	call_0649
		DB	002h
jump_2a5c:
		MOV	R1, #03Dh
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		LCALL	call_04fe
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_2a7e
		MOV	R1, #03Dh
		DEC	@R1
jump_2a7e:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	001h, 000h, 008h
		MOV	A, R3
		ORL	A, R2
		JZ	jump_2a8e
		MOV	A, #0FFh
jump_2a8e:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		PUSH	002h
		PUSH	003h
		MOV	R1, #03Ah
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		LCALL	call_04fe
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_2aae
		MOV	R1, #03Ah
		DEC	@R1
jump_2aae:
		MOV	R1, #03Fh
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #03Ch
		MOV	A, R5
		XRL	A, R3
		JZ	jump_2aba
		MOV	A, #0FFh
jump_2aba:
		INC	A
		JZ	jump_2ae9
		MOV	R3, #000h
		MOV	R1, #03Fh
		MOV	A, R3
		MOV	@R1, A
		MOV	R1, #030h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		MOV	R2, #000h
		LCALL	call_04e3
		JZ	jump_2adb
		MOV	R3, #030h
		MOV	R2, #000h
		LCALL	call_0649
		DB	002h
jump_2adb:
		MOV	R1, #052h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		LCALL	call_04fe
		JZ	jump_2ae9
		MOV	R1, #052h
		DEC	@R1
jump_2ae9:
		MOV	R1, #053h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		LCALL	call_04fe
		JZ	jump_2af7
		MOV	R1, #053h
		DEC	@R1
jump_2af7:
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 004h, 002h
		JZ	jump_2b0e
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	R1, #038h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_2b0e:
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		JNZ	jump_2b1d
		LJMP	jump_2bef
jump_2b1d:
		MOV	R1, #044h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #03Ch
		LCALL	call_0530
		JZ	jump_2b2b
		MOV	R1, #044h
		INC	@R1
jump_2b2b:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	008h, 000h, 00Bh
		JNZ	jump_2b3a
		LJMP	jump_2bed
jump_2b3a:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	020h, 000h, 00Dh
		JZ	jump_2b7f
		MOV	R1, #010h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #09Eh
		MOV	R2, #007h
		LCALL	call_056c
		JZ	jump_2b7d
		MOV	R3, #084h
		MOV	R2, #003h
		MOV	R1, #038h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Dh, 020h, 000h
jump_2b7d:
		SJMP	jump_2bed
jump_2b7f:
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 001h, 000h
		JZ	jump_2bba
		JB	PANEL_DIN, jump_2bb8
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	006h, 000h, 040h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
jump_2bb8:
		SJMP	jump_2bed
jump_2bba:
		MOV	R3, #084h
		MOV	R2, #003h
		MOV	R1, #038h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	040h, 000h, 00Eh
		JZ	jump_2bed
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Fh, 080h, 000h
jump_2bed:
		SJMP	jump_2bf5
jump_2bef:
		MOV	R3, #000h
		MOV	R1, #044h
		MOV	A, R3
		MOV	@R1, A
jump_2bf5:
		MOV	R1, #000h
		LCALL	call_2443
		LJMP	jump_0a19

;;;;;;;;;;;;;
call_2bfd:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		MOV	R1, #044h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #03Ch
		MOV	A, R5
		XRL	A, R3
		JZ	jump_2c0f
		MOV	A, #0FFh
jump_2c0f:
		INC	A
		JNZ	jump_2c15
		LJMP	jump_2c98
jump_2c15:
		MOV	R1, #014h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		MOV	R2, #000h
		LCALL	call_04e3
		JZ	jump_2c2d
		MOV	R3, #001h
		MOV	R1, #02Ch
		MOV	A, R3
		MOV	@R1, A
		SJMP	jump_2c4b
jump_2c2d:
		MOV	R1, #012h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		MOV	R2, #000h
		LCALL	call_04e3
		JZ	jump_2c45
		MOV	R3, #002h
		MOV	R1, #02Ch
		MOV	A, R3
		MOV	@R1, A
		SJMP	jump_2c4b
jump_2c45:
		MOV	R3, #003h
		MOV	R1, #02Ch
		MOV	A, R3
		MOV	@R1, A
jump_2c4b:
		MOV	R1, #016h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		MOV	R2, #000h
		LCALL	call_04e3
		PUSH	002h
		PUSH	003h
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #003h
		LCALL	call_0530
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_2c7a
		MOV	R3, #001h
		MOV	R1, #02Dh
		MOV	A, R3
		MOV	@R1, A
		SJMP	jump_2c80
jump_2c7a:
		MOV	R3, #000h
		MOV	R1, #02Dh
		MOV	A, R3
		MOV	@R1, A
jump_2c80:
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R3, A
		PUSH	003h
		MOV	R1, #02Dh
		MOV	A, @R1
		MOV	R3, A
		PUSH	003h
		MOV	R3, #002h
		MOV	R1, #0FDh
		LCALL	call_0bec
		MOV	R1, #044h
		INC	@R1
		SJMP	jump_2cc2
jump_2c98:
		MOV	R1, #044h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #03Ch
		LCALL	call_04fe
		JZ	jump_2cc2
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
		MOV	R1, #044h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #064h
		LCALL	call_04fe
		JZ	jump_2cc2
		MOV	R3, #064h
		MOV	R1, #044h
		MOV	A, R3
		MOV	@R1, A
jump_2cc2:
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;

call_2cc5:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		SETB	EXT_RLY
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	006h, 000h, 040h
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;

call_2cde:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		CLR	EXT_RLY
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	006h, 000h, 040h
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;

call_2cf7:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		JNZ	jump_2d49
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		JZ	jump_2d1c
		MOV	R1, #000h
		LCALL	call_2cc5
		SJMP	jump_2d49
jump_2d1c:
		MOV	R3, #03Ch
		MOV	R1, #03Dh
		MOV	A, R3
		MOV	@R1, A
		MOV	R1, #032h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #03Ch
		MOV	R2, #000h
		LCALL	call_083a
		MOV	R1, #034h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		CLR	C_PUMP_RLY
		CLR	CMPRSR_RLY
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
jump_2d49:
		CLR	H_PUMP_RLY
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;

call_2d4e:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		JZ	jump_2d9e
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		MOV	A, R3
		ORL	A, R2
		JZ	jump_2d7e
		MOV	A, #0FFh
jump_2d7e:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_2d91
		MOV	R1, #000h
		LCALL	call_2cde
		SJMP	jump_2d9e
jump_2d91:
		MOV	R3, #084h
		MOV	R2, #003h
		MOV	R1, #038h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SETB	CMPRSR_RLY
jump_2d9e:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		SETB	C_PUMP_RLY
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #02Eh
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		JZ	jump_2dc5
		MOV	A, #0FFh
jump_2dc5:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_2dd3
		SETB	H_PUMP_RLY
jump_2dd3:
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;

call_2dd6:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	009h, 002h, 000h
		CLR	WW_RLY
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;

call_2def:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	009h, 002h, 000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		JNZ	jump_2e11
		SETB	WW_RLY
jump_2e11:
		LJMP	jump_0a19

;;;;;;;;;;;;;;;;;

call_2e14:
		MOV	DPTR, #0002h
		LCALL	call_09e0
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	010h, 000h, 00Ch
		JNZ	jump_2e6e
		MOV	R1, #00Ch
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0D2h
		MOV	R2, #005h
		LCALL	call_0548
		JZ	jump_2e6c
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ch, 010h, 000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		JNZ	jump_2e6c
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
jump_2e6c:
		SJMP	jump_2e8c
jump_2e6e:
		MOV	R1, #00Ch
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0BEh
		MOV	R2, #005h
		LCALL	call_056c
		JZ	jump_2e8c
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ch, 010h, 000h
jump_2e8c:
		MOV	R1, #00Ch
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		ORL	A, R2
		JNZ	jump_2ea6
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
		LJMP	jump_2f50
jump_2ea6:
		MOV	R1, #010h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		ORL	A, R2
		JNZ	jump_2ec0
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
		LJMP	jump_2f50
jump_2ec0:
		MOV	R1, #012h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ORL	A, R2
		JZ	jump_2ecd
		MOV	A, #0FFh
jump_2ecd:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		PUSH	002h
		PUSH	003h
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #002h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_2ee1
		MOV	A, #0FFh
jump_2ee1:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_2f01
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
		SJMP	jump_2f50
jump_2f01:
		MOV	R1, #014h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ORL	A, R2
		JZ	jump_2f0e
		MOV	A, #0FFh
jump_2f0e:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		PUSH	002h
		PUSH	003h
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_2f22
		MOV	A, #0FFh
jump_2f22:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_2f42
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
		SJMP	jump_2f50
jump_2f42:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
jump_2f50:
		MOV	R1, #02Dh
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_2f5c
		MOV	A, #0FFh
jump_2f5c:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #016h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ORL	A, R2
		JZ	jump_2f71
		MOV	A, #0FFh
jump_2f71:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_2f8b
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
jump_2f8b:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	008h, 000h, 00Bh
		JZ	jump_2f9a
		LJMP	jump_3121
jump_2f9a:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Eh, 040h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Dh, 020h, 000h
		MOV	R3, #000h
		JNB	PRESSO_L_SW, jump_2fd8
		INC	R3
jump_2fd8:
		MOV	A, R3
		JZ	jump_2fdd
		MOV	A, #0FFh
jump_2fdd:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #03Dh
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		JZ	jump_2fee
		MOV	A, #0FFh
jump_2fee:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_3016
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
jump_3016:
		JB	PRESSO_H_SW, jump_3035
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
jump_3035:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		JNZ	jump_3044
		LJMP	jump_30f5
jump_3044:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Fh, 080h, 000h
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		JZ	jump_3061
		LJMP	jump_30e7
jump_3061:
		MOV	R3, #000h
		JNB	CMPRSR_CHK, jump_3067
		INC	R3
jump_3067:
		MOV	A, R3
		JZ	jump_306c
		MOV	A, #0FFh
jump_306c:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		PUSH	002h
		PUSH	003h
		MOV	A, #0FAh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0E8h
		MOV	R2, #003h
		LCALL	call_0519
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_309e
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R3, A
		MOV	R2, #000h
		LCALL	call_0643
		DB	002h
		SJMP	jump_3061
jump_309e:
		MOV	A, #0FCh
		ADD	A, SP
		MOV	R1, A
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0E8h
		MOV	R2, #003h
		MOV	A, R5
		XRL	A, R3
		JNZ	jump_30b2
		MOV	A, R4
		XRL	A, R2
jump_30b2:
		JZ	jump_30b6
		MOV	A, #0FFh
jump_30b6:
		INC	A
		JZ	jump_30d7
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Eh, 040h, 000h
		SJMP	jump_30e5
jump_30d7:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Eh, 040h, 000h
jump_30e5:
		SJMP	jump_30f5
jump_30e7:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Eh, 040h, 000h
jump_30f5:
		MOV	R1, #010h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #066h
		MOV	R2, #008h
		LCALL	call_0548
		JZ	jump_3121
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Dh, 020h, 000h
jump_3121:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	008h, 000h, 00Bh
		MOV	A, R3
		ORL	A, R2
		JZ	jump_3131
		MOV	A, #0FFh
jump_3131:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 004h, 002h
		MOV	A, R3
		ORL	A, R2
		JZ	jump_3149
		MOV	A, #0FFh
jump_3149:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		MOV	R2, A
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	010h, 000h, 00Ch
		MOV	A, R3
		ORL	A, R2
		JZ	jump_3167
		MOV	A, #0FFh
jump_3167:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		MOV	R2, A
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	004h, 000h, 00Ah
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_31a0
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ah, 004h, 000h
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	R1, #03Bh
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_31a0:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	008h, 000h, 00Bh
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	010h, 000h, 00Ch
		MOV	A, R3
		ORL	A, R5
		MOV	R3, A
		MOV	A, R2
		ORL	A, R4
		MOV	R2, A
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 004h, 002h
		MOV	A, R3
		ORL	A, R5
		MOV	R3, A
		MOV	A, R2
		ORL	A, R4
		MOV	R2, A
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	004h, 000h, 00Ah
		MOV	A, R3
		ORL	A, R2
		JZ	jump_31e6
		MOV	A, #0FFh
jump_31e6:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_3210
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Ah, 004h, 000h
		MOV	R3, #010h
		MOV	R2, #00Eh
		MOV	R1, #03Bh
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #000h
		LCALL	call_2d4e
jump_3210:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	004h, 000h, 00Ah
		LJMP	jump_0a19



;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;###############28/05/2021#########:;;;;;;;;;;;;;;;;;;;;;;;;

call_321d:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_072c
		DB	008h, 000h, 00Bh
		JNZ	jump_3234
		MOV	R1, #000h
		LCALL	call_2e14
jump_3234:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 080h, 007h
		MOV	A, R3
		ORL	A, R2
		JZ	jump_3244
		MOV	A, #0FFh
jump_3244:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		PUSH	002h
		PUSH	003h
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R1, #020h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_056c
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_3277
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
jump_3277:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 080h, 007h
		PUSH	002h
		PUSH	003h
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R1, #024h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_0548
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_32be
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
jump_32be:
		MOV	R1, #03Ah
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		LCALL	call_04fe
		PUSH	002h
		PUSH	003h
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #002h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_32d7
		MOV	A, #0FFh
jump_32d7:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_32f5
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
jump_32f5:
		MOV	R1, #016h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		MOV	R2, #000h
		LCALL	call_04e3
		PUSH	002h
		PUSH	003h
		MOV	R1, #02Dh
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_3313
		MOV	A, #0FFh
jump_3313:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JNZ	jump_3326
		LJMP	jump_3431
jump_3326:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	001h, 000h, 008h
		MOV	A, R3
		ORL	A, R2
		JZ	jump_3336
		MOV	A, #0FFh
jump_3336:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		PUSH	002h
		PUSH	003h
		MOV	R1, #018h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0E7h
		MOV	R2, #0FFh
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		POP	005h
		POP	004h
		PUSH	004h
		PUSH	005h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #016h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_0548
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_337f
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
jump_337f:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	001h, 000h, 008h
		PUSH	002h
		PUSH	003h
		MOV	R1, #018h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #019h
		MOV	R2, #000h
		MOV	A, R3
		ADD	A, R5
		MOV	R3, A
		MOV	A, R2
		ADDC	A, R4
		MOV	R2, A
		POP	005h
		POP	004h
		PUSH	004h
		PUSH	005h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #016h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_056c
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_342f
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #003h
		LCALL	call_0530
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #030h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ORL	A, R2
		JZ	jump_33e8
		MOV	A, #0FFh
jump_33e8:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_3424
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		JNZ	jump_3406
		MOV	R3, #078h
		MOV	R1, #052h
		MOV	A, R3
		MOV	@R1, A
jump_3406:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
		SJMP	jump_342f
jump_3424:
		MOV	R1, #000h
		LCALL	call_2def
		MOV	R3, #03Ch
		MOV	R1, #03Dh
		MOV	A, R3
		MOV	@R1, A
jump_342f:
		SJMP	jump_343f
jump_3431:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
jump_343f:
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #003h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_344b
		MOV	A, #0FFh
jump_344b:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #030h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ORL	A, R2
		JZ	jump_3460
		MOV	A, #0FFh
jump_3460:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_349a
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		JNZ	jump_347e
		MOV	R3, #078h
		MOV	R1, #052h
		MOV	A, R3
		MOV	@R1, A
jump_347e:
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
jump_349a:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		MOV	A, R3
		ORL	A, R2
		JZ	jump_34aa
		MOV	A, #0FFh
jump_34aa:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JNZ	jump_34c7
		LJMP	jump_35b4
jump_34c7:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	001h, 000h, 008h
		JZ	jump_34fb
		MOV	R1, #034h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		ORL	A, R2
		JNZ	jump_34f8
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
jump_34f8:
		LJMP	jump_359d
jump_34fb:
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R1, #020h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_0548
		JZ	jump_356f
		MOV	R1, #036h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		ORL	A, R2
		JNZ	jump_356d
		MOV	R1, #02Ah
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_0519
		JZ	jump_353f
		MOV	R1, #032h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #03Ch
		MOV	R2, #000h
		LCALL	call_083a
		MOV	R1, #034h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_353f:
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #02Ah
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #032h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #03Ch
		MOV	R2, #000h
		LCALL	call_083a
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #00Ah
		MOV	R2, #000h
		LCALL	call_084f
		MOV	R1, #036h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_356d:
		SJMP	jump_359d
jump_356f:
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #02Ah
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #032h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #03Ch
		MOV	R2, #000h
		LCALL	call_083a
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #00Ah
		MOV	R2, #000h
		LCALL	call_084f
		MOV	R1, #036h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_359d:
		MOV	R1, #034h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		ORL	A, R2
		JNZ	jump_35b4
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
jump_35b4:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	001h, 000h, 008h
		MOV	A, R3
		ORL	A, R2
		JZ	jump_35d2
		MOV	A, #0FFh
jump_35d2:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JNZ	jump_35e1
		LJMP	jump_371b
jump_35e1:
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_35ed
		MOV	A, #0FFh
jump_35ed:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 040h, 006h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JNZ	jump_360a
		LJMP	jump_36c2
jump_360a:
		MOV	R1, #00Ch
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0B4h
		MOV	R2, #005h
		LCALL	call_056c
		PUSH	002h
		PUSH	003h
		MOV	R1, #022h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0B4h
		MOV	R2, #005h
		LCALL	call_0548
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_3644
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
jump_3644:
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R1, #022h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_056c
		PUSH	002h
		PUSH	003h
		MOV	R1, #00Ch
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0B4h
		MOV	R2, #005h
		LCALL	call_056c
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_3681
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
jump_3681:
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R1, #026h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_0548
		JZ	jump_36a2
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
jump_36a2:
		MOV	R1, #00Ch
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0BEh
		MOV	R2, #005h
		LCALL	call_0548
		JZ	jump_36c0
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
jump_36c0:
		SJMP	jump_371b
jump_36c2:
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R1, #022h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_056c
		JZ	jump_36e3
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
jump_36e3:
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R1, #026h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		LCALL	call_0548
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #03Ah
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		JZ	jump_3701
		MOV	A, #0FFh
jump_3701:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_371b
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
jump_371b:
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 080h, 007h
		PUSH	002h
		PUSH	003h
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #002h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_3735
		MOV	A, #0FFh
jump_3735:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		MOV	R2, A
		PUSH	002h
		PUSH	003h
		MOV	R1, #012h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #09Ch
		MOV	R2, #004h
		LCALL	call_04e3
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_376f
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
jump_376f:
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 080h, 007h
		JNZ	jump_3789
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
jump_3789:
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		PUSH	002h
		PUSH	003h
		MOV	R1, #012h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #098h
		MOV	R2, #004h
		LCALL	call_0519
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_37bf
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
jump_37bf:
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		JZ	jump_37e7
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
jump_37e7:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		JZ	jump_380b
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		JZ	jump_3806
		MOV	R1, #000h
		LCALL	call_2cc5
		SJMP	jump_380b
jump_3806:
		MOV	R1, #000h
		LCALL	call_2cde
jump_380b:
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		JNZ	jump_381a
		LJMP	jump_38fb
jump_381a:
		MOV	R3, #03Ch
		MOV	R1, #02Eh
		MOV	A, R3
		MOV	@R1, A
		MOV	R1, #000h
		LCALL	call_2d4e
		MOV	R1, #000h
		LCALL	call_2cc5
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	007h, 000h, 080h
		MOV	R1, #016h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #040h
		MOV	R2, #006h
		LCALL	call_0548
		PUSH	002h
		PUSH	003h
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #003h
		LCALL	call_0530
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		MOV	R2, A
		PUSH	002h
		PUSH	003h
		MOV	R1, #00Ch
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #040h
		MOV	R2, #006h
		LCALL	call_0548
		POP	005h
		POP	004h
		PUSH	004h
		PUSH	005h
		PUSH	002h
		PUSH	003h
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #003h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_3895
		MOV	A, #0FFh
jump_3895:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		MOV	R2, A
		POP	005h
		POP	004h
		MOV	A, R3
		ORL	A, R5
		MOV	R3, A
		MOV	A, R2
		ORL	A, R4
		MOV	R2, A
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #052h
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		JZ	jump_38ba
		MOV	A, #0FFh
jump_38ba:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ORL	A, R5
		MOV	R3, A
		MOV	A, R2
		ORL	A, R4
		ORL	A, R3
		JZ	jump_38f8
		MOV	R1, #000h
		LCALL	call_2cde
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
		MOV	R1, #000h
		LCALL	call_2def
		MOV	R3, #03Ch
		MOV	R1, #02Fh
		MOV	A, R3
		MOV	@R1, A
		MOV	R3, #03Ch
		MOV	R1, #03Dh
		MOV	A, R3
		MOV	@R1, A
jump_38f8:
		LJMP	jump_3b4c
jump_38fb:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	001h, 000h, 008h
		JNZ	jump_390a
		LJMP	jump_3a16
jump_390a:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 080h, 007h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 004h, 002h
		MOV	A, R3
		ORL	A, R2
		JZ	jump_3928
		MOV	A, #0FFh
jump_3928:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		MOV	R2, A
		PUSH	002h
		PUSH	003h
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #002h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_3942
		MOV	A, #0FFh
jump_3942:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		POP	005h
		POP	004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_3966
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
		MOV	R3, #03Ch
		MOV	R1, #03Ah
		MOV	A, R3
		MOV	@R1, A
jump_3966:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	004h, 000h, 00Ah
		MOV	A, R3
		ORL	A, R2
		JZ	jump_3976
		MOV	A, #0FFh
jump_3976:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #038h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ORL	A, R2
		JZ	jump_398b
		MOV	A, #0FFh
jump_398b:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_39a1
		MOV	R1, #000h
		LCALL	call_2cf7
		MOV	R1, #000h
		LCALL	call_2dd6
jump_39a1:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	004h, 000h, 00Ah
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #03Bh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ORL	A, R2
		JZ	jump_39bc
		MOV	A, #0FFh
jump_39bc:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_39e0
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		MOV	R1, #000h
		LCALL	call_2cc5
		MOV	R1, #000h
		LCALL	call_2dd6
jump_39e0:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	004h, 000h, 00Ah
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_3a13
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		MOV	R1, #000h
		LCALL	call_2dd6
jump_3a13:
		LJMP	jump_3b4c
jump_3a16:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 080h, 007h
		JNZ	jump_3a25
		LJMP	jump_3af7
jump_3a25:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	002h, 000h, 004h
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	004h, 000h, 00Ah
		MOV	A, R3
		ORL	A, R2
		JZ	jump_3a51
		MOV	A, #0FFh
jump_3a51:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #038h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ORL	A, R2
		JZ	jump_3a66
		MOV	A, #0FFh
jump_3a66:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_3ab6
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		JNZ	jump_3aac
		MOV	R1, #028h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #02Ah
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #032h
		MOV	A, @R1
		MOV	R4, A
		INC	R1
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #03Ch
		MOV	R2, #000h
		LCALL	call_083a
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #00Ah
		MOV	R2, #000h
		LCALL	call_084f
		MOV	R1, #036h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_3aac:
		MOV	R1, #000h
		LCALL	call_2cf7
		MOV	R1, #000h
		LCALL	call_2def
jump_3ab6:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	004h, 000h, 00Ah
		MOV	005h, R3
		MOV	004h, R2
		MOV	R1, #03Bh
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	A, R3
		ORL	A, R2
		JZ	jump_3ad1
		MOV	A, #0FFh
jump_3ad1:
		INC	A
		MOV	R3, A
		MOV	R2, #000h
		MOV	A, R3
		ANL	A, R5
		MOV	R3, A
		MOV	A, R2
		ANL	A, R4
		ORL	A, R3
		JZ	jump_3af5
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	001h, 000h, 002h
		MOV	R1, #000h
		LCALL	call_2cc5
		MOV	R1, #000h
		LCALL	call_2def
jump_3af5:
		SJMP	jump_3b4c
jump_3af7:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 008h, 003h
		JZ	jump_3b21
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	008h, 001h, 000h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
		SJMP	jump_3b4c
jump_3b21:
		MOV	R1, #000h
		LCALL	call_2d4e
		MOV	R1, #000h
		LCALL	call_2def
		MOV	R1, #000h
		LCALL	call_2cde
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	004h, 000h, 010h
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	005h, 000h, 020h
jump_3b4c:
		LJMP	jump_0a19

;;;; #########################################

call_3b4f:
		MOV	DPTR, #0000h
		LCALL	call_09e0
		MOV	R1, #000h
		LCALL	call_26b7
		MOV	R3, #000h
		MOV	R1, #047h
		MOV	A, R3
		MOV	@R1, A
jump_3b60:
		MOV	R1, #047h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #00Fh
		LCALL	call_0530
		JZ	jump_3b7f
		MOV	R1, #000h
		LCALL	call_0091
		MOV	R1, #000h
		LCALL	call_1ed5
		MOV	R1, #000h
		LCALL	call_2443
		MOV	R1, #047h
		INC	@R1
		SJMP	jump_3b60
jump_3b7f:
		MOV	R1, #000h
		LCALL	call_2690
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
		MOV	R3, #004h
		MOV	R1, #0FFh
		LCALL	call_0a28
		MOV	R1, #009h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_3ba5
		MOV	A, #0FFh
jump_3ba5:
		INC	A
		JZ	jump_3bb6
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
jump_3bb6:
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0a28
		MOV	R1, #009h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_3bc9
		MOV	A, #0FFh
jump_3bc9:
		INC	A
		JZ	jump_3bda
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
jump_3bda:
		MOV	R3, #002h
		MOV	R1, #0FFh
		LCALL	call_0a28
		MOV	R1, #009h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #0FFh
		MOV	A, R5
		XRL	A, R3
		JZ	jump_3bed
		MOV	A, #0FFh
jump_3bed:
		INC	A
		JZ	jump_3bfe
		MOV	R3, #001h
		MOV	R1, #02Ch
		MOV	A, R3
		MOV	@R1, A
		MOV	R3, #000h
		MOV	R1, #02Dh
		MOV	A, R3
		MOV	@R1, A
		SJMP	jump_3c0e
jump_3bfe:
		MOV	R1, #009h
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #02Ch
		MOV	A, R3
		MOV	@R1, A
		MOV	R1, #008h
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #02Dh
		MOV	A, R3
		MOV	@R1, A
jump_3c0e:
		MOV	R1, #046h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #000h
		LCALL	call_04fe
		JZ	jump_3c1e
		MOV	R1, #046h
		DEC	@R1
		SJMP	jump_3c20
jump_3c1e:
		SJMP	jump_3c1e
jump_3c20:
		MOV	R1, #000h
		LCALL	call_0091
		MOV	R1, #000h
		LCALL	call_1ed5
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 001h, 000h
		JNZ	jump_3c39
		LJMP	jump_3d5e
jump_3c39:
		MOV	R1, #045h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #00Ah
		LCALL	call_04fe
		JZ	jump_3c52
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_075a
		DB	003h, 000h, 008h
jump_3c52:
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 008h, 003h
		JZ	jump_3c7f
		MOV	R3, #000h
		MOV	R1, #045h
		MOV	A, R3
		MOV	@R1, A
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
		CLR	C_PUMP_RLY
		SETB	H_PUMP_RLY
		SETB	CMPRSR_RLY
		SETB	WW_RLY
		CLR	EXT_RLY
		LJMP	jump_3d5c
jump_3c7f:
		MOV	R3, #04Ch
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 010h, 004h
		JNZ	jump_3c8d
		CLR	H_PUMP_RLY
jump_3c8d:
		MOV	R1, #044h
		MOV	A, @R1
		JZ	jump_3c99
		MOV	R1, #000h
		LCALL	call_2bfd
		SJMP	jump_3ca7
jump_3c99:
		MOV	R5, #000h
		MOV	R4, #000h
		MOV	R3, #04Eh
		MOV	R2, #000h
		LCALL	call_075a
		DB	00Bh, 008h, 000h
jump_3ca7:
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 020h, 005h
		JZ	jump_3cbe
		MOV	R3, #000h
		MOV	R2, #000h
		MOV	R1, #038h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
jump_3cbe:
		MOV	R1, #02Ch
		MOV	A, @R1
		MOV	R3, A
		PUSH	003h
		MOV	R5, #001h
		LCALL	call_0588
		POP	003h
		JNZ	jump_3cdd
		MOV	R1, #014h
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #028h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_3d0f
jump_3cdd:
		PUSH	003h
		MOV	R5, #002h
		LCALL	call_0588
		POP	003h
		JNZ	jump_3cf8
		MOV	R1, #00Ch
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #028h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_3d0f
jump_3cf8:
		MOV	R5, #003h
		LCALL	call_0588
		JNZ	jump_3d0f
		MOV	R1, #00Ch
		MOV	A, @R1
		MOV	R2, A
		INC	R1
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #028h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		SJMP	jump_3d0f
jump_3d0f:
		MOV	R3, #050h
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 008h, 003h
		JZ	jump_3d57
		JNB	EXT_SW, jump_3d25
		MOV	R1, #000h
		LCALL	call_321d
		SJMP	jump_3d55
jump_3d25:
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 002h, 001h
		MOV	005h, R3
		MOV	004h, R2
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_072c
		DB	000h, 040h, 006h
		MOV	A, R3
		ORL	A, R5
		MOV	R3, A
		MOV	A, R2
		ORL	A, R4
		ORL	A, R3
		JZ	jump_3d55
		MOV	R3, #084h
		MOV	R2, #003h
		MOV	R1, #038h
		MOV	A, R2
		MOV	@R1, A
		MOV	A, R3
		INC	R1
		MOV	@R1, A
		MOV	R1, #000h
		LCALL	call_26b7
jump_3d55:
		SJMP	jump_3d5c
jump_3d57:
		MOV	R1, #000h
		LCALL	call_321d
jump_3d5c:
		SJMP	jump_3dab
jump_3d5e:
		MOV	R1, #000h
		LCALL	call_26b7
		MOV	R3, #004h
		MOV	R1, #0FFh
		LCALL	call_0a28
		MOV	R1, #009h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_3d76
		MOV	A, #0FFh
jump_3d76:
		INC	A
		JZ	jump_3d87
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
jump_3d87:
		MOV	R3, #006h
		MOV	R1, #0FFh
		LCALL	call_0a28
		MOV	R1, #009h
		MOV	A, @R1
		MOV	R5, A
		MOV	R3, #001h
		MOV	A, R5
		XRL	A, R3
		JZ	jump_3d9a
		MOV	A, #0FFh
jump_3d9a:
		INC	A
		JZ	jump_3dab
		MOV	R5, #001h
		MOV	R4, #000h
		MOV	R3, #04Ah
		MOV	R2, #000h
		LCALL	call_075a
		DB	000h, 000h, 001h
jump_3dab:
		MOV	R3, #002h
		MOV	R1, #0FFh
		LCALL	call_0a28
		MOV	R1, #009h
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #02Ch
		MOV	A, R3
		MOV	@R1, A
		MOV	R1, #008h
		MOV	A, @R1
		MOV	R3, A
		MOV	R1, #02Dh
		MOV	A, R3
		MOV	@R1, A
		LJMP	jump_3c0e


; I don't know what those values represent, but for some reason there are defined here and copied by code to IRAM

const_start:
		DW	0000h, 0000h, 0000h, 0000h
		DW	0000h, 0000h, 0000h, 0000h
		DW	0000h, 0000h, 0000h, 0000h
		DW	0000h, 0000h, 0000h, 0000h
		DW	0000h, 0000h, 0100h, 0000h
		DW	05A0h, 0000h, 0064h, 0000h
		DW	0384h, 0000h, 0000h, 0000h
		DW	0000h, 0100h, 0000h, 0A00h
const_end:

END
