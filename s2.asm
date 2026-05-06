; Disassembly originally created by drx
; thanks to Hivebrain and Rika_Chou

; Updated by Alex Field, Filter, and RepellantMold

; ===========================================================================
; ASSEMBLY OPTIONS:

EnableSRAM	  = 0	; change to 1 to enable SRAM
BackupSRAM	  = 1
AddressSRAM	  = 3	; 0 = odd+even; 2 = even only; 3 = odd only

FixBugs	= 0
;	| If 1, enables various bugfixes across the game and sound driver
;	| See also FixMusicAndSFXDataBugs

AllOptimizations = 0
;	| If 1, enables all optimizations
ZeroOffsetOptimization = 0|AllOptimizations
;	| If 1, makes a handful of zero-offset instructions smaller
RemoveJmpTos = 0|AllOptimizations
;	| If 1, many unnecessary JmpTos are removed, improving performance
PaddingOptimization = 0|AllOptimizations
;	| If 1, removes about 125 KB of various superfluous padding

; ===========================================================================
; AS-specific macros and assembler settings
	cpu 68000
	include "MacroSetup.asm"

; ===========================================================================
; Simplifying macros and functions
	include "Macros.asm"

; ===========================================================================
; Equates section - Names for constants
	include "Constants.asm"

; ===========================================================================
; Expressing sprite mappings and DPLCs in a portable and human-readable form
SonicMappingsVer = 2
SonicDplcVer = 2
	include	"mappings/MapMacros.asm"

; ===========================================================================
; start of ROM

StartOfRom:
Vectors:
		dc.l v_systemstack
		dc.l EntryPoint
		dc.l BusError
		dc.l AddressError
		dc.l IllegalInstr
		dc.l ZeroDivide
		dc.l ChkInstr
		dc.l TrapvInstr
		dc.l PrivilegeViol
		dc.l Trace
		dc.l Line1010Emu
		dc.l Line1111Emu
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorExcept
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l H_Int
		dc.l ErrorTrap
		dc.l V_Int
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.l ErrorTrap
		dc.b "SEGA MEGA DRIVE "		; Console name
		dc.b "(C)SEGA 1991.APR"		; Copyright holder and release year (leftover from Sonic 1)
		dc.b "SONIC THE       " 	; Domestic name
		dc.b "      HEDGEHOG 2"
		dc.b "                "
		dc.b "SONIC THE       "		; International name
		dc.b "      HEDGEHOG 2"
		dc.b "                "
		dc.b "GM 00004049-01"		; Version (leftover from Sonic 1)
Checksum:	dc.w $AFC7				; Checksum (leftover from Sonic 1)
		dc.b "J               "		; I/O support
		dc.l StartOfRom				; Start address of ROM
ROMEndLoc:	dc.l S1_EndOfRom-1		; End address of ROM (leftover from Sonic 1)
		dc.l v_ram_start&$FFFFFF	; Start address of RAM
		dc.l (v_ram_end-1)&$FFFFFF	; End address of RAM
		if EnableSRAM=1
		dc.b $52, $41, $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20 ; Backup RAM ID
		else
		dc.l $20202020
		endif
		dc.l $20202020				; Backup RAM start address
		dc.l $20202020				; Backup RAM end address
		dc.l $20202020				; Modem support
		dc.b "                                                " ; Notes (unused, anything can be put in this space, but it has to be 48 bytes.)
		dc.b "JUE             "		; Country code (region)
EndOfHeader:

; ---------------------------------------------------------------------------

ErrorTrap:
		nop
		nop
		bra.s	ErrorTrap
; ---------------------------------------------------------------------------

EntryPoint:
		tst.l	(port_1_control_hi).l		; test Port A Ctrl
		bne.s	PortA_OK
		tst.w	(expansion_control_hi).l	; test Port C Ctrl

PortA_OK:
		bne.s	PortC_OK
		lea	InitValues(pc),a5
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	console_version-z80_bus_request(a1),d0			; get hardware version
		andi.b	#$F,d0
		beq.s	SkipSecurity
		move.l	#"SEGA",security_addr-z80_bus_request(a1)

SkipSecurity:
		move.w	(a4),d0
		moveq	#0,d0
		movea.l	d0,a6
		move.l	a6,usp
		moveq	#VDPInitValues_End-VDPInitValues-1,d1

VDPInitLoop:
		move.b	(a5)+,d5
		move.w	d5,(a4)
		add.w	d7,d5
		dbf	d1,VDPInitLoop
		move.l	(a5)+,(a4)
		move.w	d0,(a3)
		move.w	d7,(a1)
		move.w	d7,(a2)

WaitForZ80:
		btst	d0,(a1)
		bne.s	WaitForZ80
		moveq	#Z80StartupCodeEnd-Z80StartupCodeBegin-1,d2

Z80InitLoop:
		move.b	(a5)+,(a0)+
		dbf	d2,Z80InitLoop
		move.w	d0,(a2)
		move.w	d0,(a1)
		move.w	d7,(a2)

ClearRAMLoop:
		move.l	d0,-(a6)
		dbf	d6,ClearRAMLoop
		move.l	(a5)+,(a4)
		move.l	(a5)+,(a4)
		moveq	#bytesToLcnt($80),d3

ClearCRAMLoop:
		move.l	d0,(a3)
		dbf	d3,ClearCRAMLoop
		move.l	(a5)+,(a4)
		moveq	#bytesToLcnt($50),d4

ClearVSRAMLoop:
		move.l	d0,(a3)
		dbf	d4,ClearVSRAMLoop
		moveq	#PSGInitValues_End-PSGInitValues-1,d5

PSGInitLoop:
		move.b	(a5)+,psg_input-vdp_data_port(a3)
		dbf	d5,PSGInitLoop
		move.w	d0,(a2)
		movem.l	(a6),d0-a6
		disable_ints

PortC_OK:
		bra.s	GameProgram
; ---------------------------------------------------------------------------
InitValues:	dc.w $8000
		dc.w bytesToLcnt(v_ram_end-v_ram_start)
		dc.w $100

		dc.l z80_ram				; Z80 RAM start	location
		dc.l z80_bus_request			; Z80 bus request
		dc.l z80_reset				; Z80 reset
		dc.l vdp_data_port			; VDP data port
		dc.l vdp_control_port			; VDP control port

VDPInitValues:						; values for VDP registers
		dc.b 4			; VDP $80 - 8-colour mode
		dc.b $14		; VDP $81 - Megadrive mode, DMA enable
		dc.b (vram_fg>>10)	; VDP $82 - foreground nametable address
		dc.b ($F000>>10)	; VDP $83 - window nametable address
		dc.b (vram_bg>>13)	; VDP $84 - background nametable address
		dc.b ($D800>>9)		; VDP $85 - sprite table address
		dc.b 0			; VDP $86 - unused
		dc.b 0			; VDP $87 - background colour
		dc.b 0			; VDP $88 - unused
		dc.b 0			; VDP $89 - unused
		dc.b 255		; VDP $8A - HBlank register
		dc.b 0			; VDP $8B - full screen scroll
		dc.b $81		; VDP $8C - 40 cell display
		dc.b ($DC00>>10)	; VDP $8D - hscroll table address
		dc.b 0			; VDP $8E - unused
		dc.b 1			; VDP $8F - VDP increment
		dc.b 1			; VDP $90 - 64 cell hscroll size
		dc.b 0			; VDP $91 - window h position
		dc.b 0			; VDP $92 - window v position
		dc.w $FFFF		; VDP $93/94 - DMA length
		dc.w 0			; VDP $95/96 - DMA source
		dc.b $80		; VDP $97 - DMA fill VRAM
VDPInitValues_End:

		dc.l $40000080		; value	for VRAM fill

Z80StartupCodeBegin:
	; Z80 instructions (not the sound driver; that gets loaded later)
	if (*)+$26 < $10000
	save
	CPU Z80 ; start assembling Z80 code
	phase 0 ; pretend we're at address 0
	xor	a	; clear a to 0
	ld	bc,((z80_ram_end-z80_ram)-zStartupCodeEndLoc)-1 ; prepare to loop this many times
	ld	de,zStartupCodeEndLoc+1	; initial destination address
	ld	hl,zStartupCodeEndLoc	; initial source address
	ld	sp,hl	; set the address the stack starts at
	ld	(hl),a	; set first byte of the stack to 0
	ldir		; loop to fill the stack (entire remaining available Z80 RAM) with 0
	pop	ix	; clear ix
	pop	iy	; clear iy
	ld	i,a	; clear i
	ld	r,a	; clear r
	pop	de	; clear de
	pop	hl	; clear hl
	pop	af	; clear af
	ex	af,af'	; swap af with af'
	exx		; swap bc/de/hl with their shadow registers too
	pop	bc	; clear bc
	pop	de	; clear de
	pop	hl	; clear hl
	pop	af	; clear af
	ld	sp,hl	; clear sp
	di		; clear iff1 (for interrupt handler)
	im	1	; interrupt handling mode = 1
	ld	(hl),0E9h ; replace the first instruction with a jump to itself
	jp	(hl)	  ; jump to the first instruction (to stay there forever)
zStartupCodeEndLoc:
	dephase ; stop pretending
	restore
	padding off ; unfortunately our flags got reset so we have to set them again...
	else ; due to an address range limitation I could work around but don't think is worth doing so:
	message "Warning: using pre-assembled Z80 startup code."
	dc.w $AF01,$D91F,$1127,$0021,$2600,$F977,$EDB0,$DDE1,$FDE1,$ED47,$ED4F,$D1E1,$F108,$D9C1,$D1E1,$F1F9,$F3ED,$5636,$E9E9
	endif
Z80StartupCodeEnd:

		dc.w $8104				; VDP display mode
		dc.w $8F02				; VDP increment
		dc.l $C0000000				; value	for CRAM Write mode
		dc.l $40000010				; value	for VSRAM write	mode

PSGInitValues:
		dc.b  $9F, $BF,	$DF, $FF		; values for PSG channel volumes
PSGInitValues_End:
; ---------------------------------------------------------------------------

GameProgram:
		tst.w	(vdp_control_port).l
		btst	#6,(expansion_control).l
		beq.s	ChecksumTest
		cmpi.l	#"init",(v_init).w
		beq.w	GameInit

ChecksumTest:
		movea.l	#EndOfHeader,a0		; start checking bytes after header ($200)
		movea.l	#ROMEndLoc,a1		; stop at end of ROM (but not really since it's half of the ROM, leftover from Sonic 1)
		move.l	(a1),d0
		move.l	#S1_EndOfRom-1,d0
		moveq	#0,d1

ChecksumLoop:
		add.w	(a0)+,d1
		cmp.l	a0,d0
		bhs.s	ChecksumLoop
		movea.l	#Checksum,a1		; read the checksum
		cmp.w	(a1),d1				; compare correct checksum to one in ROM
	if 0
		bne.w	ChecksumError		; if not equal to the one in ROM, checksum error
	else
		nop							; and do absolutely nothing with it
		nop
	endif
		lea	(v_crossresetram).w,a6
		moveq	#0,d7
		move.w	#bytesToLcnt(v_ram_end-v_crossresetram),d6

loc_350:
		move.l	d7,(a6)+
		dbf	d6,loc_350
		move.b	(console_version).l,d0
		andi.b	#$C0,d0
		move.b	d0,(v_megadrive).w
		move.l	#"init",(v_init).w

GameInit:
		lea	(v_ram_start&$FFFFFF).l,a6
		moveq	#0,d7
		move.w	#bytesToLcnt(v_crossresetram-v_ram_start),d6

.clrRAM:
		move.l	d7,(a6)+
		dbf	d6,.clrRAM
		bsr.w	VDPSetupGame
		bsr.w	DACDriverLoad
		bsr.w	JoypadInit
		move.b	#GameModeID_SegaScreen,(v_gamemode).w

MainGameLoop:
		move.b	(v_gamemode).w,d0
		andi.w	#GameModeID_S1End,d0	; limit to credits game mode (even though it doesn't exist)
		jsr	GameModeArray(pc,d0.w)
		bra.s	MainGameLoop
; ===========================================================================
; loc_3A8:
GameModeArray:
GameMode_SegaScreen:	bra.w	SegaScreen		; SEGA screen mode ($00)
GameMode_TitleScreen:	bra.w	TitleScreen		; Title screen mode ($04)
GameMode_Demo:		bra.w	Level			; Demo mode ($08)
GameMode_Level:		bra.w	Level			; Zone play mode ($0C)
GameMode_SpecialStage:	bra.w	SpecialStage		; Special Stage play mode ($10)
; ===========================================================================
; Leftover from Sonic 1, turns the screen red if the checksum check fails
ChecksumError:
		bsr.w	VDPSetupGame
		move.l	#$C0000000,(vdp_control_port).l
		moveq	#bytesToWcnt(palette_size),d7

Checksum_Red:
		move.w	#cRed,(vdp_data_port).l
		dbf	d7,Checksum_Red

.loop:
		bra.s	.loop
; ===========================================================================

BusError:
		move.b	#2,(v_errortype).w
		bra.s	ErrorMsg_TwoAddresses
; ---------------------------------------------------------------------------

AddressError:
		move.b	#4,(v_errortype).w
		bra.s	ErrorMsg_TwoAddresses
; ---------------------------------------------------------------------------

IllegalInstr:
		move.b	#6,(v_errortype).w
		addq.l	#2,2(sp)
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

ZeroDivide:
		move.b	#8,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

ChkInstr:
		move.b	#$A,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

TrapvInstr:
		move.b	#$C,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

PrivilegeViol:
		move.b	#$E,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

Trace:
		move.b	#$10,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

Line1010Emu:
		move.b	#$12,(v_errortype).w
		addq.l	#2,2(sp)
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

Line1111Emu:
		move.b	#$14,(v_errortype).w
		addq.l	#2,2(sp)
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

ErrorExcept:
		move.b	#0,(v_errortype).w
		bra.s	ErrorMessage
; ---------------------------------------------------------------------------

ErrorMsg_TwoAddresses:
		disable_ints
		addq.w	#2,sp
		move.l	(sp)+,(v_spbuffer).w
		addq.w	#2,sp
		movem.l	d0-sp,(v_regbuffer).w
		bsr.w	ShowErrorMsg
		move.l	2(sp),d0
		bsr.w	ShowErrAddress
		move.l	(v_spbuffer).w,d0
		bsr.w	ShowErrAddress
		bra.s	ErrorMsg_Wait
; ---------------------------------------------------------------------------

ErrorMessage:
		disable_ints
		movem.l	d0-sp,(v_regbuffer).w
		bsr.w	ShowErrorMsg
		move.l	2(sp),d0
		bsr.w	ShowErrAddress

ErrorMsg_Wait:
		bsr.w	ErrorWaitForC
		movem.l	(v_regbuffer).w,d0-sp
		enable_ints
		rte

; =============== S U B	R O U T	I N E =======================================


ShowErrorMsg:
		lea	(vdp_data_port).l,a6
		locVRAM	ArtTile_Error_Handler_Font*tile_size
		lea	(Art_Text).l,a0
		move.w	#bytesToWcnt(Art_Text_End-Art_Text-tile_size),d1 ; strangely, this does not load the final tile

.loadgfx:
		move.w	(a0)+,(a6)
		dbf	d1,.loadgfx

		moveq	#0,d0
		move.b	(v_errortype).w,d0
		move.w	ErrorText(pc,d0.w),d0
		lea	ErrorText(pc,d0.w),a0
		locVRAM	vram_fg+$604
		moveq	#19-1,d1

.showchars:
		moveq	#0,d0
		move.b	(a0)+,d0
		addi.w	#-'0'+ArtTile_Error_Handler_Font,d0 ; rebase from ASCII to a VRAM index
		move.w	d0,(a6)
		dbf	d1,.showchars	; repeat for number of characters
		rts
; End of function ShowErrorMsg

; ---------------------------------------------------------------------------
ErrorText:
		dc.w .exception-ErrorText	; 0
		dc.w .bus-ErrorText		; 2
		dc.w .address-ErrorText		; 4
		dc.w .illinstruct-ErrorText	; 6
		dc.w .zerodivide-ErrorText	; 8
		dc.w .chkinstruct-ErrorText	; $A
		dc.w .trapv-ErrorText		; $C
		dc.w .privilege-ErrorText	; $E
		dc.w .trace-ErrorText		; $10
		dc.w .line1010-ErrorText	; $12
		dc.w .line1111-ErrorText	; $14
.exception:	dc.b "ERROR EXCEPTION    "
.bus:		dc.b "BUS ERROR          "
.address:	dc.b "ADDRESS ERROR      "
.illinstruct:	dc.b "ILLEGAL INSTRUCTION"
.zerodivide:	dc.b "@ERO DIVIDE        "
.chkinstruct:	dc.b "CHK INSTRUCTION    "
.trapv:		dc.b "TRAPV INSTRUCTION  "
.privilege:	dc.b "PRIVILEGE VIOLATION"
.trace:		dc.b "TRACE              "
.line1010:	dc.b "LINE 1010 EMULATOR "
.line1111:	dc.b "LINE 1111 EMULATOR "
		even

; =============== S U B	R O U T	I N E =======================================


ShowErrAddress:
		move.w	#ArtTile_Error_Handler_Font+10,(a6)	; display "$" symbol
		moveq	#8-1,d2

ShowErrAddress_DigitLoop:
		rol.l	#4,d0
		bsr.s	ShowErrDigit
		dbf	d2,ShowErrAddress_DigitLoop
		rts
; End of function ShowErrAddress


; =============== S U B	R O U T	I N E =======================================


ShowErrDigit:
		move.w	d0,d1
		andi.w	#$F,d1
		cmpi.w	#$A,d1
		blo.s	ShowErrDigit_NoOverflow
		addq.w	#7,d1		; add 7 for characters A-F

ShowErrDigit_NoOverflow:
		addi.w	#ArtTile_Error_Handler_Font,d1
		move.w	d1,(a6)
		rts
; End of function ShowErrDigit


; =============== S U B	R O U T	I N E =======================================


ErrorWaitForC:
		bsr.w	ReadJoypads
		cmpi.b	#btnC,(v_jpadpress1).w ; is button C pressed?
		bne.w	ErrorWaitForC	; if not, branch
		rts
; End of function ErrorWaitForC

; ---------------------------------------------------------------------------
Art_Text:	binclude	"art/uncompressed/Level select and Debug Mode text.bin"
Art_Text_End:	even

; ===========================================================================
; vertical and horizontal interrupt handlers
; VERTICAL INTERRUPT HANDLER:
V_Int:
		movem.l	d0-a6,-(sp)
		tst.b	(v_vbla_routine).w
		beq.s	Vint_Lag

.waitforvint:
		move.w	(vdp_control_port).l,d0
		andi.w	#%1000,d0
		beq.s	.waitforvint
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l
		btst	#6,(v_megadrive).w
		beq.s	.notPAL
		move.w	#17930/10-1,d0

.loop:
		dbf	d0,.loop

.notPAL:
		move.b	(v_vbla_routine).w,d0
		move.b	#VintID_Lag,(v_vbla_routine).w
		move.w	#1,(f_hbla_pal).w
		andi.w	#$3E,d0
		move.w	Vint_SwitchTbl(pc,d0.w),d0
		jsr	Vint_SwitchTbl(pc,d0.w)
; loc_B5C:
Vint_SoundDriver:
		jsr	(UpdateMusic).l
; loc_B62:
VintRet:
		addq.l	#1,(Vint_runcount).w
		movem.l	(sp)+,d0-a6
		rte
; ===========================================================================
; off_B6C:
Vint_SwitchTbl:
Vint_Lag_ptr:		dc.w Vint_Lag-Vint_SwitchTbl
Vint_SEGA_ptr:		dc.w Vint_SEGA-Vint_SwitchTbl
Vint_Title_ptr:		dc.w Vint_Title-Vint_SwitchTbl
Vint_Unused6_ptr:	dc.w Vint_Unused6-Vint_SwitchTbl
Vint_Level_ptr:		dc.w Vint_Level-Vint_SwitchTbl
Vint_S1SS_ptr:		dc.w Vint_S1SS-Vint_SwitchTbl
Vint_TitleCard_ptr:	dc.w Vint_TitleCard-Vint_SwitchTbl
Vint_UnusedE_ptr:	dc.w Vint_UnusedE-Vint_SwitchTbl
Vint_Pause_ptr:		dc.w Vint_Pause-Vint_SwitchTbl
Vint_Fade_ptr:		dc.w Vint_Fade-Vint_SwitchTbl
Vint_PCM_ptr:		dc.w Vint_PCM-Vint_SwitchTbl
Vint_SSResults_ptr:	dc.w Vint_SSResults-Vint_SwitchTbl
Vint_TitleCard2_ptr:	dc.w Vint_TitleCard-Vint_SwitchTbl
; ===========================================================================
; loc_B86: VintSub0:
Vint_Lag:
		cmpi.b	#GameModeID_TitleCard+GameModeID_Level,(v_gamemode).w
		beq.s	loc_BA0
		cmpi.b	#GameModeID_Demo,(v_gamemode).w
		beq.s	loc_BA0
		cmpi.b	#GameModeID_Level,(v_gamemode).w
		bne.w	Vint_SoundDriver

loc_BA0:
		tst.b	(Water_flag).w
		beq.w	Vint0_noWater
		move.w	(vdp_control_port).l,d0
		btst	#6,(v_megadrive).w
		beq.s	loc_BBE
		move.w	#17930/10-1,d0
		dbf	d0,*

loc_BBE:
		move.w	#1,(f_hbla_pal).w
		stopZ80
		waitZ80
		tst.b	(f_wtr_state).w
		bne.s	loc_C02
		writeCRAM	v_palette,0
		bra.s	loc_C26
; ---------------------------------------------------------------------------

loc_C02:
		writeCRAM	v_palette_water,0

loc_C26:
		move.w	(v_hbla_hreg).w,(a5)
		move.w	#$8200+(vram_fg>>10),(vdp_control_port).l
		startZ80
		bra.w	Vint_SoundDriver
; ---------------------------------------------------------------------------
; loc_C3E:
Vint0_noWater:
		move.w	(vdp_control_port).l,d0
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l
		btst	#6,(v_megadrive).w
		beq.s	loc_C66
		move.w	#17930/10-1,d0

.loop:
		dbf	d0,.loop

loc_C66:
		move.w	#1,(f_hbla_pal).w
		move.w	(v_hbla_hreg).w,(vdp_control_port).l
		move.w	#$8200+(vram_fg>>10),(vdp_control_port).l
		move.l	(v_bg3scrposy_vdp).w,(Camera_X_pos_copy).w
		writeVRAM	Sprite_Table,vram_sprites
		bra.w	Vint_SoundDriver
; ===========================================================================
; loc_CAA: VintSub2:
Vint_SEGA:
		bsr.w	Do_ControllerPal
; loc_CAE: VintSub14:
Vint_PCM:
		tst.w	(v_generictimer).w
		beq.w	.end
		subq.w	#1,(v_generictimer).w

.end:
		rts
; ===========================================================================
; loc_CBC: VintSub4:
Vint_Title:
		bsr.w	Do_ControllerPal
		bsr.w	ProcessDPLC
		tst.w	(v_generictimer).w
		beq.w	.end
		subq.w	#1,(v_generictimer).w

.end:
		rts
; ===========================================================================
; loc_CD2: VintSub6:
Vint_Unused6:
		bsr.w	Do_ControllerPal
		rts
; ===========================================================================
; loc_CD8: VintSub10:
Vint_Pause:
		cmpi.b	#GameModeID_SpecialStage,(v_gamemode).w
		beq.w	Vint_S1SS
; loc_CE2: VintSub8:
Vint_Level:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w
		bne.s	loc_D24

		writeCRAM	v_palette,0
		bra.s	loc_D48
; ---------------------------------------------------------------------------

loc_D24:
		writeCRAM	v_palette_water,0

loc_D48:
		move.w	(v_hbla_hreg).w,(a5)
		move.w	#$8200+(vram_fg>>10),(vdp_control_port).l
		writeVRAM	v_hscrolltablebuffer,vram_hscroll
		writeVRAM	Sprite_Table,vram_sprites
		bsr.w	ProcessDMAQueue
		startZ80
		movem.l	(Camera_RAM).w,d0-d7
		movem.l	d0-d7,(Camera_RAM_copy).w
		movem.l	(Camera_X_pos_P2).w,d0-d7
		movem.l	d0-d7,(Camera_P2_copy).w
		movem.l	(Scroll_flags).w,d0-d3
		movem.l	d0-d3,(Scroll_flags_copy).w
		move.l	(v_bg3scrposy_vdp).w,(Camera_X_pos_copy).w
		cmpi.b	#92,(v_hbla_line).w
		bhs.s	Do_Updates
		move.b	#1,(f_doupdatesinhblank).w
		addq.l	#4,sp
		bra.w	VintRet

; ---------------------------------------------------------------------------
; Subroutine to run a demo for an amount of time
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Demo_Time:
Do_Updates:
		bsr.w	LoadTilesAsYouMove
		jsr	(HudUpdate).l
		bsr.w	ProcessDPLC2
		tst.w	(v_generictimer).w
		beq.w	.end
		subq.w	#1,(v_generictimer).w

.end:
		rts
; End of function Do_Updates

; ===========================================================================
; loc_E02: VintSubA:
Vint_S1SS:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		writeCRAM	v_palette,0
		writeVRAM	Sprite_Table,vram_sprites
		writeVRAM	v_hscrolltablebuffer,vram_hscroll
		bsr.w	ProcessDMAQueue
		startZ80
		bsr.w	PalCycle_S1SS
		tst.w	(v_generictimer).w
		beq.w	.end
		subq.w	#1,(v_generictimer).w

.end:
		rts
; ===========================================================================
; loc_EA2: VintSubC: VintSub18:
Vint_TitleCard:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w
		bne.s	loc_EE4
		writeCRAM	v_palette,0
		bra.s	loc_F08
; ---------------------------------------------------------------------------

loc_EE4:
		writeCRAM	v_palette_water,0

loc_F08:
		move.w	(v_hbla_hreg).w,(a5)
		writeVRAM	v_hscrolltablebuffer,vram_hscroll
		writeVRAM	Sprite_Table,vram_sprites
		bsr.w	ProcessDMAQueue
		startZ80
		movem.l	(Camera_RAM).w,d0-d7
		movem.l	d0-d7,(Camera_RAM_copy).w
		movem.l	(Scroll_flags).w,d0-d1
		movem.l	d0-d1,(Scroll_flags_copy).w
		bsr.w	LoadTilesAsYouMove
		jsr	(HudUpdate).l
		bsr.w	ProcessDPLC
		rts
; ===========================================================================
; loc_F88: VintSubE:
Vint_UnusedE:
		bsr.w	Do_ControllerPal
		addq.b	#1,(v_vbla_0e_counter).w
		move.b	#VintID_UnusedE,(v_vbla_routine).w
		rts
; ===========================================================================
; loc_F98: VintSub12:
Vint_Fade:
		bsr.w	Do_ControllerPal
		move.w	(v_hbla_hreg).w,(a5)
		bra.w	ProcessDPLC
; ===========================================================================
; loc_FA4: VintSub16:
Vint_SSResults:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		writeCRAM	v_palette,0
		writeVRAM	Sprite_Table,vram_sprites
		writeVRAM	v_hscrolltablebuffer,vram_hscroll
		startZ80
		tst.w	(v_generictimer).w
		beq.w	.end
		subq.w	#1,(v_generictimer).w

.end:
		rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_103C:
Do_ControllerPal:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w
		bne.s	loc_107E
		writeCRAM	v_palette,0
		bra.s	loc_10A2
; ---------------------------------------------------------------------------

loc_107E:
		writeCRAM	v_palette_water,0

loc_10A2:
		writeVRAM	Sprite_Table,vram_sprites
		writeVRAM	v_hscrolltablebuffer,vram_hscroll
		startZ80
		rts
; End of function Do_ControllerPal

; ||||||||||||||| E N D   O F   V - I N T |||||||||||||||||||||||||||||||||||

; ===========================================================================
; Start of H-INT code
H_Int:
		tst.w	(f_hbla_pal).w
		beq.w	locret_1184
		tst.w	(Two_player_mode).w
		beq.w	PalToCRAM
		move.w	#0,(f_hbla_pal).w
		move.l	a5,-(sp)
		move.l	d0,-(sp)

loc_110E:
		move.w	(vdp_control_port).l,d0
		andi.w	#%0100,d0
		beq.s	loc_110E
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		move.w	#$8200+(vram_fg_2p>>10),(vdp_control_port).l
		move.l	#$40000010,(vdp_control_port).l
		move.l	(Camera_X_pos_copy).w,(vdp_data_port).l
		writeVRAM	Sprite_Table_2P,vram_sprites

loc_1166:
		move.w	(vdp_control_port).l,d0
		andi.w	#%0100,d0
		beq.s	loc_1166
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		move.l	(sp)+,d0
		movea.l	(sp)+,a5

locret_1184:
		rte

; ---------------------------------------------------------------------------
; loc_1188:
PalToCRAM:
		disable_ints
		move.w	#0,(f_hbla_pal).w
		movem.l	a0-a1,-(sp)
		lea	(vdp_data_port).l,a1
		lea	(v_palette_water).w,a0		; load palette from RAM
		move.l	#$C0000000,4(a1)		; set VDP to write to CRAM address $00
	rept (v_palette_water_end-v_palette_water)/4
		move.l	(a0)+,(a1)			; move palette to CRAM (all 64 colors at once)
	endr
		move.w	#$8A00+224-1,4(a1)		; write %1101 %1111 to register 10 (interrupt every 224th line)
		movem.l	(sp)+,a0-a1
		tst.b	(f_doupdatesinhblank).w
		bne.s	Hint_SoundDriver
		rte
; ===========================================================================
; loc_11F8:
Hint_SoundDriver:
		clr.b	(f_doupdatesinhblank).w
		movem.l	d0-a6,-(sp)
		bsr.w	Do_Updates
		jsr	(UpdateMusic).l
		movem.l	(sp)+,d0-a6
		rte

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to initialize joypads
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


JoypadInit:
		stopZ80
		waitZ80
		moveq	#$40,d0
		move.b	d0,(port_1_control).l
		move.b	d0,(port_2_control).l
		move.b	d0,(expansion_control).l
		startZ80
		rts
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


ReadJoypads:
		lea	(v_jpadhold1).w,a0		; address where joypad states are written
		lea	(port_1_data).l,a1		; first joypad port
		bsr.s	Joypad_Read			; do the first joypad
		addq.w	#port_2_data-port_1_data,a1	; do the second joypad

Joypad_Read:
		move.b	#0,(a1)
		nop
		nop
		move.b	(a1),d0
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)
		nop
		nop
		move.b	(a1),d1
		andi.b	#$3F,d1
		or.b	d1,d0
		not.b	d0
		move.b	(a0),d1
		eor.b	d0,d1
		move.b	d0,(a0)+
		and.b	d0,d1
		move.b	d1,(a0)+
		rts
; End of function ReadJoypads


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


VDPSetupGame:
		lea	(vdp_control_port).l,a0
		lea	(vdp_data_port).l,a1
		lea	(VDPSetupArray).l,a2
		moveq	#bytesToWcnt(VDPSetupArray_End-VDPSetupArray),d7

VDP_Loop:
		move.w	(a2)+,(a0)
		dbf	d7,VDP_Loop
		move.w	(VDPSetupArray+2).l,d0
		move.w	d0,(v_vdp_buffer1).w
		move.w	#$8A00+224-1,(v_hbla_hreg).w
		moveq	#0,d0
		move.l	#$40000010,(vdp_control_port).l	; write to VRAM port
		move.w	d0,(a1)
		move.w	d0,(a1)
		move.l	#$C0000000,(vdp_control_port).l	; write to CRAM port
		move.w	#bytesToWcnt(palette_size),d7	; get palette size

VDP_ClrCRAM:
		move.w	d0,(a1)
		dbf	d7,VDP_ClrCRAM
		clr.l	(v_scrposy_vdp).w
		clr.l	(v_scrposx_vdp).w
		move.l	d1,-(sp)
		fillVRAM	0,0,$10000	; clear the entirety of VRAM
		move.l	(sp)+,d1
		rts
; End of function VDPSetupGame

; ===========================================================================
VDPSetupArray:
		dc.w $8004				; H-INT disabled
		dc.w $8100+%00110100	; Mega Drive display, DMA enabled, V-INT enabled
		dc.w $8200+(vram_fg>>10)		; PNT A base: $C000
		dc.w $8300+(vram_window>>10)	; PNT W base: $A000
		dc.w $8400+(vram_bg>>13)		; PNT B base: $E000
		dc.w $8500+(vram_sprites>>9)	; Sprite attribute table base: $F800
		dc.w $8600
		dc.w $8700				; Background palette/color: 0/0
		dc.w $8800
		dc.w $8900
		dc.w $8A00				; H-INT every scanline
		dc.w $8B00				; EXT-INT off, V scroll by screen, H scroll by screen
		dc.w $8C00+%10000001	; H res 40 cells, no interlace, S/H disabled
		dc.w $8D00+(vram_hscroll>>10)
		dc.w $8E00
		dc.w $8F02				; VRAM pointer increment: $0002
		dc.w $9000+%0001		; Scroll table size: 64x32
		dc.w $9100				; Disable window
		dc.w $9200				; Disable window
VDPSetupArray_End:

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


ClearScreen:
		fillVRAM	0, vram_fg, vram_fg+plane_size_64x32 ; clear foreground namespace
		fillVRAM	0, vram_bg, vram_bg+plane_size_64x32 ; clear background namespace

		clr.l	(v_scrposy_vdp).w
		clr.l	(v_scrposx_vdp).w
	if FixBugs
		clearRAM Sprite_Table,Sprite_Table_end
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end_padded
	else
		clearRAM Sprite_Table,Sprite_Table_end+4 ; Clears too much RAM, clearing the first 4 bytes of v_palette_water.
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end_padded+4 ; Clears too much RAM, clearing the first 4 bytes of v_objspace.
	endif
		rts
; End of function ClearScreen

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load the compressed DAC driver
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_380
DACDriverLoad:
		nop
		stopZ80
		resetZ80
		lea	(DACDriver).l,a0
		lea	(z80_ram).l,a1
		bsr.w	KosDec
		resetZ80a
		nop
		nop
		nop
		nop
		resetZ80
		startZ80
		rts
; End of function DACDriverLoad


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; PlaySound:
QueueSound1:
		move.b	d0,(v_snddriver_ram.v_soundqueue0).w
		rts
; End of function PlaySound


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


QueueSound2:
		move.b	d0,(v_snddriver_ram.v_soundqueue1).w
		rts
; End of function QueueSound2


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; PlaySound_Unused:
QueueSound3:
		move.b	d0,(v_snddriver_ram.v_soundqueue2).w
		rts
; End of functions QueueSound3


		include	"_Include/PauseGame.asm"

; ---------------------------------------------------------------------------
; Subroutine to transfer a plane map to VRAM
; ---------------------------------------------------------------------------

; control register:
;    CD1 CD0 A13 A12 A11 A10 A09 A08     (D31-D24)
;    A07 A06 A05 A04 A03 A02 A01 A00     (D23-D16)
;     ?   ?   ?   ?   ?   ?   ?   ?      (D15-D8)
;    CD5 CD4 CD3 CD2  ?   ?  A15 A14     (D7-D0)
;
;	A00-A15 - address
;	CD0-CD3 - code
;	CD4 - 1 if VRAM copy DMA mode. 0 otherwise.
;	CD5 - DMA operation
;
;	Bits CD3-CD0:
;	0000 - VRAM read
;	0001 - VRAM write
;	0011 - CRAM write
;	0100 - VSRAM read
;	0101 - VSRAM write
;	1000 - CRAM read
;
; d0 = control register
; d1 = width
; d2 = heigth
; a1 = source address

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ShowVDPGraphics: PlaneMapToVRAM:
PlaneMapToVRAM_H40:
		lea	(vdp_data_port).l,a6
		move.l	#$800000,d4

PlaneMapToVRAM_H40_LineLoop:
		move.l	d0,4(a6)
		move.w	d1,d3

PlaneMapToVRAM_H40_TileLoop:
		move.w	(a1)+,(a6)
		dbf	d3,PlaneMapToVRAM_H40_TileLoop
		add.l	d4,d0
		dbf	d2,PlaneMapToVRAM_H40_LineLoop
		rts
; End of function PlaneMapToVRAM_H40

		include "_Include/DMA Queue.asm"
		include "_Include/Nemesis Decompression.asm"

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
; Subroutine to load pattern load cues (aka to queue pattern load requests)
; ---------------------------------------------------------------------------

; ARGUMENTS
; d0 = index of PLC list (see ArtLoadCues)

; NOTICE: This subroutine does not check for buffer overruns. The programmer
;	  (or hacker) is responsible for making sure that no more than
;	  16 load requests are copied into the buffer.
;    _________DO NOT PUT MORE THAN 16 LOAD REQUESTS IN A LIST!__________
;         (or if you change the size of v_plc_buffer, the limit becomes (v_plc_buffer_Only_End-v_plc_buffer)/6)

; PLCLoad:
LoadPLC:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		lea	(v_plc_buffer).w,a2

loc_1688:
		tst.l	(a2)
		beq.s	loc_1690
		addq.w	#6,a2
		bra.s	loc_1688
; ---------------------------------------------------------------------------

loc_1690:
		move.w	(a1)+,d0
		bmi.s	loc_169C

loc_1694:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		dbf	d0,loc_1694

loc_169C:
		movem.l	(sp)+,a1-a2
		rts
; End of function LoadPLC


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; Queue pattern load requests, but clear the PLQ first

; ARGUMENTS
; d0 = index of PLC list (see ArtLoadCues)

; NOTICE: This subroutine does not check for buffer overruns. The programmer
;	  (or hacker) is responsible for making sure that no more than
;	  16 load requests are copied into the buffer.
;	  _________DO NOT PUT MORE THAN 16 LOAD REQUESTS IN A LIST!__________
;         (or if you change the size of v_plc_buffer, the limit becomes (v_plc_buffer_Only_End-v_plc_buffer)/6)

NewPLC:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		bsr.s	ClearPLC
		lea	(v_plc_buffer).w,a2
		move.w	(a1)+,d0
		bmi.s	loc_16C8

loc_16C0:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		dbf	d0,loc_16C0

loc_16C8:
		movem.l	(sp)+,a1-a2
		rts
; End of function NewPLC


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Clear the pattern load queue ($FFF680 - $FFF700)

ClearPLC:
		lea	(v_plc_buffer).w,a2
		moveq	#bytesToLcnt(v_plc_buffer_end-v_plc_buffer),d0

loc_16D4:
		clr.l	(a2)+
		dbf	d0,loc_16D4
		rts
; End of function ClearPLC


; ---------------------------------------------------------------------------
; Subroutine to use graphics listed in a pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; RunPLC:
RunPLC_RAM:
		tst.l	(v_plc_buffer).w
		beq.s	locret_1730
		tst.w	(v_plc_patternsleft).w
		bne.s	locret_1730
		movea.l	(v_plc_buffer).w,a0
		lea	NemPCD_WriteRowToVDP(pc),a3
		nop
		lea	(v_ngfx_buffer).w,a1
		move.w	(a0)+,d2
		bpl.s	loc_16FE
		adda.w	#NemPCD_WriteRowToVDP_XOR-NemPCD_WriteRowToVDP,a3

loc_16FE:
		andi.w	#$7FFF,d2
	if FixBugs=0
		; There is a bug here where the game can crash if a race condition occurs with pattern load cues.
		; Read more about this bug at https://info.sonicretro.org/SCHG_How-to:Fix_a_race_condition_with_Pattern_Load_Cues
		move.w	d2,(v_plc_patternsleft).w
	endif
		bsr.w	NemDec_BuildCodeTable
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6
		moveq	#0,d0
		move.l	a0,(v_plc_buffer).w
		move.l	a3,(v_plc_ptrnemcode).w
		move.l	d0,(v_plc_repeatcount).w
		move.l	d0,(v_plc_paletteindex).w
		move.l	d0,(v_plc_previousrow).w
		move.l	d5,(v_plc_dataword).w
		move.l	d6,(v_plc_shiftvalue).w
	if FixBugs
		move.w	d2,(v_plc_patternsleft).w
	endif

locret_1730:
		rts
; End of function RunPLC_RAM


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; Process one PLC from the queue

; sub_1732:
ProcessDPLC:
		tst.w	(v_plc_patternsleft).w
		beq.w	locret_17CA
		move.w	#9,(v_plc_framepatternsleft).w
		moveq	#0,d0
		move.w	(v_plc_buffer+4).w,d0
		addi.w	#$120,(v_plc_buffer+4).w
		bra.s	ProcessDPLC_Main

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; Process one PLC from the queue

; loc_174E:
ProcessDPLC2:
		tst.w	(v_plc_patternsleft).w
		beq.s	locret_17CA
		move.w	#3,(v_plc_framepatternsleft).w
		moveq	#0,d0
		move.w	(v_plc_buffer+4).w,d0
		addi.w	#$60,(v_plc_buffer+4).w
; loc_1766:
ProcessDPLC_Main:
		lea	(vdp_control_port).l,a4
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,(a4)
		subq.w	#4,a4
		movea.l	(v_plc_buffer).w,a0
		movea.l	(v_plc_ptrnemcode).w,a3
		move.l	(v_plc_repeatcount).w,d0
		move.l	(v_plc_paletteindex).w,d1
		move.l	(v_plc_previousrow).w,d2
		move.l	(v_plc_dataword).w,d5
		move.l	(v_plc_shiftvalue).w,d6
		lea	(v_ngfx_buffer).w,a1

loc_179A:
		movea.w	#8,a5
		bsr.w	NemPCD_NewRow
		subq.w	#1,(v_plc_patternsleft).w
		beq.s	ProcessDPLC_Pop
		subq.w	#1,(v_plc_framepatternsleft).w
		bne.s	loc_179A
		move.l	a0,(v_plc_buffer).w
		move.l	a3,(v_plc_ptrnemcode).w
		move.l	d0,(v_plc_repeatcount).w
		move.l	d1,(v_plc_paletteindex).w
		move.l	d2,(v_plc_previousrow).w
		move.l	d5,(v_plc_dataword).w
		move.l	d6,(v_plc_shiftvalue).w

locret_17CA:
		rts
; ===========================================================================
; pop one request off the buffer so that the next one can be filled
; loc_17CC:
ProcessDPLC_Pop:
		lea	(v_plc_buffer).w,a0
		moveq	#bytesToLcnt(v_plc_buffer_only_end-v_plc_buffer-6),d0

loc_17D2:
		move.l	6(a0),(a0)+
		dbf	d0,loc_17D2

	if FixBugs
		; The above code does not properly 'pop' the 16th PLC entry.
		; Because of this, occupying the 16th slot will cause it to
		; be repeatedly decompressed infinitely.
		; Granted, this could be conisdered more of an optimisation
		; than a bug: treating the 16th entry as a dummy that
		; should never be occupied makes this code unnecessary.
		; Still, the overhead of this code is minimal.
	if (v_plc_buffer_only_end-v_plc_buffer-6)&2
		move.w	6(a0),(a0)
	endif

		clr.l	(v_plc_buffer_only_end-6).w
	endif
		rts
; End of function ProcessDPLC


; ---------------------------------------------------------------------------
; Subroutine to execute a pattern load cue directly from the ROM
; rather than loading them into the queue first
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


QuickPLC:
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,d1

loc_17EE:
		movea.l	(a1)+,a0
		moveq	#0,d0
		move.w	(a1)+,d0
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,(vdp_control_port).l
		bsr.w	NemDec
		dbf	d1,loc_17EE
		rts
; End of function QuickPLC

		include "_Include/Enigma Decompression.asm"
		include "_Include/Kosinski Decompression.asm"
		include "_Include/Kid Chameleon Decompression.asm"

		include	"_Include/PaletteCycle.asm"

Pal_HTZCyc2:	binclude "palette/Hill Top Lava Delay.bin"
		even
Pal_S1TitleCyc:	binclude "palette/S1 Title Water.bin"
		even
Pal_GHZCyc:	binclude "palette/GHZ Water.bin"
		even
Pal_EHZCyc:	binclude "palette/EHZ Water.bin"
		even
Pal_HTZCyc1:	binclude "palette/Hill Top Lava.bin"
		even
Pal_CPZCyc1:	binclude "palette/CPZ Cycle 1.bin"
		even
Pal_CPZCyc2:	binclude "palette/CPZ Cycle 2.bin"
		even
Pal_CPZCyc3:	binclude "palette/CPZ Cycle 3.bin"
		even
Pal_HPZCyc1:	binclude "palette/HPZ Water Cycle.bin"
		even
Pal_HPZCyc2:	binclude "palette/HPZ Underwater Cycle.bin"
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to fade in from black
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Pal_FadeTo:
Pal_FadeFromBlack:
		move.w	#$3F,(v_pfade_start).w
; Pal_FadeTo2:
Pal_FadeFromBlack2:
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#cBlack,d1
		move.b	(v_pfade_size).w,d0

loc_2162:
		move.w	d1,(a0)+
		dbf	d0,loc_2162			; fill palette with $000 (black)
		move.w	#$16-1,d4

loc_216C:
		move.b	#VintID_Fade,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.s	Pal_FadeIn
		bsr.w	RunPLC_RAM
		dbf	d4,loc_216C
		rts
; End of function Pal_FadeFromBlack

; ---------------------------------------------------------------------------
; Subroutine to update all colours once
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeIn:
		moveq	#0,d0
		lea	(v_palette).w,a0
		lea	(v_palette_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_2198:
		bsr.s	Pal_AddColor
		dbf	d0,loc_2198
		tst.b	(Water_flag).w
		beq.s	locret_21C0
		moveq	#0,d0
		lea	(v_palette_water).w,a0
		lea	(v_palette_water_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_21BA:
		bsr.s	Pal_AddColor
		dbf	d0,loc_21BA

locret_21C0:
		rts
; End of function Pal_FadeIn

; ---------------------------------------------------------------------------
; Subroutine to update a single colour once
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Pal_AddColor:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	Pal_AddNone
		move.w	d3,d1
		addi.w	#$200,d1
		cmp.w	d2,d1
		bhi.s	Pal_AddGreen
		move.w	d1,(a0)+
		rts
; ---------------------------------------------------------------------------

Pal_AddGreen:
		move.w	d3,d1
		addi.w	#$20,d1
		cmp.w	d2,d1
		bhi.s	Pal_AddRed
		move.w	d1,(a0)+
		rts
; ---------------------------------------------------------------------------

Pal_AddRed:
		addq.w	#2,(a0)+
		rts
; ---------------------------------------------------------------------------
; Pal_NoAdd:
Pal_AddNone:
		addq.w	#2,a0
		rts
; End of function Pal_AddColor


; ---------------------------------------------------------------------------
; Subroutine to fade out to black
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Pal_FadeFrom:
Pal_FadeToBlack:
		move.w	#$3F,(v_pfade_start).w
		move.w	#$16-1,d4

loc_21F8:
		move.b	#VintID_Fade,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.s	Pal_FadeOut
		bsr.w	RunPLC_RAM
		dbf	d4,loc_21F8
		rts
; End of function Pal_FadeFrom

; ---------------------------------------------------------------------------
; Subroutine to update all colours once
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeOut:
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_221E:
		bsr.s	Pal_DecColor
		dbf	d0,loc_221E
		moveq	#0,d0
		lea	(v_palette_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_2234:
		bsr.s	Pal_DecColor
		dbf	d0,loc_2234
		rts
; End of function Pal_FadeOut


; ---------------------------------------------------------------------------
; Subroutine to update a single colour once
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Pal_DecColor:
		move.w	(a0),d2
		beq.s	Pal_NoDec
		move.w	d2,d1
		andi.w	#$E,d1
		beq.s	Pal_DecGreen
		subq.w	#2,(a0)+
		rts
; ---------------------------------------------------------------------------

Pal_DecGreen:
		move.w	d2,d1
		andi.w	#$E0,d1
		beq.s	Pal_DecBlue
		subi.w	#$20,(a0)+
		rts
; ---------------------------------------------------------------------------

Pal_DecBlue:
		move.w	d2,d1
		andi.w	#$E00,d1
		beq.s	Pal_NoDec
		subi.w	#$200,(a0)+
		rts
; ---------------------------------------------------------------------------

Pal_NoDec:
		addq.w	#2,a0
		rts
; End of function Pal_DecColor


; =============== S U B	R O U T	I N E =======================================


Pal_MakeWhite:
		move.w	#$3F,(v_pfade_start).w
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.w	#cWhite,d1
		move.b	(v_pfade_size).w,d0

loc_2286:
		move.w	d1,(a0)+
		dbf	d0,loc_2286
		move.w	#$16-1,d4

loc_2290:
		move.b	#VintID_Fade,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.s	Pal_WhiteToBlack
		bsr.w	RunPLC_RAM
		dbf	d4,loc_2290
		rts
; End of function Pal_MakeWhite


; =============== S U B	R O U T	I N E =======================================


Pal_WhiteToBlack:
		moveq	#0,d0
		lea	(v_palette).w,a0
		lea	(v_palette_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_22BC:
		bsr.s	Pal_DecColor2
		dbf	d0,loc_22BC
		tst.b	(Water_flag).w
		beq.s	locret_22E4
		moveq	#0,d0
		lea	(v_palette_water).w,a0
		lea	(v_palette_water_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_22DE:
		bsr.s	Pal_DecColor2
		dbf	d0,loc_22DE

locret_22E4:
		rts
; End of function Pal_WhiteToBlack


; =============== S U B	R O U T	I N E =======================================


Pal_DecColor2:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	loc_2312
		move.w	d3,d1
		subi.w	#$200,d1
		blo.s	loc_22FE
		cmp.w	d2,d1
		blo.s	loc_22FE
		move.w	d1,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_22FE:
		move.w	d3,d1
		subi.w	#$20,d1
		blo.s	loc_230E
		cmp.w	d2,d1
		blo.s	loc_230E
		move.w	d1,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_230E:
		subq.w	#2,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_2312:
		addq.w	#2,a0
		rts
; End of function Pal_DecColor2


; =============== S U B	R O U T	I N E =======================================


Pal_MakeFlash:
		move.w	#$3F,(v_pfade_start).w
		move.w	#$16-1,d4

loc_2320:
		move.b	#VintID_Fade,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.s	Pal_ToWhite
		bsr.w	RunPLC_RAM
		dbf	d4,loc_2320
		rts
; End of function Pal_MakeFlash


; =============== S U B	R O U T	I N E =======================================


Pal_ToWhite:
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_2346:
		bsr.s	Pal_AddColor2
		dbf	d0,loc_2346
		moveq	#0,d0
		lea	(v_palette_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_235C:
		bsr.s	Pal_AddColor2
		dbf	d0,loc_235C
		rts
; End of function Pal_ToWhite


; =============== S U B	R O U T	I N E =======================================


Pal_AddColor2:
		move.w	(a0),d2
		cmpi.w	#$EEE,d2
		beq.s	loc_23A0
		move.w	d2,d1
		andi.w	#$E,d1
		cmpi.w	#$E,d1
		beq.s	loc_237C
		addq.w	#2,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_237C:
		move.w	d2,d1
		andi.w	#$E0,d1
		cmpi.w	#$E0,d1
		beq.s	loc_238E

loc_2388:
		addi.w	#$20,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_238E:
		move.w	d2,d1
		andi.w	#$E00,d1
		cmpi.w	#$E00,d1
		beq.s	loc_23A0
		addi.w	#$200,(a0)+
		rts
; ---------------------------------------------------------------------------

loc_23A0:
		addq.w	#2,a0
		rts
; End of function Pal_AddColor2


; =============== S U B	R O U T	I N E =======================================


PalCycle_Sega:
		tst.b	(v_pcyc_time+1).w
		bne.s	loc_2404
		lea	(v_palette_line_2).w,a1
		lea	(Pal_Sega1).l,a0
		moveq	#5,d1
		move.w	(v_pcyc_num).w,d0

loc_23BA:
		bpl.s	loc_23C4
		addq.w	#2,a0
		subq.w	#1,d1
		addq.w	#2,d0
		bra.s	loc_23BA
; ---------------------------------------------------------------------------

loc_23C4:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_23CE
		addq.w	#2,d0

loc_23CE:
		cmpi.w	#$60,d0
		bhs.s	loc_23D8
		move.w	(a0)+,(a1,d0.w)

loc_23D8:
		addq.w	#2,d0
		dbf	d1,loc_23C4
		move.w	(v_pcyc_num).w,d0
		addq.w	#2,d0
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_23EE
		addq.w	#2,d0

loc_23EE:
		cmpi.w	#$64,d0
		blt.s	loc_23FC
		move.w	#$401,(v_pcyc_time).w
		moveq	#-$C,d0

loc_23FC:
		move.w	d0,(v_pcyc_num).w
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------

loc_2404:
		subq.b	#1,(v_pcyc_time).w
		bpl.s	loc_2456
		move.b	#4,(v_pcyc_time).w
		move.w	(v_pcyc_num).w,d0
		addi.w	#$C,d0
		cmpi.w	#$30,d0
		blo.s	loc_2422
		moveq	#0,d0
		rts
; ---------------------------------------------------------------------------

loc_2422:
		move.w	d0,(v_pcyc_num).w
		lea	(Pal_Sega2).l,a0
		lea	(a0,d0.w),a0
		lea	(v_palette_line_1+4).w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)
		lea	(v_palette_line_2).w,a1
		moveq	#0,d0
		moveq	#$2C,d1

loc_2442:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_244C
		addq.w	#2,d0

loc_244C:
		move.w	(a0),(a1,d0.w)
		addq.w	#2,d0
		dbf	d1,loc_2442

loc_2456:
		moveq	#1,d0
		rts
; End of function PalCycle_Sega

; ---------------------------------------------------------------------------
Pal_Sega1:	binclude "palette/Sega1.bin"
		even
Pal_Sega2:	binclude "palette/Sega2.bin"
		even

; =============== S U B	R O U T	I N E =======================================


PalLoad1:
		lea	(Pal_Index).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		adda.w	#v_palette_fading-v_palette,a3
		move.w	(a1)+,d7

.loop:
		move.l	(a2)+,(a3)+
		dbf	d7,.loop
		rts
; End of function PalLoad1


; =============== S U B	R O U T	I N E =======================================


PalLoad2:
		lea	(Pal_Index).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		move.w	(a1)+,d7

.loop:
		move.l	(a2)+,(a3)+
		dbf	d7,.loop
		rts
; End of function PalLoad2


; =============== S U B	R O U T	I N E =======================================


PalLoad3_Water:
		lea	(Pal_Index).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		suba.w	#v_palette-v_palette_water,a3
		move.w	(a1)+,d7

.loop:
		move.l	(a2)+,(a3)+
		dbf	d7,.loop
		rts
; End of function PalLoad3_Water


; =============== S U B	R O U T	I N E =======================================


PalLoad4_Water:
		lea	(Pal_Index).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		suba.w	#v_palette-v_palette_water_fading,a3
		move.w	(a1)+,d7

.loop:
		move.l	(a2)+,(a3)+
		dbf	d7,.loop
		rts
; End of function PalLoad4_Water

; ===========================================================================

		include	"_Include/Palette Index.asm"

; ---------------------------------------------------------------------------
; Palette data
; ---------------------------------------------------------------------------
Pal_SegaBG:	binclude	"palette/Sega Background.bin"
		even
Pal_Title:	binclude	"palette/Title Screen.bin"
		even
Pal_LevelSel:	binclude	"palette/Level Select.bin"
		even
Pal_SonicTails:	binclude	"palette/Sonic and Tails.bin"
		even
Pal_GHZ:	binclude	"palette/GHZ.bin"
		even
Pal_HPZWater:	binclude	"palette/HPZ Underwater.bin"
		even
Pal_CPZ:	binclude	"palette/CPZ.bin"
		even
Pal_EHZ:	binclude	"palette/EHZ.bin"
		even
Pal_HPZ:	binclude	"palette/HPZ.bin"
		even
Pal_HTZ:	binclude	"palette/HTZ.bin"
		even
Pal_S1SpecialStage:	binclude	"palette/S1 Special Stage.bin"
		even
Pal_LZ4:	binclude	"palette/LZ4.bin"
		even
Pal_LZ4Water:	binclude	"palette/LZ4 Underwater.bin"
		even
Pal_LZSonicWater:	binclude	"palette/LZ Sonic Underwater.bin"
		even
Pal_LZ4SonicWater:	binclude	"palette/LZ4 Sonic Underwater.bin"
		even
Pal_S1SpeResults:	binclude	"palette/S1 Special Stage Results.bin"
		even
Pal_S1Continue:	binclude	"palette/S1 Continue Screen.bin"
		even
Pal_S1Ending:	binclude	"palette/S1 Ending.bin"
		even

		jmpTos	; Empty

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to perform vertical synchronization
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; DelayProgram:
WaitForVint:
		enable_ints

loc_2C88:
		tst.b	(v_vbla_routine).w
		bne.s	loc_2C88
		rts
; End of function WaitForVint

; ---------------------------------------------------------------------------
; Subroutine to generate a pseudo-random number in d0
; d0 = (RNG & $FFFF0000) | ((RNG*41 & $FFFF) + ((RNG*41 & $FFFF0000) >> 16))
; RNG = ((RNG*41 + ((RNG*41 & $FFFF) << 16)) & $FFFF0000) | (RNG*41 & $FFFF)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; PseudoRandomNumber:
RandomNumber:
		move.l	(v_random).w,d1
		bne.s	loc_2C9C
		move.l	#$2A6D365A,d1

loc_2C9C:
		; set the high word of d0 to be the high word of the RNG
		; and multiply the RNG by 41
		move.l	d1,d0
		asl.l	#2,d1
		add.l	d0,d1
		asl.l	#3,d1
		add.l	d0,d1

		; add the low word of the RNG to the high word of the RNG
		; and set the low word of d0 to be the result
		move.w	d1,d0
		swap	d1
		add.w	d1,d0
		move.w	d0,d1
		swap	d1

		move.l	d1,(v_random).w
		rts
; End of function RandomNumber

; ---------------------------------------------------------------------------
; Subroutine to calculate sine and cosine of an angle
; d0 = input byte = angle (360 degrees == 256)
; d0 = output word = 255 * sine(angle)
; d1 = output word = 255 * cosine(angle)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


CalcSine:
		andi.w	#$FF,d0
		add.w	d0,d0
		addi.w	#$80,d0
		move.w	Sine_Data(pc,d0.w),d1		; cos
		subi.w	#$80,d0
		move.w	Sine_Data(pc,d0.w),d0		; sin
		rts
; End of function CalcSine

; ===========================================================================
Sine_Data:	binclude "misc/sinewave.bin"
		even

; ---------------------------------------------------------------------------
; Subroutine to calculate arctangent of y/x
; d1 = input x
; d2 = input y
; d0 = output angle (360 degrees == 256)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


CalcAngle:
		movem.l	d3-d4,-(sp)
		moveq	#0,d3
		moveq	#0,d4
		move.w	d1,d3
		move.w	d2,d4
		or.w	d3,d4
		beq.s	CalcAngle_Zero			; special case return if x and y are both 0
		move.w	d2,d4
		tst.w	d3				; calculate absolute value of x
		bpl.w	loc_2F68
		neg.w	d3

loc_2F68:
		tst.w	d4				; calculate absolute value of y
		bpl.w	loc_2F70
		neg.w	d4

loc_2F70:
		cmp.w	d3,d4
		bhs.w	loc_2F82
		lsl.l	#8,d4
		divu.w	d3,d4
		moveq	#0,d0
		move.b	AngleData(pc,d4.w),d0
		bra.s	loc_2F8C
; ---------------------------------------------------------------------------

loc_2F82:
		lsl.l	#8,d3
		divu.w	d4,d3
		moveq	#$40,d0
		sub.b	AngleData(pc,d3.w),d0

loc_2F8C:
		tst.w	d1
		bpl.w	loc_2F98
		neg.w	d0
		addi.w	#$80,d0

loc_2F98:
		tst.w	d2
		bpl.w	loc_2FA4
		neg.w	d0
		addi.w	#$100,d0

loc_2FA4:
		movem.l	(sp)+,d3-d4
		rts
; ===========================================================================
; loc_2FAA:
CalcAngle_Zero:
		move.w	#$40,d0
		movem.l	(sp)+,d3-d4
		rts
; End of function CalcAngle

; ===========================================================================
AngleData:	binclude "misc/angles.bin"
		even

		jmpTos	; Empty

; ===========================================================================
; ---------------------------------------------------------------------------
; Sega logo, exact same as Sonic 1's
; ---------------------------------------------------------------------------

SegaScreen:
		move.b	#bgm_Stop,d0
		bsr.w	QueueSound2
		bsr.w	ClearPLC
		bsr.w	Pal_FadeToBlack
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)
		move.w	#$8200+(vram_fg>>10),(a6)
		move.w	#$8400+(vram_bg>>13),(a6)
		move.w	#$8700,(a6)
		move.w	#$8B00,(a6)
		move.w	#$8C81,(a6)
		clr.b	(f_wtr_state).w
		disable_ints
		disable_display
		bsr.w	ClearScreen
		locVRAM ArtTile_Sega_Tiles*tile_size
		lea	(Nem_SegaLogo).l,a0
		bsr.w	NemDec
		lea	(v_ram_start).l,a1
		lea	(Eni_SegaLogo).l,a0
		move.w	#make_art_tile(ArtTile_Sega_Tiles,0,0),d0
		bsr.w	EniDec
		copyTilemap	v_ram_start,vram_bg+$510,24,8
		copyTilemap	v_ram_start+$180,vram_fg,40,28
		tst.b	(v_megadrive).w			; is console Japanese?
		bmi.s	loc_316A			; if not, branch
		copyTilemap	v_ram_start+$A40,vram_fg+$53A,3,2 ; hide "TM" with a white rectangle

loc_316A:
		moveq	#palid_SegaBG,d0
		bsr.w	PalLoad2
		move.w	#-$A,(v_pcyc_num).w
		move.w	#0,(v_pcyc_time).w
		move.w	#0,(v_pal_buffer+$12).w
		move.w	#0,(v_pal_buffer+$10).w
		enable_display

Sega_WaitPalette:
		move.b	#VintID_SEGA,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	PalCycle_Sega
		bne.s	Sega_WaitPalette

		move.b	#sfx_Sega,d0
		bsr.w	QueueSound2
		move.b	#VintID_PCM,(v_vbla_routine).w
		bsr.w	WaitForVint
		move.w	#30,(v_generictimer).w

Sega_WaitEnd:
		move.b	#VintID_SEGA,(v_vbla_routine).w
		bsr.w	WaitForVint
		tst.w	(v_generictimer).w
		beq.s	Sega_GoToTitleScreen
		andi.b	#btnStart,(v_jpadpress1).w
		beq.s	Sega_WaitEnd

Sega_GoToTitleScreen:
		move.b	#GameModeID_TitleScreen,(v_gamemode).w
		rts
; ===========================================================================

		jmpTos0	; Empty

; ===========================================================================

TitleScreen:
		move.b	#bgm_Stop,d0
		bsr.w	QueueSound2
		bsr.w	ClearPLC
		bsr.w	Pal_FadeToBlack
		disable_ints
		bsr.w	DACDriverLoad
		lea	(vdp_control_port).l,a6
		move.w	#$8000+%0100,(a6)
		move.w	#$8200+(vram_fg>>10),(a6)
		move.w	#$8400+(vram_bg>>13),(a6)
		move.w	#$9001,(a6)
		move.w	#$9200,(a6)
		move.w	#$8B00+%0011,(a6)
		move.w	#$8720,(a6)
		clr.b	(f_wtr_state).w
		move.w	#$8C00+%10000001,(a6)
		bsr.w	ClearScreen

		clearRAM v_spritequeue,v_spritequeue_end
		clearRAM v_objspace,v_objend
		clearRAM v_levelvariables,v_levelvariables_end
		clearRAM Camera_RAM,Camera_RAM_End
		clearRAM v_palette_fading,v_palette_fading_end

		moveq	#palid_SonicTails,d0
		bsr.w	PalLoad1
		bsr.w	Pal_FadeFromBlack
		disable_ints
		locVRAM	ArtTile_Title_Foreground*tile_size
		lea	(Nem_Title).l,a0
		bsr.w	NemDec
		locVRAM	ArtTile_Title_Sonic_And_Tails*tile_size
		lea	(Nem_TitleSonicTails).l,a0
		bsr.w	NemDec
		lea	(vdp_data_port).l,a6
		locVRAM	ArtTile_Level_Select_Font*tile_size,4(a6)
		lea	(Art_Text).l,a5
		move.w	#bytesToWcnt(Art_Text_End-Art_Text),d1

loc_32C4:
		move.w	(a5)+,(a6)
		dbf	d1,loc_32C4

		nop
		move.b	#0,(v_lastlamp).w
		move.w	#0,(Debug_placement_mode).w
		move.w	#0,(f_demo).w
		move.w	#0,(word_FFEA).w
		move.w	#id_GHZ<<8,(Current_ZoneAndAct).w
		move.w	#0,(v_pcyc_time).w
		bsr.w	Pal_FadeToBlack
		disable_ints
		lea	(v_ram_start).l,a1
		lea	(Eni_TitleMap).l,a0
		move.w	#make_art_tile(ArtTile_Title_Foreground,0,0),d0
		bsr.w	EniDec

		copyTilemap	v_ram_start,vram_fg,40,28

		lea	(v_ram_start).l,a1
		lea	(Eni_TitleBg1).l,a0
		move.w	#make_art_tile(ArtTile_Title_Foreground,0,0),d0
		bsr.w	EniDec

		copyTilemap	v_ram_start,vram_bg,32,28

		lea	(v_ram_start).l,a1
		lea	(Eni_TitleBg2).l,a0
		move.w	#make_art_tile(ArtTile_Title_Foreground,0,0),d0
		bsr.w	EniDec

		copyTilemap	v_ram_start,vram_bg+64,32,28

		moveq	#palid_Title,d0
		bsr.w	PalLoad1
		move.b	#bgm_Title,d0
		bsr.w	QueueSound2
		move.b	#0,(Debug_mode_flag).w
		move.w	#0,(Two_player_mode).w
		move.w	#376,(v_generictimer).w

		clearRAM v_titletails,v_titletails+object_size

		move.b	#id_Obj0E,(v_titlesonic).w
		move.b	#id_Obj0E,(v_titletails).w
		move.b	#1,(v_titletails+obFrame).w
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		moveq	#plcid_Main,d0
		bsr.w	NewPLC
		move.w	#0,(v_title_dcount).w
		move.w	#0,(v_title_ccount).w
		move.w	#id_EHZ<<8,(Current_ZoneAndAct).w
		move.w	#4,(Sonic_Pos_Record_Index).w
		move.w	#0,(Sonic_Pos_Record_Buf).w
		enable_display
		bsr.w	Pal_FadeFromBlack

TitleScreen_Loop:
		move.b	#VintID_Title,(v_vbla_routine).w
		bsr.w	WaitForVint
		jsr	(ExecuteObjects).l
		bsr.w	Deform_TitleScreen
		jsr	(BuildSprites).l
		bsr.w	RunPLC_RAM
		tst.b	(v_megadrive).w
		bpl.s	Title_RegionJ
		lea	(LvlSelCode_US).l,a0
		bra.s	LevelSelectCheat
; ---------------------------------------------------------------------------

Title_RegionJ:
		lea	(LvlSelCode_J).l,a0

LevelSelectCheat:
		move.w	(v_title_dcount).w,d0
		adda.w	d0,a0
		move.b	(v_jpadpress1).w,d0
		andi.b	#btnUp+btnDn+btnL+btnR,d0
		cmp.b	(a0),d0
		bne.s	Title_Cheat_NoMatch
		addq.w	#1,(v_title_dcount).w
		tst.b	d0
		bne.s	Title_Cheat_CountC
		lea	(f_levselcheat).w,a0
		move.w	(v_title_ccount).w,d1
		lsr.w	#1,d1
		andi.w	#3,d1
		beq.s	Title_Cheat_PlayRing
		tst.b	(v_megadrive).w
		bpl.s	Title_Cheat_PlayRing
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)

Title_Cheat_PlayRing:
		move.b	#1,(a0,d1.w)
		move.b	#sfx_Ring,d0
		bsr.w	QueueSound2
		bra.s	Title_Cheat_CountC
; ---------------------------------------------------------------------------

Title_Cheat_NoMatch:
		tst.b	d0
		beq.s	Title_Cheat_CountC
		cmpi.w	#9,(v_title_dcount).w
		beq.s	Title_Cheat_CountC
		move.w	#0,(v_title_dcount).w

Title_Cheat_CountC:
		move.b	(v_jpadpress1).w,d0
		andi.b	#btnC,d0
		beq.s	Title_Cheat_NoC
		addq.w	#1,(v_title_ccount).w

Title_Cheat_NoC:
		tst.w	(v_generictimer).w
		beq.w	Demo
		andi.b	#btnStart,(v_jpadpress1).w
		beq.w	TitleScreen_Loop

Title_CheckLvlSel:
		tst.b	(f_levselcheat).w
		beq.w	PlayLevel

	if FixBugs
		; Fix the level selects graphics bug
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_Level_Select_graphics_bug
		move.b	#VintID_Title,(v_vbla_routine).w	; set routine 4 in V-Int
		bsr.w	WaitForVint		; run V-Blank one extra frame to prevent graphical glitches
	endif

		moveq	#palid_LevelSel,d0
		bsr.w	PalLoad2
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end
		move.l	d0,(v_scrposy_vdp).w
		disable_ints
		lea	(vdp_data_port).l,a6
		move.l	#$60000003,(vdp_control_port).l
		move.w	#bytesToLcnt($1000),d1

LevelSelect_ClearVRAM:
		move.l	d0,(a6)
		dbf	d1,LevelSelect_ClearVRAM
		bsr.w	LevSelTextLoad

; ---------------------------------------------------------------------------
; Level Select main loop
; ---------------------------------------------------------------------------

LevelSelect:
		move.b	#VintID_Title,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	LevelSelect_Controls
		bsr.w	RunPLC_RAM
		tst.l	(v_plc_buffer).w
		bne.s	LevelSelect
		andi.b	#btnABC+btnStart,(v_jpadpress1).w
		beq.s	LevelSelect
		move.w	#0,(Two_player_mode).w	; disable 2P mode
		btst	#bitB,(v_jpadhold1).w	; is button B held?
		beq.s	loc_3516	; if not, branch
		move.w	#1,(Two_player_mode).w	; enable 2P mode

loc_3516:
		move.w	(v_levselitem).w,d0
		cmpi.w	#$14,d0
		bne.s	loc_3570
		move.w	(v_levselsound).w,d0
		addi.w	#$80,d0
		tst.b	(f_creditscheat).w
		beq.s	loc_353A
		cmpi.w	#$9F,d0
		beq.s	loc_354C
		cmpi.w	#$9E,d0
		beq.s	loc_355A

loc_353A:
	if FixBugs=0
		; This is a workaround for a bug; see PlaySoundID for more.
		cmpi.w	#bgm__Last+1,d0		; is sound $80-$93 being played?
		blo.s	LevSel_PlaySnd		; if yes, branch
		cmpi.w	#sfx__First,d0		; is sound $94-$9F being played?
		blo.s	LevelSelect		; if yes, branch
LevSel_PlaySnd:
	endif

loc_3546:
		bsr.w	QueueSound2
		bra.s	LevelSelect
; ---------------------------------------------------------------------------

loc_354C:
		move.b	#GameModeID_S1Ending,(v_gamemode).w
		move.w	#id_EndZ<<8,(Current_ZoneAndAct).w
		rts
; ---------------------------------------------------------------------------

loc_355A:
		move.b	#GameModeID_S1Credits,(v_gamemode).w
		move.b	#bgm_Credits,d0
		bsr.w	QueueSound2
		move.w	#0,(v_creditsnum).w
		rts
; ---------------------------------------------------------------------------

loc_3570:
		add.w	d0,d0
		move.w	LevSel_Ptrs(pc,d0.w),d0
		bmi.w	LevelSelect
		cmpi.w	#id_SS<<8,d0
		bne.s	LevelSelect_Level
		move.b	#GameModeID_SpecialStage,(v_gamemode).w
		clr.w	(Current_ZoneAndAct).w
		move.b	#3,(v_lives).w
		moveq	#0,d0
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.l	d0,(v_score).w
		move.l	#5000,(v_scorelife).w
		rts
; ---------------------------------------------------------------------------
LevSel_Ptrs:
		dc.b id_GHZ,0
		dc.b id_GHZ,1
		dc.b id_GHZ,2
		dc.b id_MZ,0
		dc.b id_MZ,1
		dc.b id_MZ,2
		dc.b id_HPZ,0
		dc.b id_HPZ,1
		dc.b id_HPZ,2
		dc.b id_LZ,0
		dc.b id_LZ,1
		dc.b id_LZ,2
		dc.b id_EHZ,0
		dc.b id_EHZ,1
		dc.b id_EHZ,2
		dc.b id_HTZ,0
		dc.b id_HTZ,1
		dc.b id_LZ,3
		dc.b id_HTZ,2
		dc.b id_SS,0
		dc.w $8000
; ---------------------------------------------------------------------------

LevelSelect_Level:
		andi.w	#$3FFF,d0
		move.w	d0,(Current_ZoneAndAct).w

PlayLevel:
		move.b	#GameModeID_Level,(v_gamemode).w
		move.b	#3,(v_lives).w
		moveq	#0,d0
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.l	d0,(v_score).w
		move.b	d0,(v_lastspecial).w
		move.b	d0,(v_emeralds).w
		move.l	d0,(v_emldlist).w
		move.l	d0,(v_emldlist+4).w
		move.b	d0,(v_continues).w
		move.l	#5000,(v_scorelife).w
		move.b	#bgm_Fade,d0
		bsr.w	QueueSound2
		rts
; ---------------------------------------------------------------------------
LvlSelCode_J:	dc.b btnUp, btnDn, btnDn, btnDn, btnDn, btnUp, 0, $FF	; up, down, down, down, down, up
LvlSelCode_US:	dc.b btnUp, btnDn, btnDn, btnDn, btnDn, btnUp, 0, $FF	; up, down, down, down, down, up
; ---------------------------------------------------------------------------

Demo:
		move.w	#30,(v_generictimer).w

loc_3630:
		move.b	#VintID_Title,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	RunPLC_RAM
		move.w	(v_objspace+obX).w,d0
		addq.w	#2,d0
		move.w	d0,(v_objspace+obX).w
		cmpi.w	#$1C00,d0
		blo.s	RunDemo
		move.b	#GameModeID_SegaScreen,(v_gamemode).w
		rts
; ---------------------------------------------------------------------------

RunDemo:
		andi.b	#btnStart,(v_jpadpress1).w
		bne.w	Title_CheckLvlSel
		tst.w	(v_generictimer).w
		bne.w	loc_3630
		move.b	#bgm_Fade,d0
		bsr.w	QueueSound2
		move.w	(v_demonum).w,d0
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Demo_Levels(pc,d0.w),d0
		move.w	d0,(Current_ZoneAndAct).w
		addq.w	#1,(v_demonum).w
		cmpi.w	#4,(v_demonum).w
		blo.s	loc_3694
		move.w	#0,(v_demonum).w

loc_3694:
		move.w	#1,(f_demo).w
		move.b	#GameModeID_Demo,(v_gamemode).w
		cmpi.w	#id_EHZ<<8,d0
		bne.s	loc_36AC
		move.w	#1,(Two_player_mode).w

loc_36AC:
		cmpi.w	#(id_SS-1)<<8,d0
		bne.s	loc_36C0
		move.b	#GameModeID_SpecialStage,(v_gamemode).w
		clr.w	(Current_ZoneAndAct).w
		clr.b	(v_lastspecial).w

loc_36C0:
		move.b	#3,(v_lives).w
		moveq	#0,d0
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.l	d0,(v_score).w
		move.l	#5000,(v_scorelife).w
		rts
; ---------------------------------------------------------------------------
Demo_Levels:
		dc.b id_CPZ,0
		dc.b id_EHZ,0
		dc.b id_HPZ,0
		dc.b id_HTZ,0
		dc.b id_HTZ,0
		dc.b id_HTZ,0
		dc.b id_HTZ,0
		dc.b id_HTZ,0
		dc.b id_HPZ,0
		dc.b id_HPZ,0
		dc.b id_HPZ,0
		dc.b id_HPZ,0

; =============== S U B	R O U T	I N E =======================================


LevelSelect_Controls:
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnUp+btnDn,d1
		bne.s	loc_3706
		subq.w	#1,(v_levseldelay).w
		bpl.s	loc_3740

loc_3706:
		move.w	#12-1,(v_levseldelay).w
		move.b	(v_jpadhold1).w,d1
		andi.b	#btnUp+btnDn,d1
		beq.s	loc_3740
		move.w	(v_levselitem).w,d0
		btst	#bitUp,d1
		beq.s	loc_3726
		subq.w	#1,d0
		bhs.s	loc_3726
		moveq	#$14,d0

loc_3726:
		btst	#bitDn,d1
		beq.s	loc_3736
		addq.w	#1,d0
		cmpi.w	#$15,d0
		blo.s	loc_3736
		moveq	#0,d0

loc_3736:
		move.w	d0,(v_levselitem).w
		bsr.w	LevSelTextLoad
		rts
; ---------------------------------------------------------------------------

loc_3740:
		cmpi.w	#$14,(v_levselitem).w
		bne.s	locret_377A
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnL+btnR,d1
		beq.s	locret_377A
		move.w	(v_levselsound).w,d0
		btst	#bitL,d1
		beq.s	loc_3762
		subq.w	#1,d0
		bhs.s	loc_3762
		moveq	#sfx__Last-$80,d0

loc_3762:
		btst	#bitR,d1
		beq.s	loc_3772
		addq.w	#1,d0
		cmpi.w	#spec__First-$80,d0
		blo.s	loc_3772
		moveq	#0,d0

loc_3772:
		move.w	d0,(v_levselsound).w
		bsr.w	LevSelTextLoad

locret_377A:
		rts
; End of function LevelSelect_Controls

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load level select text
; ---------------------------------------------------------------------------

LevSelTextLoad:

textpos:	= ($40000000+(($E210&$3FFF)<<16)+(($E210&$C000)>>14))
					; $E210 is a VRAM address

		lea	(LevelSelect_Text).l,a1
		lea	(vdp_data_port).l,a6
		move.l	#textpos,d4
		move.w	#$8680,d3
		moveq	#21-1,d1

loc_3794:
		move.l	d4,4(a6)
		bsr.w	LevSel_ChgLine
		addi.l	#$800000,d4
		dbf	d1,loc_3794
		moveq	#0,d0
		move.w	(v_levselitem).w,d0
		move.w	d0,d1
		move.l	#textpos,d4
		lsl.w	#7,d0
		swap	d0
		add.l	d0,d4
		lea	(LevelSelect_Text).l,a1
		lsl.w	#3,d1
		move.w	d1,d0
		add.w	d1,d1
		add.w	d0,d1
		adda.w	d1,a1
		move.w	#$C680,d3
		move.l	d4,4(a6)
		bsr.w	LevSel_ChgLine
		move.w	#$8680,d3
		cmpi.w	#$14,(v_levselitem).w
		bne.s	LevSel_DrawSnd
		move.w	#$C680,d3

LevSel_DrawSnd:
		locVRAM	vram_bg+$C30		; sound test position on screen
		move.w	(v_levselsound).w,d0
		addi.w	#$80,d0
		move.b	d0,d2
		lsr.b	#4,d0
		bsr.w	LevSel_ChgSnd
		move.b	d2,d0
		bsr.w	LevSel_ChgSnd
		rts
; End of function LevelSelect_TextLoad


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSel_ChgSnd:
		andi.w	#$F,d0
		cmpi.b	#$A,d0		; is digit $A-$F?
		blo.s	LevSel_Numb	; if not, branch
		addi.b	#7,d0		; use alpha characters

LevSel_Numb:
		add.w	d3,d0
		move.w	d0,(a6)
		rts
; End of function LevSel_ChgSnd


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSel_ChgLine:
		moveq	#24-1,d2		; number of characters per line

LevSel_LineLoop:
		moveq	#0,d0
		move.b	(a1)+,d0	; get character
		bpl.s	LevSel_CharOk	; branch if valid
		move.w	#0,(a6)		; use blank character
		dbf	d2,LevSel_LineLoop
		rts


LevSel_CharOk:
		add.w	d3,d0		; combine char with VRAM setting
		move.w	d0,(a6)		; send to VRAM
		dbf	d2,LevSel_LineLoop
		rts
; End of function LevSel_ChgLine

; ---------------------------------------------------------------------------

LevelSelect_Text:
		charset ' ', $FF
		charset '0','9',$00
		charset '$', $0A
		charset '-', $0B
		charset '=', $0C
		charset '>', $0D
		;charset '>', $0E ; there are two right arrows in the font for some reason
		charset 'Y','Z',$0F ; Y and Z come before A-X
		charset 'A','X',$11

		dc.b "GREEN HILL ZONE  STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "MARBLE ZONE      STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "SPRING YARD ZONE STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "LABYRINTH ZONE   STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "STAR LIGHT ZONE  STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "SCRAP BRAIN ZONE STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "FINAL ZONE              "
		dc.b "SPECIAL STAGE           "
		dc.b "SOUND SELECT            "

		charset
		even
; ---------------------------------------------------------------------------

; This appears to be potentially related to 16x16 data despite it using the
; address for chunk RAM.
UnknownSub_1:
		lea	(v_ram_start).l,a1
		; This contains a size of block data that is 0x5D8 in size.
		move.w	#bytesToWcnt($5D8),d2

loc_3A3A:
		move.w	(a1),d0
		move.w	d0,d1
		andi.w	#nontile_mask,d1
		andi.w	#tile_mask,d0
		lsr.w	#1,d0
		or.w	d0,d1
		move.w	d1,(a1)+
		dbf	d2,loc_3A3A
		rts
; ---------------------------------------------------------------------------

UnknownSub_2:
		lea	(RAM_debug_start).l,a1
		lea	(RAM_debug_start+$80).l,a2
		lea	(v_ram_start).l,a3
		move.w	#bytesToWcnt($80),d1

loc_3A68:
		bsr.w	UnknownSub_4
		bsr.w	UnknownSub_4
		dbf	d1,loc_3A68
		lea	(RAM_debug_start).l,a1
		lea	(v_ram_start&$FFFFFF).l,a2
		move.w	#bytesToWcnt($80),d1

loc_3A84:
		move.w	#0,(a2)+
		dbf	d1,loc_3A84
		move.w	#bytesToWcnt($7F80),d1

loc_3A90:
		move.w	(a1)+,(a2)+
		dbf	d1,loc_3A90
		rts
; ---------------------------------------------------------------------------

UnknownSub_3:
		lea	(RAM_debug_start).l,a1
		lea	(v_ram_start).l,a3
		moveq	#bytesToLcnt($80),d0

loc_3AA6:
		move.l	(a1)+,(a3)+
		dbf	d0,loc_3AA6
		moveq	#0,d7
		lea	(RAM_debug_start).l,a1
		move.w	#$100-1,d5

loc_3AB8:
		lea	(v_ram_start).l,a3
		move.w	d7,d6

loc_3AC0:
		movem.l	a1-a3,-(sp)
		move.w	#bytesToWcnt($80),d0

loc_3AC8:
		cmpm.w	(a1)+,(a3)+
		bne.s	loc_3ADE
		dbf	d0,loc_3AC8
		movem.l	(sp)+,a1-a3
		adda.w	#$80,a1
		dbf	d5,loc_3AB8
		bra.s	loc_3AF8
; ---------------------------------------------------------------------------

loc_3ADE:
		movem.l	(sp)+,a1-a3
		adda.w	#$80,a3
		dbf	d6,loc_3AC0
		moveq	#bytesToLcnt($80),d0

loc_3AEC:
		move.l	(a1)+,(a3)+
		dbf	d0,loc_3AEC
		addq.l	#1,d7
		dbf	d5,loc_3AB8

loc_3AF8:
		bra.s	loc_3AF8

; =============== S U B	R O U T	I N E =======================================


UnknownSub_4:
		moveq	#bytesToXcnt($280,$50),d0

loc_3AFC:
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		dbf	d0,loc_3AFC
		adda.w	#$80,a1
		adda.w	#$80,a2
		rts
; End of function UnknownSub_4

		jmpTos	; Empty

MusicList:
		dc.b bgm_GHZ
		dc.b bgm_LZ
		dc.b bgm_MZ
		dc.b bgm_SLZ
		dc.b bgm_SYZ
		dc.b bgm_SBZ
		dc.b bgm_FZ
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Level
; DEMO AND ZONE LOOP (MLS values $08, $0C; bit 7 set indicates that load routine is running)
; ---------------------------------------------------------------------------

Level:
		bset	#GameModeFlag_TitleCard,(v_gamemode).w
		tst.w	(f_demo).w	; are we on an ending demo?
		bmi.s	Level_NoMusicFade	; if so, branch
		move.b	#bgm_Fade,d0
		bsr.w	QueueSound2

Level_NoMusicFade:
		bsr.w	ClearPLC
		bsr.w	Pal_FadeToBlack
		tst.w	(f_demo).w	; are we on an ending demo?
		bmi.s	loc_3BB6	; if so, branch
		disable_ints
		locVRAM	ArtTile_Title_Card*tile_size
		lea	(Nem_TitleCard).l,a0
		bsr.w	NemDec
		bsr.w	ClearScreen
		fillVRAM	0, vram_fg_2p, vram_fg_2p+plane_size_64x32 ; clear 2 player foreground namespace
		enable_ints
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#4,d0
		lea	(LevelArtPointers).l,a2
		lea	(a2,d0.w),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	loc_3BB0
		bsr.w	LoadPLC

loc_3BB0:
		moveq	#plcid_Main2,d0
		bsr.w	LoadPLC

loc_3BB6:
		clearRAM v_spritequeue,v_spritequeue_end
		clearRAM v_objspace,v_objend
		clearRAM v_misc_variables,v_misc_variables_end
		clearRAM v_levelvariables,v_levelvariables_end
		clearRAM v_timingvariables,v_timingvariables_end
		cmpi.b	#id_HPZ,(Current_Zone).w	; are we on Hidden Palace Zone?
		bne.s	.skipwater		; if not, skip
		move.b	#1,(Water_flag).w
		move.w	#0,(Two_player_mode).w

.skipwater:
		lea	(vdp_control_port).l,a6
		move.w	#$8B00+%0011,(a6)	; set horizontal scrolling single pixel rows mode
		move.w	#$8200+(vram_fg>>10),(a6)
		move.w	#$8400+(vram_bg>>13),(a6)
		move.w	#$8500+(vram_sprites>>9),(a6)
		move.w	#$9001,(a6)
		move.w	#$8000+%0100,(a6)
		move.w	#$8700+32,(a6)	; set background color to first slot of line 2
		move.w	#$8A00+224-1,(v_hbla_hreg).w
		tst.w	(Two_player_mode).w	; is two player mode enabled?
		beq.s	.not2P			; if not, skip horizontal interrupts
		move.w	#$8A00+(224/2-4)-1,(v_hbla_hreg).w
		move.w	#$8000+%00010100,(a6)	; enable h-int
		move.w	#$8C00+%10000111,(a6)	; set interlace double resolution mode

.not2P:
		move.w	(v_hbla_hreg).w,(a6)
		move.l	#VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w	; reset the DMA Queue
		tst.b	(Water_flag).w
		beq.s	LevelInit_NoWater
		move.w	#$8000+%00010100,(a6)	; enable h-int
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		lea	(WaterHeight).l,a1
		move.w	(a1,d0.w),d0
		move.w	d0,(v_waterpos1).w
		move.w	d0,(v_waterpos2).w
		move.w	d0,(v_waterpos3).w
		clr.b	(v_wtr_routine).w
		clr.b	(f_wtr_state).w
		move.b	#1,(f_water).w

LevelInit_NoWater:
		move.w	#30,(v_air).w
		moveq	#palid_SonicTails,d0
		bsr.w	PalLoad2
		tst.b	(Water_flag).w
		beq.s	Level_GetBgm
		moveq	#palid_LZSonWater,d0
		cmpi.b	#3,(Current_Act).w
		bne.s	Level_WaterPal
		moveq	#palid_SBZ3SonWat,d0

Level_WaterPal:
		bsr.w	PalLoad3_Water
		tst.b	(v_lastlamp).w
		beq.s	Level_GetBgm
		move.b	(v_lamp_wtrstat).w,(f_wtr_state).w

Level_GetBgm:
		tst.w	(f_demo).w	; are we on an ending demo?
		bmi.s	Level_SkipTtlCard	; if so, branch
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		cmpi.w	#(id_LZ<<8)+3,(Current_ZoneAndAct).w
		bne.s	Level_BgmNotLZ4
		moveq	#5,d0

Level_BgmNotLZ4:
		cmpi.w	#(id_SBZ<<8)+2,(Current_ZoneAndAct).w
		bne.s	Level_PlayBgm
		moveq	#6,d0

Level_PlayBgm:
		lea	MusicList(pc),a1
		nop
		move.b	(a1,d0.w),d0
		bsr.w	QueueSound1
		move.b	#id_Obj34,(v_titlecard).w

Level_TtlCardLoop:
		move.b	#VintID_TitleCard,(v_vbla_routine).w
		bsr.w	WaitForVint
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		bsr.w	RunPLC_RAM
	if FixBugs=0
		move.w	(v_ttlcardact+obX).w,d0		; get current position of the "ACT" element of the title cards
		cmp.w	(v_ttlcardact+card_mainX).w,d0	; has "ACT" element reached its target position?
		bne.s	Level_TtlCardLoop		; if not, loop until it has
	else
		; Check if *every* title card element has reached their target position.
		; Decompression is normally slow enough that every element is able
		; to reach their target position before it's finished, but if
		; decompression is upgraded with something faster, then the risk
		; of decompression finishing and exiting this loop before all of the title
		; card is finished moving into place is increased.
		lea	(v_titlecard).w,a0		; get title card elements
		moveq	#4-1,d0				; number of title card elements

Level_CheckTtlCard:
		move.w	obX(a0),d0			; get current position of a title card element
		cmp.w	card_mainX(a0),d0		; has this title card element reached its target position?
		bne.s	Level_TtlCardLoop		; if not, loop until it has
		lea	object_size(a0),a0		; next title card element
		dbf	d0,Level_CheckTtlCard		; loop until every element has reached its target position
	endif
		tst.l	(v_plc_buffer).w
		bne.s	Level_TtlCardLoop
	if FixBugs
		; Do Vint for one extra frame to provide enough processing time
		; for the remaining data initialization below. Without it, it's 
		; possible for Vint to interrupt in the middle of a transfer,
		; resulting in visual corruption. This will also make title cards
		; smoother should decompression get upgraded with something faster.
		move.b	#VintID_TitleCard,(v_vbla_routine).w ; set Vint routine to $0C
		bsr.w	WaitForVint			; wait until Vint has finished
	endif
		jsr	(HUD_Base).l

Level_SkipTtlCard:
		moveq	#palid_SonicTails,d0
		bsr.w	PalLoad1
		bsr.w	LevelSizeLoad
		bsr.w	DeformBGLayer
		bset	#2,(Scroll_flags).w
		bsr.w	MainLevelLoadBlock
		jsr	(LoadAnimatedBlocks).l
		bsr.w	LoadTilesFromStart
		jsr	(ApplySonic1Collision).l
		bsr.w	LoadCollisionIndexes
		bsr.w	WaterEffects
		move.b	#id_Obj01,(v_player).w	; load Sonic object
		tst.w	(f_demo).w	; are we on an ending demo?
		bmi.s	Level_ChkDebug	; if not, branch
		move.b	#id_Obj21,(v_hud).w	; load HUD object

Level_ChkDebug:
		tst.w	(Two_player_mode).w
		bne.s	LevelInit_LoadTails
		cmpi.b	#id_EHZ,(Current_Zone).w	; is this EHZ?
		beq.s	LevelInit_SkipTails	; if so, skip loading Tails object

LevelInit_LoadTails:
		move.b	#id_Obj02,(v_player2).w	; load Tails object
		move.w	(v_player+obX).w,(v_player2+obX).w	; copy player 1's x position to player 2
		move.w	(v_player+obY).w,(v_player2+obY).w	; copy player 1's y position to player 2
		subi.w	#32,(v_player2+obX).w	; set player 2's x position 32 pixels behind player 1's

LevelInit_SkipTails:
		tst.b	(f_debugcheat).w
		beq.s	Level_ChkWater
		btst	#bitA,(v_jpadhold1).w
		beq.s	Level_ChkWater
		move.b	#1,(Debug_mode_flag).w

Level_ChkWater:
		move.w	#0,(v_jpadhold2).w
		move.w	#0,(v_jpadhold1).w
		tst.b	(Water_flag).w
		beq.s	Level_LoadObj
		move.b	#id_Obj04,(v_watersurface1).w
		move.w	#$60,(v_watersurface1+obX).w
		move.b	#id_Obj04,(v_watersurface2).w
		move.w	#$120,(v_watersurface2+obX).w

Level_LoadObj:
		jsr	(ObjectsManager).l
		jsr	(RingsManager).l
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		jsrto	JmpTo_AniArt_Load
		moveq	#0,d0
		tst.b	(v_lastlamp).w
		bne.s	Level_SkipClr
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.b	d0,(v_lifecount).w

Level_SkipClr:
		move.b	d0,(f_timeover).w
		move.b	d0,(v_shield).w
		move.b	d0,(v_invinc).w
		move.b	d0,(v_shoes).w
		move.b	d0,(v_unused1).w
		move.w	d0,(Debug_placement_mode).w
		move.w	d0,(Level_Inactive_flag).w
		move.w	d0,(Timer_frames).w
		bsr.w	OscillateNumInit
		move.b	#1,(f_scorecount).w
		move.b	#1,(f_ringcount).w
		move.b	#1,(f_timecount).w
		move.w	#4,(Sonic_Pos_Record_Index).w
		move.w	#0,(Sonic_Pos_Record_Buf).w
		move.w	#0,(Demo_button_index).w
		move.w	#0,(Demo_button_index_2P).w
		lea	(Demo_Index).l,a1
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		tst.w	(f_demo).w	; is this an ending demo?
		bpl.s	Level_Demo	; if not, branch
		lea	(Demo_S1EndIndex).l,a1		; garbage, leftover from Sonic 1's ending sequence demos
		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1

Level_Demo:
		move.b	1(a1),(Demo_press_counter).w
		subq.b	#1,(Demo_press_counter).w
		lea	(Demo_EHZ_2P).l,a1
		move.b	1(a1),(Demo_press_counter_2P).w
		subq.b	#1,(Demo_press_counter_2P).w
		move.w	#1640,(v_generictimer).w
		tst.w	(f_demo).w	; is this an ending demo?
		bpl.s	Level_ChkWaterPal	; if not, branch
		move.w	#540,(v_generictimer).w
		cmpi.w	#4,(v_creditsnum).w
		bne.s	Level_ChkWaterPal
		move.w	#510,(v_generictimer).w

Level_ChkWaterPal:
		tst.b	(Water_flag).w
		beq.s	Level_Delay
		moveq	#palid_HPZWater,d0
		cmpi.b	#3,(Current_Act).w
		bne.s	Level_WtrNotHtz
		moveq	#palid_SBZ3Water,d0

Level_WtrNotHtz:
		bsr.w	PalLoad4_Water

Level_Delay:
		move.w	#4-1,d1

Level_DelayLoop:
		move.b	#VintID_Level,(v_vbla_routine).w
		bsr.w	WaitForVint
		dbf	d1,Level_DelayLoop
		move.w	#$202F,(v_pfade_start).w
		bsr.w	Pal_FadeFromBlack2
		tst.w	(f_demo).w	; is this an ending demo?
		bmi.s	Level_ClrTitleCard	; if so, branch
		addq.b	#2,(v_ttlcardname+obRoutine).w
		addq.b	#4,(v_ttlcardzone+obRoutine).w
		addq.b	#4,(v_ttlcardact+obRoutine).w
		addq.b	#4,(v_ttlcardoval+obRoutine).w
		bra.s	Level_StartGame
; ===========================================================================

Level_ClrTitleCard:
		moveq	#plcid_Explode,d0
		jsr	(LoadPLC).l
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		addi.w	#plcid_GHZAnimals,d0
		jsr	(LoadPLC).l

Level_StartGame:
		bclr	#GameModeFlag_TitleCard,(v_gamemode).w

; ---------------------------------------------------------------------------
; Main level loop (when all title card and loading sequences are finished)
; ---------------------------------------------------------------------------
Level_MainLoop:
		bsr.w	PauseGame
		move.b	#VintID_Level,(v_vbla_routine).w
		bsr.w	WaitForVint
		addq.w	#1,(Timer_frames).w
		bsr.w	MoveSonicInDemo
		bsr.w	WaterEffects
		jsr	(ExecuteObjects).l
		tst.w	(Level_Inactive_flag).w
		bne.w	Level
		tst.w	(Debug_placement_mode).w
		bne.s	Level_DoScroll
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	Level_SkipScroll

Level_DoScroll:
		bsr.w	DeformBGLayer

Level_SkipScroll:
		bsr.w	ChangeWaterSurfacePos
		jsr	(RingsManager).l
		jsrto	JmpTo_AniArt_Load
		bsr.w	PalCycle_Load
		bsr.w	RunPLC_RAM
		bsr.w	OscillateNumDo
		bsr.w	ChangeRingFrame
		bsr.w	SignpostArtLoad
		jsr	(BuildSprites).l
		jsr	(ObjectsManager).l
		cmpi.b	#GameModeID_Demo,(v_gamemode).w
		beq.s	Level_ChkDemo
		cmpi.b	#GameModeID_Level,(v_gamemode).w
		beq.w	Level_MainLoop
		rts
; ---------------------------------------------------------------------------

Level_ChkDemo:
		tst.w	(Level_Inactive_flag).w
		bne.s	Level_EndDemo
		tst.w	(v_generictimer).w
		beq.s	Level_EndDemo
		cmpi.b	#GameModeID_Demo,(v_gamemode).w
		beq.w	Level_MainLoop
		move.b	#GameModeID_SegaScreen,(v_gamemode).w
		rts
; ---------------------------------------------------------------------------

Level_EndDemo:
		cmpi.b	#GameModeID_Demo,(v_gamemode).w
		bne.s	Level_FadeDemo
		move.b	#GameModeID_SegaScreen,(v_gamemode).w
		tst.w	(f_demo).w
		bpl.s	Level_FadeDemo
		move.b	#GameModeID_S1Credits,(v_gamemode).w

Level_FadeDemo:
		move.w	#60,(v_generictimer).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(PalChangeSpeed).w

Level_FDLoop:
		move.b	#VintID_Level,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	MoveSonicInDemo
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		jsr	(ObjectsManager).l
		subq.w	#1,(PalChangeSpeed).w
		bpl.s	loc_400E
		move.w	#2,(PalChangeSpeed).w
		bsr.w	Pal_FadeOut

loc_400E:
		tst.w	(v_generictimer).w
		bne.s	Level_FDLoop
		rts

		include	"_Include/WaterFeatures.asm"
		include "_Include/MoveSonicInDemo.asm"

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ColIndexLoad:
LoadCollisionIndexes:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#2,d0
		move.l	#v_colladdr1,(Collision_addr).w
		movea.l	ColP_Index(pc,d0.w),a1
		lea	(v_colladdr1).w,a2
		bsr.s	Col_Load
		movea.l	ColS_Index(pc,d0.w),a1
		lea	(v_colladdr2).w,a2

Col_Load:
		move.w	#bytesToWcnt(v_colladdr1_end-v_colladdr1),d1
		moveq	#0,d2

.loop:
		move.b	(a1)+,d2	; move low byte of collision address to d2
		move.w	d2,(a2)+	; and then move the high byte of d2 to collision RAM address
		dbf	d1,.loop
		rts
; End of function Col_Load

; ===========================================================================
; ---------------------------------------------------------------------------
; Pointers to primary collision indexes

; Contains an array of pointers to the primary collision index data for each
; level. 1 pointer for each level, pointing the primary collision index.
; ---------------------------------------------------------------------------
ColP_Index:	dc.l ColP_GHZ
		dc.l ColP_CPZ
		dc.l ColP_CPZ
		dc.l ColP_EHZ
		dc.l ColP_HPZ
		dc.l ColP_EHZ
		;dc.l ColP_GHZ				; pointer for Ending is missing by default.

; ---------------------------------------------------------------------------
; Pointers to secondary collision indexes

; Contains an array of pointers to the secondary collision index data for
; each level. 1 pointer for each level, pointing the secondary collision
; index.
; ---------------------------------------------------------------------------
ColS_Index:	dc.l ColS_GHZ
		dc.l ColS_CPZ
		dc.l ColS_CPZ
		dc.l ColS_EHZ
		dc.l ColS_HPZ
		dc.l ColS_EHZ
		;dc.l ColS_GHZ				; pointer for Ending is missing by default.

		include	"_Include/Oscillatory Routines.asm"

; =============== S U B	R O U T	I N E =======================================


ChangeRingFrame:
		subq.b	#1,(v_ani0_time).w
		bpl.s	loc_4754
		move.b	#11,(v_ani0_time).w
		subq.b	#1,(v_ani0_frame).w
		andi.b	#7,(v_ani0_frame).w

loc_4754:
		subq.b	#1,(v_ani1_time).w
		bpl.s	loc_476A
		move.b	#7,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#3,(v_ani1_frame).w

loc_476A:
		subq.b	#1,(v_ani2_time).w
		bpl.s	loc_4788
		move.b	#7,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		cmpi.b	#6,(v_ani2_frame).w
		blo.s	loc_4788
		move.b	#0,(v_ani2_frame).w

loc_4788:
		tst.b	(v_ani3_time).w
		beq.s	locret_47AA
		moveq	#0,d0
		move.b	(v_ani3_time).w,d0
		add.w	(v_ani3_buf).w,d0
		move.w	d0,(v_ani3_buf).w
		rol.w	#7,d0
		andi.w	#3,d0
		move.b	d0,(v_ani3_frame).w
		subq.b	#1,(v_ani3_time).w

locret_47AA:
		rts
; End of function ChangeRingFrame


; =============== S U B	R O U T	I N E =======================================


SignpostArtLoad:
		tst.w	(Debug_placement_mode).w
		bne.w	locret_47E2
		cmpi.b	#1,(Current_Act).w
		beq.s	locret_47E2
		move.w	(Camera_X_pos).w,d0
		move.w	(Camera_Max_X_pos).w,d1
		subi.w	#$100,d1
		cmp.w	d1,d0
		blt.s	locret_47E2
		tst.b	(f_timecount).w
		beq.s	locret_47E2
		cmp.w	(Camera_Min_X_pos).w,d1
		beq.s	locret_47E2
		move.w	d1,(Camera_Min_X_pos).w
		moveq	#plcid_Signpost,d0
		bra.w	NewPLC
; ---------------------------------------------------------------------------

locret_47E2:
		rts
; End of function SignpostArtLoad


Demo_EHZ:	binclude	"demodata/Intro - EHZ (1P).bin"
		even
Demo_EHZ_2P:	binclude	"demodata/Intro - EHZ (2P).bin"
		even
Demo_HTZ:	binclude	"demodata/Intro - HTZ.bin"
		even
Demo_HPZ:	binclude	"demodata/Intro - HPZ.bin"
		even
Demo_CPZ:	binclude	"demodata/Intro - CPZ.bin"
		even
Demo_S1GHZ:	binclude	"demodata/S1/Intro - GHZ.bin"
		even
Demo_S1MZ:	binclude	"demodata/S1/Intro - MZ.bin"
		even
Demo_S1SYZ:	binclude	"demodata/S1/Intro - SYZ.bin"
		even
Demo_S1SS:	binclude	"demodata/S1/Intro - Special Stage.bin"
		even

		jmpTos	JmpTo_AniArt_Load

; ===========================================================================
; Sonic 1 Special Stage; crashes due to bad PLCs and missing pointers, but
; is otherwise identical
; GameMode10:
SpecialStage:
		move.w	#sfx_EnterSS,d0
		bsr.w	QueueSound2
		bsr.w	Pal_MakeFlash
		disable_ints
		lea	(vdp_control_port).l,a6
		move.w	#$8B00+%0011,(a6)	; set horizontal scrolling single pixel rows mode
		move.w	#$8000+%0100,(a6)
		move.w	#$8A00+175,(v_hbla_hreg).w
		move.w	#$9011,(a6)
		disable_display
		bsr.w	ClearScreen
		enable_ints
		fillVRAM	0, ArtTile_SS_Plane_1*tile_size+plane_size_64x32, ArtTile_SS_Plane_5*tile_size
		bsr.w	S1_SSBGLoad
		moveq	#plcid_SpecialStage,d0
		bsr.w	QuickPLC
	if FixBugs
		clearRAM v_objspace,v_objend
	else
		; This does not clear the object space, resulting in Sonic and Tails on the title screen to remain!
		; Instead, this clears the collision addresses.
		lea	(v_objspace_end).w,a1
		moveq	#0,d0
		move.w	#bytesToLcnt(v_objend-v_objspace),d1

.loop:
		move.l	d0,(a1)+
		dbf	d1,.loop
	endif
		clearRAM v_levelvariables,v_levelvariables_end
		clearRAM v_timingvariables,v_timingvariables_end-$80
		clearRAM v_ngfx_buffer,v_ngfx_buffer_end
		clr.b	(f_wtr_state).w
		clr.w	(Level_Inactive_flag).w
		moveq	#palid_Special,d0
		bsr.w	PalLoad1
		jsr	(S1SS_Load).l
		move.l	#0,(Camera_X_pos).w
		move.l	#0,(Camera_Y_pos).w
		move.b	#id_Obj09,(v_player).w
		bsr.w	PalCycle_S1SS
		clr.w	(v_ssangle).w
		move.w	#$40,(v_ssrotate).w
		move.w	#bgm_SS,d0
		bsr.w	QueueSound1
		move.w	#0,(Demo_button_index).w
		lea	(Demo_Index).l,a1
		moveq	#6,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		move.b	1(a1),(Demo_press_counter).w
		subq.b	#1,(Demo_press_counter).w
		clr.w	(v_rings).w
		clr.b	(v_lifecount).w
		move.w	#0,(Debug_placement_mode).w
		move.w	#1800,(v_generictimer).w
		tst.b	(f_debugcheat).w
		beq.s	loc_5158
		btst	#bitA,(v_jpadhold1).w
		beq.s	loc_5158
		move.b	#1,(Debug_mode_flag).w

loc_5158:
		enable_display
		bsr.w	Pal_MakeWhite

loc_516A:
		bsr.w	PauseGame
		move.b	#VintID_S1SS,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	MoveSonicInDemo
		move.w	(v_jpadhold1).w,(v_jpadhold2).w
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		jsr	(S1SS_ShowLayout).l
		bsr.w	S1SS_BgAnimate
		tst.w	(f_demo).w
		beq.s	loc_51A6
		tst.w	(v_generictimer).w
		beq.w	loc_52D4

loc_51A6:
		cmpi.b	#GameModeID_SpecialStage,(v_gamemode).w
		beq.w	loc_516A
		tst.w	(f_demo).w
		bne.w	loc_52DC
		move.b	#GameModeID_Level,(v_gamemode).w
		cmpi.w	#(id_SBZ<<8)+3,(Current_ZoneAndAct).w
		blo.s	loc_51CA
		clr.w	(Current_ZoneAndAct).w

loc_51CA:
		move.w	#60,(v_generictimer).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(PalChangeSpeed).w

loc_51DA:
		move.b	#VintID_SSResults,(v_vbla_routine).w
		bsr.w	WaitForVint
		bsr.w	MoveSonicInDemo
		move.w	(v_jpadhold1).w,(v_jpadhold2).w
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		jsr	(S1SS_ShowLayout).l
		bsr.w	S1SS_BgAnimate
		subq.w	#1,(PalChangeSpeed).w
		bpl.s	loc_5214
		move.w	#2,(PalChangeSpeed).w
		bsr.w	Pal_ToWhite

loc_5214:
		tst.w	(v_generictimer).w
		bne.s	loc_51DA
		disable_ints
		lea	(vdp_control_port).l,a6
		move.w	#$8200+(vram_fg>>10),(a6)
		move.w	#$8400+(vram_bg>>13),(a6)
		move.w	#$9001,(a6)
		bsr.w	ClearScreen
		locVRAM	ArtTile_Title_Card*tile_size
		lea	(Nem_TitleCard).l,a0
		bsr.w	NemDec
		jsr	(HUD_Base).l
		enable_ints
		moveq	#palid_SSResult,d0
		bsr.w	PalLoad2
		moveq	#plcid_Main,d0
		bsr.w	NewPLC
		moveq	#plcid_SSResult,d0
		bsr.w	LoadPLC
		move.b	#1,(f_scorecount).w
		move.b	#1,(f_endactbonus).w
		move.w	(v_rings).w,d0
		mulu.w	#10,d0
		move.w	d0,(v_ringbonus).w
		move.w	#bgm_GotThrough,d0
		jsr	(QueueSound2).l
		clearRAM v_objspace,v_objend
		move.b	#id_Obj7E,(v_endcard).w

loc_529C:
		bsr.w	PauseGame
		move.b	#VintID_TitleCard,(v_vbla_routine).w
		bsr.w	WaitForVint
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		bsr.w	RunPLC_RAM
		tst.w	(Level_Inactive_flag).w
		beq.s	loc_529C
		tst.l	(v_plc_buffer).w
		bne.s	loc_529C
		move.w	#sfx_EnterSS,d0
		bsr.w	QueueSound2
		bsr.w	Pal_MakeFlash
		rts
; ---------------------------------------------------------------------------

loc_52D4:
		move.b	#GameModeID_SegaScreen,(v_gamemode).w
		rts
; ---------------------------------------------------------------------------

loc_52DC:
		cmpi.b	#GameModeID_Level,(v_gamemode).w
		beq.s	loc_52D4
		rts

; =============== S U B	R O U T	I N E =======================================


S1_SSBGLoad:
		lea	(v_ssbuffer1).l,a1
		; Bug: The mappings for the birds and fish are not loaded here!
		; Unfortunantely, they don't exist in ROM either...
;		lea	(Eni_SSBg1).l,a0 ; load mappings for the birds and fish
		move.w	#make_art_tile(ArtTile_SS_Background_Fish,2,0),d0
		bsr.w	EniDec
		locVRAM	ArtTile_SS_Plane_1*tile_size+plane_size_64x32,d3
		lea	(v_ssbuffer1+$80).l,a2
		moveq	#7-1,d7

loc_5302:
		move.l	d3,d0
		moveq	#3,d6
		moveq	#0,d4
		cmpi.w	#4-1,d7
		bhs.s	loc_5310
		moveq	#1,d4

loc_5310:
		moveq	#8-1,d5

loc_5312:
		movea.l	a2,a1
		eori.b	#1,d4
		bne.s	loc_5326
		cmpi.w	#6,d7
		bne.s	loc_5336
		lea	(v_ssbuffer1).l,a1

loc_5326:
		movem.l	d0-d4,-(sp)
		moveq	#8-1,d1
		moveq	#8-1,d2
		bsr.w	PlaneMapToVRAM_H40
		movem.l	(sp)+,d0-d4

loc_5336:
		addi.l	#$100000,d0
		dbf	d5,loc_5312
		addi.l	#$3800000,d0
		eori.b	#1,d4
		dbf	d6,loc_5310
		addi.l	#$10000000,d3
		bpl.s	loc_5360
		swap	d3
		addi.l	#$C000,d3
		swap	d3

loc_5360:
		adda.w	#$80,a2
		dbf	d7,loc_5302
		lea	(v_ssbuffer1).l,a1
		; Bug: The mappings for the clouds are not loaded here!
		; Unfortunantely, they don't exist in ROM either...
;		lea	(Eni_SSBg2).l,a0 ; load mappings for the clouds
		move.w	#make_art_tile(ArtTile_SS_Background_Clouds,2,0),d0
		bsr.w	EniDec
		copyTilemap	v_ssbuffer1,ArtTile_SS_Plane_5*tile_size,64,32
		copyTilemap	v_ssbuffer1,ArtTile_SS_Plane_5*tile_size+plane_size_64x32,64,64
		rts
; End of function S1_SSBGLoad


; =============== S U B	R O U T	I N E =======================================


PalCycle_S1SS:
		tst.w	(f_pause).w
		bne.s	locret_5424
		subq.w	#1,(v_palss_time).w
		bpl.s	locret_5424
		lea	(vdp_control_port).l,a6
		move.w	(v_palss_num).w,d0
		addq.w	#1,(v_palss_num).w
		andi.w	#$1F,d0
		lsl.w	#2,d0
		lea	(word_547A).l,a0
		adda.w	d0,a0
		move.b	(a0)+,d0
		bpl.s	loc_53D0
		move.w	#$1FF,d0

loc_53D0:
		move.w	d0,(v_palss_time).w
		moveq	#0,d0
		move.b	(a0)+,d0
		move.w	d0,(v_ssbganim).w
		lea	(word_54FA).l,a1
		lea	(a1,d0.w),a1
		move.w	#$8200,d0
		move.b	(a1)+,d0
		move.w	d0,(a6)
		move.b	(a1),(v_scrposy_vdp).w
		move.w	#$8400,d0
		move.b	(a0)+,d0
		move.w	d0,(a6)
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.s	loc_5426
		lea	(Pal_S1SSCyc1).l,a1
		adda.w	d0,a1
		lea	(v_palette_line_3+$E).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+

locret_5424:
		rts
; ---------------------------------------------------------------------------

loc_5426:
		move.w	(v_palss_index).w,d1
		cmpi.w	#$8A,d0
		blo.s	loc_5432
		addq.w	#1,d1

loc_5432:
		mulu.w	#$2A,d1
		lea	(Pal_S1SSCyc2).l,a1
		adda.w	d1,a1
		andi.w	#$7F,d0
		bclr	#0,d0
		beq.s	loc_5456
		lea	(v_palette_line_4+$E).w,a2
		move.l	(a1),(a2)+
		move.l	4(a1),(a2)+
		move.l	8(a1),(a2)+

loc_5456:
		adda.w	#$C,a1
		lea	(v_palette_line_3+$1A).w,a2
		cmpi.w	#$A,d0
		blo.s	loc_546C
		subi.w	#$A,d0
		lea	(v_palette_line_4+$1A).w,a2

loc_546C:
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		adda.w	d0,a1
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		rts
; End of function PalCycle_S1SS

; ---------------------------------------------------------------------------
SSBGData:	macro time,anim,vram,index,flag1,flag2
		dc.b	(time), (anim), ((vram)*tile_size)>>13
	if flag1
		dc.b	(index)|$80|(flag2)
	else
		dc.b	(index)*12
	endif
		endm

word_547A:
		; Time, anim, BG VRAM, palette cycle index & flags
		SSBGData  3,  0, ArtTile_SS_Plane_6, 18, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 16, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 14, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 12, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 10, TRUE , TRUE

		SSBGData  3,  0, ArtTile_SS_Plane_6,  0, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  2, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  4, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  6, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  8, TRUE , FALSE


		SSBGData  7,  8, ArtTile_SS_Plane_6,  0, FALSE, FALSE
		SSBGData  7, 10, ArtTile_SS_Plane_6,  1, FALSE, FALSE
		SSBGData -1, 12, ArtTile_SS_Plane_6,  2, FALSE, FALSE
		SSBGData -1, 12, ArtTile_SS_Plane_6,  2, FALSE, FALSE
		SSBGData  7, 10, ArtTile_SS_Plane_6,  1, FALSE, FALSE
		SSBGData  7,  8, ArtTile_SS_Plane_6,  0, FALSE, FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  8, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  6, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  4, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  2, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  0, TRUE , TRUE

		SSBGData  3,  0, ArtTile_SS_Plane_5, 10, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 12, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 14, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 16, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 18, TRUE , FALSE

		SSBGData  7,  2, ArtTile_SS_Plane_5,  3, FALSE, FALSE
		SSBGData  7,  4, ArtTile_SS_Plane_5,  4, FALSE, FALSE
		SSBGData -1,  6, ArtTile_SS_Plane_5,  5, FALSE, FALSE
		SSBGData -1,  6, ArtTile_SS_Plane_5,  5, FALSE, FALSE
		SSBGData  7,  4, ArtTile_SS_Plane_5,  4, FALSE, FALSE
		SSBGData  7,  2, ArtTile_SS_Plane_5,  3, FALSE, FALSE
		even

SSFGData:	macro vram,y
		dc.b ((vram)*tile_size)>>10, (y)>>8
		endm

word_54FA:
		; FG VRAM, Y coordinate
		SSFGData ArtTile_SS_Plane_1, $100
		SSFGData ArtTile_SS_Plane_2,    0
		SSFGData ArtTile_SS_Plane_2, $100
		SSFGData ArtTile_SS_Plane_3,    0
		SSFGData ArtTile_SS_Plane_3, $100
		SSFGData ArtTile_SS_Plane_4,    0
		SSFGData ArtTile_SS_Plane_4, $100
		even

Pal_S1SSCyc1:	binclude	"palette/S1/Cycle - Special Stage 1.bin"
		even
Pal_S1SSCyc2:	binclude	"palette/S1/Cycle - Special Stage 2.bin"
		even

; =============== S U B	R O U T	I N E =======================================


S1SS_BgAnimate:
		move.w	(v_ssbganim).w,d0
		bne.s	loc_5634
		move.w	#0,(Camera_BG_Y_pos).w
		move.w	(Camera_BG_Y_pos).w,(v_bgscrposy_vdp).w

loc_5634:
		cmpi.w	#8,d0
		bhs.s	loc_568C
		cmpi.w	#6,d0
		bne.s	loc_564E
		addq.w	#1,(Camera_BG3_X_pos).w
		addq.w	#1,(Camera_BG_Y_pos).w
		move.w	(Camera_BG_Y_pos).w,(v_bgscrposy_vdp).w

loc_564E:
		moveq	#0,d0
		move.w	(Camera_BG_X_pos).w,d0
		neg.w	d0
		swap	d0
		lea	(byte_5709).l,a1
		lea	(v_ngfx_buffer).w,a3
		moveq	#9,d3

loc_5664:
		move.w	2(a3),d0
		bsr.w	CalcSine
		moveq	#0,d2
		move.b	(a1)+,d2
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,(a3)+
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d2,(a3)+
		dbf	d3,loc_5664
		lea	(v_ngfx_buffer).w,a3
		lea	(byte_56F6).l,a2
		bra.s	loc_56BC
; ---------------------------------------------------------------------------

loc_568C:
		cmpi.w	#$C,d0
		bne.s	loc_56B2
		subq.w	#1,(Camera_BG3_X_pos).w
		lea	(v_ssscroll_buffer).w,a3
		move.l	#$18000,d2
		moveq	#6,d1

loc_56A2:
		move.l	(a3),d0
		sub.l	d2,d0
		move.l	d0,(a3)+
		subi.l	#$2000,d2
		dbf	d1,loc_56A2

loc_56B2:
		lea	(v_ssscroll_buffer).w,a3
		lea	(byte_5701).l,a2

loc_56BC:
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(Camera_BG3_X_pos).w,d0
		neg.w	d0
		swap	d0
		moveq	#0,d3
		move.b	(a2)+,d3
		move.w	(Camera_BG_Y_pos).w,d2
		neg.w	d2
		andi.w	#$FF,d2
		lsl.w	#2,d2

loc_56D8:
		move.w	(a3)+,d0
		addq.w	#2,a3
		moveq	#0,d1
		move.b	(a2)+,d1
		subq.w	#1,d1

loc_56E2:
		move.l	d0,(a1,d2.w)
		addq.w	#4,d2
		andi.w	#$3FC,d2
		dbf	d1,loc_56E2
		dbf	d3,loc_56D8
		rts
; End of function S1SS_BgAnimate


byte_56F6:	dc.b   9,$28,$18,$10,$28,$18,$10,$30,$18,  8,$10
byte_5701:	dc.b   6,$30,$30,$30,$28,$18,$18,$18
byte_5709:	dc.b   8,  2,  4,$FF,  2,  3,  8,$FF,  4,  2,  2,  3,  8,$FD,  4,  2
		dc.b   2,  3,  2,$FF
		even

		jmpTos	; Empty

; =============== S U B	R O U T	I N E =======================================


LevelSizeLoad:
		clr.w	(Scroll_flags).w
		clr.w	(Scroll_flags_BG).w
		clr.w	(Scroll_flags_BG2).w
		clr.w	(Scroll_flags_BG3).w
		clr.w	(Scroll_flags_P2).w
		clr.w	(Scroll_flags_BG_P2).w
		clr.w	(Scroll_flags_BG2_P2).w
		clr.w	(Scroll_flags_BG3_P2).w
		clr.w	(Scroll_flags_copy).w
		clr.w	(Scroll_flags_BG_copy).w
		clr.w	(Scroll_flags_BG2_copy).w
		clr.w	(Scroll_flags_BG3_copy).w
		clr.w	(Scroll_flags_copy_P2).w
		clr.w	(Scroll_flags_BG_copy_P2).w
		clr.w	(Scroll_flags_BG2_copy_P2).w
		clr.w	(Scroll_flags_BG3_copy_P2).w
		clr.b	(Deform_lock).w
		moveq	#0,d0
		move.b	d0,(Dynamic_Resize_Routine).w
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#3,d0
		lea	LevelSizeArray(pc,d0.w),a0
		move.l	(a0)+,d0
		move.l	d0,(Camera_Min_X_pos).w
		move.l	d0,(Camera_Min_X_pos_target).w
		move.l	(a0)+,d0
		move.l	d0,(Camera_Min_Y_pos).w
		move.l	d0,(Camera_Min_Y_pos_target).w
		move.w	#$1010,(Horiz_block_crossed_flag).w
		move.w	#$60,(Camera_Y_pos_bias).w
		bra.w	LevelSize_CheckLamp
; ===========================================================================
LevelSizeArray:
		dc.w	 0,  $24BF,     0,	$300	; GHZ1
		dc.w	 0,  $1EBF,     0,	$300	; GHZ2
		dc.w	 0,  $2960,     0,	$300	; GHZ3
		dc.w	 0,  $2ABF,     0,	$300	; GHZ4
		dc.w	 0,  $3FFF,     0,	$720	; LZ1
		dc.w	 0,  $3FFF,     0,	$720	; LZ2
		dc.w	 0,  $3FFF,     0,	$720	; LZ3
		dc.w	 0,  $3FFF,     0,	$720	; LZ4
		dc.w	 0,  $3FFF,     0,	$720	; CPZ1
		dc.w	 0,  $3FFF,     0,	$720	; CPZ2
		dc.w	 0,  $3FFF,     0,	$720	; CPZ3
		dc.w	 0,  $3FFF,     0,	$720	; CPZ4
		dc.w	 0,  $29A0,     0,	$320	; EHZ1
		dc.w	 0,  $2940,     0,	$420	; EHZ2
		dc.w	 0,  $25C0,     0,	$720	; EHZ3
		dc.w	 0,  $3FFF,     0,	$720	; EHZ4
		dc.w	 0,  $3FFF,     0,	$720	; HPZ1
		dc.w	 0,  $3FFF,     0,	$720	; HPZ2
		dc.w	 0,  $3FFF,     0,	$720	; HPZ3
		dc.w	 0,  $3FFF,     0,	$720	; HPZ4
		dc.w	 0,  $3FFF,     0,	$720	; HTZ1
		dc.w	 0,  $3FFF, -$100,	$720	; HTZ2
		dc.w $2080,  $3FFF,  $510,	$720	; HTZ3
		dc.w	 0,  $3FFF,     0,	$720	; HTZ4
		dc.w	 0,  $500,   $110,	$110	; S1 Ending 1
		dc.w	 0,  $DC0,   $110,	$110	; S1 Ending 2
		dc.w	 0,  $2FFF,     0,	$320	; S1 Ending 3
		dc.w	 0,  $2FFF,     0,	$320	; S1 Ending 4
; ===========================================================================
S1EndingStartLoc:
		binclude	"startpos/S1/ghz1 (Credits demo 1).bin"
		even
		binclude	"startpos/S1/mz2 (Credits demo).bin"
		even
		binclude	"startpos/S1/syz3 (Credits demo).bin"
		even
		binclude	"startpos/S1/lz3 (Credits demo).bin"
		even
		binclude	"startpos/S1/slz3 (Credits demo).bin"
		even
		binclude	"startpos/S1/sbz1 (Credits demo).bin"
		even
		binclude	"startpos/S1/sbz2 (Credits demo).bin"
		even
		binclude	"startpos/S1/ghz1 (Credits demo 2).bin"
		even
; ===========================================================================

LevelSize_CheckLamp:
		tst.b	(v_lastlamp).w
		beq.s	LevelSize_StartLoc
		jsr	(Lamppost_LoadInfo).l
		move.w	(v_player+obX).w,d1
		move.w	(v_player+obY).w,d0
		bra.s	LevelSize_StartLocLoaded
; ---------------------------------------------------------------------------

LevelSize_StartLoc:
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	StartLocArray(pc,d0.w),a1
		tst.w	(f_demo).w
		bpl.s	loc_58CE

		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		lea	S1EndingStartLoc(pc,d0.w),a1

loc_58CE:
		moveq	#0,d1
		move.w	(a1)+,d1
		move.w	d1,(v_player+obX).w
		moveq	#0,d0
		move.w	(a1),d0
		move.w	d0,(v_player+obY).w

LevelSize_StartLocLoaded:
		subi.w	#$A0,d1
		bhs.s	loc_58E6
		moveq	#0,d1

loc_58E6:
		move.w	(Camera_Max_X_pos).w,d2
		cmp.w	d2,d1
		blo.s	loc_58F0
		move.w	d2,d1

loc_58F0:
		move.w	d1,(Camera_X_pos).w
		move.w	d1,(Camera_X_pos_P2).w
		subi.w	#$60,d0
		bhs.s	loc_5900
		moveq	#0,d0

loc_5900:
		cmp.w	(Camera_Max_Y_pos).w,d0
		blt.s	loc_590A
		move.w	(Camera_Max_Y_pos).w,d0

loc_590A:
		move.w	d0,(Camera_Y_pos).w
		move.w	d0,(Camera_Y_pos_P2).w
		bsr.w	BgScrollSpeed
		rts
; End of function LevelSizeLoad


StartLocArray:
		binclude	"startpos/S1/ghz1.bin"	; GHZ1
		even
		binclude	"startpos/S1/ghz2.bin"	; GHZ2
		even
		binclude	"startpos/S1/ghz3.bin"	; GHZ3
		even
		dc.w   $80,  $A8			; GHZ4
		even
		binclude	"startpos/S1/lz1.bin"	; LZ1
		even
		binclude	"startpos/S1/lz2.bin"	; LZ2
		even
		binclude	"startpos/S1/lz3.bin"	; LZ3
		even
		binclude	"startpos/S1/sbz3.bin"	; SBZ3 (LZ4)
		even
		binclude	"startpos/CPZ_1.bin"	; CPZ1
		even
		binclude	"startpos/S1/mz2.bin"	; CPZ2 (MZ2)
		even
		binclude	"startpos/S1/mz3.bin"	; CPZ3 (MZ3)
		even
		dc.w   $80,  $A8			; CPZ4
		even
		binclude	"startpos/EHZ_1.bin"	; EHZ1
		even
		binclude	"startpos/EHZ_2.bin"	; EHZ2
		even
		binclude	"startpos/EHZ_3.bin"	; EHZ3
		even
		dc.w   $80,  $A8			; EHZ4
		even
		binclude	"startpos/HPZ_1.bin"	; HPZ1
		even
		binclude	"startpos/S1/syz2.bin"	; HPZ2 (SYZ2)
		even
		binclude	"startpos/S1/syz3.bin"	; HPZ3 (SYZ3)
		even
		dc.w   $80,  $A8			; HPZ4
		even
		binclude	"startpos/HTZ_1.bin"	; HTZ1
		even
		binclude	"startpos/HTZ_2.bin"	; HTZ2
		even
		binclude	"startpos/S1/fz.bin"	; HTZ3 (FZ)
		even
		dc.w   $80,  $A8			; HTZ4
		even
		binclude	"startpos/S1/end1.bin"	; S1 Ending 1
		even
		binclude	"startpos/S1/end2.bin"	; S1 Ending 2
		even
		dc.w   $80,  $A8			; S1 Ending 3
		even
		dc.w   $80,  $A8			; S1 Ending 4
		even

; =============== S U B	R O U T	I N E =======================================


BgScrollSpeed:
		tst.b	(v_lastlamp).w
		bne.s	loc_59B6
		move.w	d0,(Camera_BG_Y_pos).w
		move.w	d0,(Camera_BG2_Y_pos).w
		move.w	d1,(Camera_BG_X_pos).w
		move.w	d1,(Camera_BG2_X_pos).w
		move.w	d1,(Camera_BG3_X_pos).w
		move.w	d0,(Camera_BG_Y_pos_P2).w
		move.w	d0,(Camera_BG2_Y_pos_P2).w
		move.w	d1,(Camera_BG_X_pos_P2).w
		move.w	d1,(Camera_BG2_X_pos_P2).w
		move.w	d1,(Camera_BG3_X_pos_P2).w

loc_59B6:
		moveq	#0,d2
		move.b	(Current_Zone).w,d2
		add.w	d2,d2
		move.w	BgScroll_Index(pc,d2.w),d2
		jmp	BgScroll_Index(pc,d2.w)
; End of function BgScrollSpeed

; ---------------------------------------------------------------------------
BgScroll_Index:	dc.w BgScroll_GHZ-BgScroll_Index
		dc.w BgScroll_LZ-BgScroll_Index
		dc.w BgScroll_CPZ-BgScroll_Index
		dc.w BgScroll_EHZ-BgScroll_Index
		dc.w BgScroll_HPZ-BgScroll_Index
		dc.w BgScroll_EHZ-BgScroll_Index
		dc.w BgScroll_S1Ending-BgScroll_Index
; ---------------------------------------------------------------------------

BgScroll_GHZ:
		clr.l	(Camera_BG_X_pos).w
		clr.l	(Camera_BG_Y_pos).w
		clr.l	(Camera_BG2_Y_pos).w
		clr.l	(Camera_BG3_Y_pos).w
		lea	(v_bgscroll_buffer).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(Camera_BG_X_pos_P2).w
		clr.l	(Camera_BG_Y_pos_P2).w
		clr.l	(Camera_BG2_Y_pos_P2).w
		clr.l	(Camera_BG3_Y_pos_P2).w
		rts
; ---------------------------------------------------------------------------

BgScroll_LZ:
		asr.l	#1,d0
		move.w	d0,(Camera_BG_Y_pos).w
		rts
; ---------------------------------------------------------------------------

BgScroll_CPZ:
		lsr.w	#2,d0
		move.w	d0,(Camera_BG_Y_pos).w
		move.w	d0,(Camera_BG_Y_pos_P2).w
		clr.l	(Camera_BG_X_pos).w
		clr.l	(Camera_BG2_X_pos).w
		rts
; ---------------------------------------------------------------------------

BgScroll_EHZ:
		; identical to BgScroll_GHZ
		clr.l	(Camera_BG_X_pos).w
		clr.l	(Camera_BG_Y_pos).w
		clr.l	(Camera_BG2_Y_pos).w
		clr.l	(Camera_BG3_Y_pos).w
		lea	(v_bgscroll_buffer).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(Camera_BG_X_pos_P2).w
		clr.l	(Camera_BG_Y_pos_P2).w
		clr.l	(Camera_BG2_Y_pos_P2).w
		clr.l	(Camera_BG3_Y_pos_P2).w
		rts
; ---------------------------------------------------------------------------

BgScroll_HPZ:
		asr.w	#1,d0
		move.w	d0,(Camera_BG_Y_pos).w
		clr.l	(Camera_BG_X_pos).w
		rts
; ---------------------------------------------------------------------------

BgScroll_S1SYZ:						; leftover from Sonic 1
		asl.l	#4,d0
		move.l	d0,d2
		asl.l	#1,d0
		add.l	d2,d0
		asr.l	#8,d0
		addq.w	#1,d0
		move.w	d0,(Camera_BG_Y_pos).w
		clr.l	(Camera_BG_X_pos).w
		rts
; ---------------------------------------------------------------------------

BgScroll_S1Ending:
		move.w	(Camera_X_pos).w,d0
		asr.w	#1,d0
		move.w	d0,(Camera_BG_X_pos).w
		move.w	d0,(Camera_BG2_X_pos).w
		asr.w	#2,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,(Camera_BG3_X_pos).w
		clr.l	(Camera_BG_Y_pos).w
		clr.l	(Camera_BG2_Y_pos).w
		clr.l	(Camera_BG3_Y_pos).w
		lea	(v_bgscroll_buffer).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts

		include	"_Include/DeformLayers.asm"
		include	"_Include/Level Drawing.asm"

; =============== S U B	R O U T	I N E =======================================


MainLevelLoadBlock:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#4,d0
		lea	(LevelArtPointers).l,a2
		lea	(a2,d0.w),a2
		move.l	a2,-(sp)
		addq.l	#4,a2
		movea.l	(a2)+,a0
		tst.b	(Current_Zone).w
		beq.s	MainLevelLoadBlock_Convert16
		bra.s	MainLevelLoadBlock_Convert16
; ---------------------------------------------------------------------------

MainLevelLoadBlock_Skip16Convert:			; leftover from a previous build
		lea	(v_16x16).w,a1
		move.w	#make_art_tile(ArtTile_Level,0,0),d0
		bsr.w	EniDec
		bra.s	loc_72C2
; ---------------------------------------------------------------------------

MainLevelLoadBlock_Convert16:
		lea	(v_16x16).w,a1
		move.w	#bytesToWcnt(v_16x16_end-v_16x16),d2

MainLevelLoadBlock_ConvertLoop:
		move.w	(a0)+,d0
		tst.w	(Two_player_mode).w
		beq.s	MainLevelLoadBlock_Not2p
		move.w	d0,d1
		andi.w	#nontile_mask,d0
		andi.w	#tile_mask,d1
		lsr.w	#1,d1
		or.w	d1,d0

MainLevelLoadBlock_Not2p:
		move.w	d0,(a1)+
		dbf	d2,MainLevelLoadBlock_ConvertLoop

loc_72C2:
		cmpi.b	#id_HTZ,(Current_Zone).w
		bne.s	loc_72F4
		lea	(v_16x16+$980).w,a1
		lea	(Map16_HTZ).l,a0
	if FixBugs
		move.w	#bytesToWcnt(Map16_HTZ_End-Map16_HTZ),d2
	else
		; There is a slight bug here in which 50 bytes are copied from the start of Nem_HTZ.
		move.w	#bytesToWcnt(Map16_HTZ_End+$50-Map16_HTZ),d2
	endif

loc_72D8:
		move.w	(a0)+,d0
		tst.w	(Two_player_mode).w
		beq.s	loc_72EE
		move.w	d0,d1
		andi.w	#nontile_mask,d0
		andi.w	#tile_mask,d1
		lsr.w	#1,d1
		or.w	d1,d0

loc_72EE:
		move.w	d0,(a1)+
		dbf	d2,loc_72D8

loc_72F4:
		movea.l	(a2)+,a0
		; What follows is a very C style compare code for zones that aren't GHZ, LZ, or EndZ.
		; This works well in-game, except for LZ which uses the same data as CPZ.
		; What this could point to is that at some point, LZ used compressed chunks similar to that of GHZ.
		; However, instead it tries to decompress chunks that are already uncompressed to begin with.

		; This could also be entirely rewritten so that EndZ is compared first, and if equal, then branch to the decompression routine.
		; Then it could follow up with a check to see if the zone is greater than or equal to CPZ, simplifying the following compares into
		; just two compares.

	if FixBugs
		; Fixes the bug described above, resulting in a graphical mess for LZ.
		cmpi.b	#id_LZ,(Current_Zone).w
		beq.s	loc_7338
	endif
		cmpi.b	#id_CPZ,(Current_Zone).w
		beq.s	loc_7338
		cmpi.b	#id_EHZ,(Current_Zone).w
		beq.s	loc_7338
		cmpi.b	#id_HPZ,(Current_Zone).w
		beq.s	loc_7338
		cmpi.b	#id_HTZ,(Current_Zone).w
		beq.s	loc_7338
		move.l	a2,-(sp)
		moveq	#0,d1
		moveq	#0,d2
		move.w	(a0)+,d0
		lea	(a0,d0.w),a1
		lea	(v_128x128).l,a2
		lea	(v_128x128_end).w,a3

loc_732C:
		bsr.w	KC_Dec
		tst.w	d0
		bmi.s	loc_732C
		movea.l	(sp)+,a2
		bra.s	loc_7348
; ---------------------------------------------------------------------------

loc_7338:
		lea	(v_128x128).l,a1
		move.w	#bytesToWcnt(v_128x128_end-v_128x128),d0

loc_7342:
		move.w	(a0)+,(a1)+
		dbf	d0,loc_7342

loc_7348:
		bsr.w	LevelLayoutLoad
		move.w	(a2)+,d0
		move.w	(a2),d0
		andi.w	#$FF,d0
		cmpi.w	#(id_LZ<<8)+3,(Current_ZoneAndAct).w
		bne.s	loc_735E
		moveq	#palid_SBZ3,d0

loc_735E:
		cmpi.w	#(id_SBZ<<8)+1,(Current_ZoneAndAct).w
		beq.s	loc_736E
		cmpi.w	#(id_SBZ<<8)+2,(Current_ZoneAndAct).w
		bne.s	loc_7370

loc_736E:
		moveq	#palid_HTZ2,d0

loc_7370:
		bsr.w	PalLoad1
		movea.l	(sp)+,a2
		addq.w	#4,a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	locret_7382
		bsr.w	LoadPLC

locret_7382:
		rts
; End of function MainLevelLoadBlock

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load a level layout from RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


LevelLayoutLoad:
		lea	(v_lvllayout).w,a3
		move.w	#bytesToLcnt(v_lvllayout_end-v_lvllayout),d1
		moveq	#0,d0

loc_738E:
		move.l	d0,(a3)+
		dbf	d1,loc_738E			; fill $8000-$8FFF with 0

		lea	(v_lvllayout).w,a3		; load foreground into RAM
		moveq	#0,d1
		bsr.w	LevelLayoutLoad2
		lea	(v_lvllayoutbg).w,a3		; load background into RAM
		moveq	#2,d1

LevelLayoutLoad2:
		tst.b	(Current_Zone).w		; test zone bit
		beq.s	LevelLayoutLoad_GHZ		; if zero (GHZ), branch
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#5,d0
		move.w	d0,d2
		add.w	d0,d0
		add.w	d2,d0
		add.w	d1,d0
		lea	(Level_Index).l,a1
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		moveq	#0,d1
		move.w	d1,d2
		move.b	(a1)+,d1			; load level width (in tiles)
		move.b	(a1)+,d2			; load level height (in tiles)
		move.l	d1,d5
		addq.l	#1,d5
		moveq	#0,d3
		move.w	#$80,d3
		divu.w	d5,d3
		subq.w	#1,d3

loc_73DE:
		movea.l	a3,a0
		move.w	d3,d4

loc_73E2:
		move.l	a1,-(sp)
		move.w	d1,d0

loc_73E6:
		move.b	(a1)+,(a0)+
		dbf	d0,loc_73E6
		movea.l	(sp)+,a1
		dbf	d4,loc_73E2
		lea	(a1,d5.w),a1
		lea	$80*2(a3),a3
		dbf	d2,loc_73DE
		rts
; End of function LevelLayoutLoad

; ===========================================================================
; dynamically converts the Sonic 1 level layout into Sonic 2 Nick Arcade's,
; read more about it here: https://forums.sonicretro.org/index.php?posts/993641/
LevelLayoutLoad_GHZ:
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#5,d0
		move.w	d0,d2
		add.w	d0,d0
		add.w	d2,d0
		add.w	d1,d0
		lea	(Level_Index).l,a1
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		moveq	#0,d1
		move.w	d1,d2
		move.b	(a1)+,d1			; load level width (in tiles)
		move.b	(a1)+,d2			; load level height (in tiles)

loc_7426:
		move.w	d1,d0
		movea.l	a3,a0

loc_742A:
		move.b	(a1)+,d3			; get chunk ID
		subq.b	#1,d3				; subtract 1 from chunk ID
		bhs.s	loc_7440			; if chunk is not $00, branch
		moveq	#0,d3				; set 'air' chunk to $00
		move.b	d3,(a0)+			; load first chunk
		move.b	d3,(a0)+			; load second chunk
		move.b	d3,$FE(a0)			; load third chunk
		move.b	d3,$FF(a0)			; load fourth chunk
		bra.s	loc_7456
; ===========================================================================

loc_7440:
		lsl.b	#2,d3				; multiply chunk ID by 4
		addq.b	#1,d3				; add 1 to chunk ID
		move.b	d3,(a0)+			; load first chunk
		addq.b	#1,d3				; add 1 to chunk ID
		move.b	d3,(a0)+			; load second chunk
		addq.b	#1,d3				; add 1 to chunk ID
		move.b	d3,$FE(a0)			; load third chunk
		addq.b	#1,d3				; add 1 to chunk ID
		move.b	d3,$FF(a0)			; load fourth chunk

loc_7456:
		dbf	d0,loc_742A			; load 1 row
		lea	$80*4(a3),a3			; do next row
		dbf	d2,loc_7426			; repeat for number of rows
		rts
; End of function LevelLayoutLoad_GHZ

; ---------------------------------------------------------------------------

LevelLayout_Convert:					; leftover level layout	converting function (from raw to the way it's stored in the game)
		lea	(RAM_debug_start).l,a1
		lea	(RAM_debug_start+$80).l,a2
		lea	(v_ram_start).l,a3
		move.w	#$40-1,d1

loc_747A:
		bsr.w	sub_750C
		bsr.w	sub_750C
		dbf	d1,loc_747A
		lea	(RAM_debug_start).l,a1
		lea	(v_ram_start&$FFFFFF).l,a2
		move.w	#bytesToWcnt($80),d1

loc_7496:
		move.w	#0,(a2)+
		dbf	d1,loc_7496
		move.w	#bytesToWcnt($7F80),d1

loc_74A2:
		move.w	(a1)+,(a2)+
		dbf	d1,loc_74A2
		rts
; ---------------------------------------------------------------------------
		lea	(RAM_debug_start).l,a1
		lea	(v_ram_start).l,a3
		moveq	#bytesToLcnt($80),d0

loc_74B8:
		move.l	(a1)+,(a3)+
		dbf	d0,loc_74B8
		moveq	#0,d7
		lea	(RAM_debug_start).l,a1
		move.w	#bytesToWcnt($200),d5

loc_74CA:
		lea	(v_ram_start).l,a3
		move.w	d7,d6

loc_74D2:
		movem.l	a1-a3,-(sp)
		move.w	#bytesToWcnt($80),d0

loc_74DA:
		cmpm.w	(a1)+,(a3)+
		bne.s	loc_74F0
		dbf	d0,loc_74DA
		movem.l	(sp)+,a1-a3
		adda.w	#$80,a1
		dbf	d5,loc_74CA
		bra.s	loc_750A
; ---------------------------------------------------------------------------

loc_74F0:
		movem.l	(sp)+,a1-a3
		adda.w	#$80,a3
		dbf	d6,loc_74D2
		moveq	#bytesToLcnt($80),d0

loc_74FE:
		move.l	(a1)+,(a3)+
		dbf	d0,loc_74FE
		addq.l	#1,d7
		dbf	d5,loc_74CA

loc_750A:
		bra.s	loc_750A

; =============== S U B	R O U T	I N E =======================================


sub_750C:
		moveq	#bytesToXcnt($100,32),d0

loc_750E:
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		dbf	d0,loc_750E
		adda.w	#$80,a1
		adda.w	#$80,a2
		rts
; End of function sub_750C


; =============== S U B	R O U T	I N E =======================================


DynScreenResizeLoad:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		move.w	DynResize_Index(pc,d0.w),d0
		jsr	DynResize_Index(pc,d0.w)
		moveq	#2,d1
		move.w	(Camera_Max_Y_pos_target).w,d0
		sub.w	(Camera_Max_Y_pos).w,d0
		beq.s	locret_756A
		bhs.s	loc_756C
		neg.w	d1
		move.w	(Camera_Y_pos).w,d0
		cmp.w	(Camera_Max_Y_pos_target).w,d0
		bls.s	loc_7560
		move.w	d0,(Camera_Max_Y_pos).w
		andi.w	#-2,(Camera_Max_Y_pos).w

loc_7560:
		add.w	d1,(Camera_Max_Y_pos).w
		move.b	#1,(Camera_Max_Y_Pos_Changing).w

locret_756A:
		rts
; ---------------------------------------------------------------------------

loc_756C:
		move.w	(Camera_Y_pos).w,d0
		addi.w	#8,d0
		cmp.w	(Camera_Max_Y_pos).w,d0
		blo.s	loc_7586
		btst	#1,(v_player+obStatus).w
		beq.s	loc_7586
		add.w	d1,d1
		add.w	d1,d1

loc_7586:
		add.w	d1,(Camera_Max_Y_pos).w
		move.b	#1,(Camera_Max_Y_Pos_Changing).w
		rts
; End of function DynScreenResizeLoad

; ---------------------------------------------------------------------------
DynResize_Index:dc.w DynResize_GHZ-DynResize_Index
		dc.w DynResize_LZ-DynResize_Index
		dc.w DynResize_CPZ-DynResize_Index
		dc.w DynResize_EHZ-DynResize_Index
		dc.w DynResize_HPZ-DynResize_Index
		dc.w DynResize_HTZ-DynResize_Index
		dc.w DynResize_S1Ending-DynResize_Index
; ---------------------------------------------------------------------------

DynResize_GHZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynResize_GHZ_Index(pc,d0.w),d0
		jmp	DynResize_GHZ_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_GHZ_Index:dc.w DynResize_GHZ1-DynResize_GHZ_Index
		dc.w DynResize_GHZ2-DynResize_GHZ_Index
		dc.w DynResize_GHZ3-DynResize_GHZ_Index
; ---------------------------------------------------------------------------

DynResize_GHZ1:
		move.w	#$300,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1780,(Camera_X_pos).w
		blo.s	locret_75CA
		move.w	#$400,(Camera_Max_Y_pos_target).w

locret_75CA:
		rts
; ---------------------------------------------------------------------------

DynResize_GHZ2:
		move.w	#$300,(Camera_Max_Y_pos_target).w
		cmpi.w	#$ED0,(Camera_X_pos).w
		blo.s	locret_75FC
		move.w	#$200,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1600,(Camera_X_pos).w
		blo.s	locret_75FC
		move.w	#$400,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1D60,(Camera_X_pos).w
		blo.s	locret_75FC
		move.w	#$300,(Camera_Max_Y_pos_target).w

locret_75FC:
		rts
; ---------------------------------------------------------------------------

DynResize_GHZ3:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	DynResize_GHZ3_Index(pc,d0.w),d0
		jmp	DynResize_GHZ3_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_GHZ3_Index:dc.w DynResize_GHZ3_Main-DynResize_GHZ3_Index
		dc.w DynResize_GHZ3_Boss-DynResize_GHZ3_Index
		dc.w DynResize_GHZ3_End-DynResize_GHZ3_Index
; ---------------------------------------------------------------------------

DynResize_GHZ3_Main:
		move.w	#$300,(Camera_Max_Y_pos_target).w
		cmpi.w	#$380,(Camera_X_pos).w
		blo.s	locret_7658
		move.w	#$310,(Camera_Max_Y_pos_target).w
		cmpi.w	#$960,(Camera_X_pos).w
		blo.s	locret_7658
		cmpi.w	#$280,(Camera_Y_pos).w
		blo.s	loc_765A
		move.w	#$400,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1380,(Camera_X_pos).w
		bhs.s	loc_7650
		move.w	#$4C0,(Camera_Max_Y_pos_target).w
		move.w	#$4C0,(Camera_Max_Y_pos).w

loc_7650:
		cmpi.w	#$1700,(Camera_X_pos).w
		bhs.s	loc_765A

locret_7658:
		rts
; ---------------------------------------------------------------------------

loc_765A:
		move.w	#$300,(Camera_Max_Y_pos_target).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		rts
; ---------------------------------------------------------------------------

DynResize_GHZ3_Boss:
		cmpi.w	#$960,(Camera_X_pos).w
		bhs.s	loc_7672
		subq.b	#2,(Dynamic_Resize_Routine).w

loc_7672:
		cmpi.w	#$2960,(Camera_X_pos).w
		blo.s	locret_76AA
		bsr.w	FindFreeObj
		bne.s	loc_7692
		_move.b	#id_Obj3D,obID(a1)
		move.w	#$2A60,obX(a1)
		move.w	#$280,obY(a1)

loc_7692:
		move.w	#bgm_Boss,d0
		bsr.w	QueueSound1
		move.b	#1,(f_lockscreen).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		moveq	#plcid_Boss,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_76AA:
		rts
; ---------------------------------------------------------------------------

DynResize_GHZ3_End:
		move.w	(Camera_X_pos).w,(Camera_Min_X_pos).w
		rts
; ---------------------------------------------------------------------------

DynResize_LZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynResize_LZ_Index(pc,d0.w),d0
		jmp	DynResize_LZ_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_LZ_Index:dc.w	DynResize_LZ_Null-DynResize_LZ_Index
		dc.w DynResize_LZ_Null-DynResize_LZ_Index
		dc.w DynResize_LZ3-DynResize_LZ_Index
		dc.w DynResize_LZ4-DynResize_LZ_Index
; ---------------------------------------------------------------------------

DynResize_LZ_Null:
		rts
; ---------------------------------------------------------------------------

DynResize_LZ3:
		tst.b	(f_switch+$F).w
		beq.s	loc_76EA
		lea	(v_lvllayout+$206).w,a1
		cmpi.b	#7,(a1)
		beq.s	loc_76EA
		move.b	#7,(a1)
		move.w	#sfx_Rumbling,d0
		bsr.w	QueueSound2

loc_76EA:
		tst.b	(Dynamic_Resize_Routine).w
		bne.s	locret_7726
		cmpi.w	#$1CA0,(Camera_X_pos).w
		blo.s	locret_7724
		cmpi.w	#$600,(Camera_Y_pos).w
		bhs.s	locret_7724
		bsr.w	FindFreeObj
		bne.s	loc_770C
		_move.b	#id_Obj77,obID(a1)

loc_770C:
		move.w	#bgm_Boss,d0
		bsr.w	QueueSound1
		move.b	#1,(f_lockscreen).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		moveq	#plcid_Boss,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_7724:
		rts
; ---------------------------------------------------------------------------

locret_7726:
		rts
; ---------------------------------------------------------------------------

DynResize_LZ4:
		cmpi.w	#$D00,(Camera_X_pos).w
		blo.s	locret_774E
		cmpi.w	#$18,(v_player+obY).w
		bhs.s	locret_774E
		clr.b	(v_lastlamp).w
		move.w	#1,(Level_Inactive_flag).w
		move.w	#(id_SBZ<<8)+2,(Current_ZoneAndAct).w
		move.b	#1,(f_playerctrl).w

locret_774E:
		rts
; ---------------------------------------------------------------------------

DynResize_CPZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynResize_CPZ_Index(pc,d0.w),d0
		jmp	DynResize_CPZ_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_CPZ_Index:dc.w DynResize_CPZ1-DynResize_CPZ_Index
		dc.w DynResize_CPZ2-DynResize_CPZ_Index
		dc.w DynResize_CPZ3-DynResize_CPZ_Index
; ---------------------------------------------------------------------------

DynResize_CPZ1:
		rts
; ---------------------------------------------------------------------------

S1DynResize_MZ1:					; leftover from Sonic 1
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	off_7776(pc,d0.w),d0
		jmp	off_7776(pc,d0.w)
; ---------------------------------------------------------------------------
off_7776:	dc.w loc_777E-off_7776
		dc.w loc_77AE-off_7776
		dc.w loc_77F2-off_7776
		dc.w loc_781C-off_7776
; ---------------------------------------------------------------------------

loc_777E:
		move.w	#$1D0,(Camera_Max_Y_pos_target).w
		cmpi.w	#$700,(Camera_X_pos).w
		blo.s	locret_77AC
		move.w	#$220,(Camera_Max_Y_pos_target).w
		cmpi.w	#$D00,(Camera_X_pos).w
		blo.s	locret_77AC
		move.w	#$340,(Camera_Max_Y_pos_target).w
		cmpi.w	#$340,(Camera_Y_pos).w
		blo.s	locret_77AC
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_77AC:
		rts
; ---------------------------------------------------------------------------

loc_77AE:
		cmpi.w	#$340,(Camera_Y_pos).w
		bhs.s	loc_77BC
		subq.b	#2,(Dynamic_Resize_Routine).w
		rts
; ---------------------------------------------------------------------------

loc_77BC:
		move.w	#0,(Camera_Min_Y_pos).w
		cmpi.w	#$E00,(Camera_X_pos).w
		bhs.s	locret_77F0
		move.w	#$340,(Camera_Min_Y_pos).w
		move.w	#$340,(Camera_Max_Y_pos_target).w
		cmpi.w	#$A90,(Camera_X_pos).w
		bhs.s	locret_77F0
		move.w	#$500,(Camera_Max_Y_pos_target).w
		cmpi.w	#$370,(Camera_Y_pos).w
		blo.s	locret_77F0
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_77F0:
		rts
; ---------------------------------------------------------------------------

loc_77F2:
		cmpi.w	#$370,(Camera_Y_pos).w
		bhs.s	loc_7800
		subq.b	#2,(Dynamic_Resize_Routine).w
		rts
; ---------------------------------------------------------------------------

loc_7800:
		cmpi.w	#$500,(Camera_Y_pos).w
		blo.s	locret_781A
		cmpi.w	#$B80,(Camera_X_pos).w
		blo.s	locret_781A
		move.w	#$500,(Camera_Min_Y_pos).w
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_781A:
		rts
; ---------------------------------------------------------------------------

loc_781C:
		cmpi.w	#$B80,(Camera_X_pos).w
		bhs.s	loc_7832
		cmpi.w	#$340,(Camera_Min_Y_pos).w
		beq.s	locret_786A
		subq.w	#2,(Camera_Min_Y_pos).w
		rts
; ---------------------------------------------------------------------------

loc_7832:
		cmpi.w	#$500,(Camera_Min_Y_pos).w
		beq.s	loc_7848
		cmpi.w	#$500,(Camera_Y_pos).w
		blo.s	locret_786A
		move.w	#$500,(Camera_Min_Y_pos).w

loc_7848:
		cmpi.w	#$E70,(Camera_X_pos).w
		blo.s	locret_786A
		move.w	#0,(Camera_Min_Y_pos).w
		move.w	#$500,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1430,(Camera_X_pos).w
		blo.s	locret_786A
		move.w	#$210,(Camera_Max_Y_pos_target).w

locret_786A:
		rts
; ---------------------------------------------------------------------------

DynResize_CPZ2:
		rts
; ---------------------------------------------------------------------------

S1DynResize_MZ2:					; leftover from Sonic 1
		move.w	#$520,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1700,(Camera_X_pos).w
		blo.s	locret_7882
		move.w	#$200,(Camera_Max_Y_pos_target).w

locret_7882:
		rts
; ===========================================================================

DynResize_CPZ3:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	off_7892(pc,d0.w),d0
		jmp	off_7892(pc,d0.w)
; ===========================================================================
off_7892:	dc.w DynResize_CPZ3_BossCheck-off_7892
		dc.w DynResize_CPZ3_Null-off_7892
; ===========================================================================

DynResize_CPZ3_BossCheck:
		cmpi.w	#$480,(Camera_X_pos).w
		blt.s	DynResize_CPZ3_Null
		cmpi.w	#$740,(Camera_X_pos).w
		bgt.s	DynResize_CPZ3_Null
		move.w	(Camera_Max_Y_pos).w,d0
		cmp.w	(Camera_Y_pos).w,d0
		bne.s	DynResize_CPZ3_Null
		move.w	#$740,(Camera_Max_X_pos).w
		move.w	#$480,(Camera_Min_X_pos).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		bsr.w	FindFreeObj
		bne.s	DynResize_CPZ3_Null
		_move.b	#id_Obj55,obID(a1)			; load Obj55 (EHZ boss, likely CPZ boss at one point)
		move.w	#$680,obX(a1)
		move.w	#$540,obY(a1)
		moveq	#plcid_Boss,d0
		bra.w	LoadPLC
; ===========================================================================

DynResize_CPZ3_Null:
		rts
; ---------------------------------------------------------------------------

DynResize_EHZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	off_78F0(pc,d0.w),d0
		jmp	off_78F0(pc,d0.w)
; ---------------------------------------------------------------------------
off_78F0:	dc.w DynResize_EHZ1-off_78F0
		dc.w DynResize_EHZ2-off_78F0
		dc.w locret_7980-off_78F0
; ---------------------------------------------------------------------------

DynResize_EHZ1:
		rts
; ---------------------------------------------------------------------------

DynResize_EHZ2:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	DynResize_EHZ2_Index(pc,d0.w),d0
		jmp	DynResize_EHZ2_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_EHZ2_Index:dc.w DynResize_EHZ2_01-DynResize_EHZ2_Index
		dc.w DynResize_EHZ2_02-DynResize_EHZ2_Index
		dc.w DynResize_EHZ2_03-DynResize_EHZ2_Index
; ---------------------------------------------------------------------------

DynResize_EHZ2_01:
		cmpi.w	#$26E0,(Camera_X_pos).w
		blo.s	locret_795A
		move.w	(Camera_X_pos).w,(Camera_Min_X_pos).w
		move.w	#$390,(Camera_Max_Y_pos_target).w
		move.w	#$390,(Camera_Max_Y_pos).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		bsr.w	FindFreeObj
		bne.s	loc_7946
		move.b	#id_Obj55,obID(a1)	; load EHZ Boss object
		move.b	#$81,obSubtype(a1)
		move.w	#$29D0,obX(a1)
		move.w	#$426,obY(a1)

loc_7946:
		move.w	#bgm_Boss,d0
		bsr.w	QueueSound1
		move.b	#1,(f_lockscreen).w
		moveq	#plcid_Boss,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_795A:
		rts
; ---------------------------------------------------------------------------

DynResize_EHZ2_02:
		cmpi.w	#$2880,(Camera_X_pos).w
		blo.s	locret_796E
		move.w	#$2880,(Camera_Min_X_pos).w
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_796E:
		rts
; ---------------------------------------------------------------------------

DynResize_EHZ2_03:
		tst.b	(Boss_defeated_flag).w
		beq.s	DynResize_EHZ3
		move.b	#GameModeID_SegaScreen,(v_gamemode).w

DynResize_EHZ3:
		rts
; ---------------------------------------------------------------------------
		rts
; ---------------------------------------------------------------------------

locret_7980:
		rts
; ---------------------------------------------------------------------------

S1DynResize_SLZ3:					; leftover from Sonic 1
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	off_7990(pc,d0.w),d0
		jmp	off_7990(pc,d0.w)
; ---------------------------------------------------------------------------
off_7990:	dc.w loc_7996-off_7990
		dc.w loc_79AA-off_7990
		dc.w loc_79D6-off_7990
; ---------------------------------------------------------------------------

loc_7996:
		cmpi.w	#$1E70,(Camera_X_pos).w
		blo.s	locret_79A8
		move.w	#$210,(Camera_Max_Y_pos_target).w
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_79A8:
		rts
; ---------------------------------------------------------------------------

loc_79AA:
		cmpi.w	#$2000,(Camera_X_pos).w
		blo.s	locret_79D4
		bsr.w	FindFreeObj
		bne.s	loc_79BC
		move.b	#id_Obj7A,obID(a1)	; load object 7A

loc_79BC:
		move.w	#bgm_Boss,d0
		bsr.w	QueueSound1
		move.b	#1,(f_lockscreen).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		moveq	#plcid_Boss,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_79D4:
		rts
; ---------------------------------------------------------------------------

loc_79D6:
		move.w	(Camera_X_pos).w,(Camera_Min_X_pos).w
		rts
; ---------------------------------------------------------------------------
		rts
; ---------------------------------------------------------------------------

DynResize_HPZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynResize_HPZ_Index(pc,d0.w),d0
		jmp	DynResize_HPZ_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_HPZ_Index:dc.w DynResize_HPZ1-DynResize_HPZ_Index
		dc.w DynResize_HPZ2-DynResize_HPZ_Index
		dc.w DynResize_HPZ3-DynResize_HPZ_Index
; ---------------------------------------------------------------------------

DynResize_HPZ1:
		rts
; ---------------------------------------------------------------------------

DynResize_HPZ2:
		move.w	#$520,(Camera_Max_Y_pos_target).w
		cmpi.w	#$25A0,(Camera_X_pos).w
		blo.s	locret_7A1A
		move.w	#$420,(Camera_Max_Y_pos_target).w
		cmpi.w	#$4D0,(v_player+obY).w
		blo.s	locret_7A1A
		move.w	#$520,(Camera_Max_Y_pos_target).w

locret_7A1A:
		rts
; ---------------------------------------------------------------------------

DynResize_HPZ3:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	DynResize_HPZ3_Index(pc,d0.w),d0
		jmp	DynResize_HPZ3_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_HPZ3_Index:dc.w loc_7A30-DynResize_HPZ3_Index
		dc.w loc_7A48-DynResize_HPZ3_Index
		dc.w loc_7A7A-DynResize_HPZ3_Index
; ---------------------------------------------------------------------------

loc_7A30:
		cmpi.w	#$2AC0,(Camera_X_pos).w
		blo.s	locret_7A46
		bsr.w	FindFreeObj
		bne.s	locret_7A46
		move.b	#id_Obj76,obID(a1)	; load object 76
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_7A46:
		rts
; ---------------------------------------------------------------------------

loc_7A48:
		cmpi.w	#$2C00,(Camera_X_pos).w
		blo.s	locret_7A78
		move.w	#$4CC,(Camera_Max_Y_pos_target).w
		bsr.w	FindFreeObj
		bne.s	loc_7A64
		move.b	#id_Obj75,obID(a1)	; load object 75
		addq.b	#2,(Dynamic_Resize_Routine).w

loc_7A64:
		move.w	#bgm_Boss,d0
		bsr.w	QueueSound1
		move.b	#1,(f_lockscreen).w
		moveq	#plcid_Boss,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_7A78:
		rts
; ---------------------------------------------------------------------------

loc_7A7A:
		move.w	(Camera_X_pos).w,(Camera_Min_X_pos).w
		rts
; ---------------------------------------------------------------------------

DynResize_HTZ:
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynResize_HTZ_Index(pc,d0.w),d0
		jmp	DynResize_HTZ_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_HTZ_Index:dc.w DynResize_HTZ1-DynResize_HTZ_Index
		dc.w DynResize_HTZ2-DynResize_HTZ_Index
		dc.w DynResize_HTZ3-DynResize_HTZ_Index
; ---------------------------------------------------------------------------

DynResize_HTZ1:
		move.w	#$720,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1880,(Camera_X_pos).w
		blo.s	locret_7ABA
		move.w	#$620,(Camera_Max_Y_pos_target).w
		cmpi.w	#$2000,(Camera_X_pos).w
		blo.s	locret_7ABA
		move.w	#$2A0,(Camera_Max_Y_pos_target).w

locret_7ABA:
		rts
; ---------------------------------------------------------------------------

DynResize_HTZ2:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	DynResize_HTZ2_Index(pc,d0.w),d0
		jmp	DynResize_HTZ2_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_HTZ2_Index:dc.w loc_7AD2-DynResize_HTZ2_Index
		dc.w loc_7AF4-DynResize_HTZ2_Index
		dc.w loc_7B12-DynResize_HTZ2_Index
		dc.w loc_7B30-DynResize_HTZ2_Index
; ---------------------------------------------------------------------------

loc_7AD2:
		move.w	#$800,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1800,(Camera_X_pos).w
		blo.s	locret_7AF2
		move.w	#$510,(Camera_Max_Y_pos_target).w
		cmpi.w	#$1E00,(Camera_X_pos).w
		blo.s	locret_7AF2
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_7AF2:
		rts
; ---------------------------------------------------------------------------

loc_7AF4:
		cmpi.w	#$1EB0,(Camera_X_pos).w
		blo.s	locret_7B10
		bsr.w	FindFreeObj
		bne.s	locret_7B10
		move.b	#id_Obj83,obID(a1)	; load object 83
		addq.b	#2,(Dynamic_Resize_Routine).w
		moveq	#plcid_EggmanSBZ2,d0
		bra.w	LoadPLC
; ---------------------------------------------------------------------------

locret_7B10:
		rts
; ---------------------------------------------------------------------------

loc_7B12:
		cmpi.w	#$1F60,(Camera_X_pos).w
		blo.s	loc_7B2E
		bsr.w	FindFreeObj
		bne.s	loc_7B28
		move.b	#id_Obj82,obID(a1)	; load object 82
		addq.b	#2,(Dynamic_Resize_Routine).w

loc_7B28:
		move.b	#1,(f_lockscreen).w

loc_7B2E:
		bra.s	loc_7B3A
; ---------------------------------------------------------------------------

loc_7B30:
		cmpi.w	#$2050,(Camera_X_pos).w
		blo.s	loc_7B3A
		rts
; ---------------------------------------------------------------------------

loc_7B3A:
		move.w	(Camera_X_pos).w,(Camera_Min_X_pos).w
		rts
; ---------------------------------------------------------------------------

DynResize_HTZ3:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	DynResize_HTZ3_Index(pc,d0.w),d0
		jmp	DynResize_HTZ3_Index(pc,d0.w)
; ---------------------------------------------------------------------------
DynResize_HTZ3_Index:dc.w loc_7B5A-DynResize_HTZ3_Index
		dc.w loc_7B6E-DynResize_HTZ3_Index
		dc.w loc_7B8C-DynResize_HTZ3_Index
		dc.w locret_7B9A-DynResize_HTZ3_Index
		dc.w loc_7B9C-DynResize_HTZ3_Index
; ---------------------------------------------------------------------------

loc_7B5A:
		cmpi.w	#$2148,(Camera_X_pos).w
		blo.s	loc_7B6C
		addq.b	#2,(Dynamic_Resize_Routine).w
		moveq	#plcid_FZBoss,d0
		bsr.w	LoadPLC

loc_7B6C:
		bra.s	loc_7B3A
; ---------------------------------------------------------------------------

loc_7B6E:
		cmpi.w	#$2300,(Camera_X_pos).w
		blo.s	loc_7B8A
		bsr.w	FindFreeObj
		bne.s	loc_7B8A
		move.b	#id_Obj85,obID(a1)	; load object 85 (final boss object)
		addq.b	#2,(Dynamic_Resize_Routine).w
		move.b	#1,(f_lockscreen).w

loc_7B8A:
		bra.s	loc_7B3A
; ---------------------------------------------------------------------------

loc_7B8C:
		cmpi.w	#$2450,(Camera_X_pos).w
		blo.s	loc_7B98
		addq.b	#2,(Dynamic_Resize_Routine).w

loc_7B98:
		bra.s	loc_7B3A
; ---------------------------------------------------------------------------

locret_7B9A:
		rts
; ---------------------------------------------------------------------------

loc_7B9C:
		bra.s	loc_7B3A
; ---------------------------------------------------------------------------

DynResize_S1Ending:
		rts
; ---------------------------------------------------------------------------
		include	"obj/11 Bridge.asm"
Map_obj11_GHZ:	include	"mappings/sprite/obj11_GHZ.asm"
Map_obj11_HPZ:	include	"mappings/sprite/obj11_HPZ.asm"
Map_obj11_EHZ:	include	"mappings/sprite/obj11_EHZ.asm"

		jmpTos	; Empty
; ===========================================================================

		include	"obj/15 Swinging Platforms.asm"
; ---------------------------------------------------------------------------
Map_Obj15:	dc.w word_8534-Map_Obj15
		dc.w word_8546-Map_Obj15
		dc.w word_8550-Map_Obj15
word_8534:	dc.w 2
		dc.w $F809,    4,    2,$FFE8
		dc.w $F809,    4,    2,	   0
word_8546:	dc.w 1
		dc.w $F805,    0,    0,$FFF8
word_8550:	dc.w 1
		dc.w $F805,   $A,    5,$FFF8
Map_Obj15_CPZ:	dc.w word_855C-Map_Obj15_CPZ
word_855C:	dc.w 2
		dc.w $F00F,    8,    4,$FFE0
		dc.w $F00F, $808, $804,	   0
Map_Obj15_SLZ:	dc.w word_8574-Map_Obj15_SLZ
		dc.w word_85B6-Map_Obj15_SLZ
		dc.w word_85C0-Map_Obj15_SLZ
word_8574:	dc.w 8
		dc.w $F00F,    4,    2,$FFE0
		dc.w $F00F, $804, $802,	   0
		dc.w $F005,  $14,   $A,$FFD0
		dc.w $F005, $814, $80A,	 $20
		dc.w $1004,  $18,   $C,$FFE0
		dc.w $1004, $818, $80C,	 $10
		dc.w $1001,  $1A,   $D,$FFF8
		dc.w $1001, $81A, $80D,	   0
word_85B6:	dc.w 1
		dc.w $F805,$4000,$4000,$FFF8
word_85C0:	dc.w 1
		dc.w $F805,  $1C,   $E,$FFF8
Map_Obj48:	dc.w word_85D2-Map_Obj48
		dc.w word_8604-Map_Obj48
		dc.w word_8626-Map_Obj48
		dc.w word_8648-Map_Obj48
word_85D2:	dc.w 6
		dc.w $F004,  $24,  $12,$FFF0
		dc.w $F804,$1024,$1012,$FFF0
		dc.w $E80A,    0,    0,$FFE8
		dc.w $E80A, $800, $800,	   0
		dc.w	$A,$1000,$1000,$FFE8
		dc.w	$A,$1800,$1800,	   0
word_8604:	dc.w 4
		dc.w $E80A,    9,    4,$FFE8
		dc.w $E80A, $809, $804,	   0
		dc.w	$A,$1009,$1004,$FFE8
		dc.w	$A,$1809,$1804,	   0
word_8626:	dc.w 4
		dc.w $E80A,  $12,    9,$FFE8
		dc.w $E80A,  $1B,   $D,	   0
		dc.w	$A,$181B,$180D,$FFE8
		dc.w	$A,$1812,$1809,	   0
word_8648:	dc.w 4
		dc.w $E80A, $81B, $80D,$FFE8
		dc.w $E80A, $812, $809,	   0
		dc.w	$A,$1012,$1009,$FFE8
		dc.w	$A,$101B,$100D,	   0

		jmpTos	; Empty
; ===========================================================================

		include	"obj/S1/17 Spiked Pole Helix.asm"
Map_Obj17:	include	"mappings/sprite/S1/Spiked Pole Helix.asm"

		include	"obj/18 Platforms.asm"
Map_Obj18x:	include	"mappings/sprite/obj18 (Unused).asm"
Map_Obj18_GHZ:	include	"mappings/sprite/obj18_GHZ.asm"
Map_Obj18_EHZ:	include	"mappings/sprite/obj18_EHZ.asm"

		jmpTos	; Empty
; ===========================================================================

		include	"obj/1A Collapsing Platforms.asm"
		include	"obj/S1/53 Collapsing Floors.asm"
; ---------------------------------------------------------------------------

loc_8E58:
		lea	(byte_8EF2).l,a4
		cmpi.b	#id_HPZ,(Current_Zone).w
		bne.s	loc_8E6C
		lea	(byte_8F0B).l,a4

loc_8E6C:
		addq.b	#2,obFrame(a0)

loc_8E70:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		add.w	d0,d0
		movea.l	obMap(a0),a3
		adda.w	(a3,d0.w),a3
		move.w	(a3)+,d1
		subq.w	#1,d1
		bset	#5,obRender(a0)
		_move.b	obID(a0),d4
		move.b	obRender(a0),d5
		movea.l	a0,a1
		bra.s	loc_8E9E
; ---------------------------------------------------------------------------

loc_8E96:
		bsr.w	FindFreeObj
		bne.s	loc_8EE4
		addq.w	#8,a3

loc_8E9E:
		move.b	#4,obRoutine(a1)
		_move.b	d4,obID(a1)
		move.l	a3,obMap(a1)
		move.b	d5,obRender(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obPriority(a0),obPriority(a1)
		move.b	obActWid(a0),obActWid(a1)
		move.b	obHeight(a0),obHeight(a1)
		move.b	(a4)+,objoff_38(a1)
		cmpa.l	a0,a1
		bhs.s	loc_8EE0
		bsr.w	DisplaySprite2

loc_8EE0:
		dbf	d1,loc_8E96

loc_8EE4:
		bsr.w	DisplaySprite
		move.w	#sfx_Collapse,d0
		jmp	(QueueSound2).l
; ---------------------------------------------------------------------------
byte_8EF2:	dc.b $1C,$18,$14,$10
		dc.b $1A,$16,$12, $E
		dc.b  $A,  6,$18,$14
		dc.b $10, $C,  8,  4
		dc.b $16,$12, $E, $A
		dc.b   6,  2,$14,$10
		dc.b  $C
byte_8F0B:	dc.b $18,$1C,$20,$1E
		dc.b $1A,$16,  6, $E
		dc.b $14,$12, $A,  2
byte_8F17:	dc.b $1E,$16, $E,  6
		dc.b $1A,$12, $A,  2
byte_8F1F:	dc.b $16,$1E,$1A,$12
		dc.b   6, $E, $A,  2
		even

Obj1A_Conf:	dc.b $20,$20,$20,$20
		dc.b $20,$20,$20,$20
		dc.b $21,$21,$22,$22
		dc.b $23,$23,$24,$24
		dc.b $25,$25,$26,$26
		dc.b $27,$27,$28,$28
		dc.b $29,$29,$2A,$2A
		dc.b $2B,$2B,$2C,$2C
		dc.b $2D,$2D,$2E,$2E
		dc.b $2F,$2F,$30,$30
		dc.b $30,$30,$30,$30
		dc.b $30,$30,$30,$30
		even
Map_Obj1A:	dc.w word_8F60-Map_Obj1A
		dc.w word_8FE2-Map_Obj1A
		dc.w word_9064-Map_Obj1A
		dc.w word_912E-Map_Obj1A
word_8F60:	dc.w $10
		dc.w $C80E,  $57,  $2B,	 $10
		dc.w $D00D,  $63,  $31,$FFF0
		dc.w $E00D,  $6B,  $35,	 $10
		dc.w $E00D,  $73,  $39,$FFF0
		dc.w $D806,  $7B,  $3D,$FFE0
		dc.w $D806,  $81,  $40,$FFD0
		dc.w $F00D,  $87,  $43,	 $10
		dc.w $F00D,  $8F,  $47,$FFF0
		dc.w $F005,  $97,  $4B,$FFE0
		dc.w $F005,  $9B,  $4D,$FFD0
		dc.w	$D,  $9F,  $4F,	 $10
		dc.w	 5,  $A7,  $53,	   0
		dc.w	$D,  $AB,  $55,$FFE0
		dc.w	 5,  $B3,  $59,$FFD0
		dc.w $100D,  $AB,  $55,	 $10
		dc.w $1005,  $B7,  $5B,	   0
word_8FE2:	dc.w $10
		dc.w $C80E,  $57,  $2B,	 $10
		dc.w $D00D,  $63,  $31,$FFF0
		dc.w $E00D,  $6B,  $35,	 $10
		dc.w $E00D,  $73,  $39,$FFF0
		dc.w $D806,  $7B,  $3D,$FFE0
		dc.w $D806,  $BB,  $5D,$FFD0
		dc.w $F00D,  $87,  $43,	 $10
		dc.w $F00D,  $8F,  $47,$FFF0
		dc.w $F005,  $97,  $4B,$FFE0
		dc.w $F005,  $C1,  $60,$FFD0
		dc.w	$D,  $9F,  $4F,	 $10
		dc.w	 5,  $A7,  $53,	   0
		dc.w	$D,  $AB,  $55,$FFE0
		dc.w	 5,  $B7,  $5B,$FFD0
		dc.w $100D,  $AB,  $55,	 $10
		dc.w $1005,  $B7,  $5B,	   0
word_9064:	dc.w $19
		dc.w $C806,  $5D,  $2E,	 $20
		dc.w $C806,  $57,  $2B,	 $10
		dc.w $D005,  $67,  $33,	   0
		dc.w $D005,  $63,  $31,$FFF0
		dc.w $E005,  $6F,  $37,	 $20
		dc.w $E005,  $6B,  $35,	 $10
		dc.w $E005,  $77,  $3B,	   0
		dc.w $E005,  $73,  $39,$FFF0
		dc.w $D806,  $7B,  $3D,$FFE0
		dc.w $D806,  $81,  $40,$FFD0
		dc.w $F005,  $8B,  $45,	 $20
		dc.w $F005,  $87,  $43,	 $10
		dc.w $F005,  $93,  $49,	   0
		dc.w $F005,  $8F,  $47,$FFF0
		dc.w $F005,  $97,  $4B,$FFE0
		dc.w $F005,  $9B,  $4D,$FFD0
		dc.w	 5,  $8B,  $45,	 $20
		dc.w	 5,  $8B,  $45,	 $10
		dc.w	 5,  $A7,  $53,	   0
		dc.w	 5,  $AB,  $55,$FFF0
		dc.w	 5,  $AB,  $55,$FFE0
		dc.w	 5,  $B3,  $59,$FFD0
		dc.w $1005,  $AB,  $55,	 $20
		dc.w $1005,  $AB,  $55,	 $10
		dc.w $1005,  $B7,  $5B,	   0
word_912E:	dc.w $19
		dc.w $C806,  $5D,  $2E,	 $20
		dc.w $C806,  $57,  $2B,	 $10
		dc.w $D005,  $67,  $33,	   0
		dc.w $D005,  $63,  $31,$FFF0
		dc.w $E005,  $6F,  $37,	 $20
		dc.w $E005,  $6B,  $35,	 $10
		dc.w $E005,  $77,  $3B,	   0
		dc.w $E005,  $73,  $39,$FFF0
		dc.w $D806,  $7B,  $3D,$FFE0
		dc.w $D806,  $BB,  $5D,$FFD0
		dc.w $F005,  $8B,  $45,	 $20
		dc.w $F005,  $87,  $43,	 $10
		dc.w $F005,  $93,  $49,	   0
		dc.w $F005,  $8F,  $47,$FFF0
		dc.w $F005,  $97,  $4B,$FFE0
		dc.w $F005,  $C1,  $60,$FFD0
		dc.w	 5,  $8B,  $45,	 $20
		dc.w	 5,  $8B,  $45,	 $10
		dc.w	 5,  $A7,  $53,	   0
		dc.w	 5,  $AB,  $55,$FFF0
		dc.w	 5,  $AB,  $55,$FFE0
		dc.w	 5,  $B7,  $5B,$FFD0
		dc.w $1005,  $AB,  $55,	 $20
		dc.w $1005,  $AB,  $55,	 $10
		dc.w $1005,  $B7,  $5B,	   0
Map_S1Obj53:	dc.w word_9200-Map_S1Obj53
		dc.w word_9222-Map_S1Obj53
		dc.w word_9264-Map_S1Obj53
		dc.w word_9286-Map_S1Obj53
word_9200:	dc.w 4
		dc.w $F80D,    0,    0,$FFE0
		dc.w  $80D,    0,    0,$FFE0
		dc.w $F80D,    0,    0,	   0
		dc.w  $80D,    0,    0,	   0
word_9222:	dc.w 8
		dc.w $F805,    0,    0,$FFE0
		dc.w $F805,    0,    0,$FFF0
		dc.w $F805,    0,    0,	   0
		dc.w $F805,    0,    0,	 $10
		dc.w  $805,    0,    0,$FFE0
		dc.w  $805,    0,    0,$FFF0
		dc.w  $805,    0,    0,	   0
		dc.w  $805,    0,    0,	 $10
word_9264:	dc.w 4
		dc.w $F80D,    0,    0,$FFE0
		dc.w  $80D,    8,    4,$FFE0
		dc.w $F80D,    0,    0,	   0
		dc.w  $80D,    8,    4,	   0
word_9286:	dc.w 8
		dc.w $F805,    0,    0,$FFE0
		dc.w $F805,    4,    2,$FFF0
		dc.w $F805,    0,    0,	   0
		dc.w $F805,    4,    2,	 $10
		dc.w  $805,    8,    4,$FFE0
		dc.w  $805,   $C,    6,$FFF0
		dc.w  $805,    8,    4,	   0
		dc.w  $805,   $C,    6,	 $10

Obj1A_Conf_HPZ:	dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		even

Map_Obj1A_HPZ:	include	"mappings/sprite/obj1A_HPZ.asm"

		jmpTos	; Empty
; ===========================================================================

		include	"obj/1C Scenery.asm"

Ani_Obj1C:	dc.w byte_9494-Ani_Obj1C
		dc.w byte_949C-Ani_Obj1C
byte_9494:	dc.b   8,  3,  3,  4,  5,  5,  4,$FF
byte_949C:	dc.b   5,  0,  0,  0,  1,  2,  3,  3
		dc.b   2,  1,  2,  3,  3,  1,$FF
		even

Map_Obj1C_01:	include	"mappings/sprite/obj1C.asm"

		include	"obj/S1/2A SBZ Small Door.asm"

Ani_Obj2A:	dc.w byte_9590-Ani_Obj2A
		dc.w byte_959C-Ani_Obj2A
byte_9590:	dc.b   0,  8,  7,  6,  5,  4,  3,  2
		dc.b   1,  0,$FE,  1
byte_959C:	dc.b   0,  0,  1,  2,  3,  4,  5,  6
		dc.b   7,  8,$FE,  1
		even
Map_Obj2A:	dc.w word_95BA-Map_Obj2A
		dc.w word_95CC-Map_Obj2A
		dc.w word_95DE-Map_Obj2A
		dc.w word_95F0-Map_Obj2A
		dc.w word_9602-Map_Obj2A
		dc.w word_9614-Map_Obj2A
		dc.w word_9626-Map_Obj2A
		dc.w word_9638-Map_Obj2A
		dc.w word_964A-Map_Obj2A
word_95BA:	dc.w 2
		dc.w $E007, $800, $800,$FFF8
		dc.w	 7, $800, $800,$FFF8
word_95CC:	dc.w 2
		dc.w $DC07, $800, $800,$FFF8
		dc.w  $407, $800, $800,$FFF8
word_95DE:	dc.w 2
		dc.w $D807, $800, $800,$FFF8
		dc.w  $807, $800, $800,$FFF8
word_95F0:	dc.w 2
		dc.w $D407, $800, $800,$FFF8
		dc.w  $C07, $800, $800,$FFF8
word_9602:	dc.w 2
		dc.w $D007, $800, $800,$FFF8
		dc.w $1007, $800, $800,$FFF8
word_9614:	dc.w 2
		dc.w $CC07, $800, $800,$FFF8
		dc.w $1407, $800, $800,$FFF8
word_9626:	dc.w 2
		dc.w $C807, $800, $800,$FFF8
		dc.w $1807, $800, $800,$FFF8
word_9638:	dc.w 2
		dc.w $C407, $800, $800,$FFF8
		dc.w $1C07, $800, $800,$FFF8
word_964A:	dc.w 2
		dc.w $C007, $800, $800,$FFF8
		dc.w $2007, $800, $800,$FFF8

		include	"obj/S1/1E Ball Hog.asm"
		include	"obj/S1/20 Cannonball.asm"
		include	"obj/S1/24, 27 & 3F Explosions.asm"

Ani_S1Obj1E:	dc.w byte_996C-Ani_S1Obj1E
byte_996C:	dc.b   9,  0,  0,  2,  2,  3,  2,  0
		dc.b   0,  2,  2,  3,  2,  0,  0,  2
		dc.b   2,  3,  2,  0,  0,  1,$FF
		even
Map_S1Obj1E:	dc.w word_9990-Map_S1Obj1E
		dc.w word_99A2-Map_S1Obj1E
		dc.w word_99B4-Map_S1Obj1E
		dc.w word_99C6-Map_S1Obj1E
		dc.w word_99D8-Map_S1Obj1E
		dc.w word_99E2-Map_S1Obj1E
word_9990:	dc.w 2
		dc.w $EF09,    0,    0,$FFF4
		dc.w $FF0A,    6,    3,$FFF4
word_99A2:	dc.w 2
		dc.w $EF09,    0,    0,$FFF4
		dc.w $FF0A,   $F,    7,$FFF4
word_99B4:	dc.w 2
		dc.w $F409,    0,    0,$FFF4
		dc.w  $409,  $18,   $C,$FFF4
word_99C6:	dc.w 2
		dc.w $E409,    0,    0,$FFF4
		dc.w $F40A,  $1E,   $F,$FFF4
word_99D8:	dc.w 1
		dc.w $F805,  $27,  $13,$FFF8
word_99E2:	dc.w 1
		dc.w $F805,  $2B,  $15,$FFF8
Map_Obj24:	dc.w word_99F4-Map_Obj24
		dc.w word_99FE-Map_Obj24
		dc.w word_9A08-Map_Obj24
		dc.w word_9A12-Map_Obj24
word_99F4:	dc.w 1
		dc.w $F40A,    0,    0,$FFF4
word_99FE:	dc.w 1
		dc.w $F40A,    9,    4,$FFF4
word_9A08:	dc.w 1
		dc.w $F40A,  $12,    9,$FFF4
word_9A12:	dc.w 1
		dc.w $F40A,  $1B,   $D,$FFF4
Map_Obj27:	dc.w word_9A26-Map_Obj27
		dc.w word_9A30-Map_Obj27
		dc.w word_9A3A-Map_Obj27
		dc.w word_9A44-Map_Obj27
		dc.w word_9A66-Map_Obj27
word_9A26:	dc.w 1
		dc.w $F809,    0,    0,$FFF4
word_9A30:	dc.w 1
		dc.w $F00F,    6,    3,$FFF0
word_9A3A:	dc.w 1
		dc.w $F00F,  $16,   $B,$FFF0
word_9A44:	dc.w 4
		dc.w $EC0A,  $26,  $13,$FFEC
		dc.w $EC05,  $2F,  $17,	   4
		dc.w  $405,$182F,$1817,$FFEC
		dc.w $FC0A,$1826,$1813,$FFFC
word_9A66:	dc.w 4
		dc.w $EC0A,  $33,  $19,$FFEC
		dc.w $EC05,  $3C,  $1E,	   4
		dc.w  $405,$183C,$181E,$FFEC
		dc.w $FC0A,$1833,$1819,$FFFC
Map_Obj3F:	dc.w word_9A26-Map_Obj3F
		dc.w word_9A92-Map_Obj3F
		dc.w word_9A9C-Map_Obj3F
		dc.w word_9A44-Map_Obj3F
		dc.w word_9A66-Map_Obj3F
word_9A92:	dc.w 1
		dc.w $F00F,  $40,  $20,$FFF0
word_9A9C:	dc.w 1
		dc.w $F00F,  $50,  $28,$FFF0

		jmpTos	; Empty
; ===========================================================================

		include	"obj/28 Animals.asm"
		include	"obj/29 Points.asm"

Map_Obj28a:	dc.w word_A006-Map_Obj28a
		dc.w word_A010-Map_Obj28a
		dc.w word_9FFC-Map_Obj28a
word_9FFC:	dc.w 1
		dc.w $F406,    0,    0,$FFF8
word_A006:	dc.w 1
		dc.w $F406,    6,    3,$FFF8
word_A010:	dc.w 1
		dc.w $F406,   $C,    6,$FFF8
Map_Obj28:	dc.w word_A02A-Map_Obj28
		dc.w word_A034-Map_Obj28
		dc.w word_A020-Map_Obj28
word_A020:	dc.w 1
		dc.w $F406,    0,    0,$FFF8
word_A02A:	dc.w 1
		dc.w $FC05,    6,    3,$FFF8
word_A034:	dc.w 1
		dc.w $FC05,   $A,    5,$FFF8
Map_Obj28b:	dc.w word_A04E-Map_Obj28b
		dc.w word_A058-Map_Obj28b
		dc.w word_A044-Map_Obj28b
word_A044:	dc.w 1
		dc.w $F406,    0,    0,$FFF8
word_A04E:	dc.w 1
		dc.w $FC09,    6,    3,$FFF4
word_A058:	dc.w 1
		dc.w $FC09,   $C,    6,$FFF4
Map_Obj29:	dc.w word_A070-Map_Obj29
		dc.w word_A07A-Map_Obj29
		dc.w word_A084-Map_Obj29
		dc.w word_A08E-Map_Obj29
		dc.w word_A0A0-Map_Obj29
		dc.w word_A0AA-Map_Obj29
		dc.w word_A0BC-Map_Obj29
word_A070:	dc.w 1
		dc.w $F805,    2,    1,$FFF8
word_A07A:	dc.w 1
		dc.w $F805,    6,    3,$FFF8
word_A084:	dc.w 1
		dc.w $F805,   $A,    5,$FFF8
word_A08E:	dc.w 2
		dc.w $F801,    0,    0,$FFF8
		dc.w $F805,   $E,    7,	   0
word_A0A0:	dc.w 1
		dc.w $F801,    0,    0,$FFFC
word_A0AA:	dc.w 2
		dc.w $F805,    2,    1,$FFF0
		dc.w $F805,   $E,    7,	   0
word_A0BC:	dc.w 2
		dc.w $F805,   $A,    5,$FFF0
		dc.w $F805,   $E,    7,	   0

		jmpTos	; Empty
; ===========================================================================

		include	"obj/S1/1F Crabmeat.asm"
; ===========================================================================
; animation script
Ani_obj1F:	dc.w byte_A30C-Ani_obj1F
		dc.w byte_A30F-Ani_obj1F
		dc.w byte_A312-Ani_obj1F
		dc.w byte_A315-Ani_obj1F
		dc.w byte_A31A-Ani_obj1F
		dc.w byte_A31F-Ani_obj1F
		dc.w byte_A324-Ani_obj1F
		dc.w byte_A327-Ani_obj1F
byte_A30C:	dc.b  $F,  0,$FF
byte_A30F:	dc.b  $F,  2,$FF
byte_A312:	dc.b  $F,$22,$FF
byte_A315:	dc.b  $F,  1,$21,  0,$FF
byte_A31A:	dc.b  $F,$21,  3,  2,$FF
byte_A31F:	dc.b  $F,  1,$23,$22,$FF
byte_A324:	dc.b  $F,  4,$FF
byte_A327:	dc.b   1,  5,  6,$FF
		even

; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj1F:	include	"mappings/sprite/S1/obj1F.asm"

		include	"obj/S1/22 Buzz Bomber.asm"
		include	"obj/S1/23 Buzz Bomber Missile.asm"
; ===========================================================================
; animation script
Ani_obj22:	dc.w byte_A652-Ani_obj22
		dc.w byte_A656-Ani_obj22
		dc.w byte_A65A-Ani_obj22
byte_A652:	dc.b   1,  0,  1,$FF
byte_A656:	dc.b   1,  2,  3,$FF
byte_A65A:	dc.b   1,  4,  5,$FF
		even
Ani_obj23:	dc.w byte_A662-Ani_obj23
		dc.w byte_A666-Ani_obj23
byte_A662:	dc.b   7,  0,  1,$FC
byte_A666:	dc.b   1,  2,  3,$FF
		even
; ---------------------------------------------------------------------------
; sprite mappings - Buzz Bomber
; ---------------------------------------------------------------------------
Map_obj22:	binclude	"mappings/sprite/S1/obj22.bin"
		even
; ---------------------------------------------------------------------------
; sprite mappings - Buzz Bomber missile
; ---------------------------------------------------------------------------
Map_obj23:	binclude	"mappings/sprite/S1/obj23.bin"
		even

		jmpTos	; Empty
; ===========================================================================

		include	"obj/25 & 37 Rings.asm"
		include	"obj/S1/4B Giant Ring.asm"
		include	"obj/S1/7C Ring Flash.asm"

Ani_Obj25:	dc.w byte_ABEC-Ani_Obj25
byte_ABEC:	dc.b   5,  4,  5,  6,  7,$FC
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_Ring:	include	"mappings/sprite/Rings.asm"

Map_S1Obj4B:	dc.w word_AC5E-Map_S1Obj4B
		dc.w word_ACB0-Map_S1Obj4B
		dc.w word_ACF2-Map_S1Obj4B
		dc.w word_AD14-Map_S1Obj4B
word_AC5E:	dc.w $A
		dc.w $E008,    0,    0,$FFE8
		dc.w $E008,    3,    1,	   0
		dc.w $E80C,    6,    3,$FFE0
		dc.w $E80C,   $A,    5,	   0
		dc.w $F007,   $E,    7,$FFE0
		dc.w $F007,  $16,   $B,	 $10
		dc.w $100C,  $1E,   $F,$FFE0
		dc.w $100C,  $22,  $11,	   0
		dc.w $1808,  $26,  $13,$FFE8
		dc.w $1808,  $29,  $14,	   0
word_ACB0:	dc.w 8
		dc.w $E00C,  $2C,  $16,$FFF0
		dc.w $E808,  $30,  $18,$FFE8
		dc.w $E809,  $33,  $19,	   0
		dc.w $F007,  $39,  $1C,$FFE8
		dc.w $F805,  $41,  $20,	   8
		dc.w  $809,  $45,  $22,	   0
		dc.w $1008,  $4B,  $25,$FFE8
		dc.w $180C,  $4E,  $27,$FFF0
word_ACF2:	dc.w 4
		dc.w $E007,  $52,  $29,$FFF4
		dc.w $E003, $852, $829,	   4
		dc.w	 7,  $5A,  $2D,$FFF4
		dc.w	 3, $85A, $82D,	   4
word_AD14:	dc.w 8
		dc.w $E00C, $82C, $816,$FFF0
		dc.w $E808, $830, $818,	   0
		dc.w $E809, $833, $819,$FFE8
		dc.w $F007, $839, $81C,	   8
		dc.w $F805, $841, $820,$FFE8
		dc.w  $809, $845, $822,$FFE8
		dc.w $1008, $84B, $825,	   0
		dc.w $180C, $84E, $827,$FFF0
Map_S1Obj7C:	dc.w word_AD66-Map_S1Obj7C
		dc.w word_AD78-Map_S1Obj7C
		dc.w word_AD9A-Map_S1Obj7C
		dc.w word_ADBC-Map_S1Obj7C
		dc.w word_ADDE-Map_S1Obj7C
		dc.w word_AE00-Map_S1Obj7C
		dc.w word_AE22-Map_S1Obj7C
		dc.w word_AE34-Map_S1Obj7C
word_AD66:	dc.w 2
		dc.w $E00F,    0,    0,	   0
		dc.w	$F,$1000,$1000,	   0
word_AD78:	dc.w 4
		dc.w $E00F,  $10,    8,$FFF0
		dc.w $E007,  $20,  $10,	 $10
		dc.w	$F,$1010,$1008,$FFF0
		dc.w	 7,$1020,$1010,	 $10
word_AD9A:	dc.w 4
		dc.w $E00F,  $28,  $14,$FFE8
		dc.w $E00B,  $38,  $1C,	   8
		dc.w	$F,$1028,$1014,$FFE8
		dc.w	$B,$1038,$101C,	   8
word_ADBC:	dc.w 4
		dc.w $E00F, $834, $81A,$FFE0
		dc.w $E00F,  $34,  $1A,	   0
		dc.w	$F,$1834,$181A,$FFE0
		dc.w	$F,$1034,$101A,	   0
word_ADDE:	dc.w 4
		dc.w $E00B, $838, $81C,$FFE0
		dc.w $E00F, $828, $814,$FFF8
		dc.w	$B,$1838,$181C,$FFE0
		dc.w	$F,$1828,$1814,$FFF8
word_AE00:	dc.w 4
		dc.w $E007, $820, $810,$FFE0
		dc.w $E00F, $810, $808,$FFF0
		dc.w	 7,$1820,$1810,$FFE0
		dc.w	$F,$1810,$1808,$FFF0
word_AE22:	dc.w 2
		dc.w $E00F, $800, $800,$FFE0
		dc.w	$F,$1800,$1800,$FFE0
word_AE34:	dc.w 4
		dc.w $E00F,  $44,  $22,$FFE0
		dc.w $E00F, $844, $822,	   0
		dc.w	$F,$1044,$1022,$FFE0
		dc.w	$F,$1844,$1822,	   0

		jmpTos	; Empty
; ===========================================================================

		include	"obj/26 Monitor.asm"
		include	"obj/2E Monitor Content Power-Up.asm"

; =============== S U B	R O U T	I N E =======================================


Obj26_SolidSides:
		lea	(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_B20E
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.s	loc_B20E
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3
		sub.w	obY(a0),d3
		add.w	d2,d3
		bmi.s	loc_B20E
		add.w	d2,d2
		cmp.w	d2,d3
		bhs.s	loc_B20E
		tst.b	(f_playerctrl).w
		bmi.s	loc_B20E
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	loc_B20E
		tst.w	(Debug_placement_mode).w
		bne.s	loc_B20E
		cmp.w	d0,d1
		bhs.s	loc_B204
		add.w	d1,d1
		sub.w	d1,d0

loc_B204:
		cmpi.w	#$10,d3
		blo.s	loc_B212

loc_B20A:
		moveq	#1,d1
		rts
; ---------------------------------------------------------------------------

loc_B20E:
		moveq	#0,d1
		rts
; ---------------------------------------------------------------------------

loc_B212:
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addq.w	#4,d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	obX(a1),d1
		sub.w	obX(a0),d1
		bmi.s	loc_B20A
		cmp.w	d2,d1
		bhs.s	loc_B20A
		moveq	#-1,d1
		rts
; End of function Obj26_SolidSides

; ===========================================================================
; animation script
Ani_obj26:	dc.w byte_B246-Ani_obj26
		dc.w byte_B24A-Ani_obj26
		dc.w byte_B252-Ani_obj26
		dc.w byte_B25A-Ani_obj26
		dc.w byte_B262-Ani_obj26
		dc.w byte_B26A-Ani_obj26
		dc.w byte_B272-Ani_obj26
		dc.w byte_B27A-Ani_obj26
		dc.w byte_B282-Ani_obj26
		dc.w byte_B28A-Ani_obj26
		dc.w byte_B292-Ani_obj26
byte_B246:	dc.b   1,  0,  1,$FF
byte_B24A:	dc.b   1,  0,  2,  2,  1,  2,  2,$FF
byte_B252:	dc.b   1,  0,  3,  3,  1,  3,  3,$FF
byte_B25A:	dc.b   1,  0,  4,  4,  1,  4,  4,$FF
byte_B262:	dc.b   1,  0,  5,  5,  1,  5,  5,$FF
byte_B26A:	dc.b   1,  0,  6,  6,  1,  6,  6,$FF
byte_B272:	dc.b   1,  0,  7,  7,  1,  7,  7,$FF
byte_B27A:	dc.b   1,  0,  8,  8,  1,  8,  8,$FF
byte_B282:	dc.b   1,  0,  9,  9,  1,  9,  9,$FF
byte_B28A:	dc.b   1,  0, $A, $A,  1, $A, $A,$FF
byte_B292:	dc.b   2,  0,  1, $B,$FE,  1
		even

; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_Obj26:	include	"mappings/sprite/obj26.asm"
		include	"obj/0E Title Sonic And Tails.asm"

		include	"obj/0F.asm"

Map_Obj0F:	include "mappings/sprite/obj0F.asm"
Ani_S1Obj0E:	dc.w byte_B51C-Ani_S1Obj0E
byte_B51C:	dc.b   7,  0,  1,  2,  3,  4,  5,  6
		dc.b   7,$FE,  2
		even
Ani_S1Obj0F:	dc.w byte_B52A-Ani_S1Obj0F
byte_B52A:	dc.b $1F,  0,  1,$FF
		even
Map_S1Obj0F:	include "mappings/sprite/S1/obj0F.asm"
Map_Obj0E:	include "mappings/sprite/obj0E.asm"

		jmpTos	; Empty
; ===========================================================================

		include	"obj/S1/2B Chopper.asm"

Ani_Obj2B:	dc.w byte_B7BA-Ani_Obj2B
		dc.w byte_B7BE-Ani_Obj2B
		dc.w byte_B7C2-Ani_Obj2B
byte_B7BA:	dc.b   7,  0,  1,$FF
byte_B7BE:	dc.b   3,  0,  1,$FF
byte_B7C2:	dc.b   7,  0,$FF
		even
Map_Obj2B:	dc.w word_B7CA-Map_Obj2B
		dc.w word_B7D4-Map_Obj2B
word_B7CA:	dc.w 1
		dc.w $F00F,    0,    0,$FFF0
word_B7D4:	dc.w 1
		dc.w $F00F,  $10,    8,$FFF0

		include	"obj/S1/2C Jaws.asm"

Ani_Obj2C:	dc.b   0,  2,  7,  0,  1,  2,  3,$FF
		even
Map_Obj2C:	dc.w word_B880-Map_Obj2C
		dc.w word_B892-Map_Obj2C
		dc.w word_B8A4-Map_Obj2C
		dc.w word_B8B6-Map_Obj2C
word_B880:	dc.w 2
		dc.w $F40E,    0,    0,$FFF0
		dc.w $F505,  $18,   $C,	 $10
word_B892:	dc.w 2
		dc.w $F40E,   $C,    6,$FFF0
		dc.w $F505,  $1C,   $E,	 $10
word_B8A4:	dc.w 2
		dc.w $F40E,    0,    0,$FFF0
		dc.w $F505,$1018,$100C,	 $10
word_B8B6:	dc.w 2
		dc.w $F40E,   $C,    6,$FFF0
		dc.w $F505,$101C,$100E,	 $10

		include	"obj/S1/34 Title Cards.asm"
		include	"obj/S1/39 Game Over.asm"
		include	"obj/S1/3A Got Through Card.asm"
		include	"obj/S1/7E Special Stage Results.asm"
		include	"obj/S1/7F SS Result Chaos Emeralds.asm"

Map_Obj34:	dc.w M_Card_GHZ-Map_Obj34
		dc.w M_Card_LZ-Map_Obj34
		dc.w M_Card_MZ-Map_Obj34
		dc.w M_Card_SLZ-Map_Obj34
		dc.w M_Card_SYZ-Map_Obj34
		dc.w M_Card_SBZ-Map_Obj34
		dc.w M_Card_Zone-Map_Obj34
		dc.w M_Card_Act1-Map_Obj34
		dc.w M_Card_Act2-Map_Obj34
		dc.w M_Card_Act3-Map_Obj34
		dc.w M_Card_Oval-Map_Obj34
		dc.w M_Card_FZ-Map_Obj34

M_Card_GHZ:	dc.w 9	; GREEN HILL
		dc.w $F805,  $18,   $C,$FFB4	; G
		dc.w $F805,  $3A,  $1D,$FFC4	; R
		dc.w $F805,  $10,    8,$FFD4	; E
		dc.w $F805,  $10,    8,$FFE4	; E
		dc.w $F805,  $2E,  $17,$FFF4	; N

		dc.w $F805,  $1C,   $E,	 $14	; H
		dc.w $F801,  $20,  $10,	 $24	; I
		dc.w $F805,  $26,  $13,	 $2C	; L
		dc.w $F805,  $26,  $13,	 $3C	; L

M_Card_LZ:	dc.w 9	; LABYRINTH
		dc.w $F805,  $26,  $13,$FFBC	; L
		dc.w $F805,    0,    0,$FFCC	; A
		dc.w $F805,    4,    2,$FFDC	; B
		dc.w $F805,  $4A,  $25,$FFEC	; Y
		dc.w $F805,  $3A,  $1D,$FFFC	; R
		dc.w $F801,  $20,  $10,	  $C	; I
		dc.w $F805,  $2E,  $17,	 $14	; N
		dc.w $F805,  $42,  $21,	 $24	; T
		dc.w $F805,  $1C,   $E,	 $34	; H

M_Card_MZ:	dc.w 6	; MARBLE
		dc.w $F805,  $2A,  $15,$FFCF	; M
		dc.w $F805,    0,    0,$FFE0	; A
		dc.w $F805,  $3A,  $1D,$FFF0	; R
		dc.w $F805,    4,    2,	   0	; B
		dc.w $F805,  $26,  $13,	 $10	; L
		dc.w $F805,  $10,    8,	 $20	; E

M_Card_SLZ:	dc.w 9	; STAR LIGHT
		dc.w $F805,  $3E,  $1F,$FFB4	; S
		dc.w $F805,  $42,  $21,$FFC4	; T
		dc.w $F805,    0,    0,$FFD4	; A
		dc.w $F805,  $3A,  $1D,$FFE4	; R

		dc.w $F805,  $26,  $13,	   4	; L
		dc.w $F801,  $20,  $10,	 $14	; I
		dc.w $F805,  $18,   $C,	 $1C	; G
		dc.w $F805,  $1C,   $E,	 $2C	; H
		dc.w $F805,  $42,  $21,	 $3C	; T

M_Card_SYZ:	dc.w $A	; SPRING YARD
		dc.w $F805,  $3E,  $1F,$FFAC	; S
		dc.w $F805,  $36,  $1B,$FFBC	; P
		dc.w $F805,  $3A,  $1D,$FFCC	; R
		dc.w $F801,  $20,  $10,$FFDC	; I
		dc.w $F805,  $2E,  $17,$FFE4	; N
		dc.w $F805,  $18,   $C,$FFF4	; G

		dc.w $F805,  $4A,  $25,	 $14	; Y
		dc.w $F805,    0,    0,	 $24	; A
		dc.w $F805,  $3A,  $1D,	 $34	; R
		dc.w $F805,   $C,    6,	 $44	; D

M_Card_SBZ:	dc.w $A	; SCRAP BRAIN
		dc.w $F805,  $3E,  $1F,$FFAC	; S
		dc.w $F805,    8,    4,$FFBC	; C
		dc.w $F805,  $3A,  $1D,$FFCC	; R
		dc.w $F805,    0,    0,$FFDC	; A
		dc.w $F805,  $36,  $1B,$FFEC	; P

		dc.w $F805,    4,    2,	  $C	; B
		dc.w $F805,  $3A,  $1D,	 $1C	; R
		dc.w $F805,    0,    0,	 $2C	; A
		dc.w $F801,  $20,  $10,	 $3C	; I
		dc.w $F805,  $2E,  $17,	 $44	; N

M_Card_Zone:	dc.w 4	; ZONE
		dc.w $F805,  $4E,  $27,$FFE0	; Z
		dc.w $F805,  $32,  $19,$FFF0	; O
		dc.w $F805,  $2E,  $17,	   0	; N
		dc.w $F805,  $10,    8,	 $10	; E

M_Card_Act1:	dc.w 2	; Act number 1
		dc.w  $40C,  $53,  $29,$FFEC	; "ACT"
		dc.w $F402,  $57,  $2B,	  $C	; 1

M_Card_Act2:	dc.w 2	; Act number 2
		dc.w  $40C,  $53,  $29,$FFEC	; "ACT"
		dc.w $F406,  $5A,  $2D,	   8	; 2

M_Card_Act3:	dc.w 2	; Act number 3
		dc.w  $40C,  $53,  $29,$FFEC	; "ACT"
		dc.w $F406,  $60,  $30,	   8	; 3

M_Card_Oval:	dc.w $D	; Blue oval
		dc.w $E40C,  $70,  $38,$FFF4
		dc.w $E402,  $74,  $3A,	 $14
		dc.w $EC04,  $77,  $3B,$FFEC
		dc.w $F405,  $79,  $3C,$FFE4
		dc.w $140C,$1870,$1838,$FFEC
		dc.w  $402,$1874,$183A,$FFE4
		dc.w  $C04,$1877,$183B,	   4
		dc.w $FC05,$1879,$183C,	  $C
		dc.w $EC08,  $7D,  $3E,$FFFC
		dc.w $F40C,  $7C,  $3E,$FFF4
		dc.w $FC08,  $7C,  $3E,$FFF4
		dc.w  $40C,  $7C,  $3E,$FFEC
		dc.w  $C08,  $7C,  $3E,$FFEC

M_Card_FZ:	dc.w 5	; FINAL
		dc.w $F805,  $14,   $A,$FFDC	; F
		dc.w $F801,  $20,  $10,$FFEC	; I
		dc.w $F805,  $2E,  $17,$FFF4	; N
		dc.w $F805,    0,    0,	   4	; A
		dc.w $F805,  $26,  $13,	 $14	; L

Map_Obj39:	dc.w word_C280-Map_Obj39
		dc.w word_C292-Map_Obj39
		dc.w word_C2A4-Map_Obj39
		dc.w word_C2B6-Map_Obj39
word_C280:	dc.w 2
		dc.w $F80D,    0,    0,$FFB8
		dc.w $F80D,    8,    4,$FFD8
word_C292:	dc.w 2
		dc.w $F80D,  $14,   $A,	   8
		dc.w $F80D,   $C,    6,	 $28
word_C2A4:	dc.w 2
		dc.w $F809,  $1C,   $E,$FFC4
		dc.w $F80D,    8,    4,$FFDC
word_C2B6:	dc.w 2
		dc.w $F80D,  $14,   $A,	  $C
		dc.w $F80D,   $C,    6,	 $2C

Map_Obj3A:	dc.w word_C2DA-Map_Obj3A
		dc.w word_C31C-Map_Obj3A
		dc.w word_C34E-Map_Obj3A
		dc.w word_C380-Map_Obj3A
		dc.w word_C3BA-Map_Obj3A
		dc.w M_Card_Oval-Map_Obj3A
		dc.w M_Card_Act1-Map_Obj3A
		dc.w M_Card_Act2-Map_Obj3A
		dc.w M_Card_Act3-Map_Obj3A
word_C2DA:	dc.w 8
		dc.w $F805,  $3E,  $1F,$FFB8
		dc.w $F805,  $32,  $19,$FFC8
		dc.w $F805,  $2E,  $17,$FFD8
		dc.w $F801,  $20,  $10,$FFE8
		dc.w $F805,    8,    4,$FFF0
		dc.w $F805,  $1C,   $E,	 $10
		dc.w $F805,    0,    0,	 $20
		dc.w $F805,  $3E,  $1F,	 $30
word_C31C:	dc.w 6
		dc.w $F805,  $36,  $1B,$FFD0
		dc.w $F805,    0,    0,$FFE0
		dc.w $F805,  $3E,  $1F,$FFF0
		dc.w $F805,  $3E,  $1F,	   0
		dc.w $F805,  $10,    8,	 $10
		dc.w $F805,   $C,    6,	 $20
word_C34E:	dc.w 6
		dc.w $F80D, $14A,  $A5,$FFB0
		dc.w $F801, $162,  $B1,$FFD0
		dc.w $F809, $164,  $B2,	 $18
		dc.w $F80D, $16A,  $B5,	 $30
		dc.w $F704,  $6E,  $37,$FFCD
		dc.w $FF04,$186E,$1837,$FFCD
word_C380:	dc.w 7
		dc.w $F80D, $15A,  $AD,$FFB0
		dc.w $F80D,  $66,  $33,$FFD9
		dc.w $F801, $14A,  $A5,$FFF9
		dc.w $F704,  $6E,  $37,$FFF6
		dc.w $FF04,$186E,$1837,$FFF6
		dc.w $F80D,$FFF0,$FBF8,	 $28
		dc.w $F801, $170,  $B8,	 $48
word_C3BA:	dc.w 7
		dc.w $F80D, $152,  $A9,$FFB0
		dc.w $F80D,  $66,  $33,$FFD9
		dc.w $F801, $14A,  $A5,$FFF9
		dc.w $F704,  $6E,  $37,$FFF6
		dc.w $FF04,$186E,$1837,$FFF6
		dc.w $F80D,$FFF8,$FBFC,	 $28
		dc.w $F801, $170,  $B8,	 $48
; ---------------------------------------------------------------------------
; Sprite mappings - special stage results screen
; ---------------------------------------------------------------------------
Map_S1Obj7E:	include	"mappings/sprite/S1/obj7E.asm"
Map_S1Obj7F:	dc.w word_C624-Map_S1Obj7F
		dc.w word_C62E-Map_S1Obj7F
		dc.w word_C638-Map_S1Obj7F
		dc.w word_C642-Map_S1Obj7F
		dc.w word_C64C-Map_S1Obj7F
		dc.w word_C656-Map_S1Obj7F
		dc.w word_C660-Map_S1Obj7F
word_C624:	dc.w 1
		dc.w $F805,$2004,$2002,$FFF8
word_C62E:	dc.w 1
		dc.w $F805,    0,    0,$FFF8
word_C638:	dc.w 1
		dc.w $F805,$4004,$4002,$FFF8
word_C642:	dc.w 1
		dc.w $F805,$6004,$6002,$FFF8
word_C64C:	dc.w 1
		dc.w $F805,$2008,$2004,$FFF8
word_C656:	dc.w 1
		dc.w $F805,$200C,$2006,$FFF8
word_C660:	dc.w 0

		jmpTos	; Empty
; ===========================================================================

		include	"obj/36 Spikes.asm"
Map_Obj36:	include	"mappings/sprite/obj36.asm"


		include	"obj/S1/3B Purple Rock.asm"
Map_Obj3B:	include	"mappings/sprite/S1/Purple Rock.asm"

		jmpTos0	; Empty
; ===========================================================================

		include	"obj/S1/3C Smashable Wall.asm"
		include	"obj/S1/sub SmashObject.asm"

Obj3C_FragSpdRight:dc.w	 $400,-$500
		dc.w  $600,-$100
		dc.w  $600, $100
		dc.w  $400, $500
		dc.w  $600,-$600
		dc.w  $800,-$200
		dc.w  $800, $200
		dc.w  $600, $600
Obj3C_FragSpdLeft:dc.w -$600,-$600
		dc.w -$800,-$200
		dc.w -$800, $200
		dc.w -$600, $600
		dc.w -$400,-$500
		dc.w -$600,-$100
		dc.w -$600, $100
		dc.w -$400, $500
Map_Obj3C:	dc.w word_CA6C-Map_Obj3C
		dc.w word_CAAE-Map_Obj3C
		dc.w word_CAF0-Map_Obj3C
word_CA6C:	dc.w 8
		dc.w $E005,    0,    0,$FFF0
		dc.w $F005,    0,    0,$FFF0
		dc.w	 5,    0,    0,$FFF0
		dc.w $1005,    0,    0,$FFF0
		dc.w $E005,    4,    2,	   0
		dc.w $F005,    4,    2,	   0
		dc.w	 5,    4,    2,	   0
		dc.w $1005,    4,    2,	   0
word_CAAE:	dc.w 8
		dc.w $E005,    4,    2,$FFF0
		dc.w $F005,    4,    2,$FFF0
		dc.w	 5,    4,    2,$FFF0
		dc.w $1005,    4,    2,$FFF0
		dc.w $E005,    4,    2,	   0
		dc.w $F005,    4,    2,	   0
		dc.w	 5,    4,    2,	   0
		dc.w $1005,    4,    2,	   0
word_CAF0:	dc.w 8
		dc.w $E005,    4,    2,$FFF0
		dc.w $F005,    4,    2,$FFF0
		dc.w	 5,    4,    2,$FFF0
		dc.w $1005,    4,    2,$FFF0
		dc.w $E005,    8,    4,	   0
		dc.w $F005,    8,    4,	   0
		dc.w	 5,    8,    4,	   0
		dc.w $1005,    8,    4,	   0

		jmpTos	; Empty

; ===========================================================================
; ---------------------------------------------------------------------------
; This runs the code of all the objects that are in Object_RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ObjectsLoad:
ExecuteObjects:
		lea	(v_objspace).w,a0
		moveq	#bytesToXcnt(v_objend-v_objspace,object_size),d7	; run the first $80 objects out of levels
		moveq	#0,d0
		cmpi.b	#6,(v_player+obRoutine).w	; is Sonic dead?
		bhs.s	ExecuteObjectsWhenPlayerIsDead	; if yes, branch

; ---------------------------------------------------------------------------
; This is THE place where each individual object's code gets called from
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_CB44:
RunObject:
		move.b	obID(a0),d0			; get the object's ID
		beq.s	loc_CB54			; if it's obj00, skip it
		add.w	d0,d0
		add.w	d0,d0				; d0 = object ID * 4
		movea.l	Obj_Index-4(pc,d0.w),a1		; load the address of the object's code
		jsr	(a1)				; dynamic call! to one of the the entries in Obj_Index
		moveq	#0,d0

loc_CB54:
		lea	object_size(a0),a0		; load obj address
		dbf	d7,RunObject
		rts
; ---------------------------------------------------------------------------
; this skips certain objects to make enemies and things pause when Sonic dies
; loc_CB5E:
ExecuteObjectsWhenPlayerIsDead:
		moveq	#bytesToXcnt(v_lvlobjspace-v_objspace,object_size),d7
		bsr.s	RunObject
		moveq	#bytesToXcnt(v_lvlobjend-v_lvlobjspace,object_size),d7

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_CB64:
ExecuteObjectsDisplayOnly:
		moveq	#0,d0
		move.b	obID(a0),d0			; get the object's ID
		beq.s	loc_CB74			; if it's obj00, skip it
		tst.b	obRender(a0)		; should we render it?
		bpl.s	loc_CB74			; if not, skip it
		bsr.w	DisplaySprite

loc_CB74:
		lea	object_size(a0),a0		; load obj address
		dbf	d7,ExecuteObjectsDisplayOnly
		rts
; End of function ExecuteObjects

; ===========================================================================
; ---------------------------------------------------------------------------
; OBJECT POINTER ARRAY ; object pointers ; sprite pointers ; object list ; sprite list
;
; This array contains the pointers to all the objects used in the game.
; ---------------------------------------------------------------------------
Obj_Index:

objptr:	macro objectpointer,{INTLABEL},{GLOBALSYMBOLS}
__LABEL__: = ((*-Obj_Index)/4)+1
	dc.l	objectpointer
	endm

; ---------------------------------------------------------------------------
; ID label:	non-zero index byte (see ID value)
; Object label:	main label to the actual object source

; ID label			Object label		  ID value
id_Obj01:	objptr	Obj01				; Sonic
id_Obj02:	objptr	Obj02				; Tails
id_Obj03:	objptr	Obj03				; Collision plane/layer switcher
id_Obj04:	objptr	Obj04				; Surface of the water
id_Obj05:	objptr	Obj05				; Tails' tails
id_Obj06:	objptr	Obj06				; Twisting spiral pathway in EHZ
id_Obj07:	objptr	NullObject
id_Obj08:	objptr	Obj08				; Water splash in HPZ
id_Obj09:	objptr	Obj09				; (S1) Sonic in the Special Stage
id_Obj0A:	objptr	Obj0A				; Small bubbles from Sonic's face while underwater
id_Obj0B:	objptr	Obj0B				; (S1) Pole that breaks in LZ
id_Obj0C:	objptr	Obj0C				; Strange floating/falling platform object from CPZ
id_Obj0D:	objptr	Obj0D				; End of level signpost
id_Obj0E:	objptr	Obj0E				; Sonic and Tails from the title screen
id_Obj0F:	objptr	Obj0F				; Mappings test?
id_Obj10:	objptr	Obj10				; (S1) Blank, animation test in prototype
id_Obj11:	objptr	Obj11				; Bridges in GHZ, EHZ and HPZ
id_Obj12:	objptr	Obj12				; Emerald from Hidden Palace Zone
id_Obj13:	objptr	Obj13				; Waterfall from Hidden Palace Zone
id_Obj14:	objptr	Obj14				; Seesaw from Hill Top Zone
id_Obj15:	objptr	Obj15				; Swinging platforms in GHZ, CPZ and EHZ
id_Obj16:	objptr	Obj16				; Diagonally moving lift from HTZ
id_Obj17:	objptr	Obj17				; (S1) GHZ rotating log helix spikes
id_Obj18:	objptr	Obj18				; Stationary/moving platforms from GHZ and EHZ
id_Obj19:	objptr	Obj19				; Platform from CPZ
id_Obj1A:	objptr	Obj1A				; Collapsing platform from GHZ and HPZ
id_Obj1B:	objptr	NullObject
id_Obj1C:	objptr	Obj1C				; Stage decorations in GHZ, EHZ, HTZ and HPZ
id_Obj1D:	objptr	NullObject
id_Obj1E:	objptr	NullObject
id_Obj1F:	objptr	Obj1F				; (S1) Crabmeat from GHZ
id_Obj20:	objptr	NullObject
id_Obj21:	objptr	Obj21				; Score/Rings/Time display (HUD)
id_Obj22:	objptr	Obj22				; (S1) Buzz Bomber from GHZ
id_Obj23:	objptr	Obj23				; (S1) Buzz Bomber/Newtron missile
id_Obj24:	objptr	Obj24				; (S1) Unused Buzz Bomber missile explosion
id_Obj25:	objptr	Obj25				; A ring
id_Obj26:	objptr	Obj26				; Monitor
id_Obj27:	objptr	Obj27				; An explosion, giving off an animal and 100 points
id_Obj28:	objptr	Obj28				; Animal and the 100 points from a badnik
id_Obj29:	objptr	Obj29				; "100 points" text
id_Obj2A:	objptr	Obj2A				; (S1) Small door from SBZ
id_Obj2B:	objptr	Obj2B				; (S1) Chopper from GHZ
id_Obj2C:	objptr	Obj2C				; (S1) Jaws from LZ
id_Obj2D:	objptr	NullObject
id_Obj2E:	objptr	Obj2E				; Monitor contents (code for power-up behavior and rising image)
id_Obj2F:	objptr	NullObject
id_Obj30:	objptr	NullObject
id_Obj31:	objptr	NullObject
id_Obj32:	objptr	NullObject
id_Obj33:	objptr	NullObject
id_Obj34:	objptr	Obj34				; (S1) Level title card
id_Obj35:	objptr	NullObject
id_Obj36:	objptr	Obj36				; Vertical spikes
id_Obj37:	objptr	Obj37				; Scattering rings (generated when Sonic or Tails are hurt and has rings)
id_Obj38:	objptr	Obj38				; Shield
id_Obj39:	objptr	Obj39				; Game Over/Time Over text
id_Obj3A:	objptr	Obj3A				; (S1) End of level results screen
id_Obj3B:	objptr	Obj3B				; (S1) Purple rock from GHZ
id_Obj3C:	objptr	Obj3C				; (S1) Breakable wall
id_Obj3D:	objptr	Obj3D				; (S1) GHZ boss
id_Obj3E:	objptr	Obj3E				; Egg prison
id_Obj3F:	objptr	Obj3F				; Boss explosion
id_Obj40:	objptr	Obj40				; (S1) Motobug from GHZ
id_Obj41:	objptr	Obj41				; Spring
id_Obj42:	objptr	Obj42				; (S1) Newtron from GHZ
id_Obj43:	objptr	NullObject
id_Obj44:	objptr	Obj44				; (S1) Breakable wall
id_Obj45:	objptr	NullObject
id_Obj46:	objptr	NullObject
id_Obj47:	objptr	NullObject
id_Obj48:	objptr	Obj48				; (S1) Eggman's wrecking ball
id_Obj49:	objptr	Obj49				; Waterfall sound effect
id_Obj4A:	objptr	Obj4A				; Octus from HPZ
id_Obj4B:	objptr	Obj4B				; Buzzer from EHZ
id_Obj4C:	objptr	Obj4C				; BBat from HPZ
id_Obj4D:	objptr	Obj4D				; Stego/Stegway from HPZ
id_Obj4E:	objptr	Obj4E				; Gator from HPZ
id_Obj4F:	objptr	Obj4F				; Redz (dinosaur badnik) from HPZ
id_Obj50:	objptr	Obj50				; Seahorse/Aquis from HPZ
id_Obj51:	objptr	Obj51				; Skyhorse from HPZ
id_Obj52:	objptr	Obj52				; BFish from HPZ
id_Obj53:	objptr	Obj53				; Masher from EHZ
id_Obj54:	objptr	Obj54				; Snail badnik from EHZ
id_Obj55:	objptr	Obj55				; EHZ boss
id_Obj56:	objptr	Obj56				; EHZ boss part 2
id_Obj57:	objptr	Obj57				; EHZ boss part 3
id_Obj58:	objptr	Obj58				; EHZ boss part 4
id_Obj59:	objptr	NullObject
id_Obj5A:	objptr	NullObject
id_Obj5B:	objptr	NullObject
id_Obj5C:	objptr	NullObject
id_Obj5D:	objptr	NullObject
id_Obj5E:	objptr	NullObject
id_Obj5F:	objptr	NullObject
id_Obj60:	objptr	NullObject
id_Obj61:	objptr	NullObject
id_Obj62:	objptr	NullObject
id_Obj63:	objptr	NullObject
id_Obj64:	objptr	NullObject
id_Obj65:	objptr	NullObject
id_Obj66:	objptr	NullObject
id_Obj67:	objptr	NullObject
id_Obj68:	objptr	NullObject
id_Obj69:	objptr	NullObject
id_Obj6A:	objptr	NullObject
id_Obj6B:	objptr	NullObject
id_Obj6C:	objptr	NullObject
id_Obj6D:	objptr	NullObject
id_Obj6E:	objptr	NullObject
id_Obj6F:	objptr	NullObject
id_Obj70:	objptr	NullObject
id_Obj71:	objptr	NullObject
id_Obj72:	objptr	NullObject
id_Obj73:	objptr	NullObject
id_Obj74:	objptr	NullObject
id_Obj75:	objptr	NullObject
id_Obj76:	objptr	NullObject
id_Obj77:	objptr	NullObject
id_Obj78:	objptr	NullObject
id_Obj79:	objptr	Obj79				; Checkpoint
id_Obj7A:	objptr	NullObject
id_Obj7B:	objptr	NullObject
id_Obj7C:	objptr	NullObject
id_Obj7D:	objptr	Obj7D				; (S1) Hidden points at end of stage
id_Obj7E:	objptr	NullObject			; (S1) Special Stage Results (unreferenced, but can be found as S1Obj7E, also contains a leftover PLC pointer in mappings)
id_Obj7F:	objptr	NullObject			; (S1) SS Result Chaos Emeralds (unreferenced, but can be found as S1Obj7F)
id_Obj80:	objptr	NullObject			; Was originally Continue Screen Elements, but was completely stripped out
id_Obj81:	objptr	NullObject			; Was originally Continue Screen Sonic, but was completely stripped out
id_Obj82:	objptr	NullObject			; Was originally Eggman - Scrap Brain 2, but was completely stripped out
id_Obj83:	objptr	NullObject			; Was originally SBZ Eggman's Crumbling Floor, but was completely stripped out
id_Obj84:	objptr	NullObject			; Was originally FZ Eggman's Cylinders, but was completely stripped out
id_Obj85:	objptr	NullObject			; Was originally Boss - Final, but was completely stripped out
id_Obj86:	objptr	NullObject			; Was originally FZ Plasma Ball Launcher, but was completely stripped out
id_Obj87:	objptr	NullObject			; Was originally Ending Sequence Sonic, but was completely stripped out
id_Obj88:	objptr	NullObject			; Was originally Ending Sequence Emeralds, but was completely stripped out
id_Obj89:	objptr	NullObject			; Was originally Ending Sequence STH, but was completely stripped out
id_Obj8A:	objptr	Obj8A				; (S1) "SONIC TEAM PRESENTS" screen and credits
id_Obj8B:	objptr	NullObject			; Was originally Try Again & End Eggman, but was completely stripped out
id_Obj8C:	objptr	NullObject			; Was originally Try Again Emeralds, but was completely stripped out

; ===========================================================================
; blank object, allocates its array
; jmp_DeleteObject:
NullObject:
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Subroutine to make an object move and fall downward increasingly fast
; This moves the object horizontally and vertically
; and also applies gravity to its speed
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

ObjectMoveAndFall:
ObjectFall:
		move.l	obX(a0),d2			; load x position
		move.l	obY(a0),d3			; load y position
		move.w	obVelX(a0),d0			; load x speed
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,d2				; add x speed to x position
		move.w	obVelY(a0),d0			; load y speed
		addi.w	#$38,obVelY(a0)			; increase vertical speed (apply gravity)
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,d3				; add old y speed to y position
		move.l	d2,obX(a0)			; store new x position
		move.l	d3,obY(a0)			; store new y position
		rts
; End of function ObjectMoveAndFall

; ---------------------------------------------------------------------------
; Subroutine translating object speed to update object position
; This moves the object horizontally and vertically
; but does not apply gravity to it
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

ObjectMove:
SpeedToPos:
		move.l	obX(a0),d2			; load x position
		move.l	obY(a0),d3			; load y position
		move.w	obVelX(a0),d0			; load x speed
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,d2				; add x speed to x position
		move.w	obVelY(a0),d0			; load y speed
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,d3				; add old y speed to y position
		move.l	d2,obX(a0)			; store new x position
		move.l	d3,obY(a0)			; store new y position
		rts
; End of function ObjectMove

; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


DisplaySprite:
		lea	(v_spritequeue).w,a1
		move.w	obPriority(a0),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a1
		cmpi.w	#$7E,(a1)
		bhs.s	locret_CE20
		addq.w	#2,(a1)
		adda.w	(a1),a1
		move.w	a0,(a1)

locret_CE20:
		rts
; End of function DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a1 is the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; DisplayA1Sprite:
DisplaySprite2:
		lea	(v_spritequeue).w,a2
		move.w	obPriority(a1),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a2
		cmpi.w	#$7E,(a2)
		bhs.s	locret_CE3E
		addq.w	#2,(a2)
		adda.w	(a2),a2
		move.w	a1,(a2)

locret_CE3E:
		rts
; End of function DisplaySprite2

; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; and d0 is already (priority/2)&$380
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; DisplaySprite_Param:
DisplaySprite3:
		lea	(v_spritequeue).w,a1
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a1
		cmpi.w	#$7E,(a1)
		bhs.s	locret_CE58
		addq.w	#2,(a1)
		adda.w	(a1),a1
		move.w	a0,(a1)

locret_CE58:
		rts
; End of function DisplaySprite3

; ===========================================================================
; ---------------------------------------------------------------------------
; Routines to mark an enemy/monitor/ring/platform as destroyed
; a0 = the object
; ---------------------------------------------------------------------------

MarkObjGone:
RememberState:
		tst.w	(Two_player_mode).w
		beq.s	.not2P
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

.not2P:
		out_of_range.w	.offscreen
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

.offscreen:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	.delete
		bclr	#7,2(a2,d0.w)

.delete:
		bra.w	DeleteObject
; ===========================================================================
; does nothing instead of calling DisplaySprite in the case of no deletion
; loc_CE92:
MarkObjGone2:
		tst.w	(Two_player_mode).w
		beq.s	.not2P
		rts
; ---------------------------------------------------------------------------

.not2P:
		out_of_range.w	.offscreen
		rts
; ---------------------------------------------------------------------------

.offscreen:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	.delete
		bclr	#7,2(a2,d0.w)

.delete:
		bra.w	DeleteObject
; ===========================================================================
; first player in two player mode
; loc_CEC6:
MarkObjGone_P1:
		tst.w	(Two_player_mode).w
		bne.s	MarkObjGone_P2
		out_of_range.w	.offscreen
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

.offscreen:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	.delete
		bclr	#7,2(a2,d0.w)

.delete:
		bra.w	DeleteObject
; ===========================================================================
; second player in two player mode
; loc_CEFA:
MarkObjGone_P2:
		out_of_range_p2.w	.offscreen
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

.offscreen:
		out_of_range_p2_sub.w	.offscreenP2
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

.offscreenP2:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	.delete
		bclr	#7,2(a2,d0.w)

.delete:
		bra.w	DeleteObject			; useless branch...

; ---------------------------------------------------------------------------
; Subroutine to delete an object
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


DeleteObject:
		movea.l	a0,a1
; sub_CF3C:
DeleteChild:
		moveq	#0,d1
		moveq	#bytesToLcnt(object_size),d0	; we want to clear up to the next object
		; delete the object by setting all of its bytes to 0
DelObj_Loop:
		move.l	d1,(a1)+
		dbf	d0,DelObj_Loop
		rts
; End of function DeleteObject

; ---------------------------------------------------------------------------
; Subroutine to animate a sprite using an animation script
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


AnimateSprite:
		moveq	#0,d0
		move.b	obAnim(a0),d0			; move animation number to d0
		cmp.b	obPrevAni(a0),d0		; is animation set to change?
		beq.s	Anim_Run			; if not, branch
		move.b	d0,obPrevAni(a0)		; set previous animation to current one
		move.b	#0,obAniFrame(a0)		; reset animation
		move.b	#0,obTimeFrame(a0)		; reset frame duration
; loc_CF64:
Anim_Run:
		subq.b	#1,obTimeFrame(a0)		; subtract 1 from frame duration
		bpl.s	Anim_Wait			; if time remains, branch
		add.w	d0,d0
		adda.w	(a1,d0.w),a1			; calculate address of appropriate animation script
		move.b	(a1),obTimeFrame(a0)		; load frame duration
		moveq	#0,d1
		move.b	obAniFrame(a0),d1		; load current frame number
		move.b	1(a1,d1.w),d0			; read sprite number from script
		bmi.s	Anim_End_FF			; if animation is complete, branch
; loc_CF80:
Anim_Next:
		move.b	d0,d1				; move animation number to current frame number
		andi.b	#$1F,d0
		move.b	d0,obFrame(a0)			; load sprite number
		move.b	obStatus(a0),d0			; match the orientation dictated by the object
		rol.b	#3,d1				; with the orientation used by the object engine
		eor.b	d0,d1
		andi.b	#3,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		addq.b	#1,obAniFrame(a0)		; next frame number
; locret_CFA4:
Anim_Wait:
		rts
; ===========================================================================
; loc_CFA6:
Anim_End_FF:
		addq.b	#1,d0				; is the end flag = $FF ?
		bne.s	Anim_End_FE			; if not, branch
		move.b	#0,obAniFrame(a0)		; restart the animation
		move.b	1(a1),d0			; read sprite number
		bra.s	Anim_Next
; ===========================================================================
; loc_CFB6:
Anim_End_FE:
		addq.b	#1,d0				; is the end flag = $FE ?
		bne.s	Anim_End_FD			; if not, branch
		move.b	2(a1,d1.w),d0			; read the next byte in the script
		sub.b	d0,obAniFrame(a0)		; jump back d0 bytes in the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0			; read sprite number
		bra.s	Anim_Next
; ===========================================================================
; loc_CFCA:
Anim_End_FD:
		addq.b	#1,d0				; is the end flag = $FD ?
		bne.s	Anim_End_FC			; if not, branch
		move.b	2(a1,d1.w),obAnim(a0)		; read next byte, run that animation
		rts
; ===========================================================================
; loc_CFD6:
Anim_End_FC:
		addq.b	#1,d0				; is the end flag = $FC ?
		bne.s	Anim_End_FB			; if not, branch
		addq.b	#2,obRoutine(a0)		; jump to next routine
		rts
; ===========================================================================
; loc_CFE0:
Anim_End_FB:
		addq.b	#1,d0				; is the end flag = $FB ?
		bne.s	Anim_End_FA			; if not, branch
		move.b	#0,obAniFrame(a0)		; reset animation
		clr.b	ob2ndRout(a0)			; reset 2nd routine counter
		rts
; ===========================================================================
; loc_CFF0:
Anim_End_FA:
		addq.b	#1,d0				; is the end flag = $FA ?
		bne.s	Anim_End			; if not, branch
		addq.b	#2,ob2ndRout(a0)		; jump to next routine
		rts
; ===========================================================================
; locret_CFFA:
Anim_End:
		rts
; End of function AnimateSprite

; ---------------------------------------------------------------------------
BldSpr_ScrPos:
		dc.l 0
		dc.l Camera_X_pos
		dc.l Camera_BG_X_pos
		dc.l Camera_BG3_X_pos

; =============== S U B	R O U T	I N E =======================================


BuildSprites:
		tst.w	(Two_player_mode).w
		bne.w	BuildSprites_2P
		lea	(Sprite_Table).w,a2
		moveq	#0,d5
		moveq	#0,d4
		tst.b	(Level_started_flag).w
		beq.s	loc_D026
		bsr.w	BuildRings

loc_D026:
		lea	(v_spritequeue).w,a4
		moveq	#7,d7

loc_D02C:
		tst.w	(a4)
		beq.w	loc_D102
		moveq	#2,d6

loc_D034:
		movea.w	(a4,d6.w),a0
		tst.b	obID(a0)
		beq.w	loc_D124
		tst.l	obMap(a0)
		beq.w	loc_D124
		andi.b	#$7F,obRender(a0)
		move.b	obRender(a0),d0
		move.b	d0,d4
		btst	#6,d0
		bne.w	loc_D126
		andi.w	#$C,d0
		beq.s	loc_D0B2
		movea.l	BldSpr_ScrPos(pc,d0.w),a1
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D0FA
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1
		bge.w	loc_D0FA
		addi.w	#128,d3
		btst	#4,d4
		beq.s	loc_D0BC
		moveq	#0,d0
		move.b	obHeight(a0),d0
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_D0FA
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#224,d1
		bge.s	loc_D0FA
		addi.w	#128,d2
		bra.s	loc_D0D4
; ---------------------------------------------------------------------------

loc_D0B2:
		move.w	obScreenY(a0),d2
		move.w	obX(a0),d3
		bra.s	loc_D0D4
; ---------------------------------------------------------------------------

loc_D0BC:
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		addi.w	#128,d2
		cmpi.w	#$60,d2
		blo.s	loc_D0FA
		cmpi.w	#$180,d2
		bhs.s	loc_D0FA

loc_D0D4:
		movea.l	obMap(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_D0F0
		move.b	obFrame(a0),d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D0F4

loc_D0F0:
		bsr.w	sub_D1B6

loc_D0F4:
		ori.b	#$80,obRender(a0)

loc_D0FA:
		addq.w	#2,d6
		subq.w	#2,(a4)
		bne.w	loc_D034

loc_D102:
		lea	$80(a4),a4
		dbf	d7,loc_D02C
		move.b	d5,(v_spritecount).w
		cmpi.b	#80,d5
		beq.s	loc_D11C
		move.l	#0,(a2)
		rts
; ---------------------------------------------------------------------------

loc_D11C:
		move.b	#0,-5(a2)
		rts
; ---------------------------------------------------------------------------

loc_D124:
		bra.s	loc_D0FA
; ---------------------------------------------------------------------------

loc_D126:
		move.l	a4,-(sp)
		lea	(Camera_RAM).w,a4
		movea.w	obGfx(a0),a3
		movea.l	obMap(a0),a5
		moveq	#0,d0
		move.b	mainspr_width(a0),d0
		move.w	obX(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D1B0
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1
		bge.s	loc_D1B0
		move.w	obY(a0),d2
		sub.w	4(a4),d2
		addi.w	#128,d2
		cmpi.w	#$60,d2
		blo.s	loc_D1B0
		cmpi.w	#$180,d2
		bhs.s	loc_D1B0
		ori.b	#$80,obRender(a0)
		lea	subspr_data(a0),a6
		moveq	#0,d0
		move.b	mainspr_childsprites(a0),d0
		subq.w	#1,d0
		blo.s	loc_D1B0

loc_D17E:
		swap	d0
		move.w	(a6)+,d3
		sub.w	(a4),d3
		addi.w	#128,d3
		move.w	(a6)+,d2
		sub.w	4(a4),d2
		addi.w	#128,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1
		add.w	d1,d1
		movea.l	a5,a1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D1AA
		bsr.w	sub_D1BA

loc_D1AA:
		swap	d0
		dbf	d0,loc_D17E

loc_D1B0:
		movea.l	(sp)+,a4
		bra.w	loc_D0FA
; End of function BuildSprites


; =============== S U B	R O U T	I N E =======================================


sub_D1B6:
		movea.w	obGfx(a0),a3
; End of function sub_D1B6


; =============== S U B	R O U T	I N E =======================================


sub_D1BA:
	if FixBugs=0
		cmpi.b	#80,d5
		bhs.s	locret_D1F6
	endif
		btst	#0,d4
		bne.s	loc_D1F8
		btst	#1,d4
		bne.w	loc_D258

loc_D1CE:
	if FixBugs
		; In a rather overzealous optimisation, this game doesn't check if
		; the sprite limit has been reached every time it processes a sprite
		; piece. Naturally, this leads to the 'Sprite_Table' buffer being
		; overflowed if too many sprites are processed. To mitigate this, the
		; developers placed an $80 byte large spill buffer after
		; 'Sprite_Table', to 'catch' the overflow. Unfortunately, this spill
		; buffer is not big enough to catch all overflow: this oversight is
		; responsible for the famous 'Ashua' bug. To fix this, we'll just
		; undo this optimistaion. Sonic 3 & Knuckles undid this optimistaion
		; too, but heavily optimised the rest of 'BuildSprites' to make up
		; for it.
		cmpi.b	#80,d5
		bhs.s	locret_D1F6
	endif
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D1F0
		addq.w	#1,d0

loc_D1F0:
		move.w	d0,(a2)+
		dbf	d1,loc_D1CE

locret_D1F6:
		rts
; ---------------------------------------------------------------------------

loc_D1F8:
		btst	#1,d4
		bne.w	loc_D2A0

loc_D200:
	if FixBugs
		cmpi.b	#80,d5
		bhs.s	locret_D1F6
	endif
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$800,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		neg.w	d0
		move.b	byte_D238(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D230
		addq.w	#1,d0

loc_D230:
		move.w	d0,(a2)+
		dbf	d1,loc_D200
		rts
; ---------------------------------------------------------------------------
byte_D238:	dc.b   8,  8,  8,  8
		dc.b $10,$10,$10,$10
		dc.b $18,$18,$18,$18
		dc.b $20,$20,$20,$20
; ---------------------------------------------------------------------------
byte_D248:	dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
; ---------------------------------------------------------------------------

loc_D258:
	if FixBugs
		cmpi.b	#80,d5
		bhs.s	locret_D288
	endif
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	byte_D248(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1000,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D288
		addq.w	#1,d0

loc_D288:
		move.w	d0,(a2)+
		dbf	d1,loc_D258

locret_D288:
		rts
; ---------------------------------------------------------------------------
byte_D290:	dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
; ---------------------------------------------------------------------------

loc_D2A0:
	if FixBugs
		cmpi.b	#80,d5
		bhs.s	locret_D288
	endif
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	byte_D290(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1800,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		neg.w	d0
		move.b	byte_D2E2(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D2DA
		addq.w	#1,d0

loc_D2DA:
		move.w	d0,(a2)+
		dbf	d1,loc_D2A0
		rts
; End of function sub_D1BA

; ---------------------------------------------------------------------------
byte_D2E2:	dc.b   8,  8,  8,  8
		dc.b $10,$10,$10,$10
		dc.b $18,$18,$18,$18
		dc.b $20,$20,$20,$20
; ---------------------------------------------------------------------------

BldSpr_ScrPos_2P:
		dc.l 0
		dc.l Camera_X_pos
		dc.l Camera_BG_X_pos
		dc.l Camera_BG3_X_pos
; ---------------------------------------------------------------------------

BuildSprites_2P:
		tst.w	(f_hbla_pal).w
		bne.s	BuildSprites_2P
		lea	(Sprite_Table).w,a2
		moveq	#2,d5
		moveq	#0,d4
		move.l	#$1D80F01,(a2)+	; mask all sprites
		move.l	#1,(a2)+
		move.l	#$1D80F02,(a2)+	; from 216px to 248px
		move.l	#0,(a2)+
		tst.b	(Level_started_flag).w
		beq.s	loc_D332
		bsr.w	BuildRings_2P

loc_D332:
		lea	(v_spritequeue).w,a4
		moveq	#7,d7

loc_D338:
		move.w	(a4),d0
		beq.w	loc_D410
		move.w	d0,-(sp)
		moveq	#2,d6

loc_D342:
		movea.w	(a4,d6.w),a0
		tst.b	obID(a0)
		beq.w	loc_D406
		andi.b	#$7F,obRender(a0)
		move.b	obRender(a0),d0
		move.b	d0,d4
		btst	#6,d0
		bne.w	loc_D54A
		andi.w	#$C,d0
		beq.s	loc_D3B6
		movea.l	BldSpr_ScrPos_2P(pc,d0.w),a1
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D406
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1
		bge.s	loc_D406
		addi.w	#128,d3
		btst	#4,d4
		beq.s	loc_D3C4
		moveq	#0,d0
		move.b	obHeight(a0),d0
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_D406
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#224,d1
		bge.s	loc_D406
		addi.w	#$100,d2
		bra.s	loc_D3E0
; ---------------------------------------------------------------------------

loc_D3B6:
		move.w	obScreenY(a0),d2
		move.w	obX(a0),d3
		addi.w	#128,d2
		bra.s	loc_D3E0
; ---------------------------------------------------------------------------

loc_D3C4:
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		addi.w	#128,d2
		cmpi.w	#$60,d2
		blo.s	loc_D406
		cmpi.w	#$180,d2
		bhs.s	loc_D406
		addi.w	#128,d2

loc_D3E0:
		movea.l	obMap(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_D3FC
		move.b	obFrame(a0),d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D400

loc_D3FC:
		bsr.w	sub_D6A2

loc_D400:
		ori.b	#$80,obRender(a0)

loc_D406:
		addq.w	#2,d6
		subq.w	#2,(sp)
		bne.w	loc_D342
		addq.w	#2,sp

loc_D410:
		lea	$80(a4),a4
		dbf	d7,loc_D338
		move.b	d5,(v_spritecount).w
		cmpi.b	#80,d5
		bhs.s	loc_D42A
		move.l	#0,(a2)
		bra.s	loc_D442
; ---------------------------------------------------------------------------

loc_D42A:
		move.b	#0,-5(a2)
		bra.s	loc_D442
; ---------------------------------------------------------------------------
dword_D432:
		dc.l 0
		dc.l Camera_X_pos_P2
		dc.l Camera_BG_X_pos_P2
		dc.l Camera_BG3_X_pos_P2
; ---------------------------------------------------------------------------

loc_D442:
		lea	(Sprite_Table_2P).w,a2
		moveq	#0,d5
		moveq	#0,d4
		tst.b	(Level_started_flag).w
		beq.s	loc_D454
		bsr.w	sub_DACA

loc_D454:
		lea	(v_spritequeue).w,a4
		moveq	#7,d7

loc_D45A:
		tst.w	(a4)
		beq.w	loc_D528
		moveq	#2,d6

loc_D462:
		movea.w	(a4,d6.w),a0
		tst.b	obID(a0)
		beq.w	loc_D520
		move.b	obRender(a0),d0
		move.b	d0,d4
		btst	#6,d0
		bne.w	loc_D5DA
		andi.w	#$C,d0
		beq.s	loc_D4D0
		movea.l	dword_D432(pc,d0.w),a1
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D520
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1
		bge.s	loc_D520
		addi.w	#128,d3
		btst	#4,d4
		beq.s	loc_D4DE
		moveq	#0,d0
		move.b	obHeight(a0),d0
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_D520
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#224,d1
		bge.s	loc_D520
		addi.w	#$1E0,d2
		bra.s	loc_D4FA
; ---------------------------------------------------------------------------

loc_D4D0:
		move.w	obScreenY(a0),d2
		move.w	obX(a0),d3
		addi.w	#$160,d2
		bra.s	loc_D4FA
; ---------------------------------------------------------------------------

loc_D4DE:
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		addi.w	#128,d2
		cmpi.w	#$60,d2
		blo.s	loc_D520
		cmpi.w	#$180,d2
		bhs.s	loc_D520
		addi.w	#$160,d2

loc_D4FA:
		movea.l	obMap(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_D516
		move.b	obFrame(a0),d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D51A

loc_D516:
		bsr.w	sub_D6A2

loc_D51A:
		ori.b	#$80,obRender(a0)

loc_D520:
		addq.w	#2,d6
		subq.w	#2,(a4)
		bne.w	loc_D462

loc_D528:
		lea	$80(a4),a4
		dbf	d7,loc_D45A
		move.b	d5,(v_spritecount).w
		cmpi.b	#80,d5
		beq.s	loc_D542
		move.l	#0,(a2)
		rts
; ---------------------------------------------------------------------------

loc_D542:
		move.b	#0,-5(a2)
		rts
; ---------------------------------------------------------------------------

loc_D54A:
		move.l	a4,-(sp)
		lea	(Camera_RAM).w,a4
		movea.w	obGfx(a0),a3
		movea.l	obMap(a0),a5
		moveq	#0,d0
		move.b	mainspr_width(a0),d0
		move.w	obX(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D5D4
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1
		bge.s	loc_D5D4
		move.w	obY(a0),d2
		sub.w	4(a4),d2
		addi.w	#128,d2
		cmpi.w	#$60,d2
		blo.s	loc_D5D4
		cmpi.w	#$180,d2
		bhs.s	loc_D5D4
		ori.b	#$80,obRender(a0)
		lea	subspr_data(a0),a6
		moveq	#0,d0
		move.b	mainspr_childsprites(a0),d0
		subq.w	#1,d0
		blo.s	loc_D5D4

loc_D5A2:
		swap	d0
		move.w	(a6)+,d3
		sub.w	(a4),d3
		addi.w	#128,d3
		move.w	(a6)+,d2
		sub.w	4(a4),d2
		addi.w	#$100,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1
		add.w	d1,d1
		movea.l	a5,a1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D5CE
		bsr.w	sub_D6A6

loc_D5CE:
		swap	d0
		dbf	d0,loc_D5A2

loc_D5D4:
		movea.l	(sp)+,a4
		bra.w	loc_D406
; ---------------------------------------------------------------------------

loc_D5DA:
		move.l	a4,-(sp)
		lea	(Camera_X_pos_P2).w,a4
		movea.w	obGfx(a0),a3
		movea.l	obMap(a0),a5
		moveq	#0,d0
		move.b	mainspr_width(a0),d0
		move.w	obX(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D664
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1
		bge.s	loc_D664
		move.w	obY(a0),d2
		sub.w	4(a4),d2
		addi.w	#128,d2
		cmpi.w	#$60,d2
		blo.s	loc_D664
		cmpi.w	#$180,d2
		bhs.s	loc_D664
		ori.b	#$80,obRender(a0)
		lea	subspr_data(a0),a6
		moveq	#0,d0
		move.b	mainspr_childsprites(a0),d0
		subq.w	#1,d0
		blo.s	loc_D664

loc_D632:
		swap	d0
		move.w	(a6)+,d3
		sub.w	(a4),d3
		addi.w	#128,d3
		move.w	(a6)+,d2
		sub.w	4(a4),d2
		addi.w	#$1E0,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1
		add.w	d1,d1
		movea.l	a5,a1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_D65E
		bsr.w	sub_D6A6

loc_D65E:
		swap	d0
		dbf	d0,loc_D632

loc_D664:
		movea.l	(sp)+,a4
		bra.w	loc_D520

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; adjust art pointer of object at a0 for 2-player mode
; ModifySpriteAttr_2P:
Adjust2PArtPointer:
		tst.w	(Two_player_mode).w
		beq.s	locret_D684
		move.w	obGfx(a0),d0
		andi.w	#tile_mask,d0
		lsr.w	#1,d0
		andi.w	#nontile_mask,obGfx(a0)
		add.w	d0,obGfx(a0)

locret_D684:
		rts
; End of function Adjust2PArtPointer


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; adjust art pointer of object at a1 for 2-player mode
; ModifyA1SpriteAttr_2P:
Adjust2PArtPointer2:
		tst.w	(Two_player_mode).w
		beq.s	locret_D6BE
		move.w	obGfx(a1),d0
		andi.w	#tile_mask,d0
		lsr.w	#1,d0
		andi.w	#nontile_mask,obGfx(a1)
		add.w	d0,obGfx(a1)

locret_D6BE
		rts
; End of function Adjust2PArtPointer2


; =============== S U B	R O U T	I N E =======================================


sub_D6A2:
		movea.w	obGfx(a0),a3
; End of function sub_D6A2


; =============== S U B	R O U T	I N E =======================================


sub_D6A6:
	if FixBugs=0
		cmpi.b	#80,d5
		bhs.s	locret_D6E6
	endif
		btst	#0,d4
		bne.s	loc_D6F8
		btst	#1,d4
		bne.w	loc_D75A

loc_D6BA:
	if FixBugs
		cmpi.b	#80,d5
		bhs.s	locret_D6E6
	endif
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	byte_D6E8(pc,d4.w),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D6E0
		addq.w	#1,d0

loc_D6E0:
		move.w	d0,(a2)+
		dbf	d1,loc_D6BA

locret_D6E6:
		rts
; ---------------------------------------------------------------------------
byte_D6E8:	dc.b   0,  0
		dc.b   1,  1
		dc.b   4,  4
		dc.b   5,  5
		dc.b   8,  8
		dc.b   9,  9
		dc.b  $C, $C
		dc.b  $D, $D
; ---------------------------------------------------------------------------

loc_D6F8:
		btst	#1,d4
		bne.w	loc_D7B6

loc_D700:
	if FixBugs
		cmpi.b	#80,d5
		bhs.s	locret_D6E6
	endif
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	byte_D6E8(pc,d4.w),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$800,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		neg.w	d0
		move.b	byte_D73A(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D732
		addq.w	#1,d0

loc_D732:
		move.w	d0,(a2)+
		dbf	d1,loc_D700
		rts
; ---------------------------------------------------------------------------
byte_D73A:	dc.b   8,  8
		dc.b   8,  8
		dc.b $10,$10
		dc.b $10,$10
		dc.b $18,$18
		dc.b $18,$18
		dc.b $20,$20
		dc.b $20,$20
; ---------------------------------------------------------------------------
byte_D74A:	dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
; ---------------------------------------------------------------------------

loc_D75A:
	if FixBugs
		cmpi.b	#80,d5
		bhs.s	locret_D78E
	endif
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	byte_D74A(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	byte_D796(pc,d4.w),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1000,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D78E
		addq.w	#1,d0

loc_D78E:
		move.w	d0,(a2)+
		dbf	d1,loc_D75A

locret_D78E:
		rts
; ---------------------------------------------------------------------------
byte_D796:	dc.b   0,  0,  1,  1
		dc.b   4,  4,  5,  5
		dc.b   8,  8,  9,  9
		dc.b  $C, $C, $D, $D
; ---------------------------------------------------------------------------
byte_D7A6:	dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
		dc.b   8,$10,$18,$20
; ---------------------------------------------------------------------------

loc_D7B6:
	if FixBugs
		cmpi.b	#80,d5
		bhs.s	locret_D78E
	endif
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	byte_D7A6(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	byte_D796(pc,d4.w),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1800,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		neg.w	d0
		move.b	byte_D7FA(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D7F2
		addq.w	#1,d0

loc_D7F2:
		move.w	d0,(a2)+
		dbf	d1,loc_D7B6
		rts
; End of function sub_D6A6

; ---------------------------------------------------------------------------
byte_D7FA:	dc.b   8,  8,  8,  8
		dc.b $10,$10,$10,$10
		dc.b $18,$18,$18,$18
		dc.b $20,$20,$20,$20
; ===========================================================================

		include	"obj/S1/sub ChkObjectVisible.asm"

		jmpTos	; Empty

; ============================================================================
; ----------------------------------------------------------------------------
; Pseudo-object that manages where rings are placed onscreen
; as you move through the level, and otherwise updates them.
; ----------------------------------------------------------------------------

; RingPosLoad:
RingsManager:
		moveq	#0,d0
		move.b	(Rings_manager_routine).w,d0
		move.w	RingsManager_States(pc,d0.w),d0
		jmp	RingsManager_States(pc,d0.w)
; End of function RingsManager

; ===========================================================================
; RPL_Index:
RingsManager_States:
		dc.w RingsManager_Init-RingsManager_States
		dc.w RingsManager_Main-RingsManager_States
; ===========================================================================
; RPL_Main:
RingsManager_Init:
		addq.b	#2,(Rings_manager_routine).w	; => RingsManager_Main
		bsr.w	RingsManager_Setup		; perform initial setup
		lea	(Ring_Positions).w,a1
		move.w	(Camera_RAM).w,d4
		subq.w	#8,d4
		bhi.s	loc_D896
		moveq	#1,d4				; no negative values allowed
		bra.s	loc_D896
; ---------------------------------------------------------------------------

loc_D892:
		lea	6(a1),a1			; load next ring

loc_D896:
		cmp.w	2(a1),d4			; is the X pos of the ring < camera X pos?
		bhi.s	loc_D892			; if it is, check next ring
		move.w	a1,(Ring_start_addr).w		; set start addresses
		move.w	a1,(Ring_start_addr_P2).w
		addi.w	#$150,d4			; advance by a screen
		bra.s	loc_D8AE
; ---------------------------------------------------------------------------

loc_D8AA:
		lea	6(a1),a1			; load next ring

loc_D8AE:
		cmp.w	2(a1),d4			; is the X pos of the ring < camera X + 336?
		bhi.s	loc_D8AA			; if it is, check next ring
		move.w	a1,(Ring_end_addr).w		; set end addresses
		move.w	a1,(Ring_end_addr_P2).w
		move.b	#1,(Level_started_flag).w
		rts
; ===========================================================================
; RPL_Next:
RingsManager_Main:
		lea	(Ring_Positions).w,a1
	if FixBugs
		move.w	#255-1,d1			; do 255 rings
	else
		; There is a slight bug here.
		; This does 256 rings, when it should be 255 to keep it consistent with RingsMgr_SortRings.
		move.w	#256-1,d1			; do 256 rings
	endif

loc_D8CC:
		move.b	(a1),d0				; is there a ring in this slot?
		beq.s	loc_D8EA			; if not, branch
		bmi.s	loc_D8EA
		subq.b	#1,(a1)				; decrement timer
		bne.s	loc_D8EA			; if it's not 0 yet, branch
		move.b	#6,(a1)				; reset timer
		addq.b	#1,1(a1)			; increment frame
		cmpi.b	#8,1(a1)			; is it destruction time yet?
		bne.s	loc_D8EA			; if not, branch
		move.w	#-1,(a1)			; destroy ring

loc_D8EA:
		lea	6(a1),a1
		dbf	d1,loc_D8CC

		; update ring start and end addresses
		movea.w	(Ring_start_addr).w,a1
		move.w	(Camera_RAM).w,d4
		subq.w	#8,d4
		bhi.s	loc_D906
		moveq	#1,d4
		bra.s	loc_D906
; ---------------------------------------------------------------------------

loc_D902:
		lea	6(a1),a1

loc_D906:
		cmp.w	2(a1),d4
		bhi.s	loc_D902
		bra.s	loc_D910
; ---------------------------------------------------------------------------

loc_D90E:
		subq.w	#6,a1

loc_D910:
		cmp.w	-4(a1),d4
		bls.s	loc_D90E
		move.w	a1,(Ring_start_addr).w		; update start address

		movea.w	(Ring_end_addr).w,a2
		addi.w	#$150,d4
		bra.s	loc_D928
; ---------------------------------------------------------------------------

loc_D924:
		lea	6(a2),a2

loc_D928:
		cmp.w	2(a2),d4
		bhi.s	loc_D924
		bra.s	loc_D932
; ---------------------------------------------------------------------------

loc_D930:
		subq.w	#6,a2

loc_D932:
		cmp.w	-4(a2),d4
		bls.s	loc_D930
		move.w	a2,(Ring_end_addr).w		; update end address
		tst.w	(Two_player_mode).w		; are we in 2P mode?
		bne.s	loc_D94C			; if we are, update P2 addresses
		move.w	a1,(Ring_start_addr_P2).w	; otherwise, copy over P1 addresses
		move.w	a2,(Ring_end_addr_P2).w
		rts
; ---------------------------------------------------------------------------

loc_D94C:
		; update ring start and end addresses for P2
		movea.w	(Ring_start_addr_P2).w,a1
		move.w	(Camera_X_pos_P2).w,d4
		subq.w	#8,d4
		bhi.s	loc_D960
		moveq	#1,d4
		bra.s	loc_D960
; ---------------------------------------------------------------------------

loc_D95C:
		lea	6(a1),a1

loc_D960:
		cmp.w	2(a1),d4
		bhi.s	loc_D95C
		bra.s	loc_D96A
; ---------------------------------------------------------------------------

loc_D968:
		subq.w	#6,a1

loc_D96A:
		cmp.w	-4(a1),d4
		bls.s	loc_D968
		move.w	a1,(Ring_start_addr_P2).w	; update start address

		movea.w	(Ring_end_addr_P2).w,a2
		addi.w	#$150,d4
		bra.s	loc_D982
; ---------------------------------------------------------------------------

loc_D97E:
		lea	6(a2),a2

loc_D982:
		cmp.w	2(a2),d4
		bhi.s	loc_D97E
		bra.s	loc_D98C
; ---------------------------------------------------------------------------

loc_D98A:
		subq.w	#6,a2

loc_D98C:
		cmp.w	-4(a2),d4
		bls.s	loc_D98A
		move.w	a2,(Ring_end_addr_P2).w		; update end address
		rts

; ---------------------------------------------------------------------------
; Subroutine to handle ring collision
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_D998:
Touch_Rings:
		movea.w	(Ring_start_addr).w,a1
		movea.w	(Ring_end_addr).w,a2
		cmpa.w	#v_player,a0
		beq.s	loc_D9AE
		movea.w	(Ring_start_addr_P2).w,a1
		movea.w	(Ring_end_addr_P2).w,a2

loc_D9AE:
		cmpa.l	a1,a2
		beq.w	locret_DA36
		cmpi.w	#90,flashtime(a0)
		bhs.s	locret_DA36
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		subi.w	#8,d2
		moveq	#0,d5
		move.b	obHeight(a0),d5
		subq.b	#3,d5
		sub.w	d5,d3
	if FixBugs
		cmpi.b	#AniIDSonAni_Duck,obAnim(a0)
	else
		; Bug: This does not check either player's ducking frame!
		; Sonic's ducking frame is $80, and Tails's frame is $5B.
		; However, this does work for Sonic 1's mapping frames.
		cmpi.b	#$39,obFrame(a0)
	endif
		bne.s	loc_D9E0
		addi.w	#$C,d3
		moveq	#$A,d5

loc_D9E0:
		move.w	#6,d1
		move.w	#12,d6
		move.w	#$10,d4
		add.w	d5,d5

loc_D9EE:
		tst.w	(a1)
		bne.w	loc_DA2C
		move.w	2(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bhs.s	loc_DA06
		add.w	d6,d0
		blo.s	loc_DA0C
		bra.w	loc_DA2C
; ---------------------------------------------------------------------------

loc_DA06:
		cmp.w	d4,d0
		bhi.w	loc_DA2C

loc_DA0C:
		move.w	4(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bhs.s	loc_DA1E
		add.w	d6,d0
		blo.s	loc_DA24
		bra.w	loc_DA2C
; ---------------------------------------------------------------------------

loc_DA1E:
		cmp.w	d5,d0
		bhi.w	loc_DA2C

loc_DA24:
		move.w	#$604,(a1)
		bsr.w	CollectRing

loc_DA2C:
		lea	6(a1),a1
		cmpa.l	a1,a2
		bne.w	loc_D9EE

locret_DA36:
		rts
; End of function Touch_Rings


; =============== S U B	R O U T	I N E =======================================


BuildRings:
		movea.w	(Ring_start_addr).w,a0
		movea.w	(Ring_end_addr).w,a4
		cmpa.l	a0,a4
		bne.s	loc_DA46
		rts
; ---------------------------------------------------------------------------

loc_DA46:
		lea	(Camera_RAM).w,a3

loc_DA4A:
		tst.w	(a0)
		bmi.w	loc_DAA8
		move.w	2(a0),d3
		sub.w	Camera_X_pos-Camera_RAM(a3),d3
		addi.w	#128,d3
		move.w	4(a0),d2
		sub.w	Camera_Y_pos-Camera_RAM(a3),d2
		addi.w	#8,d2
		bmi.s	loc_DAA8
		cmpi.w	#224+16,d2
		bge.s	loc_DAA8
		addi.w	#128-8,d2
		lea	(off_DC04).l,a1
		moveq	#0,d1
		move.b	1(a0),d1
		bne.s	loc_DA84
		move.b	(v_ani1_frame).w,d1

loc_DA84:
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		addi.w	#make_art_tile(ArtTile_Ring,1,0),d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a2)+

loc_DAA8:
		lea	6(a0),a0
		cmpa.l	a0,a4
		bne.w	loc_DA4A
		rts
; End of function BuildRings


; =============== S U B	R O U T	I N E =======================================


BuildRings_2P:
		lea	(Camera_RAM).w,a3
		move.w	#128-8,d6
		movea.w	(Ring_start_addr).w,a0
		movea.w	(Ring_end_addr).w,a4
		cmpa.l	a0,a4
		bne.s	loc_DAE0
		rts
; End of function BuildRings_2P


; =============== S U B	R O U T	I N E =======================================


sub_DACA:
		lea	(Camera_X_pos_P2).w,a3
		move.w	#320+24,d6
		movea.w	(Ring_start_addr_P2).w,a0
		movea.w	(Ring_end_addr_P2).w,a4
		cmpa.l	a0,a4
		bne.s	loc_DAE0
		rts
; ---------------------------------------------------------------------------

loc_DAE0:
		tst.w	(a0)
		bmi.w	loc_DB40
		move.w	2(a0),d3
		sub.w	Camera_X_pos-Camera_RAM(a3),d3
		addi.w	#128,d3
		move.w	4(a0),d2
		sub.w	Camera_Y_pos-Camera_RAM(a3),d2
		addi.w	#128+8,d2
		bmi.s	loc_DB40
		cmpi.w	#320+48,d2
		bge.s	loc_DB40
		add.w	d6,d2
		lea	(off_DC04).l,a1
		moveq	#0,d1
		move.b	1(a0),d1
		bne.s	loc_DB18
		move.b	(v_ani1_frame).w,d1

loc_DB18:
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	byte_DB4C(pc,d4.w),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		addi.w	#make_art_tile_2p(ArtTile_Ring,1,0),d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a2)+

loc_DB40:
		lea	6(a0),a0
		cmpa.l	a0,a4
		bne.w	loc_DAE0
		rts
; End of function sub_DACA

; ---------------------------------------------------------------------------
byte_DB4C:	dc.b   0,  0,  1,  1
		dc.b   4,  4,  5,  5
		dc.b   8,  8,  9,  9
		dc.b  $C, $C, $D, $D
		even

; ---------------------------------------------------------------------------
; Subroutine to perform initial rings manager setup
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; RingsManager2:
RingsManager_Setup:
		clearRAM Ring_Positions, Ring_Positions_End
		moveq	#0,d0
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#5,d0
		lea	(RingPos_Index).l,a1
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		lea	(Ring_Positions+6).w,a2
; loc_DB88:
RingsMgr_NextRowOrCol:
		move.w	(a1)+,d2
		bmi.s	RingsMgr_SortRings
		move.w	(a1)+,d3
		bmi.s	RingsMgr_RingCol
		move.w	d3,d0
		rol.w	#4,d0
		andi.w	#7,d0
		andi.w	#$FFF,d3
; loc_DB9C:
RingsMgr_NextRingInRow:
		move.w	#0,(a2)+
		move.w	d2,(a2)+
		move.w	d3,(a2)+
		addi.w	#$18,d2
		dbf	d0,RingsMgr_NextRingInRow
		bra.s	RingsMgr_NextRowOrCol
; ===========================================================================
; loc_DBAE:
RingsMgr_RingCol:
		move.w	d3,d0
		rol.w	#4,d0
		andi.w	#7,d0
		andi.w	#$FFF,d3
; loc_DBBA:
RingsMgr_NextRingInCol:
		move.w	#0,(a2)+
		move.w	d2,(a2)+
		move.w	d3,(a2)+
		addi.w	#$18,d3
		dbf	d0,RingsMgr_NextRingInCol
		bra.s	RingsMgr_NextRowOrCol
; ===========================================================================
; loc_Dbhs:
RingsMgr_SortRings:
		moveq	#-1,d0
		move.l	d0,(a2)+
		lea	(Ring_Positions+2).w,a1
		move.w	#255-1,d3

loc_DBD8:
		move.w	d3,d4
		lea	6(a1),a2
		move.w	(a1),d0

loc_DBE0:
		tst.w	(a2)
		beq.s	loc_DBF2
		cmp.w	(a2),d0
		bls.s	loc_DBF2
		move.l	(a1),d1
		move.l	(a2),d0
		move.l	d0,(a1)
		move.l	d1,(a2)
		swap	d0

loc_DBF2:
		lea	6(a2),a2
		dbf	d4,loc_DBE0
		lea	6(a1),a1
		dbf	d3,loc_DBD8
		rts
; End of function RingsManager_Setup

; ---------------------------------------------------------------------------
off_DC04:
		dc.w .frame1-off_DC04
		dc.w .frame2-off_DC04
		dc.w .frame3-off_DC04
		dc.w .frame4-off_DC04
		dc.w .frame5-off_DC04
		dc.w .frame6-off_DC04
		dc.w .frame7-off_DC04
		dc.w .frame8-off_DC04
.frame1:	dc.w $F805, 0, 0, $FFF8
.frame2:	dc.w $F805, 4, 2, $FFF8
.frame3:	dc.w $F801, 8, 4, $FFFC
.frame4:	dc.w $F805, $804, $802, $FFF8
.frame5:	dc.w $F805, $A, 5, $FFF8
.frame6:	dc.w $F805, $180A, $1805, $FFF8
.frame7:	dc.w $F805, $80A, $805, $FFF8
.frame8:	dc.w $F805, $100A, $1005, $FFF8

; ===========================================================================
; ---------------------------------------------------------------------------
; Objects Manager
; Subroutine that keeps track of any objects that need to remember
; their state, such as monitors or enemies.
;
; input variables:
;  -none-
;
; writes:
;  d0, d1
;  d2 = respawn index of object to load
;  d6 = camera position
;
;  a0 = address in object placement list
;  a2 = respawn table
; ---------------------------------------------------------------------------

; ObjPosLoad:
ObjectsManager:
		moveq	#0,d0
		move.b	(Obj_placement_routine).w,d0
		move.w	ObjectsManager_States(pc,d0.w),d0
		jmp	ObjectsManager_States(pc,d0.w)
; End of function ObjectsManager

; ===========================================================================
; OPL_Index:
ObjectsManager_States:
		dc.w ObjectsManager_Init-ObjectsManager_States
		dc.w ObjectsManager_Main-ObjectsManager_States
		dc.w ObjectsManager_2P_Main-ObjectsManager_States
; ===========================================================================
; loc_DC68:
ObjectsManager_Init:
		addq.b	#2,(Obj_placement_routine).w
		move.w	(Current_ZoneAndAct).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	(ObjPos_Index).l,a0
		movea.l	a0,a1
		adda.w	(a0,d0.w),a0
		move.l	a0,(Obj_load_addr_right).w
		move.l	a0,(Obj_load_addr_left).w
		move.l	a0,(Obj_load_addr_right_P2).w
		move.l	a0,(Obj_load_addr_left_P2).w
		lea	(v_objstate).w,a2
		move.w	#$101,(a2)+
	if FixBugs
		move.w	#bytesToLcnt(v_objstate_end-v_objstate-2),d0
	else
		; This clears longwords, but the loop counter is measured in words!
		; This causes $17C bytes to be cleared instead of $BE.
		move.w	#bytesToWcnt(v_objstate_end-v_objstate-2),d0
	endif

loc_DC9C:
		clr.l	(a2)+
		dbf	d0,loc_DC9C

	if FixBugs
		; Clear the last word, since the above loop only does longwords.
	if (v_objstate_end-v_objstate-2)&2
		clr.w	(a2)+
	endif
	endif

		lea	(v_objstate).w,a2
		moveq	#0,d2
		move.w	(Camera_RAM).w,d6
		subi.w	#$80,d6
		bhs.s	loc_DCB4
		moveq	#0,d6

loc_DCB4:
		andi.w	#-$80,d6
		movea.l	(Obj_load_addr_right).w,a0

loc_DCBC:
		cmp.w	(a0),d6
		bls.s	loc_DCCE
		tst.b	4(a0)
		bpl.s	loc_DCCA
		move.b	(a2),d2
		addq.b	#1,(a2)

loc_DCCA:
		addq.w	#6,a0
		bra.s	loc_DCBC
; ===========================================================================

loc_DCCE:
		move.l	a0,(Obj_load_addr_right).w
		move.l	a0,(Obj_load_addr_right_P2).w
		movea.l	(Obj_load_addr_left).w,a0
		subi.w	#$80,d6
		blo.s	loc_DCF2

loc_DCE0:
		cmp.w	(a0),d6
		bls.s	loc_DCF2
		tst.b	4(a0)
		bpl.s	loc_DCEE
		addq.b	#1,1(a2)

loc_DCEE:
		addq.w	#6,a0
		bra.s	loc_DCE0
; ===========================================================================

loc_DCF2:
		move.l	a0,(Obj_load_addr_left).w
		move.l	a0,(Obj_load_addr_left_P2).w
		move.w	#-1,(Camera_X_pos_last).w
		move.w	#-1,(Camera_X_pos_last_P2).w
		tst.w	(Two_player_mode).w
		beq.s	ObjectsManager_Main
		addq.b	#2,(Obj_placement_routine).w
		bra.w	loc_DDE0
; ===========================================================================
; loc_DD14:
ObjectsManager_Main:
		move.w	(Camera_X_pos).w,d1
		subi.w	#$80,d1
		andi.w	#-$80,d1
		move.w	d1,(Camera_X_pos_coarse).w
		lea	(v_objstate).w,a2
		moveq	#0,d2
		move.w	(Camera_X_pos).w,d6
		andi.w	#-$80,d6
		cmp.w	(Camera_X_pos_last).w,d6
		beq.w	locret_DDDE
		bge.s	loc_DD9A
		move.w	d6,(Camera_X_pos_last).w
		movea.l	(Obj_load_addr_left).w,a0
		subi.w	#$80,d6
		blo.s	loc_DD76

loc_DD4A:
		cmp.w	-6(a0),d6
		bge.s	loc_DD76
		subq.w	#6,a0
		tst.b	4(a0)
		bpl.s	loc_DD60
		subq.b	#1,1(a2)
		move.b	1(a2),d2

loc_DD60:
		bsr.w	sub_E0D2
		bne.s	loc_DD6A
		subq.w	#6,a0
		bra.s	loc_DD4A
; ===========================================================================

loc_DD6A:
		tst.b	4(a0)
		bpl.s	loc_DD74
		addq.b	#1,1(a2)

loc_DD74:
		addq.w	#6,a0

loc_DD76:
		move.l	a0,(Obj_load_addr_left).w
		movea.l	(Obj_load_addr_right).w,a0
		addi.w	#$300,d6

loc_DD82:
		cmp.w	-6(a0),d6
		bgt.s	loc_DD94
		tst.b	-2(a0)
		bpl.s	loc_DD90
		subq.b	#1,(a2)

loc_DD90:
		subq.w	#6,a0
		bra.s	loc_DD82
; ===========================================================================

loc_DD94:
		move.l	a0,(Obj_load_addr_right).w
		rts
; ===========================================================================

loc_DD9A:
		move.w	d6,(Camera_X_pos_last).w
		movea.l	(Obj_load_addr_right).w,a0
		addi.w	#$280,d6

loc_DDA6:
		cmp.w	(a0),d6
		bls.s	loc_DDBA
		tst.b	4(a0)
		bpl.s	loc_DDB4
		move.b	(a2),d2
		addq.b	#1,(a2)

loc_DDB4:
		bsr.w	sub_E0D2
		beq.s	loc_DDA6

loc_DDBA:
		move.l	a0,(Obj_load_addr_right).w
		movea.l	(Obj_load_addr_left).w,a0
		subi.w	#$300,d6
		blo.s	loc_DDDA

loc_DDC8:
		cmp.w	(a0),d6
		bls.s	loc_DDDA
		tst.b	4(a0)
		bpl.s	loc_DDD6
		addq.b	#1,1(a2)

loc_DDD6:
		addq.w	#6,a0
		bra.s	loc_DDC8
; ===========================================================================

loc_DDDA:
		move.l	a0,(Obj_load_addr_left).w

locret_DDDE:
		rts
; ===========================================================================

loc_DDE0:
		; Reset all of the 2P object manager variables to $FF.
		moveq	#-1,d0

		; Some code to generate an unrolled loop of instructions which clear
		; the 2P object manager variables.
.c := 0
	rept (Object_manager_2P_RAM_End-Object_manager_2P_RAM)/4
		move.l	d0,(Object_manager_2P_RAM+.c).w
.c := .c+4
	endm

	if (Object_manager_2P_RAM_End-Object_manager_2P_RAM)&2
		move.w	d0,(Object_manager_2P_RAM+.c).w
.c := .c+2
	endif

	if (Object_manager_2P_RAM_End-Object_manager_2P_RAM)&1
		move.b	d0,(Object_manager_2P_RAM+.c).w
	endif
		move.w	#0,(Camera_X_pos_last).w
		move.w	#0,(Camera_X_pos_last_P2).w
		lea	(v_objstate).w,a2
		move.w	(a2),(Obj_respawn_index_P2).w
		moveq	#0,d2
		lea	(v_objstate).w,a5
		lea	(Obj_load_addr_right).w,a4
		lea	(Player_1_loaded_object_blocks).w,a1
		lea	(Player_2_loaded_object_blocks).w,a6
		moveq	#-2,d6
		bsr.w	sub_DF80
		lea	(Player_1_loaded_object_blocks).w,a1
		moveq	#-1,d6
		bsr.w	sub_DF80
		lea	(Player_1_loaded_object_blocks).w,a1
		moveq	#0,d6
		bsr.w	sub_DF80
		lea	(Obj_respawn_index_P2).w,a5
		lea	(Obj_load_addr_right_P2).w,a4
		lea	(Player_2_loaded_object_blocks).w,a1
		lea	(Player_1_loaded_object_blocks).w,a6
		moveq	#-2,d6
		bsr.w	sub_DF80
		lea	(Player_2_loaded_object_blocks).w,a1
		moveq	#-1,d6
		bsr.w	sub_DF80
		lea	(Player_2_loaded_object_blocks).w,a1
		moveq	#0,d6
		bsr.w	sub_DF80

; loc_DE5C
ObjectsManager_2P_Main:
		move.w	(Camera_X_pos).w,d1
		andi.w	#-$100,d1
		move.w	d1,(Camera_X_pos_coarse).w
		move.w	(Camera_X_pos_P2).w,d1
		andi.w	#-$100,d1
		move.w	d1,(Camera_X_pos_coarse_P2).w
		move.b	(Camera_X_pos).w,d6
		andi.w	#$FF,d6
		move.w	(Camera_X_pos_last).w,d0
		cmp.w	(Camera_X_pos_last).w,d6
		beq.s	loc_DE9C
		move.w	d6,(Camera_X_pos_last).w
		lea	(v_objstate).w,a5
		lea	(Obj_load_addr_right).w,a4
		lea	(Player_1_loaded_object_blocks).w,a1
		lea	(Player_2_loaded_object_blocks).w,a6
		bsr.s	sub_DED2

loc_DE9C:
		move.b	(Camera_X_pos_P2).w,d6
		andi.w	#$FF,d6
		move.w	(Camera_X_pos_last_P2).w,d0
		cmp.w	(Camera_X_pos_last_P2).w,d6
		beq.s	loc_DEC4
		move.w	d6,(Camera_X_pos_last_P2).w
		lea	(Obj_respawn_index_P2).w,a5
		lea	(Obj_load_addr_right_P2).w,a4
		lea	(Player_2_loaded_object_blocks).w,a1
		lea	(Player_1_loaded_object_blocks).w,a6
		bsr.s	sub_DED2

loc_DEC4:
		move.w	(v_objstate).w,(v_objstate_debug).w
		move.w	(Obj_respawn_index_P2).w,(Obj_respawn_index_P2_debug).w
		rts
; ===========================================================================

sub_DED2:
		lea	(v_objstate).w,a2
		moveq	#0,d2
		cmp.w	d0,d6
		beq.w	locret_DDDE
		bge.w	sub_DF80
		move.b	2(a1),d2
		move.b	1(a1),2(a1)
		move.b	(a1),1(a1)
		move.b	d6,(a1)
		cmp.b	(a6),d2
		beq.s	loc_DF08
		cmp.b	1(a6),d2
		beq.s	loc_DF08
		cmp.b	2(a6),d2
		beq.s	loc_DF08
		bsr.w	sub_E062
		bra.s	loc_DF0C
; ===========================================================================

loc_DF08:
		bsr.w	sub_E026

loc_DF0C:
		bsr.w	sub_E002
		bne.s	loc_DF30
		movea.l	4(a4),a0

loc_DF16:
		cmp.b	-6(a0),d6
		bne.s	loc_DF2A
		tst.b	-2(a0)
		bpl.s	loc_DF26
		subq.b	#1,1(a5)

loc_DF26:
		subq.w	#6,a0
		bra.s	loc_DF16
; ===========================================================================

loc_DF2A:
		move.l	a0,4(a4)
		bra.s	loc_DF66
; ===========================================================================

loc_DF30:
		movea.l	4(a4),a0
		move.b	d6,(a1)

loc_DF36:
		cmp.b	-6(a0),d6
		bne.s	loc_DF62
		subq.w	#6,a0
		tst.b	4(a0)
		bpl.s	loc_DF4C
		subq.b	#1,1(a5)
		move.b	1(a5),d2

loc_DF4C:
		bsr.w	sub_E122
		bne.s	loc_DF56
		subq.w	#6,a0
		bra.s	loc_DF36
; ===========================================================================

loc_DF56:
		tst.b	4(a0)
		bpl.s	loc_DF60
		addq.b	#1,1(a5)

loc_DF60:
		addq.w	#6,a0

loc_DF62:
		move.l	a0,4(a4)

loc_DF66:
		movea.l	(a4),a0
		addq.w	#3,d6

loc_DF6A:
		cmp.b	-6(a0),d6
		bne.s	loc_DF7C
		tst.b	-2(a0)
		bpl.s	loc_DF78
		subq.b	#1,(a5)

loc_DF78:
		subq.w	#6,a0
		bra.s	loc_DF6A
; ===========================================================================

loc_DF7C:
		move.l	a0,(a4)
		rts
; ===========================================================================

sub_DF80:
		addq.w	#2,d6
		move.b	(a1),d2
		move.b	1(a1),(a1)
		move.b	2(a1),1(a1)
		move.b	d6,2(a1)
		cmp.b	(a6),d2
		beq.s	loc_DFA8
		cmp.b	1(a6),d2
		beq.s	loc_DFA8
		cmp.b	2(a6),d2
		beq.s	loc_DFA8
		bsr.w	sub_E062
		bra.s	loc_DFAC
; ===========================================================================

loc_DFA8:
		bsr.w	sub_E026

loc_DFAC:
		bsr.w	sub_E002
		bne.s	loc_DFC8
		movea.l	(a4),a0

loc_DFB4:
		cmp.b	(a0),d6
		bne.s	loc_DFC4
		tst.b	4(a0)
		bpl.s	loc_DFC0
		addq.b	#1,(a5)

loc_DFC0:
		addq.w	#6,a0
		bra.s	loc_DFB4
; ===========================================================================

loc_DFC4:
		move.l	a0,(a4)
		bra.s	loc_DFE2
; ===========================================================================

loc_DFC8:
		movea.l	(a4),a0
		move.b	d6,(a1)

loc_DFCC:
		cmp.b	(a0),d6
		bne.s	loc_DFE0
		tst.b	4(a0)
		bpl.s	loc_DFDA
		move.b	(a5),d2
		addq.b	#1,(a5)

loc_DFDA:
		bsr.w	sub_E122
		beq.s	loc_DFCC

loc_DFE0:
		move.l	a0,(a4)

loc_DFE2:
		movea.l	4(a4),a0
		subq.w	#3,d6
		blo.s	loc_DFFC

loc_DFEA:
		cmp.b	(a0),d6
		bne.s	loc_DFFC
		tst.b	4(a0)
		bpl.s	loc_DFF8
		addq.b	#1,1(a5)

loc_DFF8:
		addq.w	#6,a0
		bra.s	loc_DFEA
; ===========================================================================

loc_DFFC:
		move.l	a0,4(a4)
		rts
; End of function sub_DF80


; =============== S U B	R O U T	I N E =======================================


sub_E002:
		move.l	a1,-(sp)
		lea	(Object_RAM_block_indices).w,a1
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		cmp.b	(a1)+,d6
		beq.s	loc_E022
		moveq	#1,d0

loc_E022:
		movea.l	(sp)+,a1
		rts
; End of function sub_E002


; =============== S U B	R O U T	I N E =======================================


sub_E026:
		lea	(Object_RAM_block_indices).w,a1
		; Check block 1.
		lea	(Dynamic_Object_RAM_2P_End+(12*0)*object_size).w,a3
		tst.b	(a1)+
		bmi.s	.foundBlock
		; Check block 2.
		lea	(Dynamic_Object_RAM_2P_End+(12*1)*object_size).w,a3
		tst.b	(a1)+
		bmi.s	.foundBlock
		; Check block 3.
		lea	(Dynamic_Object_RAM_2P_End+(12*2)*object_size).w,a3
		tst.b	(a1)+
		bmi.s	.foundBlock
		; Check block 4.
		lea	(Dynamic_Object_RAM_2P_End+(12*3)*object_size).w,a3
		tst.b	(a1)+
		bmi.s	.foundBlock
		; Check block 5.
		lea	(Dynamic_Object_RAM_2P_End+(12*4)*object_size).w,a3
		tst.b	(a1)+
		bmi.s	.foundBlock
		; Check block 6.
		lea	(Dynamic_Object_RAM_2P_End+(12*5)*object_size).w,a3
		tst.b	(a1)+
		bmi.s	.foundBlock
		; This code should never be reached.
		nop
		nop

.foundBlock:
		; Rewind a little so that 'a1' points to the object block index that we found.
		subq.w	#1,a1
		rts
; End of function sub_E026


; =============== S U B	R O U T	I N E =======================================


sub_E062:
		; Find which object block holds this object block index.
		lea	(Object_RAM_block_indices).w,a1
		; Check block 1.
		lea	(Dynamic_Object_RAM_2P_End+(12*0)*object_size).w,a3
		cmp.b	(a1)+,d2
		beq.s	.foundBlock
		; Check block 2.
		lea	(Dynamic_Object_RAM_2P_End+(12*1)*object_size).w,a3
		cmp.b	(a1)+,d2
		beq.s	.foundBlock
		; Check block 3.
		lea	(Dynamic_Object_RAM_2P_End+(12*2)*object_size).w,a3
		cmp.b	(a1)+,d2
		beq.s	.foundBlock
		; Check block 4.
		lea	(Dynamic_Object_RAM_2P_End+(12*3)*object_size).w,a3
		cmp.b	(a1)+,d2
		beq.s	.foundBlock
		; Check block 5.
		lea	(Dynamic_Object_RAM_2P_End+(12*4)*object_size).w,a3
		cmp.b	(a1)+,d2
		beq.s	.foundBlock
		; Check block 6.
		lea	(Dynamic_Object_RAM_2P_End+(12*5)*object_size).w,a3
		cmp.b	(a1)+,d2
		beq.s	.foundBlock
		; This code should never be reached.
		nop
		nop

.foundBlock:
		; Mark this object block as empty.
		move.b	#-1,-(a1)
		movem.l	a1/a3,-(sp)
		moveq	#0,d1
		moveq	#$C-1,d2

loc_E0A6:
		tst.b	(a3)
		beq.s	loc_E0C2
		movea.l	a3,a1
		moveq	#0,d0
		move.b	obRespawnNo(a1),d0
		beq.s	loc_E0BA
		bclr	#7,2(a2,d0.w)

loc_E0BA:
		moveq	#$10-1,d0

loc_E0BC:
		move.l	d1,(a1)+
		dbf	d0,loc_E0BC

loc_E0C2:
		lea	object_size(a3),a3
		dbf	d2,loc_E0A6
		moveq	#0,d2
		movem.l	(sp)+,a1/a3
		rts
; End of function sub_E062


; =============== S U B	R O U T	I N E =======================================


sub_E0D2:
		tst.b	4(a0)
		bpl.s	loc_E0E6
		bset	#7,2(a2,d2.w)
		beq.s	loc_E0E6
		addq.w	#6,a0
		moveq	#0,d0
		rts
; ---------------------------------------------------------------------------

loc_E0E6:
		bsr.w	FindFreeObj
		bne.s	locret_E120
		move.w	(a0)+,obX(a1)
		move.w	(a0)+,d0
		move.w	d0,d1
		andi.w	#$FFF,d0
		move.w	d0,obY(a1)
		rol.w	#2,d1
		andi.b	#3,d1
		move.b	d1,obRender(a1)
		move.b	d1,obStatus(a1)
		move.b	(a0)+,d0
		bpl.s	loc_E116
		andi.b	#$7F,d0
		move.b	d2,obRespawnNo(a1)

loc_E116:
		_move.b	d0,obID(a1)
		move.b	(a0)+,obSubtype(a1)
		moveq	#0,d0

locret_E120:
		rts
; End of function sub_E0D2


; =============== S U B	R O U T	I N E =======================================


sub_E122:
		tst.b	4(a0)
		bpl.s	loc_E136
		bset	#7,2(a2,d2.w)
		beq.s	loc_E136
		addq.w	#6,a0
		moveq	#0,d0
		rts
; ---------------------------------------------------------------------------

loc_E136:
		btst	#5,obGfx(a0)
		beq.s	loc_E146
		bsr.w	FindFreeObj
		bne.s	locret_E180
		bra.s	loc_E14C
; ---------------------------------------------------------------------------

loc_E146:
		bsr.w	FindFreeObj3
		bne.s	locret_E180

loc_E14C:
		move.w	(a0)+,obX(a1)
		move.w	(a0)+,d0
		move.w	d0,d1
		andi.w	#$FFF,d0
		move.w	d0,obY(a1)
		rol.w	#2,d1
		andi.b	#3,d1
		move.b	d1,obRender(a1)
		move.b	d1,obStatus(a1)
		move.b	(a0)+,d0
		bpl.s	loc_E176
		andi.b	#$7F,d0
		move.b	d2,obRespawnNo(a1)

loc_E176:
		_move.b	d0,obID(a1)
		move.b	(a0)+,obSubtype(a1)
		moveq	#0,d0

locret_E180:
		rts
; End of function sub_E122

; ===========================================================================
; ---------------------------------------------------------------------------
; Single object loading subroutine
; Find an empty object array
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_E182: SingleObjectLoad:
FindFreeObj:
		lea	(v_lvlobjspace).w,a1		; a1=object
		move.w	#bytesToXcnt(v_lvlobjend-v_lvlobjspace,object_size),d0	; search to end of table

loc_E18A:
		tst.b	obID(a1)			; is object RAM slot empty?
		beq.s	locret_E196			; if yes, branch
		lea	object_size(a1),a1		; load obj address ; goto next object RAM slot
		dbf	d0,loc_E18A			; repeat until end

locret_E196:
		rts
; End of function FindFreeObj

; ===========================================================================
; ---------------------------------------------------------------------------
; Single object loading subroutine
; Find an empty object array AFTER the current one in the table
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_E198: S1SingleObjectLoad2:
FindNextFreeObj:
		movea.l	a0,a1
		move.w	#v_lvlobjend,d0
		sub.w	a0,d0				; subtract current object location
		lsr.w	#object_size_bits,d0		; divide by $40
		subq.w	#1,d0				; keep from going over the object zone
		blo.s	locret_E1B2

loc_E1A6:
		tst.b	obID(a1)			; is object RAM slot empty?
		beq.s	locret_E1B2			; if yes, branch
		lea	object_size(a1),a1		; load obj address ; goto next object RAM slot
		dbf	d0,loc_E1A6			; repeat until end

locret_E1B2:
		rts
; End of function FindNextFreeObj

; ===========================================================================
; ---------------------------------------------------------------------------
; Single object loading subroutine
; Find an empty object at or within < 12 slots after a3
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_E1B4:
FindFreeObj3:
		movea.l	a3,a1
		move.w	#$C-1,d0

loc_E1BA:
		tst.b	obID(a1)			; is object RAM slot empty?
		beq.s	locret_E1C6			; if yes, branch
		lea	object_size(a1),a1		; load obj address ; goto next object RAM slot
		dbf	d0,loc_E1BA			; repeat until end

locret_E1C6:
		rts
; End of function FindFreeObj3

		include	"obj/41 Springs.asm"
; ===========================================================================
; byte_E934:
Obj41_SlopeData_DiagUp:
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b $10,$10,$10,$10
		dc.b  $E, $C, $A,  8
		dc.b   6,  4,  2,  0
		dc.b $FE,$FC,$FC,$FC
		dc.b $FC,$FC,$FC,$FC
		even

; byte_E950:
Obj41_SlopeData_DiagDown:
		dc.b $F4,$F0,$F0,$F0
		dc.b $F0,$F0,$F0,$F0
		dc.b $F0,$F0,$F0,$F0
		dc.b $F2,$F4,$F6,$F8
		dc.b $FA,$FC,$FE,  0
		dc.b   2,  4,  4,  4
		dc.b   4,  4,  4,  4
		even

; animation script
Ani_obj41:	dc.w byte_E978-Ani_obj41
		dc.w byte_E97B-Ani_obj41
		dc.w byte_E987-Ani_obj41
		dc.w byte_E98A-Ani_obj41
		dc.w byte_E996-Ani_obj41
		dc.w byte_E999-Ani_obj41
byte_E978:	dc.b  $F,  0,$FF
byte_E97B:	dc.b   0,  1,  0,  0,  2,  2,  2,  2
		dc.b   2,  2,$FD,  0
byte_E987:	dc.b  $F,  3,$FF
byte_E98A:	dc.b   0,  4,  3,  3,  5,  5,  5,  5
		dc.b   5,  5,$FD,  2
byte_E996:	dc.b  $F,  7,$FF
byte_E999:	dc.b   0,  8,  7,  7,  9,  9,  9,  9
		dc.b   9,  9,$FD,  4
		even


; ----------------------------------------------------------------------------
; Sprite mappings - GHZ springs
; ----------------------------------------------------------------------------
Map_obj41_GHZ:	binclude	"mappings/sprite/obj41_GHZ.bin"
		even
; ----------------------------------------------------------------------------
; Primary sprite mappings for springs
; ----------------------------------------------------------------------------
Map_obj41:	dc.w word_EA4A-Map_obj41
		dc.w word_EA5C-Map_obj41
		dc.w word_EA66-Map_obj41
		dc.w word_EA78-Map_obj41
		dc.w word_EA8A-Map_obj41
		dc.w word_EA94-Map_obj41
		dc.w word_EAA6-Map_obj41
		dc.w word_EAB8-Map_obj41
		dc.w word_EADA-Map_obj41
		dc.w word_EAF4-Map_obj41
		dc.w word_EB16-Map_obj41
; -------------------------------------------------------------------------------
; Secondary sprite mappings for springs
; merged with the above mappings; can't split to file in a useful way...
; -------------------------------------------------------------------------------
Map_obj41a:	dc.w word_EA4A-Map_obj41a
		dc.w word_EA5C-Map_obj41a
		dc.w word_EA66-Map_obj41a
		dc.w word_EA78-Map_obj41a
		dc.w word_EA8A-Map_obj41a
		dc.w word_EA94-Map_obj41a
		dc.w word_EAA6-Map_obj41a
		dc.w word_EB38-Map_obj41a
		dc.w word_EB5A-Map_obj41a
		dc.w word_EB74-Map_obj41a
		dc.w word_EB96-Map_obj41a
word_EA4A:	dc.w 2
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 5,    8,    4,$FFF8
word_EA5C:	dc.w 1
		dc.w $F80D,    0,    0,$FFF0
word_EA66:	dc.w 2
		dc.w $E00D,    0,    0,$FFF0
		dc.w $F007,   $C,    6,$FFF8
word_EA78:	dc.w 2
		dc.w $F003,    0,    0,	   0
		dc.w $F801,    4,    2,$FFF8
word_EA8A:	dc.w 1
		dc.w $F003,    0,    0,$FFF8
word_EA94:	dc.w 2
		dc.w $F003,    0,    0,	 $10
		dc.w $F809,    6,    3,$FFF8
word_EAA6:	dc.w 2
		dc.w	$D,$1000,$1000,$FFF0
		dc.w $F005,$1008,$1004,$FFF8
word_EAB8:	dc.w 4
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 5,    8,    4,	   0
		dc.w $FB05,   $C,    6,$FFF6
		dc.w	 5,$201C,$200E,$FFF0
word_EADA:	dc.w 3
		dc.w $F60D,    0,    0,$FFEA
		dc.w  $605,    8,    4,$FFFA
		dc.w	 5,$201C,$200E,$FFF0
word_EAF4:	dc.w 4
		dc.w $E60D,    0,    0,$FFFB
		dc.w $F605,    8,    4,	  $B
		dc.w $F30B,  $10,    8,$FFF6
		dc.w	 5,$201C,$200E,$FFF0
word_EB16:	dc.w 4
		dc.w	$D,$1000,$1000,$FFF0
		dc.w $F005,$1008,$1004,	   0
		dc.w $F505,$100C,$1006,$FFF6
		dc.w $F005,$301C,$300E,$FFF0
word_EB38:	dc.w 4
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 5,    8,    4,	   0
		dc.w $FB05,   $C,    6,$FFF6
		dc.w	 5,  $1C,   $E,$FFF0
word_EB5A:	dc.w 3
		dc.w $F60D,    0,    0,$FFEA
		dc.w  $605,    8,    4,$FFFA
		dc.w	 5,  $1C,   $E,$FFF0
word_EB74:	dc.w 4
		dc.w $E60D,    0,    0,$FFFB
		dc.w $F605,    8,    4,	  $B
		dc.w $F30B,  $10,    8,$FFF6
		dc.w	 5,  $1C,   $E,$FFF0
word_EB96:	dc.w 4
		dc.w	$D,$1000,$1000,$FFF0
		dc.w $F005,$1008,$1004,	   0
		dc.w $F505,$100C,$1006,$FFF6
		dc.w $F005,$101C,$100E,$FFF0

		include	"obj/S1/42 Newtron.asm"
; ===========================================================================
; animation script
Ani_obj42:	dc.w byte_ED7C-Ani_obj42
		dc.w byte_ED7F-Ani_obj42
		dc.w byte_ED87-Ani_obj42
		dc.w byte_ED8B-Ani_obj42
		dc.w byte_ED8F-Ani_obj42
byte_ED7C:	dc.b  $F, $A,$FF
byte_ED7F:	dc.b $13,  0,  1,  3,  4,  5,$FE,  1
byte_ED87:	dc.b   2,  6,  7,$FF
byte_ED8B:	dc.b   2,  8,  9,$FF
byte_ED8F:	dc.b $13,  0,  1,  1,  2,  1,  1,  0
		dc.b $FC
		even
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj42:	binclude	"mappings/sprite/S1/obj42.bin"
		even

		include	"obj/S1/44 GHZ Edge Walls.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj44:	binclude	"mappings/sprite/S1/obj44.bin"
		even

		include	"obj/0D Signpost.asm"
; ===========================================================================
; animation script
; off_F18C:
Ani_obj0D:	dc.w byte_F194-Ani_obj0D
		dc.w byte_F197-Ani_obj0D
		dc.w byte_F1A5-Ani_obj0D
		dc.w byte_F1B3-Ani_obj0D
byte_F194:	dc.b  $F,  2,$FF
byte_F197:	dc.b   1,  2,  3,  4,  5,  1,  3,  4
		dc.b   5,  0,  3,  4,  5,$FF
byte_F1A5:	dc.b   1,  2,  3,  4,  5,  1,  3,  4
		dc.b   5,  0,  3,  4,  5,$FF
byte_F1B3:	dc.b  $F,  0,$FF
		even

; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_obj0D:	include	"mappings/sprite/obj0D.asm"
; ===========================================================================
		jmpTos	; Empty
; ===========================================================================

		include	"obj/S1/40 Moto Bug.asm"
; ===========================================================================
; animation script
Ani_obj40:	dc.w byte_F386-Ani_obj40
		dc.w byte_F389-Ani_obj40
		dc.w byte_F38F-Ani_obj40
byte_F386:	dc.b  $F,  2,$FF
byte_F389:	dc.b   7,  0,  1,  0,  2,$FF
byte_F38F:	dc.b   1,  3,  6,  3,  6,  4,  6,  4
		dc.b   6,  4,  6,  5,$FC
		even

; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_obj40:	binclude	"mappings/sprite/S1/obj40.bin"
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Solid object subroutines (includes spikes, blocks, rocks etc)
; These check collision of Sonic/Tails with objects on the screen
;
; input variables:
; d1 = object width
; d2 = object height / 2 (when jumping)
; d3 = object height / 2 (when walking)
; d4 = object x-axis position
;
; address registers:
; a0 = the object to check collision with
; a1 = sonic or tails (set inside these subroutines)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


SolidObject:
		lea	(v_player).w,a1			; a1=character
		moveq	#3,d6
		movem.l	d1-d4,-(sp)			; store input registers
		bsr.s	sub_F456			; first collision check with Sonic
		movem.l	(sp)+,d1-d4			; restore input registers
		lea	(v_player2).w,a1		; a1=character ; now check collision with Tails
		tst.b	obRender(a1)
		bpl.w	locret_F490			; return if not Tails
		addq.b	#1,d6

sub_F456:
		btst	d6,obStatus(a0)
		beq.w	SolidObject_OnScreenTest
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F47A
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F47A
		cmp.w	d2,d0
		blo.s	loc_F488

loc_F47A:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------
loc_F488:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4

locret_F490:
		rts
; End of function SolidObject

; ===========================================================================
; alternate function to check for collision even if off-screen, unused
; in this build...
; SolidObject_Always:
		lea	(v_player).w,a1			; a1=character
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	SolidObject_Always_SingleCharacter
		movem.l	(sp)+,d1-d4
		lea	(v_player2).w,a1		; a1=character
		addq.b	#1,d6
; loc_F4A8:
SolidObject_Always_SingleCharacter:
		btst	d6,obStatus(a0)
		beq.w	SolidObject_cont
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F4CC
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F4CC
		cmp.w	d2,d0
		blo.s	loc_F4DA

loc_F4CC:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_F4DA:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts
; End of function SolidObject_Always

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to collide Sonic/Tails with the top of a sloped
; solid like diagonal springs; unused in this build...
;
; input variables:
; d1 = object width
; d2 = object height / 2 (when jumping)
; d3 = object height / 2 (when walking)
; d4 = object x-axis position
;
; address registers:
; a0 = the object to check collision with
; a1 = sonic or tails (set inside these subroutines)
; a2 = height data for slope
; ---------------------------------------------------------------------------
		lea	(v_player).w,a1			; a1=character
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	SlopedSolid_SingleCharacter
		movem.l	(sp)+,d1-d4
		lea	(v_player2).w,a1		; a1=character
		addq.b	#1,d6
; loc_F4FA:
SlopedSolid_SingleCharacter:
		btst	d6,obStatus(a0)
		beq.w	SlopedSolid_cont
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F51E
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F51E
		cmp.w	d2,d0
		blo.s	loc_F52C

loc_F51E:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_F52C:
		move.w	d4,d2
		bsr.w	sub_F748
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------
; loc_F536:
SlopedSolid_cont:
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	SolidObject_TestClearPush
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	SolidObject_TestClearPush
		move.w	d0,d5
		btst	#0,obRender(a0)
		beq.s	loc_F55C
		not.w	d5
		add.w	d3,d5

loc_F55C:
		lsr.w	#1,d5
		move.b	(a2,d5.w),d3
		sub.b	(a2),d3
		ext.w	d3
		move.w	obY(a0),d5
		sub.w	d3,d5
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3
		sub.w	d5,d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	SolidObject_TestClearPush
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.w	SolidObject_TestClearPush
		bra.w	SolidObject_ChkBounds
; ===========================================================================
; loc_F590:
SolidObject_OnScreenTest:
		tst.b	obRender(a0)
		bpl.w	SolidObject_TestClearPush
; loc_F598:
SolidObject_cont:
		; We now perform the x portion of a bounding box check.  To do this, we assume a
		; coordinate system where the x origin is at the object's left edge.
		move.w	obX(a1),d0			; load Sonic's x position...
		sub.w	obX(a0),d0			; ... and calculate his x position relative to the object
		add.w	d1,d0				; assume object's left edge is at (0,0).  This is also Sonic's distance to the object's left edge.
		bmi.w	SolidObject_TestClearPush	; branch, if Sonic is outside the object's left edge
		move.w	d1,d3
		add.w	d3,d3				; calculate object's width
		cmp.w	d3,d0
		bhi.w	SolidObject_TestClearPush	; branch, if Sonic is outside the object's right edge
		; We now perform the y portion of a bounding box check.  To do this, we assume a
		; coordinate system where the y origin is at the highest y position relative to the object
		; at which Sonic would still collide with it.  This point is
		;   y_pos(object) - width(object)/2 - y_radius(Sonic) - 4,
		; where object is stored in (a0), Sonic in (a1), and height(object)/2 in d2.  This way
		; of doing it causes the object's hitbox to be vertically off-center by -4 pixels.
		move.b	obHeight(a1),d3			; load Sonic's y radius
		ext.w	d3
		add.w	d3,d2				; calculate maximum distance for a top collision
		move.w	obY(a1),d3			; load Sonic's y position
		sub.w	obY(a0),d3			; ... and calculate his y position relative to the object
		addq.w	#4,d3				; assume a slightly lower position for Sonic
		add.w	d2,d3				; assume the highest position where Sonic would still be colliding with the object to be (0,0)
		bmi.w	SolidObject_TestClearPush	; branch, if Sonic is above this point
		move.w	d2,d4
		add.w	d4,d4				; calculate minimum distance for a bottom collision
		cmp.w	d4,d3
		bhs.w	SolidObject_TestClearPush	; branch, if Sonic is below this point
; loc_F5D2:
SolidObject_ChkBounds:
		tst.b	(f_playerctrl).w
		bmi.w	SolidObject_TestClearPush	; branch, if object collisions are disabled for Sonic
		cmpi.b	#6,obRoutine(a1)		; is Sonic dead?
		bhs.w	loc_F680			; if yes, branch
		tst.w	(Debug_placement_mode).w
		bne.w	loc_F680			; branch, if in Debug Mode

		move.w	d0,d5
		cmp.w	d0,d1
		bhs.s	loc_F5FA			; branch, if Sonic is to the object's left
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5				; calculate Sonic's distance to the object's right edge...
		neg.w	d5				; ... and calculate the absolute value

loc_F5FA:
		move.w	d3,d1
		cmp.w	d3,d2
		bhs.s	loc_F608
		subq.w	#4,d3
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

loc_F608:
		cmp.w	d1,d5
		bhi.w	loc_F684			; branch, if horizontal distance is greater than vertical distance

		cmpi.w	#4,d1
		bls.s	loc_F65A
		tst.w	d0
		beq.s	loc_F634
		bmi.s	loc_F622
		tst.w	obVelX(a1)
		bmi.s	loc_F634
		bra.s	loc_F628
; ===========================================================================

loc_F622:
		tst.w	obVelX(a1)
		bpl.s	loc_F634

loc_F628:
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)

loc_F634:
		sub.w	d0,obX(a1)
		btst	#1,obStatus(a1)
		bne.s	loc_F65A
		move.l	d6,d4
		addq.b	#2,d4				; Character is pushing, not standing
		bset	d4,obStatus(a0)
		bset	#5,obStatus(a1)
		move.w	d6,d4
		addi.b	#$D,d4
		bset	d4,d6				; This sets bits 0 (Sonic) or 1 (Tails) of high word of d6
		moveq	#1,d4
		rts
; ===========================================================================

loc_F65A:
		bsr.s	Solid_NotPushing
		move.w	d6,d4
		addi.b	#$D,d4
		bset	d4,d6				; This sets bits 0 (Sonic) or 1 (Tails) of high word of d6
		moveq	#1,d4
		rts
; ===========================================================================
; loc_F668:
SolidObject_TestClearPush:
		move.l	d6,d4
		addq.b	#2,d4
		btst	d4,obStatus(a0)
		beq.s	loc_F680
	if FixBugs
		; Prevent Sonic or Tails from entering their running animation when
		; stood next to solid objects while charging a Spin Dash, dying,
		; drowning, or rolling.
		cmpi.b	#AniIDSonAni_Roll,obAnim(a1)
		beq.s	Solid_NotPushing
		cmpi.b	#AniIDSonAni_Spindash,obAnim(a1)
		beq.s	Solid_NotPushing
		cmpi.b	#AniIDSonAni_Death,obAnim(a1)
		beq.s	Solid_NotPushing
		cmpi.b	#AniIDSonAni_Drown,obAnim(a1)
		beq.s	Solid_NotPushing
	endif
		move.w	#(AniIDSonAni_Walk)<<8+AniIDSonAni_Run,obAnim(a1)	; and obPrevAni

Solid_NotPushing:
		move.l	d6,d4
		addq.b	#2,d4
		bclr	d4,obStatus(a0)

loc_F680:
		moveq	#0,d4
		rts
; ===========================================================================

loc_F684:
		tst.w	d3
		bmi.s	loc_F690
		cmpi.w	#$10,d3
		blo.s	loc_F6D2
		bra.s	SolidObject_TestClearPush
; ===========================================================================

loc_F690:
		tst.w	obVelY(a1)
		beq.s	loc_F6B2
		bpl.s	loc_F6A6
		tst.w	d3
		bpl.s	loc_F6A6
	if FixBugs=0
		; This is in the wrong place: Sonic will not be pushed out of objects
		; from above if he's not moving upwards against it!
		; This is much more noticable when playing as Knuckles, as he'll be
		; able to phase through objects when climbing up walls.
		; 'Knuckles in Sonic 2' and 'Sonic 3 & Knuckles' tried to fix this,
		; but didn't do it very well.
		sub.w	d3,obY(a1)
	endif
		move.w	#0,obVelY(a1)

loc_F6A6:
	if FixBugs
		; See above.
		sub.w	d3,obY(a1)		; Push Sonic out of the object.
	endif
		move.w	d6,d4
		addi.b	#$F,d4
		bset	d4,d6				; This sets bits 2 (Sonic) or 3 (Tails) of high word of d6
		moveq	#-2,d4
		rts
; ===========================================================================

loc_F6B2:
		btst	#1,obStatus(a1)
		bne.s	loc_F6A6
		move.l	a0,-(sp)
	if FixBugs
		; a2 needs to be set here, otherwise KillCharacter
		; will access a dangling pointer!
		movea.l	a0,a2
	endif
		movea.l	a1,a0
		jsr	(KillCharacter).l
		movea.l	(sp)+,a0			; load obj address
		move.w	d6,d4
		addi.b	#$F,d4
		bset	d4,d6				; This sets bits 2 (Sonic) or 3 (Tails) of high word of d6
		moveq	#-2,d4
		rts
; ===========================================================================

loc_F6D2:
		subq.w	#4,d3
		moveq	#0,d1
		move.b	obActWid(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	obX(a1),d1
		sub.w	obX(a0),d1
		bmi.s	loc_F70A
		cmp.w	d2,d1
		bhs.s	loc_F70A
		tst.w	obVelY(a1)
		bmi.s	loc_F70A
		sub.w	d3,obY(a1)
		subq.w	#1,obY(a1)
		bsr.w	RideObject_SetRide
		move.w	d6,d4
		addi.b	#$11,d4
		bset	d4,d6				; This sets bits 4 (Sonic) or 5 (Tails) of high word of d6
		moveq	#-1,d4
		rts
; ===========================================================================

loc_F70A:
		moveq	#0,d4
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_F70E:
MvSonicOnPtfm:
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.s	loc_F71E
; ===========================================================================
; a couple lines of unused/leftover/dead code from Sonic 1 ; a0=object
		move.w	obY(a0),d0
		subi.w	#9,d0

loc_F71E:
		tst.b	(f_playerctrl).w
		bmi.s	locret_F746
		cmpi.b	#6,obRoutine(a1)
		bhs.s	locret_F746
		tst.w	(Debug_placement_mode).w
		bne.s	locret_F746
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)

locret_F746:
		rts
; End of function MvSonicOnPtfm


; =============== S U B	R O U T	I N E =======================================


sub_F748:
		btst	#3,obStatus(a1)
		beq.s	locret_F788
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		lsr.w	#1,d0
		btst	#0,obRender(a0)
		beq.s	loc_F768
		not.w	d0
		add.w	d1,d0

loc_F768:
		move.b	(a2,d0.w),d1
		ext.w	d1
		move.w	obY(a0),d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)

locret_F788:
		rts
; End of function sub_F748


; =============== S U B	R O U T	I N E =======================================


sub_F78A:
		lea	(v_player).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	sub_F7A0
		movem.l	(sp)+,d1-d4
		lea	(v_player2).w,a1
		addq.b	#1,d6
; End of function sub_F78A


; =============== S U B	R O U T	I N E =======================================


sub_F7A0:
		btst	d6,obStatus(a0)
		beq.w	loc_F89E
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F7C4
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F7C4
		cmp.w	d2,d0
		blo.s	loc_F7D2

loc_F7C4:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_F7D2:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts
; End of function sub_F7A0


; =============== S U B	R O U T	I N E =======================================


sub_F7DC:
		lea	(v_player).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	sub_F7F2
		movem.l	(sp)+,d1-d4
		lea	(v_player2).w,a1
		addq.b	#1,d6
; End of function sub_F7DC


; =============== S U B	R O U T	I N E =======================================


sub_F7F2:
		btst	d6,obStatus(a0)
		beq.w	SlopedPlatform_cont
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F816
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F816
		cmp.w	d2,d0
		blo.s	loc_F824

loc_F816:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_F824:
		move.w	d4,d2
		bsr.w	sub_F748
		moveq	#0,d4
		rts
; End of function sub_F7F2


; =============== S U B	R O U T	I N E =======================================


sub_F82E:
		lea	(v_player).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	sub_F844
		movem.l	(sp)+,d1-d4
		lea	(v_player2).w,a1
		addq.b	#1,d6
; End of function sub_F82E


; =============== S U B	R O U T	I N E =======================================


sub_F844:
		btst	d6,obStatus(a0)
		beq.w	loc_F9A0
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	loc_F868
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F868
		cmp.w	d2,d0
		blo.s	loc_F876

loc_F868:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_F876:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts
; End of function sub_F844


; =============== S U B	R O U T	I N E =======================================


sub_F880:
		tst.w	obVelY(a1)
		bmi.w	locret_F966
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	locret_F966
		cmp.w	d2,d0
		bhs.w	locret_F966
		bra.s	loc_F8BC
; ---------------------------------------------------------------------------

loc_F89E:
		tst.w	obVelY(a1)
		bmi.w	locret_F966
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	locret_F966
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	locret_F966

loc_F8BC:
		move.w	obY(a0),d0
		sub.w	d3,d0

loc_F8C2:
		move.w	obY(a1),d2
		move.b	obHeight(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.w	locret_F966
		cmpi.w	#-$10,d0
		blo.w	locret_F966
		tst.b	(f_playerctrl).w
		bmi.w	locret_F966
		cmpi.b	#6,obRoutine(a1)
		bhs.w	locret_F966
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,obY(a1)
; sub_F8F8:
RideObject_SetRide:
		btst	#3,obStatus(a1)
		beq.s	loc_F916
		moveq	#0,d0
		move.b	standonobject(a1),d0
		lsl.w	#object_size_bits,d0
		addi.l	#v_objspace,d0
		movea.l	d0,a3
		bclr	#3,obStatus(a3)

loc_F916:
		move.w	a0,d0
		subi.w	#v_objspace,d0
		lsr.w	#object_size_bits,d0
		andi.w	#$7F,d0
		move.b	d0,standonobject(a1)
		move.b	#0,obAngle(a1)
		move.w	#0,obVelY(a1)
		move.w	obVelX(a1),obInertia(a1)
		btst	#1,obStatus(a1)
		beq.s	loc_F95C
		move.l	a0,-(sp)
		movea.l	a1,a0
		move.w	a0,d1
		subi.w	#v_objspace,d1
		bne.s	loc_F954
		jsr	(Sonic_ResetOnFloor).l
		bra.s	loc_F95A
; ===========================================================================

loc_F954:
		jsr	(Tails_ResetOnFloor).l

loc_F95A:
		movea.l	(sp)+,a0

loc_F95C:
		bset	#3,obStatus(a1)
		bset	d6,obStatus(a0)

locret_F966:
		rts
; ===========================================================================
; loc_F968:
SlopedPlatform_cont:
		tst.w	obVelY(a1)
		bmi.w	locret_F966
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	locret_F966
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.s	locret_F966
		btst	#0,obRender(a0)
		beq.s	loc_F98E
		not.w	d0
		add.w	d1,d0

loc_F98E:
		lsr.w	#1,d0
		move.b	(a2,d0.w),d3
		ext.w	d3
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	loc_F8C2
; ---------------------------------------------------------------------------

loc_F9A0:
		tst.w	obVelY(a1)
		bmi.w	locret_F966
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	locret_F966
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	locret_F966
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	loc_F8C2

; =============== S U B	R O U T	I N E =======================================


sub_F9C8:
		move.w	d1,d2
		add.w	d2,d2
		lea	(v_player).w,a1
		btst	#1,obStatus(a1)
		bne.s	loc_F9E8
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_F9E8
		cmp.w	d2,d0
		blo.s	locret_F9FA

loc_F9E8:
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a0)
		bclr	#3,obStatus(a0)

locret_F9FA:
		rts
; End of function sub_F9C8

		include	"obj/01 Sonic.asm"

		jmpTos	JmpTo_KillCharacter
; ===========================================================================

		include	"obj/02 Tails.asm"
		include	"obj/05 Tails' Tails.asm"
; ---------------------------------------------------------------------------
Obj05_Animations:
		dc.b	0,0	; TailsAni_Walk, TailsAni_Run
		dc.b	3	; TailsAni_Roll
		dc.b	3	; TailsAni_Roll2
		; There are no animations for Tails's Tails when he is stopping.
		dc.b	0	; TailsAni_Push
		dc.b	1	; TailsAni_Wait
		dc.b	0	; TailsAni_Balance
		dc.b	2	; TailsAni_LookUp
		dc.b	1	; TailsAni_Duck
		dc.b	7	; TailsAni_Spindash
		dc.b	0	; TailsAni_0A
		dc.b	0	; TailsAni_0B
		dc.b	0	; TailsAni_0C
		; There are no animations for Tails's Tails when he is stopping.
		dc.b	0	; TailsAni_Stop
		dc.b	0	; TailsAni_Fly
		dc.b	0	; TailsAni_0F
		dc.b	0	; TailsAni_Jump
		dc.b	0	; TailsAni_11
		dc.b	0	; TailsAni_12
		dc.b	0	; TailsAni_13
		dc.b	0	; TailsAni_14
		dc.b	0	; TailsAni_15
		dc.b	0	; TailsAni_Death1
		dc.b	0	; TailsAni_UnusedDrown
		dc.b	0	; TailsAni_Death2
		dc.b	0	; TailsAni_19
		dc.b	0	; TailsAni_1A
		dc.b	0	; TailsAni_1B
		dc.b	0	; TailsAni_1C
		dc.b	0	; TailsAni_1D
	if FixBugs
		dc.b	0	; TailsAni_1E
	endif
		even

Obj05_AniData:	dc.w byte_11E2A-Obj05_AniData
		dc.w byte_11E2D-Obj05_AniData
		dc.w byte_11E34-Obj05_AniData
		dc.w byte_11E3C-Obj05_AniData
		dc.w byte_11E42-Obj05_AniData
		dc.w byte_11E48-Obj05_AniData
		dc.w byte_11E4E-Obj05_AniData
		dc.w byte_11E54-Obj05_AniData
byte_11E2A:	dc.b $20,  0,$FF
byte_11E2D:	dc.b   7,  9, $A, $B, $C, $D,$FF
byte_11E34:	dc.b   3,  9, $A, $B, $C, $D,$FD,  1
byte_11E3C:	dc.b $FC,$49,$4A,$4B,$4C,$FF
byte_11E42:	dc.b   3,$4D,$4E,$4F,$50,$FF
byte_11E48:	dc.b   3,$51,$52,$53,$54,$FF
byte_11E4E:	dc.b   3,$55,$56,$57,$58,$FF
byte_11E54:	dc.b   2,$81,$82,$83,$84,$FF
		even

		jmpTos	JmpTo2_KillCharacter
; ===========================================================================

		include	"obj/S1/0A Drowning Countdown.asm"

; =============== S U B	R O U T	I N E =======================================


ResumeMusic:
		cmpi.w	#12,(v_air).w
		bhi.s	loc_12310
		move.w	#bgm_LZ,d0
		cmpi.w	#(id_LZ<<8)+3,(Current_ZoneAndAct).w
		bne.s	loc_122F6
		move.w	#bgm_SBZ,d0

loc_122F6:
		tst.b	(v_invinc).w
		beq.s	loc_12300
		move.w	#bgm_Invincible,d0

loc_12300:
		tst.b	(f_lockscreen).w
		beq.s	loc_1230A
		move.w	#bgm_Boss,d0

loc_1230A:
		jsr	(QueueSound1).l

loc_12310:
		move.w	#30,(v_air).w
		clr.b	(v_sonicbubbles+objoff_32).w
		rts
; End of function ResumeMusic

; ---------------------------------------------------------------------------
Ani_Obj0A:	dc.w byte_1233A-Ani_Obj0A,byte_12343-Ani_Obj0A
		dc.w byte_1234C-Ani_Obj0A,byte_12355-Ani_Obj0A
		dc.w byte_1235E-Ani_Obj0A,byte_12367-Ani_Obj0A
		dc.w byte_12370-Ani_Obj0A,byte_12375-Ani_Obj0A
		dc.w byte_1237D-Ani_Obj0A,byte_12385-Ani_Obj0A
		dc.w byte_1238D-Ani_Obj0A,byte_12395-Ani_Obj0A
		dc.w byte_1239D-Ani_Obj0A,byte_123A5-Ani_Obj0A
		dc.w byte_123A7-Ani_Obj0A
byte_1233A:	dc.b   5,  0,  1,  2,  3,  4,  9, $D,$FC
byte_12343:	dc.b   5,  0,  1,  2,  3,  4, $C,$12,$FC
byte_1234C:	dc.b   5,  0,  1,  2,  3,  4, $C,$11,$FC
byte_12355:	dc.b   5,  0,  1,  2,  3,  4, $B,$10,$FC
byte_1235E:	dc.b   5,  0,  1,  2,  3,  4,  9, $F,$FC
byte_12367:	dc.b   5,  0,  1,  2,  3,  4, $A, $E,$FC
byte_12370:	dc.b  $E,  0,  1,  2,$FC
byte_12375:	dc.b   7,$16, $D,$16, $D,$16, $D,$FC
byte_1237D:	dc.b   7,$16,$12,$16,$12,$16,$12,$FC
byte_12385:	dc.b   7,$16,$11,$16,$11,$16,$11,$FC
byte_1238D:	dc.b   7,$16,$10,$16,$10,$16,$10,$FC
byte_12395:	dc.b   7,$16, $F,$16, $F,$16, $F,$FC
byte_1239D:	dc.b   7,$16, $E,$16, $E,$16, $E,$FC
byte_123A5:	dc.b  $E,$FC
byte_123A7:	dc.b  $E,  1,  2,  3,  4,$FC
		even

Map_Obj0A_Countdown:dc.w word_123B0-Map_Obj0A_Countdown
word_123B0:	dc.w 1
		dc.w $E80E,    0,    0,$FFF2

		include	"obj/38 Shield and Invincibility.asm"
		include	"obj/S1/4A Special Stage Entry (Unused).asm"
		include	"obj/08 Water Splash.asm"
; ===========================================================================
; animation script
Ani_obj38:	dc.w byte_125C2-Ani_obj38
		dc.w byte_125CE-Ani_obj38
		dc.w byte_125D4-Ani_obj38
		dc.w byte_125EE-Ani_obj38
		dc.w byte_12608-Ani_obj38
byte_125C2:	dc.b   0,  5,  0,  5,  1,  5,  2,  5,  3,  5,  4,$FF
byte_125CE:	dc.b   5,  4,  5,  6,  7,$FF
byte_125D4:	dc.b   0,  4,  4,  0,  4,  4,  0,  5,  5,  0,  5,  5,  0,  6,  6,  0
		dc.b   6,  6,  0,  7,  7,  0,  7,  7,  0,$FF
byte_125EE:	dc.b   0,  4,  4,  0,  4,  0,  0,  5,  5,  0,  5,  0,  0,  6,  6,  0
		dc.b   6,  0,  0,  7,  7,  0,  7,  0,  0,$FF
byte_12608:	dc.b   0,  4,  0,  0,  4,  0,  0,  5,  0,  0,  5,  0,  0,  6,  0,  0
		dc.b   6,  0,  0,  7,  0,  0,  7,  0,  0,$FF
		even
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_obj38:	binclude	"mappings/sprite/obj38.bin"
		even
; animation script
Ani_S1obj4A:	dc.w byte_1278C-Ani_S1obj4A
byte_1278C:	dc.b   5,  0,  1,  0,  1,  0,  7,  1,  7,  2,  7,  3,  7,  4,  7,  5
		dc.b   7,  6,  7,$FC
		even
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_S1obj4A:	include	"mappings/sprite/S1/obj4A.asm"
; animation script
Ani_obj08:	dc.w byte_129C2-Ani_obj08
byte_129C2:	dc.b   4,  0,  1,  2,$FC
		even
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Map_obj08:	include	"mappings/sprite/obj08.asm"

		include	"obj/Sonic AnglePos.asm"
		include	"obj/sub FindNearestTile.asm"
		include	"obj/sub FindFloor.asm"
		include	"obj/sub FindWall.asm"

; ---------------------------------------------------------------------------
; This dummied out subroutine takes Green Hill Zone/the Sonic 1 collision
; format and converts it to the format used in-game - UNLIKE Sonic 1/2 Final,
; where this instead converts the collision from a bitmap-like format to the
; one used in game (though both of these would require a cartridge that could
; write data to itself, not standard carts).
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; FloorLog_Unk: ConvertCollisionArray:
ApplySonic1Collision:
		rts
; ---------------------------------------------------------------------------
		lea	(CollArray1_S1).l,a1
		tst.b	(Current_Zone).w
		beq.s	loc_13038
		lea	(CollArray1).l,a1

loc_13038:
		lea	(CollArray1).l,a2
		move.w	#bytesToWcnt(CollArray1_End-CollArray1),d1

loc_13042:
		move.w	(a1)+,(a2)+
		dbf	d1,loc_13042
		lea	(CollArray2).l,a2
		move.w	#bytesToWcnt(CollArray2_End-CollArray2),d1

loc_13052:
		move.w	(a1)+,(a2)+
		dbf	d1,loc_13052
		lea	(AngleMap_S1).l,a1
		tst.b	(Current_Zone).w
		beq.s	loc_1306A
		lea	(AngleMap).l,a1

loc_1306A:
		lea	(AngleMap).l,a2
		move.w	#bytesToWcnt(AngleMap_End-AngleMap),d1

loc_13074:
		move.w	(a1)+,(a2)+
		dbf	d1,loc_13074
		rts
; End of function ApplySonic1Collision


; =============== S U B	R O U T	I N E =======================================

; Sonic_WalkSpeed:
CalcRoomInFront:
		move.l	#v_colladdr1,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	loc_13094
		move.l	#v_colladdr2,(Collision_addr).w

loc_13094:
		move.b	lrb_solid_bit(a0),d5
		move.l	obX(a0),d3
		move.l	obY(a0),d2
		move.w	obVelX(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	obVelY(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap	d2
		swap	d3
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	loc_130D4
		move.b	d1,d0
		bpl.s	loc_130CE
		subq.b	#1,d0

loc_130CE:
		addi.b	#$20,d0
		bra.s	loc_130DE
; ---------------------------------------------------------------------------

loc_130D4:
		move.b	d1,d0
		bpl.s	loc_130DA
		addq.b	#1,d0

loc_130DA:
		addi.b	#$1F,d0

loc_130DE:
		andi.b	#$C0,d0
		beq.w	loc_131DE
		cmpi.b	#$80,d0
		beq.w	loc_133B0
		andi.b	#$38,d1
		bne.s	loc_130F6
		addq.w	#8,d2

loc_130F6:
		cmpi.b	#$40,d0
		beq.w	loc_13478
		bra.w	loc_132F6
; End of function CalcRoomInFront


; =============== S U B	R O U T	I N E =======================================


sub_13102:
		move.l	#v_colladdr1,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	loc_1311A
		move.l	#v_colladdr2,(Collision_addr).w

loc_1311A:
		move.b	lrb_solid_bit(a0),d5
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		addi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_13408
		cmpi.b	#$80,d0
		beq.w	Sonic_DontRunOnWalls
		cmpi.b	#$C0,d0
		beq.w	loc_1328E

loc_13146:
		move.l	#v_colladdr1,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	loc_1315E
		move.l	#v_colladdr2,(Collision_addr).w

loc_1315E:
		move.b	top_solid_bit(a0),d5
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#0,d2

loc_131BE:
		move.b	(Secondary_Angle).w,d3
		cmp.w	d0,d1
		ble.s	loc_131CC
		move.b	(Primary_Angle).w,d3
		exg.l	d0,d1

loc_131CC:
		btst	#0,d3
		beq.s	locret_131D4
		move.b	d2,d3

locret_131D4:
		rts
; End of function sub_13102

; ---------------------------------------------------------------------------
; unused
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_131DE:
		addi.w	#$A,d2
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.b	#0,d2

loc_131F6:
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_13202
		move.b	d2,d3

locret_13202:
		rts

; =============== S U B	R O U T	I N E =======================================

; Sonic_HitFloor:
ChkFloorEdge:
		move.w	obX(a0),d3
		move.w	obY(a0),d2
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.l	#v_colladdr1,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	loc_1322E
		move.l	#v_colladdr2,(Collision_addr).w

loc_1322E:
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		move.b	top_solid_bit(a0),d5
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_13254
		move.b	#0,d3

locret_13254:
		rts
; End of function ChkFloorEdge


; =============== S U B	R O U T	I N E =======================================


ObjHitFloor:
		move.w	obX(a0),d3

ObjHitFloor2:
		move.w	obY(a0),d2
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_1328C
		move.b	#0,d3

locret_1328C:
		rts
; End of function ObjHitFloor

; ---------------------------------------------------------------------------

loc_1328E:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#-$40,d2
		bra.w	loc_131BE

; =============== S U B	R O U T	I N E =======================================


sub_132EE:
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_132F6:
		addi.w	#$A,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.b	#-$40,d2
		bra.w	loc_131F6

; =============== S U B	R O U T	I N E =======================================


ObjHitWallRight:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_1333E
		move.b	#-$40,d3

locret_1333E:
		rts
; End of function ObjHitWallRight


; =============== S U B	R O U T	I N E =======================================


Sonic_DontRunOnWalls:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#$80,d2
		bra.w	loc_131BE
; End of function Sonic_DontRunOnWalls

; ---------------------------------------------------------------------------
; unused
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_133B0:
		subi.w	#$A,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.b	#$80,d2
		bra.w	loc_131F6
; ---------------------------------------------------------------------------

ObjHitCeiling:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_13406
		move.b	#$80,d3

locret_13406:
		rts
; ---------------------------------------------------------------------------

loc_13408:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_131BE

; =============== S U B	R O U T	I N E =======================================


Sonic_HitWall:
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_13478:
		subi.w	#$A,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.b	#$40,d2
		bra.w	loc_131F6
; ---------------------------------------------------------------------------

ObjHitWallLeft:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#-$10,a3
		move.w	#$400,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_134C4
		move.b	#$40,d3

locret_134C4:
		rts

		jmpTos	; Empty
; ===========================================================================

		include	"obj/79 Lamppost.asm"
; ---------------------------------------------------------------------------
Map_Obj79:	dc.w word_1370A-Map_Obj79
		dc.w word_1372C-Map_Obj79
		dc.w word_1374E-Map_Obj79
word_1370A:	dc.w 4
		dc.w $E801,$2000,$2000,$FFF8
		dc.w $E801,$2800,$2800,	   0
		dc.w $F803,    6,    3,$FFF8
		dc.w $F803, $806, $803,	   0
word_1372C:	dc.w 4
		dc.w $E801,    2,    1,$FFF8
		dc.w $E801, $802, $801,	   0
		dc.w $F803,    6,    3,$FFF8
		dc.w $F803, $806, $803,	   0
word_1374E:	dc.w 4
		dc.w $E801,$2004,$2002,$FFF8
		dc.w $E801,$2804,$2802,	   0
		dc.w $F803,    6,    3,$FFF8
		dc.w $F803, $806, $803,	   0
; ---------------------------------------------------------------------------
		include	"obj/S1/7D Hidden Bonuses.asm"
; ---------------------------------------------------------------------------
Map_Obj7D:	dc.w word_13852-Map_Obj7D
		dc.w word_13854-Map_Obj7D
		dc.w word_1385E-Map_Obj7D
		dc.w word_13868-Map_Obj7D
word_13852:	dc.w 0
word_13854:	dc.w 1
		dc.w $F40E,    0,    0,$FFF0
word_1385E:	dc.w 1
		dc.w $F40E,   $C,    6,$FFF0
word_13868:	dc.w 1
		dc.w $F40E,  $18,   $C,$FFF0
; ---------------------------------------------------------------------------
		jmpTos	; Empty
; ===========================================================================

		include	"obj/S1/47 Bumper.asm"
; ---------------------------------------------------------------------------
Ani_Bump:	dc.w byte_13988-Ani_Bump
		dc.w byte_1398B-Ani_Bump
byte_13988:	dc.b  $F,  0,$FF
byte_1398B:	dc.b   3,  1,  2,  1,  2,$FD,  0
		even
Map_Bump:	dc.w word_13998-Map_Bump
		dc.w word_139AA-Map_Bump
		dc.w word_139BC-Map_Bump
word_13998:	dc.w 2
		dc.w $F007,    0,    0,$FFF0
		dc.w $F007, $800, $800,	   0
word_139AA:	dc.w 2
		dc.w $F406,    8,    4,$FFF4
		dc.w $F402, $808, $804,	   4
word_139BC:	dc.w 2
		dc.w $F007,   $E,    7,$FFF0
		dc.w $F007, $80E, $807,	   0
; ---------------------------------------------------------------------------
		jmpTos	; Empty
; ===========================================================================

		include	"obj/S1/64 Bubbles.asm"
; ---------------------------------------------------------------------------
Ani_Bub:	dc.w byte_13CD0-Ani_Bub
		dc.w byte_13CD5-Ani_Bub
		dc.w byte_13CDB-Ani_Bub
		dc.w byte_13CE2-Ani_Bub
		dc.w byte_13CE2-Ani_Bub
		dc.w byte_13CE4-Ani_Bub
		dc.w byte_13CE9-Ani_Bub
byte_13CD0:	dc.b  $E,  0,  1,  2,$FC
byte_13CD5:	dc.b  $E,  1,  2,  3,  4,$FC
byte_13CDB:	dc.b  $E,  2,  3,  4,  5,  6,$FC
byte_13CE2:	dc.b   4,$FC
byte_13CE4:	dc.b   4,  6,  7,  8,$FC
byte_13CE9:	dc.b  $F,$13,$14,$15,$FF
		even
Map_Bub:dc.w word_13D1C-Map_Bub
		dc.w word_13D26-Map_Bub
		dc.w word_13D30-Map_Bub
		dc.w word_13D3A-Map_Bub
		dc.w word_13D44-Map_Bub
		dc.w word_13D4E-Map_Bub
		dc.w word_13D58-Map_Bub
		dc.w word_13D62-Map_Bub
		dc.w word_13D84-Map_Bub
		dc.w word_13DA6-Map_Bub
		dc.w word_13DB0-Map_Bub
		dc.w word_13DBA-Map_Bub
		dc.w word_13DC4-Map_Bub
		dc.w word_13DCE-Map_Bub
		dc.w word_13DD8-Map_Bub
		dc.w word_13DE2-Map_Bub
		dc.w word_13DEC-Map_Bub
		dc.w word_13DF6-Map_Bub
		dc.w word_13E00-Map_Bub
		dc.w word_13E0A-Map_Bub
		dc.w word_13E14-Map_Bub
		dc.w word_13E1E-Map_Bub
		dc.w word_13E28-Map_Bub
word_13D1C:	dc.w 1
		dc.w $FC00,    0,    0,$FFFC
word_13D26:	dc.w 1
		dc.w $FC00,    1,    0,$FFFC
word_13D30:	dc.w 1
		dc.w $FC00,    2,    1,$FFFC
word_13D3A:	dc.w 1
		dc.w $F805,    3,    1,$FFF8
word_13D44:	dc.w 1
		dc.w $F805,    7,    3,$FFF8
word_13D4E:	dc.w 1
		dc.w $F40A,   $B,    5,$FFF4
word_13D58:	dc.w 1
		dc.w $F00F,  $14,   $A,$FFF0
word_13D62:	dc.w 4
		dc.w $F005,  $24,  $12,$FFF0
		dc.w $F005, $824, $812,	   0
		dc.w	 5,$1024,$1012,$FFF0
		dc.w	 5,$1824,$1812,	   0
word_13D84:	dc.w 4
		dc.w $F005,  $28,  $14,$FFF0
		dc.w $F005, $828, $814,	   0
		dc.w	 5,$1028,$1014,$FFF0
		dc.w	 5,$1828,$1814,	   0
word_13DA6:	dc.w 1
		dc.w $F406,  $2C,  $16,$FFF8
word_13DB0:	dc.w 1
		dc.w $F406,  $32,  $19,$FFF8
word_13DBA:	dc.w 1
		dc.w $F406,  $38,  $1C,$FFF8
word_13DC4:	dc.w 1
		dc.w $F406,  $3E,  $1F,$FFF8
word_13DCE:	dc.w 1
		dc.w $F406,$2044,$2022,$FFF8
word_13DD8:	dc.w 1
		dc.w $F406,$204A,$2025,$FFF8
word_13DE2:	dc.w 1
		dc.w $F406,$2050,$2028,$FFF8
word_13DEC:	dc.w 1
		dc.w $F406,$2056,$202B,$FFF8
word_13DF6:	dc.w 1
		dc.w $F406,$205C,$202E,$FFF8
word_13E00:	dc.w 1
		dc.w $F406,$2062,$2031,$FFF8
word_13E0A:	dc.w 1
		dc.w $F805,  $68,  $34,$FFF8
word_13E14:	dc.w 1
		dc.w $F805,  $6C,  $36,$FFF8
word_13E1E:	dc.w 1
		dc.w $F805,  $70,  $38,$FFF8
word_13E28:	dc.w 0

		jmpTos	; Empty
; ===========================================================================

		include	"obj/03 Collision Switcher.asm"
Map_Obj03:	include	"mappings/sprite/obj03.asm"

		include	"obj/0B Section of Pipe.asm"

off_1428A:	dc.w byte_1428E-off_1428A
		dc.w byte_14296-off_1428A
byte_1428E:	dc.b   7,  0,  1,  2,  3,  4,$FE,  1
byte_14296:	dc.b   7,  4,  3,  2,  1,  0,$FE,  1
		even

Map_Obj0B:	include	"mappings/sprite/obj0B.asm"

		jmpTos	; Empty
; ===========================================================================

		include	"obj/0C Small Floating Platform.asm"
Map_Obj0C:	include	"mappings/sprite/obj0C.asm"

		jmpTos	JmpTo_CalcSine
; ===========================================================================

		include	"obj/12 HPZ Emerald.asm"
Map_Obj12:	include	"mappings/sprite/obj12.asm"

		jmpTos	; Empty
; ===========================================================================

		include	"obj/13 HPZ Waterfall.asm"
Map_Obj13:	include	"mappings/sprite/obj13.asm"

		include	"obj/06 EHZ Spiral.asm"
; ---------------------------------------------------------------------------
Obj06_PlayerAngleArray:
		dc.b   0,  0,  1,  1
		dc.b $16,$16,$16,$16
		dc.b $2C,$2C,$2C,$2C
		dc.b $42,$42,$42,$42
		dc.b $58,$58,$58,$58
		dc.b $6E,$6E,$6E,$6E
		dc.b $84,$84,$84,$84
		dc.b $9A,$9A,$9A,$9A
		dc.b $B0,$B0,$B0,$B0
		dc.b $C6,$C6,$C6,$C6
		dc.b $DC,$DC,$DC,$DC
		dc.b $F2,$F2,$F2,$F2
		dc.b   1,  1,  0,  0
		even

Obj06_PlayerDeltaYArray:
		dc.b  $20, $20,	$20, $20, $20, $20, $20, $20, $20, $20,	$20, $20, $20, $20, $20, $20
		dc.b  $20, $20,	$20, $20, $20, $20, $20, $20, $20, $20,	$20, $20, $20, $20, $1F, $1F
		dc.b  $1F, $1F,	$1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F,	$1F, $1F, $1F, $1E, $1E, $1E
		dc.b  $1E, $1E,	$1E, $1E, $1E, $1E, $1D, $1D, $1D, $1D,	$1D, $1C, $1C, $1C, $1C, $1B
		dc.b  $1B, $1B,	$1B, $1A, $1A, $1A, $19, $19, $19, $18,	$18, $18, $17, $17, $16, $16
		dc.b  $15, $15,	$14, $14, $13, $12, $12, $11, $10, $10,	 $F,  $E,  $E,	$D,  $C,  $C
		dc.b   $B,  $A,	 $A,   9,   8,	 8,   7,   6,	6,   5,	  4,   4,   3,	 2,   2,   1
		dc.b	0,  -1,	 -2,  -2,  -3,	-4,  -4,  -5,  -6,  -7,	 -7,  -8,  -9,	-9, -$A, -$A
		dc.b  -$B, -$B,	-$C, -$C, -$D, -$E, -$E, -$F, -$F,-$10,-$10,-$11,-$11,-$12,-$12,-$13
		dc.b -$13,-$13,-$14,-$15,-$15,-$16,-$16,-$17,-$17,-$18,-$18,-$19,-$19,-$1A,-$1A,-$1B
		dc.b -$1B,-$1C,-$1C,-$1C,-$1D,-$1D,-$1E,-$1E,-$1E,-$1F,-$1F,-$1F,-$20,-$20,-$20,-$21
		dc.b -$21,-$21,-$21,-$22,-$22,-$22,-$23,-$23,-$23,-$23,-$23,-$23,-$23,-$23,-$24,-$24
		dc.b -$24,-$24,-$24,-$24,-$24,-$24,-$24,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25
		dc.b -$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25,-$25
		dc.b -$25,-$25,-$25,-$25,-$24,-$24,-$24,-$24,-$24,-$24,-$24,-$23,-$23,-$23,-$23,-$23
		dc.b -$23,-$23,-$23,-$22,-$22,-$22,-$21,-$21,-$21,-$21,-$20,-$20,-$20,-$1F,-$1F,-$1F
		dc.b -$1E,-$1E,-$1E,-$1D,-$1D,-$1C,-$1C,-$1C,-$1B,-$1B,-$1A,-$1A,-$19,-$19,-$18,-$18
		dc.b -$17,-$17,-$16,-$16,-$15,-$15,-$14,-$13,-$13,-$12,-$12,-$11,-$10,-$10, -$F, -$E
		dc.b  -$E, -$D,	-$C, -$B, -$B, -$A,  -9,  -8,  -7,  -7,	 -6,  -5,  -4,	-3,  -2,  -1
		dc.b	0,   1,	  2,   3,   4,	 5,   6,   7,	8,   8,	  9,  $A,  $A,	$B,  $C,  $D
		dc.b   $D,  $E,	 $E,  $F,  $F, $10, $10, $11, $11, $12,	$12, $13, $13, $14, $14, $15
		dc.b  $15, $16,	$16, $17, $17, $18, $18, $18, $19, $19,	$19, $19, $1A, $1A, $1A, $1A
		dc.b  $1B, $1B,	$1B, $1B, $1C, $1C, $1C, $1C, $1C, $1C,	$1D, $1D, $1D, $1D, $1D, $1D
		dc.b  $1D, $1E,	$1E, $1E, $1E, $1E, $1E, $1E, $1F, $1F,	$1F, $1F, $1F, $1F, $1F, $1F
		dc.b  $1F, $1F,	$20, $20, $20, $20, $20, $20, $20, $20,	$20, $20, $20, $20, $20, $20
		dc.b  $20, $20,	$20, $20, $20, $20, $20, $20, $20, $20,	$20, $20, $20, $20, $20, $20
		even

		jmpTos	; Empty
; ===========================================================================

		include	"obj/14 HTZ Seesaw.asm"

word_14FF4:
		dc.w	 -8,  -$1C,  -$2F,  -$1C,    -8
byte_14FFE:
		dc.b  $14, $14,	$16, $18, $1A, $1C, $1A
		dc.b  $18, $16,	$14, $13, $12, $11, $10
		dc.b   $F,  $E,	 $D,  $C,  $B,	$A,   9
		dc.b	8,   7,	  6,   5,   4,	 3,   2
		dc.b	1,   0,	 -1,  -2,  -3,	-4,  -5
		dc.b   -6,  -7,	 -8,  -9, -$A, -$B, -$C
		dc.b  -$D, -$E,	-$E, -$E, -$E, -$E, -$E
byte_1502F:
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5
		even
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Map_obj14:	binclude	"mappings/sprite/obj14_a.bin"
		even
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Map_obj14b:	binclude	"mappings/sprite/obj14_b.bin"
		even

		jmpTos	JmpTo_ObjectMoveAndFall
; ===========================================================================

		include	"obj/16 HTZ Platform.asm"
Map_Obj16:	include	"mappings/sprite/obj16.asm"

		jmpTos	JmpTo_DisplaySprite,JmpTo_DeleteObject,JmpTo_ObjectMove
; ===========================================================================

		include	"obj/19 CPZ Platform.asm"
Map_Obj19:	include	"mappings/sprite/obj19.asm"

		jmpTos0	JmpTo2_DisplaySprite,JmpTo2_DeleteObject,JmpTo2_ObjectMove
; ===========================================================================

		include	"obj/04 Water Surface.asm"

Obj04_FrameData:
		dc.b   0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1
		dc.b   1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2
		dc.b   2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1
		dc.b   1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0

Map_Obj04:	dc.w word_155AC-Map_Obj04
		dc.w word_155C6-Map_Obj04
		dc.w word_155E0-Map_Obj04
		dc.w word_155FA-Map_Obj04
		dc.w word_1562C-Map_Obj04
		dc.w word_1565E-Map_Obj04
word_155AC:	dc.w 3
		dc.w $F80D,    0,    0,$FFA0
		dc.w $F80D,    0,    0,$FFE0
		dc.w $F80D,    0,    0,	 $20
word_155C6:	dc.w 3
		dc.w $F80D,    8,    4,$FFA0
		dc.w $F80D,    8,    4,$FFE0
		dc.w $F80D,    8,    4,	 $20
word_155E0:	dc.w 3
		dc.w $F80D,  $10,    8,$FFA0
		dc.w $F80D,  $10,    8,$FFE0
		dc.w $F80D,  $10,    8,	 $20
word_155FA:	dc.w 6
		dc.w $F80D,    0,    0,$FFA0
		dc.w $F80D,    8,    4,$FFC0
		dc.w $F80D,    0,    0,$FFE0
		dc.w $F80D,    8,    4,	   0
		dc.w $F80D,    0,    0,	 $20
		dc.w $F80D,    8,    4,	 $40
word_1562C:	dc.w 6
		dc.w $F80D,    8,    4,$FFA0
		dc.w $F80D,  $10,    8,$FFC0
		dc.w $F80D,    8,    4,$FFE0
		dc.w $F80D,  $10,    8,	   0
		dc.w $F80D,    8,    4,	 $20
		dc.w $F80D,  $10,    8,	 $40
word_1565E:	dc.w 6
		dc.w $F80D,  $10,    8,$FFA0
		dc.w $F80D,    8,    4,$FFC0
		dc.w $F80D,  $10,    8,$FFE0
		dc.w $F80D,    8,    4,	   0
		dc.w $F80D,  $10,    8,	 $20
		dc.w $F80D,    8,    4,	 $40

		include	"obj/49 EHZ Waterfall.asm"
Map_Obj49:	include	"mappings/sprite/obj49.asm"

		jmpTos0	JmpTo3_DisplaySprite,JmpTo3_DeleteObject,JmpTo_Adjust2PArtPointer
; ===========================================================================

		include	"obj/4D Stegway.asm"

Ani_Obj4D:	dc.w byte_159D0-Ani_Obj4D
		dc.w byte_159DE-Ani_Obj4D
		dc.w byte_159E1-Ani_Obj4D
byte_159D0:	dc.b   2,  0,  0,  0,  3,  3,  4,  1,  1,  2,  5,  5,  5,$FF
byte_159DE:	dc.b  $F,  0,$FF
byte_159E1:	dc.b   2,  6,  7,$FF
		even
Map_Obj4D:	dc.w word_159F6-Map_Obj4D
		dc.w word_15A20-Map_Obj4D
		dc.w word_15A4A-Map_Obj4D
		dc.w word_15A74-Map_Obj4D
		dc.w word_15A9E-Map_Obj4D
		dc.w word_15AC8-Map_Obj4D
		dc.w word_15AF2-Map_Obj4D
		dc.w word_15B14-Map_Obj4D
word_159F6:	dc.w 5
		dc.w $F005,    0,    0,$FFF0
		dc.w $F005,    4,    2,	   0
		dc.w $F801,    8,    4,$FFE8
		dc.w	 5,   $A,    5,$FFF0
		dc.w	 9,  $22,  $11,	   0
word_15A20:	dc.w 5
		dc.w $F005,    0,    0,$FFF0
		dc.w $F005,    4,    2,	   0
		dc.w $F801,    8,    4,$FFE8
		dc.w	 5,   $E,    7,$FFF0
		dc.w	 9,  $22,  $11,	   0
word_15A4A:	dc.w 5
		dc.w $F005,    0,    0,$FFF0
		dc.w $F005,    4,    2,	   0
		dc.w $F801,    8,    4,$FFE8
		dc.w	 5,  $12,    9,$FFF0
		dc.w	 9,  $22,  $11,	   0
word_15A74:	dc.w 5
		dc.w $F005,    0,    0,$FFF0
		dc.w $F005,    4,    2,	   0
		dc.w $F801,    8,    4,$FFE8
		dc.w	 5,   $A,    5,$FFF0
		dc.w	 9,  $28,  $14,	   0
word_15A9E:	dc.w 5
		dc.w $F005,    0,    0,$FFF0
		dc.w $F005,    4,    2,	   0
		dc.w $F801,    8,    4,$FFE8
		dc.w	 5,   $E,    7,$FFF0
		dc.w	 9,  $28,  $14,	   0
word_15AC8:	dc.w 5
		dc.w $F005,    0,    0,$FFF0
		dc.w $F005,    4,    2,	   0
		dc.w $F801,    8,    4,$FFE8
		dc.w	 5,  $12,    9,$FFF0
		dc.w	 9,  $28,  $14,	   0
word_15AF2:	dc.w 4
		dc.w $F00B,  $16,   $B,$FFE8
		dc.w $F005,    4,    2,	   0
		dc.w	 9,  $22,  $11,	   0
		dc.w $FB01,  $2E,  $17,	 $1A
word_15B14:	dc.w 4
		dc.w $F00B,  $16,   $B,$FFE8
		dc.w $F005,    4,    2,	   0
		dc.w	 9,  $28,  $14,	   0
		dc.w $FB01,  $30,  $18,	 $1A

		jmpTos0	JmpTo_MarkObjGone,JmpTo_AnimateSprite,JmpTo2_ObjectMoveAndFall
; ===========================================================================

		include	"obj/52 Piranha.asm"

Ani_Obj52:	dc.w byte_15D4E-Ani_Obj52
		dc.w byte_15D52-Ani_Obj52
		dc.w byte_15D56-Ani_Obj52
		dc.w byte_15D5A-Ani_Obj52
byte_15D4E:	dc.b  $E,  0,  1,$FF
byte_15D52:	dc.b   3,  0,  1,$FF
byte_15D56:	dc.b  $E,  2,  3,$FF
byte_15D5A:	dc.b   3,  2,  3,$FF
		even
Map_Obj52:	dc.w word_15D66-Map_Obj52
		dc.w word_15D70-Map_Obj52
		dc.w word_15D7A-Map_Obj52
		dc.w word_15D84-Map_Obj52
word_15D66:	dc.w 1
		dc.w $F00F,    0,    0,$FFF0
word_15D70:	dc.w 1
		dc.w $F00F,  $10,    8,$FFF0
word_15D7A:	dc.w 1
		dc.w $F00F,  $20,  $10,$FFF0
word_15D84:	dc.w 1
		dc.w $F00F,  $30,  $18,$FFF0

		jmpTos0	JmpTo2_MarkObjGone,JmpTo2_AnimateSprite,JmpTo3_ObjectMove
; ===========================================================================

		include	"obj/4F Redz.asm"
; ===========================================================================
; animation script
Ani_obj4F:	dc.w byte_15EB8-Ani_obj4F
		dc.w byte_15EBB-Ani_obj4F
byte_15EB8:	dc.b   9,  1,$FF
byte_15EBB:	dc.b   9,  0,  1,  2,  1,$FF
		even
; ---------------------------------------------------------------------------
; Sprite mappings - Redz (dinosaur badnik) from HPZ
; ---------------------------------------------------------------------------
Map_obj4F:	binclude	"mappings/sprite/obj4F.bin"
		even

		jmpTos0	JmpTo4_DisplaySprite,JmpTo4_DeleteObject,JmpTo3_AnimateSprite,JmpTo3_ObjectMoveAndFall,JmpTo4_ObjectMove
; ===========================================================================

		include	"obj/50 Aquis.asm"

Ani_Obj50:	dc.w byte_163B0-Ani_Obj50
		dc.w byte_163B3-Ani_Obj50
		dc.w byte_163BB-Ani_Obj50
		dc.w byte_163C1-Ani_Obj50
		dc.w byte_163C5-Ani_Obj50
		dc.w byte_163C8-Ani_Obj50
		dc.w byte_163CB-Ani_Obj50
		dc.w byte_163CF-Ani_Obj50
byte_163B0:	dc.b  $E,  0,$FF
byte_163B3:	dc.b   5,  3,  4,  3,  4,  3,  4,$FF
byte_163BB:	dc.b   3,  5,  6,  7,  6,$FF
byte_163C1:	dc.b   3,  1,  2,$FF
byte_163C5:	dc.b   1,  5,$FF
byte_163C8:	dc.b  $E,  8,$FF
byte_163CB:	dc.b   1,  9, $A,$FF
byte_163CF:	dc.b   5, $B, $C, $B, $C, $B, $C,$FF
		even
Map_Obj50:	dc.w word_163F2-Map_Obj50
		dc.w word_1640C-Map_Obj50
		dc.w word_16416-Map_Obj50
		dc.w word_16420-Map_Obj50
		dc.w word_16442-Map_Obj50
		dc.w word_16464-Map_Obj50
		dc.w word_1646E-Map_Obj50
		dc.w word_16478-Map_Obj50
		dc.w word_16482-Map_Obj50
		dc.w word_1648C-Map_Obj50
		dc.w word_164AE-Map_Obj50
		dc.w word_164D0-Map_Obj50
		dc.w word_164FA-Map_Obj50
word_163F2:	dc.w 3
		dc.w $E80D,    0,    0,$FFF0
		dc.w $F809,  $16,   $B,$FFF8
		dc.w  $805,  $24,  $12,$FFF8
word_1640C:	dc.w 1
		dc.w $F805,  $28,  $14,$FFF8
word_16416:	dc.w 1
		dc.w $F805,  $2C,  $16,$FFF8
word_16420:	dc.w 4
		dc.w $E809,    8,    4,$FFF0
		dc.w $E801,   $E,    7,	   8
		dc.w $F809,  $16,   $B,$FFF8
		dc.w  $805,  $24,  $12,$FFF8
word_16442:	dc.w 4
		dc.w $E809,  $10,    8,$FFF0
		dc.w $E801,   $E,    7,	   8
		dc.w $F809,  $16,   $B,$FFF8
		dc.w  $805,  $24,  $12,$FFF8
word_16464:	dc.w 1
		dc.w $F801,  $30,  $18,$FFFC
word_1646E:	dc.w 1
		dc.w $F801,  $32,  $19,$FFFC
word_16478:	dc.w 1
		dc.w $F801,  $34,  $1A,$FFFC
word_16482:	dc.w 1
		dc.w $F80D,  $36,  $1B,$FFF0
word_1648C:	dc.w 4
		dc.w $E80D,    0,    0,$FFF0
		dc.w $F805,  $1C,   $E,$FFF8
		dc.w $F801,  $20,  $10,	   8
		dc.w  $805,  $24,  $12,$FFF8
word_164AE:	dc.w 4
		dc.w $E80D,    0,    0,$FFF0
		dc.w $F805,  $1C,   $E,$FFF8
		dc.w $F801,  $22,  $11,	   8
		dc.w  $805,  $24,  $12,$FFF8
word_164D0:	dc.w 5
		dc.w $E809,    8,    4,$FFF0
		dc.w $E801,   $E,    7,	   8
		dc.w $F805,  $1C,   $E,$FFF8
		dc.w $F801,  $20,  $10,	   8
		dc.w  $805,  $24,  $12,$FFF8
word_164FA:	dc.w 5
		dc.w $E809,  $10,    8,$FFF0
		dc.w $E801,   $E,    7,	   8
		dc.w $F805,  $1C,   $E,$FFF8
		dc.w $F801,  $22,  $11,	   8
		dc.w  $805,  $24,  $12,$FFF8

		include	"obj/51 Aquis Child.asm"

		jmpTos0	JmpTo5_DisplaySprite,JmpTo5_DeleteObject,JmpTo_FindFreeObj,JmpTo3_MarkObjGone,JmpTo4_AnimateSprite,JmpTo4_ObjectMoveAndFall,JmpTo5_ObjectMove
; ===========================================================================

		include	"obj/4B Buzzer.asm"
; ===========================================================================
; animation script
; off_169DA:
Ani_obj4B:	dc.w byte_169E2-Ani_obj4B
		dc.w byte_169E5-Ani_obj4B
		dc.w byte_169E9-Ani_obj4B
		dc.w byte_169ED-Ani_obj4B
byte_169E2:	dc.b  $F,  0,$FF
byte_169E5:	dc.b   2,  3,  4,$FF
byte_169E9:	dc.b   3,  5,  6,$FF
byte_169ED:	dc.b   9,  1,  1,  1,  1,  1,$FD,  0
		even
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj4B:	binclude	"mappings/sprite/obj4B.bin"
		even

		jmpTos0	JmpTo6_DeleteObject,JmpTo_FindNextFreeObj,JmpTo5_AnimateSprite,JmpTo_Adjust2PArtPointer2,JmpTo_MarkObjGone_P1,JmpTo2_Adjust2PArtPointer,JmpTo6_ObjectMove
; ===========================================================================

		include	"obj/4A Octus.asm"

Ani_Obj4A:	dc.w byte_16C98-Ani_Obj4A
		dc.w byte_16C9B-Ani_Obj4A
		dc.w byte_16CA0-Ani_Obj4A
byte_16C98:	dc.b  $F,  0,$FF
byte_16C9B:	dc.b   3,  1,  2,  3,$FF
byte_16CA0:	dc.b   2,  5,  6,$FF
		even

Map_Obj4A:	dc.w word_16CB2-Map_Obj4A
		dc.w word_16CC4-Map_Obj4A
		dc.w word_16CDE-Map_Obj4A
		dc.w word_16CF8-Map_Obj4A
		dc.w word_16D12-Map_Obj4A
		dc.w word_16D1C-Map_Obj4A
		dc.w word_16D26-Map_Obj4A
word_16CB2:	dc.w 2
		dc.w $F00D,    0,    0,$FFF0
		dc.w	$D,    8,    4,$FFF0
word_16CC4:	dc.w 3
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 9,  $10,    8,$FFE8
		dc.w	 9,  $16,   $B,	   0
word_16CDE:	dc.w 3
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 9,  $1C,   $E,$FFE8
		dc.w	 9,  $22,  $11,	   0
word_16CF8:	dc.w 3
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 9,  $28,  $14,$FFE8
		dc.w	 9,  $2E,  $17,	   0
word_16D12:	dc.w 1
		dc.w $F001,  $34,  $1A,$FFF7
word_16D1C:	dc.w 1
		dc.w $F201,  $36,  $1B,$FFF0
word_16D26:	dc.w 1
		dc.w $F201,  $38,  $1C,$FFF0

		jmpTos0	JmpTo6_DisplaySprite,JmpTo7_DeleteObject,JmpTo4_MarkObjGone,JmpTo6_AnimateSprite,JmpTo5_ObjectMoveAndFall
; ===========================================================================

		include	"obj/4C BBat.asm"

Ani_Obj4C:	dc.w byte_16FC2-Ani_Obj4C
		dc.w byte_16FC6-Ani_Obj4C
		dc.w byte_16FD5-Ani_Obj4C
		dc.w byte_16FE6-Ani_Obj4C
byte_16FC2:	dc.b   1,  0,  5,$FF
byte_16FC6:	dc.b   1,  1,  6,  1,  6,  2,  7,  2,  7,  1,  6,  1,  6,$FD,  0
byte_16FD5:	dc.b   1,  1,  6,  1,  6,  2,  7,  3,  8,  4,  9,  4,  9,  3,  8,$FE
		dc.b  $A
byte_16FE6:	dc.b   3, $A, $B, $C, $D, $E,$FF
		even

Map_Obj4C:	include	"mappings/sprite/obj4C.asm"

		jmpTos0	JmpTo5_MarkObjGone,JmpTo7_AnimateSprite,JmpTo7_ObjectMove
; ===========================================================================

		include	"obj/4E Gator.asm"

Ani_Obj4E:	dc.w byte_172F4-Ani_Obj4E
		dc.w byte_172FC-Ani_Obj4E
		dc.w byte_172FF-Ani_Obj4E
byte_172F4:	dc.b   3,  0,  4,  2,  3,  1,  5,$FF
byte_172FC:	dc.b  $F,  0,$FF
byte_172FF:	dc.b   3,  6, $A,  8,  9,  7, $B,$FF
		even

Map_Obj4E:	dc.w word_17320-Map_Obj4E
		dc.w word_17342-Map_Obj4E
		dc.w word_17364-Map_Obj4E
		dc.w word_17386-Map_Obj4E
		dc.w word_173A8-Map_Obj4E
		dc.w word_173CA-Map_Obj4E
		dc.w word_173EC-Map_Obj4E
		dc.w word_1740E-Map_Obj4E
		dc.w word_17430-Map_Obj4E
		dc.w word_17452-Map_Obj4E
		dc.w word_17474-Map_Obj4E
		dc.w word_17496-Map_Obj4E
word_17320:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $20,  $10,	  $C
word_17342:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $24,  $12,	  $C
word_17364:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $28,  $14,	  $C
word_17386:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $20,  $10,	  $C
word_173A8:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $24,  $12,	  $C
word_173CA:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $28,  $14,	  $C
word_173EC:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $20,  $10,	  $C
word_1740E:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $24,  $12,	  $C
word_17430:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $28,  $14,	  $C
word_17452:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $20,  $10,	  $C
word_17474:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $24,  $12,	  $C
word_17496:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $28,  $14,	  $C

		jmpTos0	JmpTo6_MarkObjGone,JmpTo8_AnimateSprite,JmpTo6_ObjectMoveAndFall,JmpTo8_ObjectMove
; ===========================================================================

		include	"obj/53 Masher.asm"
; ===========================================================================
; animation script
Ani_obj53:	dc.w byte_17572-Ani_obj53
		dc.w byte_17576-Ani_obj53
		dc.w byte_1757A-Ani_obj53
byte_17572:	dc.b   7,  0,  1,$FF
byte_17576:	dc.b   3,  0,  1,$FF
byte_1757A:	dc.b   7,  0,$FF
		even
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj53:	binclude	"mappings/sprite/obj53.bin"
		even

		jmpTos0	JmpTo7_MarkObjGone,JmpTo9_AnimateSprite,JmpTo3_Adjust2PArtPointer,JmpTo9_ObjectMove
; ===========================================================================

		include	"obj/54 Snail.asm"
; ---------------------------------------------------------------------------
Ani_Obj54:	dc.w byte_17818-Ani_Obj54
		dc.w byte_1781C-Ani_Obj54
byte_17818:	dc.b   5,  0,  1,$FF
byte_1781C:	dc.b   1,  0,  1,$FF
		even
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_obj54:	include	"mappings/sprite/obj54.asm"

		jmpTos0	JmpTo8_DeleteObject,JmpTo2_FindNextFreeObj,JmpTo10_AnimateSprite,JmpTo2_Adjust2PArtPointer2,JmpTo2_MarkObjGone_P1,JmpTo4_Adjust2PArtPointer,JmpTo7_ObjectMoveAndFall,JmpTo10_ObjectMove
; ===========================================================================

		include	"obj/57 EHZ Boss (Part 3).asm"
		include	"obj/58 EHZ Boss (Part 4).asm"

Ani_Obj58:	dc.w byte_18000-Ani_Obj58
		dc.w byte_18004-Ani_Obj58
		dc.w byte_1801A-Ani_Obj58
byte_18000:	dc.b   1,  5,  6,$FF
byte_18004:	dc.b   1,  1,  1,  1,  2,  2,  2,  3,  3,  3,  4,  4,  4,  0,  0,  0
		dc.b   0,  0,  0,  0,  0,$FF
byte_1801A:	dc.b   1,  0,  0,  0,  0,  0,  0,  0,  0,  4,  4,  4,  3,  3,  3,  2
		dc.b   2,  2,  1,  1,  1,  5,  6,$FE,  2
		even

Map_Obj58:	dc.w word_18042-Map_Obj58
		dc.w word_1804C-Map_Obj58
		dc.w word_18076-Map_Obj58
		dc.w word_180A0-Map_Obj58
		dc.w word_180BA-Map_Obj58
		dc.w word_180D4-Map_Obj58
		dc.w word_180EE-Map_Obj58
word_18042:	dc.w 1
		dc.w $D805,    0,    0,	   2
word_1804C:	dc.w 5
		dc.w $D805,    4,    2,	   2
		dc.w $D80D,   $C,    6,	 $12
		dc.w $D80D,   $C,    6,	 $32
		dc.w $D80D,   $C,    6,$FFE2
		dc.w $D80D,   $C,    6,$FFC2
word_18076:	dc.w 5
		dc.w $D805,    4,    2,	   2
		dc.w $D80D,   $C,    6,	 $12
		dc.w $D805,    8,    4,	 $32
		dc.w $D80D,   $C,    6,$FFE2
		dc.w $D805,    8,    4,$FFD2
word_180A0:	dc.w 3
		dc.w $D805,    4,    2,	   2
		dc.w $D80D,   $C,    6,	 $12
		dc.w $D80D,   $C,    6,$FFE2
word_180BA:	dc.w 3
		dc.w $D805,    4,    2,	   2
		dc.w $D805,    8,    4,	 $12
		dc.w $D805,    8,    4,$FFF2
word_180D4:	dc.w 3
		dc.w $D805,    0,    0,	   2
		dc.w $D80D,   $C,    6,	 $12
		dc.w $D80D,   $C,    6,	 $32
word_180EE:	dc.w 3
		dc.w $D805,    4,    2,	   2
		dc.w $D80D,   $C,    6,$FFE2
		dc.w $D80D,   $C,    6,$FFC2

Ani_Obj58a:	dc.w byte_1810E-Ani_Obj58a
		dc.w byte_18113-Ani_Obj58a
		dc.w byte_18117-Ani_Obj58a
byte_1810E:	dc.b   5,  1,  2,  3,$FF
byte_18113:	dc.b   1,  4,  5,$FF
byte_18117:	dc.b   1,  6,  7,$FF
		even

Map_Obj58a:	dc.w word_1812E-Map_Obj58a
		dc.w word_18148-Map_Obj58a
		dc.w word_18152-Map_Obj58a
		dc.w word_1815C-Map_Obj58a
		dc.w word_18166-Map_Obj58a
		dc.w word_18170-Map_Obj58a
		dc.w word_1817A-Map_Obj58a
		dc.w word_18184-Map_Obj58a
		dc.w word_1818E-Map_Obj58a
word_1812E:	dc.w 3
		dc.w $F00F,    0,    0,$FFD0
		dc.w $F00F,  $10,    8,$FFF0
		dc.w $F00F,  $20,  $10,	 $10
word_18148:	dc.w 1
		dc.w $F00F,  $30,  $18,$FFF0
word_18152:	dc.w 1
		dc.w $F00F,  $40,  $20,$FFF0
word_1815C:	dc.w 1
		dc.w $F00F,  $50,  $28,$FFF0
word_18166:	dc.w 1
		dc.w $F00F,  $60,  $30,$FFF0
word_18170:	dc.w 1
		dc.w $F00F,$1060,$1030,$FFF0
word_1817A:	dc.w 1
		dc.w $F00F,  $70,  $38,$FFF0
word_18184:	dc.w 1
		dc.w $F00F,$1070,$1038,$FFF0
word_1818E:	dc.w 3
		dc.w $F00F,$8000,$8000,$FFD0
		dc.w $F00F,$8010,$8008,$FFF0
		dc.w $F00F,$8020,$8010,	 $10

		jmpTos0	JmpTo7_DisplaySprite,JmpTo9_DeleteObject,JmpTo8_MarkObjGone,JmpTo3_FindNextFreeObj,JmpTo11_AnimateSprite,JmpTo8_ObjectMoveAndFall
; ===========================================================================

		include	"obj/55 EHZ Boss (Part 1).asm"
		include	"obj/56 EHZ Boss (Part 2).asm"

Map_Obj55a:	dc.w word_184C2-Map_Obj55a
		dc.w word_184CC-Map_Obj55a
word_184C2:	dc.w 1
		dc.w	 5,    0,    0,	 $1C
word_184CC:	dc.w 1
		dc.w	 5,    4,    2,	 $1C
Map_Obj55b:	dc.w word_184DE-Map_Obj55b
		dc.w word_184E8-Map_Obj55b
		dc.w word_184F2-Map_Obj55b
		dc.w word_184FC-Map_Obj55b
word_184DE:	dc.w 1
		dc.w $F805,    0,    0,$FFF8
word_184E8:	dc.w 1
		dc.w $F805,    4,    2,$FFF8
word_184F2:	dc.w 1
		dc.w $F805,    8,    4,$FFF8
word_184FC:	dc.w 1
		dc.w $F805,   $C,    6,$FFF8
Map_Obj56:	dc.w word_18514-Map_Obj56
		dc.w word_1851E-Map_Obj56
		dc.w word_18528-Map_Obj56
		dc.w word_18532-Map_Obj56
		dc.w word_1853C-Map_Obj56
		dc.w word_18546-Map_Obj56
		dc.w word_18550-Map_Obj56
word_18514:	dc.w 1
		dc.w $F805,    0,    0,$FFF8
word_1851E:	dc.w 1
		dc.w $F00F,    4,    2,$FFF0
word_18528:	dc.w 1
		dc.w $F00F,  $14,   $A,$FFF0
word_18532:	dc.w 1
		dc.w $F00F,  $24,  $12,$FFF0
word_1853C:	dc.w 1
		dc.w $F00F,  $34,  $1A,$FFF0
word_18546:	dc.w 1
		dc.w $F00F,  $44,  $22,$FFF0
word_18550:	dc.w 1
		dc.w $F00F,  $54,  $2A,$FFF0
Ani_Obj55a:	dc.w byte_1855E-Ani_Obj55a
		dc.w byte_18561-Ani_Obj55a
byte_1855E:	dc.b  $F,  0,$FF
byte_18561:	dc.b   7,  1,  2,$FF
		even

Map_Obj55:	dc.w word_1856C-Map_Obj55
		dc.w word_1858E-Map_Obj55
		dc.w word_185B0-Map_Obj55
word_1856C:	dc.w 4
		dc.w $F805,    0,    0,$FFE0
		dc.w  $805,    4,    2,$FFE0
		dc.w $F80F,    8,    4,$FFF0
		dc.w $F807,  $18,   $C,	 $10
word_1858E:	dc.w 4
		dc.w $E805,  $28,  $14,$FFE0
		dc.w $E80D,  $30,  $18,$FFF0
		dc.w $E805,  $24,  $12,	 $10
		dc.w $D805,  $20,  $10,	   2
word_185B0:	dc.w 4
		dc.w $E805,  $28,  $14,$FFE0
		dc.w $E80D,  $38,  $1C,$FFF0
		dc.w $E805,  $24,  $12,	 $10
		dc.w $D805,  $20,  $10,	   2
; ---------------------------------------------------------------------------
		jmpTos	JmpTo8_DisplaySprite,JmpTo10_DeleteObject
; ===========================================================================

		include	"obj/S1/8A Credits.asm"
Map_Cred:	include	"mappings/sprite/S1/obj8A.asm"
; ===========================================================================
		jmpTos	JmpTo5_Adjust2PArtPointer
; ===========================================================================

		include "obj/S1/3D Boss - Green Hill (part 1).asm"

; =============== S U B	R O U T	I N E =======================================


BossDefeated:
		move.b	(Vint_runcount+3).w,d0
		andi.b	#7,d0
		bne.s	locret_18EA0
		jsr	(FindFreeObj).l
		bne.s	locret_18EA0
		_move.b	#id_Obj3F,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		jsr	(RandomNumber).l
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,obX(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,obY(a1)

locret_18EA0:
		rts
; End of function BossDefeated


; =============== S U B	R O U T	I N E =======================================


BossMove:
		move.l	objoff_30(a0),d2
		move.l	objoff_38(a0),d3
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,objoff_30(a0)
		move.l	d3,objoff_38(a0)
		rts
; End of function BossMove

		include "obj/S1/3D Boss - Green Hill (part 2).asm"
		include "obj/S1/48 Eggman's Swinging Ball.asm"

Ani_Eggman:	dc.w byte_192E0-Ani_Eggman
		dc.w byte_192E3-Ani_Eggman
		dc.w byte_192E7-Ani_Eggman
		dc.w byte_192EB-Ani_Eggman
		dc.w byte_192EF-Ani_Eggman
		dc.w byte_192F3-Ani_Eggman
		dc.w byte_192F7-Ani_Eggman
		dc.w byte_192FB-Ani_Eggman
		dc.w byte_192FE-Ani_Eggman
		dc.w byte_19302-Ani_Eggman
		dc.w byte_19306-Ani_Eggman
		dc.w byte_19309-Ani_Eggman
byte_192E0:	dc.b  $F,  0,$FF
byte_192E3:	dc.b   5,  1,  2,$FF
byte_192E7:	dc.b   3,  1,  2,$FF
byte_192EB:	dc.b   1,  1,  2,$FF
byte_192EF:	dc.b   4,  3,  4,$FF
byte_192F3:	dc.b $1F,  5,  1,$FF
byte_192F7:	dc.b   3,  6,  1,$FF
byte_192FB:	dc.b  $F, $A,$FF
byte_192FE:	dc.b   3,  8,  9,$FF
byte_19302:	dc.b   1,  8,  9,$FF
byte_19306:	dc.b  $F,  7,$FF
byte_19309:	dc.b   2,  9,  8, $B, $C, $B, $C,  9,  8,$FE,  2
		even

Map_Eggman:	dc.w word_1932E-Map_Eggman
		dc.w word_19360-Map_Eggman
		dc.w word_19372-Map_Eggman
		dc.w word_19384-Map_Eggman
		dc.w word_1939E-Map_Eggman
		dc.w word_193B8-Map_Eggman
		dc.w word_193D2-Map_Eggman
		dc.w word_193EC-Map_Eggman
		dc.w word_1940E-Map_Eggman
		dc.w word_19418-Map_Eggman
		dc.w word_19422-Map_Eggman
		dc.w word_19424-Map_Eggman
		dc.w word_19436-Map_Eggman
word_1932E:	dc.w 6
		dc.w $EC01,   $A,    5,$FFE4
		dc.w $EC05,   $C,    6,	  $C
		dc.w $FC0E,$2010,$2008,$FFE4
		dc.w $FC0E,$201C,$200E,	   4
		dc.w $140C,$2028,$2014,$FFEC
		dc.w $1400,$202C,$2016,	  $C
word_19360:	dc.w 2
		dc.w $E404,    0,    0,$FFF4
		dc.w $EC0D,    2,    1,$FFEC
word_19372:	dc.w 2
		dc.w $E404,    0,    0,$FFF4
		dc.w $EC0D,  $35,  $1A,$FFEC
word_19384:	dc.w 3
		dc.w $E408,  $3D,  $1E,$FFF4
		dc.w $EC09,  $40,  $20,$FFEC
		dc.w $EC05,  $46,  $23,	   4
word_1939E:	dc.w 3
		dc.w $E408,  $4A,  $25,$FFF4
		dc.w $EC09,  $4D,  $26,$FFEC
		dc.w $EC05,  $53,  $29,	   4
word_193B8:	dc.w 3
		dc.w $E408,  $57,  $2B,$FFF4
		dc.w $EC09,  $5A,  $2D,$FFEC
		dc.w $EC05,  $60,  $30,	   4
word_193D2:	dc.w 3
		dc.w $E404,  $64,  $32,	   4
		dc.w $E404,    0,    0,$FFF4
		dc.w $EC0D,  $35,  $1A,$FFEC
word_193EC:	dc.w 4
		dc.w $E409,  $66,  $33,$FFF4
		dc.w $E408,  $57,  $2B,$FFF4
		dc.w $EC09,  $5A,  $2D,$FFEC
		dc.w $EC05,  $60,  $30,	   4
word_1940E:	dc.w 1
		dc.w  $405,  $2D,  $16,	 $22
word_19418:	dc.w 1
		dc.w  $405,  $31,  $18,	 $22
word_19422:	dc.w 0
word_19424:	dc.w 2
		dc.w	 8, $12A, $195,	 $22
		dc.w  $808,$112A,$1995,	 $22
word_19436:	dc.w 2
		dc.w $F80B, $12D, $199,	 $22
		dc.w	 1, $139, $1AB,	 $3A

Map_BossItems:	dc.w word_19458-Map_BossItems
		dc.w word_19462-Map_BossItems
		dc.w word_19474-Map_BossItems
		dc.w word_1947E-Map_BossItems
		dc.w word_19488-Map_BossItems
		dc.w word_19492-Map_BossItems
		dc.w word_194B4-Map_BossItems
		dc.w word_194C6-Map_BossItems
word_19458:	dc.w 1
		dc.w $F805,    0,    0,$FFF8
word_19462:	dc.w 2
		dc.w $FC04,    4,    2,$FFF8
		dc.w $F805,    0,    0,$FFF8
word_19474:	dc.w 1
		dc.w $FC00,    6,    3,$FFFC
word_1947E:	dc.w 1
		dc.w $1409,    7,    3,$FFF4
word_19488:	dc.w 1
		dc.w $1405,   $D,    6,$FFF8
word_19492:	dc.w 4
		dc.w $F004,  $11,    8,$FFF8
		dc.w $F801,  $13,    9,$FFF8
		dc.w $F801, $813, $809,	   0
		dc.w  $804,  $15,   $A,$FFF8
word_194B4:	dc.w 2
		dc.w	 5,  $17,   $B,	   0
		dc.w	 0,  $1B,   $D,	 $10
word_194C6:	dc.w 2
		dc.w $1804,  $1C,   $E,	   0
		dc.w	$B,  $1E,   $F,	 $10

		jmpTos0	JmpTo3_Adjust2PArtPointer2,JmpTo6_Adjust2PArtPointer
; ===========================================================================

		include	"obj/S1/3E Prison Capsule.asm"

Ani_Pri:	dc.w byte_19730-Ani_Pri
		dc.w byte_19730-Ani_Pri
byte_19730:	dc.b   2,  1,  3,$FF
		even

Map_Pri:	dc.w word_19742-Map_Pri
		dc.w word_1977C-Map_Pri
		dc.w word_19786-Map_Pri
		dc.w word_197B8-Map_Pri
		dc.w word_197C2-Map_Pri
		dc.w word_197D4-Map_Pri
		dc.w word_197DE-Map_Pri
word_19742:	dc.w 7
		dc.w $E00C,$2000,$2000,$FFF0
		dc.w $E80D,$2004,$2002,$FFE0
		dc.w $E80D,$200C,$2006,	   0
		dc.w $F80E,$2014,$200A,$FFE0
		dc.w $F80E,$2020,$2010,	   0
		dc.w $100D,$202C,$2016,$FFE0
		dc.w $100D,$2034,$201A,	   0
word_1977C:	dc.w 1
		dc.w $F809,  $3C,  $1E,$FFF4
word_19786:	dc.w 6
		dc.w	 8,$2042,$2021,$FFE0
		dc.w  $80C,$2045,$2022,$FFE0
		dc.w	 4,$2049,$2024,	 $10
		dc.w  $80C,$204B,$2025,	   0
		dc.w $100D,$202C,$2016,$FFE0
		dc.w $100D,$2034,$201A,	   0
word_197B8:	dc.w 1
		dc.w $F809,  $4F,  $27,$FFF4
word_197C2:	dc.w 2
		dc.w $E80E,$2055,$202A,$FFF0
		dc.w	$E,$2061,$2030,$FFF0
word_197D4:	dc.w 1
		dc.w $F007,$206D,$2036,$FFF8
word_197DE:	dc.w 0

		jmpTos0	JmpTo7_Adjust2PArtPointer
; ===========================================================================

		include	"obj/sub TouchResponse.asm"

		jmpTos	JmpTo_Sonic_ResetOnFloor,JmpTo_Touch_Rings

; =============== S U B	R O U T	I N E =======================================

; leftover from Sonic 1

S1SS_ShowLayout:
		bsr.w	sub_19CC2
		bsr.w	sub_19F02
		move.w	d5,-(sp)
		lea	(v_ssbuffer3).w,a1
		move.b	(v_ssangle).w,d0
		andi.b	#$FC,d0
		jsr	(CalcSine).l
		move.w	d0,d4
		move.w	d1,d5
		muls.w	#$18,d4
		muls.w	#$18,d5
		moveq	#0,d2
		move.w	(Camera_X_pos).w,d2
		divu.w	#$18,d2
		swap	d2
		neg.w	d2
		addi.w	#-$B4,d2
		moveq	#0,d3
		move.w	(Camera_Y_pos).w,d3
		divu.w	#$18,d3
		swap	d3
		neg.w	d3
		addi.w	#-$B4,d3
		move.w	#$10-1,d7

loc_19BD0:
		movem.w	d0-d2,-(sp)
		movem.w	d0-d1,-(sp)
		neg.w	d0
		muls.w	d2,d1
		muls.w	d3,d0
		move.l	d0,d6
		add.l	d1,d6
		movem.w	(sp)+,d0-d1
		muls.w	d2,d0
		muls.w	d3,d1
		add.l	d0,d1
		move.l	d6,d2
		move.w	#$10-1,d6

loc_19BF2:
		move.l	d2,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		move.l	d1,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		add.l	d5,d2
		add.l	d4,d1
		dbf	d6,loc_19BF2
		movem.w	(sp)+,d0-d2
		addi.w	#$18,d3
		dbf	d7,loc_19BD0
		move.w	(sp)+,d5
		lea	(v_ssbuffer1).l,a0
		moveq	#0,d0
		move.w	(Camera_Y_pos).w,d0
		divu.w	#$18,d0
		mulu.w	#$80,d0
		adda.l	d0,a0
		moveq	#0,d0
		move.w	(Camera_X_pos).w,d0
		divu.w	#$18,d0
		adda.w	d0,a0
		lea	(v_ssbuffer3).w,a4
		move.w	#$10-1,d7

loc_19C3E:
		move.w	#$10-1,d6

loc_19C42:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	loc_19C9A
		cmpi.b	#$4E,d0
		bhi.s	loc_19C9A
		move.w	(a4),d3
		addi.w	#$120,d3
		cmpi.w	#$70,d3
		blo.s	loc_19C9A
		cmpi.w	#$1D0,d3
		bhs.s	loc_19C9A
		move.w	2(a4),d2
		addi.w	#$F0,d2
		cmpi.w	#$70,d2
		blo.s	loc_19C9A
		cmpi.w	#$170,d2
		bhs.s	loc_19C9A
		lea	(v_ssbuffer2).l,a5
		lsl.w	#3,d0
		lea	(a5,d0.w),a5
		movea.l	(a5)+,a1
		move.w	(a5)+,d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		movea.w	(a5)+,a3
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	loc_19C9A
		jsr	(loc_D1CE).l

loc_19C9A:
		addq.w	#4,a4
		dbf	d6,loc_19C42
		lea	$70(a0),a0
		dbf	d7,loc_19C3E
		move.b	d5,(v_spritecount).w
		cmpi.b	#80,d5
		beq.s	loc_19CBA
		move.l	#0,(a2)
		rts
; ---------------------------------------------------------------------------

loc_19CBA:
		move.b	#0,-5(a2)
		rts
; End of function S1SS_ShowLayout


; =============== S U B	R O U T	I N E =======================================


sub_19CC2:
		lea	(v_ssbuffer2+$C).l,a1
		moveq	#0,d0
		move.b	(v_ssangle).w,d0
		lsr.b	#2,d0
		andi.w	#$F,d0
		moveq	#$23,d1

loc_19CD6:
		move.w	d0,(a1)
		addq.w	#8,a1
		dbf	d1,loc_19CD6
		lea	(v_ssbuffer2+5).l,a1
		subq.b	#1,(v_ani1_time).w
		bpl.s	loc_19CFA
		move.b	#7,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#3,(v_ani1_frame).w

loc_19CFA:
		move.b	(v_ani1_frame).w,$1D0(a1)
		subq.b	#1,(v_ani2_time).w
		bpl.s	loc_19D16
		move.b	#7,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		andi.b	#1,(v_ani2_frame).w

loc_19D16:
		move.b	(v_ani2_frame).w,d0
		move.b	d0,$138(a1)
		move.b	d0,$160(a1)
		move.b	d0,$148(a1)
		move.b	d0,$150(a1)
		move.b	d0,$1D8(a1)
		move.b	d0,$1E0(a1)
		move.b	d0,$1E8(a1)
		move.b	d0,$1F0(a1)
		move.b	d0,$1F8(a1)
		move.b	d0,$200(a1)
		subq.b	#1,(v_ani3_time).w
		bpl.s	loc_19D58
		move.b	#4,(v_ani3_time).w
		addq.b	#1,(v_ani3_frame).w
		andi.b	#3,(v_ani3_frame).w

loc_19D58:
		move.b	(v_ani3_frame).w,d0
		move.b	d0,$168(a1)
		move.b	d0,$170(a1)
		move.b	d0,$178(a1)
		move.b	d0,$180(a1)
		subq.b	#1,(v_ani0_time).w
		bpl.s	loc_19D82
		move.b	#7,(v_ani0_time).w
		subq.b	#1,(v_ani0_frame).w
		andi.b	#7,(v_ani0_frame).w

loc_19D82:
		lea	(v_ssbuffer2+$16).l,a1
		lea	(S1SS_WaRiVramSet).l,a0
		moveq	#0,d0
		move.b	(v_ani0_frame).w,d0
		add.w	d0,d0
		lea	(a0,d0.w),a0
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		rts
; End of function sub_19CC2

; ---------------------------------------------------------------------------
S1SS_WaRiVramSet:
		dc.w $142,$6142,$142,$142,$142,$142,$142,$6142
		dc.w $142,$6142,$142,$142,$142,$142,$142,$6142
		dc.w $2142,$142,$2142,$2142,$2142,$2142,$2142,$142
		dc.w $2142,$142,$2142,$2142,$2142,$2142,$2142,$142
		dc.w $4142,$2142,$4142,$4142,$4142,$4142,$4142,$2142
		dc.w $4142,$2142,$4142,$4142,$4142,$4142,$4142,$2142
		dc.w $6142,$4142,$6142,$6142,$6142,$6142,$6142,$4142
		dc.w $6142,$4142,$6142,$6142,$6142,$6142,$6142,$4142

; =============== S U B	R O U T	I N E =======================================


sub_19EEC:
		lea	(v_ssitembuffer).l,a2
		move.w	#(v_ssitembuffer_end-v_ssitembuffer)/8-1,d0

loc_19EF6:
		tst.b	(a2)
		beq.s	locret_19F00
		addq.w	#8,a2
		dbf	d0,loc_19EF6

locret_19F00:
		rts
; End of function sub_19EEC


; =============== S U B	R O U T	I N E =======================================


sub_19F02:
		lea	(v_ssitembuffer).l,a0
		move.w	#(v_ssitembuffer_end-v_ssitembuffer)/8-1,d7

loc_19F0C:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_19F1A
		lsl.w	#2,d0
		movea.l	S1SS_AniIndex-4(pc,d0.w),a1
		jsr	(a1)

loc_19F1A:
		addq.w	#8,a0

loc_19F1C:
		dbf	d7,loc_19F0C
		rts
; End of function sub_19F02

; ---------------------------------------------------------------------------
S1SS_AniIndex:
		dc.l loc_19F3A
		dc.l loc_19F6A
		dc.l loc_19FA0
		dc.l loc_19FD0
		dc.l loc_1A006
		dc.l loc_1A046
; ---------------------------------------------------------------------------

loc_19F3A:
		subq.b	#1,2(a0)
		bpl.s	locret_19F62
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_19F64(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_19F62
		clr.l	(a0)
		clr.l	4(a0)

locret_19F62:
		rts
; ---------------------------------------------------------------------------
byte_19F64:	dc.b $42,$43,$44,$45,0,0
; ---------------------------------------------------------------------------

loc_19F6A:
		subq.b	#1,2(a0)
		bpl.s	locret_19F98
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_19F9A(pc,d0.w),d0
		bne.s	loc_19F96
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$25,(a1)
		rts
; ---------------------------------------------------------------------------

loc_19F96:
		move.b	d0,(a1)

locret_19F98:
		rts
; ---------------------------------------------------------------------------
byte_19F9A:	dc.b $32,$33,$32,$33,0,0
; ---------------------------------------------------------------------------

loc_19FA0:
		subq.b	#1,2(a0)
		bpl.s	locret_19FC8
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_19FCA(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_19FC8
		clr.l	(a0)
		clr.l	4(a0)

locret_19FC8:
		rts
; ---------------------------------------------------------------------------
byte_19FCA:	dc.b $46,$47,$48,$49,0,0
; ---------------------------------------------------------------------------

loc_19FD0:
		subq.b	#1,2(a0)
		bpl.s	locret_19FFE
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_1A000(pc,d0.w),d0
		bne.s	loc_19FFC
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$2B,(a1)
		rts
; ---------------------------------------------------------------------------

loc_19FFC:
		move.b	d0,(a1)

locret_19FFE:
		rts
; ---------------------------------------------------------------------------
byte_1A000:	dc.b $2B,$31,$2B,$31,0,0
; ---------------------------------------------------------------------------

loc_1A006:
		subq.b	#1,2(a0)
		bpl.s	locret_1A03E
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_1A040(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1A03E
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#4,(v_objspace+obRoutine).w
		move.w	#sfx_SSGoal,d0
		jsr	(QueueSound2).l

locret_1A03E:
		rts
; ---------------------------------------------------------------------------
byte_1A040:	dc.b $46,$47,$48,$49,0,0
; ---------------------------------------------------------------------------

loc_1A046:
		subq.b	#1,2(a0)
		bpl.s	locret_1A072
		move.b	#1,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	byte_1A074(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1A072
		move.b	4(a0),(a1)
		clr.l	(a0)
		clr.l	4(a0)

locret_1A072:
		rts
; ---------------------------------------------------------------------------
byte_1A074:	dc.b $4B,$4C,$4D,$4E,$4B,$4C,$4D,$4E,0,0

S1SS_LayoutIndex:
		dc.l S1SS_1
		dc.l S1SS_2
		dc.l S1SS_3
		dc.l S1SS_4
		dc.l S1SS_5
		dc.l S1SS_6

S1SS_StartLoc:
		dc.w  $3D0, $2E0
		dc.w  $328, $574
		dc.w  $4E4, $2E0
		dc.w  $3AD, $2E0
		dc.w  $340, $6B8
		dc.w  $49B, $358

; =============== S U B	R O U T	I N E =======================================


S1SS_Load:
		moveq	#0,d0
		move.b	(v_lastspecial).w,d0
		addq.b	#1,(v_lastspecial).w
		cmpi.b	#6,(v_lastspecial).w
		blo.s	loc_1A0C6
		move.b	#0,(v_lastspecial).w

loc_1A0C6:
		cmpi.b	#6,(v_emeralds).w
		beq.s	loc_1A0E8
		moveq	#0,d1
		move.b	(v_emeralds).w,d1
		subq.b	#1,d1
		blo.s	loc_1A0E8
		lea	(v_emldlist).w,a3

loc_1A0DC:
		cmp.b	(a3,d1.w),d0
		bne.s	loc_1A0E4
		bra.s	S1SS_Load
; ---------------------------------------------------------------------------

loc_1A0E4:
		dbf	d1,loc_1A0DC

loc_1A0E8:
		lsl.w	#2,d0
		lea	S1SS_StartLoc(pc,d0.w),a1
		move.w	(a1)+,(v_player+obX).w
		move.w	(a1)+,(v_player+obY).w
		movea.l	S1SS_LayoutIndex(pc,d0.w),a0
		lea	(v_ssbuffer2).l,a1
		move.w	#make_art_tile(ArtTile_SS_Background_Clouds,0,0),d0
		jsr	(EniDec).l
		lea	(v_ssbuffer1).l,a1
		move.w	#bytesToLcnt(v_ssbuffer2-v_ssbuffer1),d0

loc_1A114:
		clr.l	(a1)+
		dbf	d0,loc_1A114
		lea	(v_ssblockbuffer).l,a1
		lea	(v_ssbuffer2).l,a0
		moveq	#bytesToXcnt(v_ssblockbuffer_end-v_ssblockbuffer,$80),d1

loc_1A128:
		moveq	#$40-1,d2

loc_1A12A:
		move.b	(a0)+,(a1)+
		dbf	d2,loc_1A12A
		lea	$40(a1),a1
		dbf	d1,loc_1A128
		lea	(v_ssblocktypes+8).l,a1
		lea	(S1SS_MapIndex).l,a0
		moveq	#bytesToXcnt(S1SS_MapIndex_End-S1SS_MapIndex,6),d1

loc_1A146:
		move.l	(a0)+,(a1)+
		move.w	#0,(a1)+
		move.b	-4(a0),-1(a1)
		move.w	(a0)+,(a1)+
		dbf	d1,loc_1A146
		lea	(v_ssitembuffer).l,a1
		move.w	#bytesToLcnt(v_ssitembuffer_end-v_ssitembuffer),d1

loc_1A162:
		clr.l	(a1)+
		dbf	d1,loc_1A162
		rts
; End of function S1SS_Load

; ---------------------------------------------------------------------------
S1SS_MapIndex:
		include	"_Include/Special Stage Mappings & VRAM Pointers.asm"
S1SS_MapIndex_End:
; ===========================================================================
; Rather humourously, these sprite mappings are stored in the Sonic 1 format
; ---------------------------------------------------------------------------
; Sprite mappings - 'R'
; ---------------------------------------------------------------------------
Map_SS_R:	include	"mappings/sprite/S1/SS R Block.asm"
; ---------------------------------------------------------------------------
; Sprite mappings - Glass
; ---------------------------------------------------------------------------
Map_SS_Glass:	include	"mappings/sprite/S1/SS Glass Block.asm"
; ---------------------------------------------------------------------------
; Sprite mappings - 'Up'
; ---------------------------------------------------------------------------
Map_SS_Up:	include	"mappings/sprite/S1/SS UP Block.asm"
; ---------------------------------------------------------------------------
; Sprite mappings - 'Down'
; ---------------------------------------------------------------------------
Map_SS_Down:	include	"mappings/sprite/S1/SS DOWN Block.asm"
; ---------------------------------------------------------------------------
; Sprite mappings - Chaos Emeralds
; ---------------------------------------------------------------------------
		include	"mappings/sprite/S1/SS Chaos Emeralds.asm"

		jmpTos	; Empty
; ===========================================================================

		include	"obj/S1/09 Sonic in Special Stage.asm"
		include	"obj/10.asm"

		jmpTos0	JmpTo8_Adjust2PArtPointer

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to animate stage art
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; DynamicArtCues:
AniArt_Load:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	DynArtCue_Index+2(pc,d0.w),d1
		lea	DynArtCue_Index(pc,d1.w),a2
		move.w	DynArtCue_Index(pc,d0.w),d0
		jmp	DynArtCue_Index(pc,d0.w)
; ---------------------------------------------------------------------------
		rts
; End of function AniArt_Load

; ---------------------------------------------------------------------------
; ZONE ANIMATION PROCEDURES AND SCRIPTS
;
; Each zone gets two entries in this jump table. The first entry points to the
; zone's animation procedure (usually Dynamic_Null, AKA none). The second points
; to the zone's animation script.
;
; Seems like stage IDs were already being shifted, since listings for $07-$0F
; can be found, alongside HPZ's art listed from $08 (its ID in the final).
; ---------------------------------------------------------------------------
DynArtCue_Index:
		dc.w Dynamic_NullGHZ-DynArtCue_Index	; GHZ
		dc.w AnimCue_EHZ-DynArtCue_Index		; GHZ
		dc.w Dynamic_Null-DynArtCue_Index		; LZ
		dc.w AnimCue_CPZ_Boss-DynArtCue_Index	; LZ
		dc.w Dynamic_Null-DynArtCue_Index		; CPZ
		dc.w AnimCue_CPZ_Boss-DynArtCue_Index	; CPZ
		dc.w Dynamic_Normal-DynArtCue_Index		; EHZ
		dc.w AnimCue_EHZ-DynArtCue_Index		; EHZ
		dc.w Dynamic_Normal-DynArtCue_Index		; HPZ
		dc.w AnimCue_HPZ-DynArtCue_Index		; HPZ
		dc.w Dynamic_Normal-DynArtCue_Index		; HTZ
		dc.w AnimCue_EHZ-DynArtCue_Index		; HTZ
		dc.w Dynamic_Null-DynArtCue_Index		; 06
		dc.w AnimCue_CPZ_Boss-DynArtCue_Index	; 06
		dc.w Dynamic_Null-DynArtCue_Index		; 07
		dc.w AnimCue_CPZ_Boss-DynArtCue_Index	; 07
		dc.w Dynamic_Normal-DynArtCue_Index		; 08
		dc.w AnimCue_HPZ-DynArtCue_Index		; 08
		dc.w Dynamic_Null-DynArtCue_Index		; 09
		dc.w AnimCue_CPZ_Boss-DynArtCue_Index	; 09
		dc.w Dynamic_Null-DynArtCue_Index		; 0A
		dc.w AnimCue_CPZ_Boss-DynArtCue_Index	; 0A
		dc.w Dynamic_Null-DynArtCue_Index		; 0B
		dc.w AnimCue_CPZ_Boss-DynArtCue_Index	; 0B
		dc.w Dynamic_Null-DynArtCue_Index		; 0C
		dc.w AnimCue_CPZ_Boss-DynArtCue_Index	; 0C
		dc.w Dynamic_Null-DynArtCue_Index		; 0D
		dc.w AnimCue_CPZ_Boss-DynArtCue_Index	; 0D
		dc.w Dynamic_Null-DynArtCue_Index		; 0E
		dc.w AnimCue_CPZ_Boss-DynArtCue_Index	; 0E
		dc.w Dynamic_Null-DynArtCue_Index		; 0F
		dc.w AnimCue_CPZ_Boss-DynArtCue_Index	; 0F
; ===========================================================================

Dynamic_Null:
		rts
; ===========================================================================

Dynamic_NullGHZ:
		rts
; ===========================================================================

Dynamic_Normal:
		lea	(Anim_Counters).w,a3
		move.w	(a2)+,d6			; Get number of scripts in list

loc_1AACA:
		subq.b	#1,(a3)				; Tick down frame duration
		bpl.s	loc_1AB10			; If frame isn't over, move on to next script

		moveq	#0,d0
		move.b	1(a3),d0			; Get current frame
		cmp.b	6(a2),d0			; Have we processed the last frame in the script?
		blo.s	loc_1AAE0
		moveq	#0,d0				; If so, reset to first frame
		move.b	d0,1(a3)

loc_1AAE0:
		addq.b	#1,1(a3)			; Consider this frame processed; set counter to next frame
		move.b	(a2),(a3)			; Set frame duration to global duration value
		bpl.s	loc_1AAEE
		; If script uses per-frame durations, use those instead
		add.w	d0,d0
		move.b	9(a2,d0.w),(a3)			; Set frame duration to current frame's duration value

loc_1AAEE:
		; Prepare for DMA transfer
		; Get relative address of frame's art
		move.b	8(a2,d0.w),d0			; Get tile ID
		lsl.w	#5,d0				; Turn it into an offset
		; Get VRAM destination address
		move.w	4(a2),d2
		; Get ROM source address
		move.l	(a2),d1				; Get start address of animated tile art
		andi.l	#$FFFFFF,d1
		add.l	d0,d1				; Offset into art, to get the address of new frame
		; Get size of art to be transferred
		moveq	#0,d3
		move.b	7(a2),d3
		lsl.w	#4,d3				; Turn it into actual size (in words)
		; Use d1, d2 and d3 to queue art for transfer
		jsr	(QueueDMATransfer).l

loc_1AB10:
		move.b	6(a2),d0			; Get total size of frame data
		tst.b	(a2)				; Is per-frame duration data present?
		bpl.s	loc_1AB1A			; If not, keep the current size; it's correct
		add.b	d0,d0				; Double size to account for the additional frame duration data

loc_1AB1A:
		addq.b	#1,d0
		andi.w	#$FE,d0				; Round to next even address, if it isn't already
		lea	8(a2,d0.w),a2			; Advance to next script in list
		addq.w	#2,a3				; Advance to next script's slot in a3 (usually Anim_Counters)
		dbf	d6,loc_1AACA
		rts
; ===========================================================================
AnimCue_EHZ:	zoneanimstart
		; Flowers
		zoneanimdecl -1, Art_Flowers1, ArtTile_Art_Flowers1, 6, 2
		dc.b   0,$7F		; Start of the script proper
		dc.b   2,$13
		dc.b   0,  7
		dc.b   2,  7
		dc.b   0,  7
		dc.b   2,  7
		even
		; Flowers
		zoneanimdecl -1, Art_Flowers2, ArtTile_Art_Flowers2, 8, 2
		dc.b   2,$7F
		dc.b   0, $B
		dc.b   2, $B
		dc.b   0, $B
		dc.b   2,  5
		dc.b   0,  5
		dc.b   2,  5
		dc.b   0,  5
		even
		; Flowers
		zoneanimdecl 7, Art_Flowers3, ArtTile_Art_Flowers3, 2, 2
		dc.b   0
		dc.b   2
		even
		; Flowers
		zoneanimdecl -1, Art_Flowers4, ArtTile_Art_Flowers4, 8, 2
		dc.b   0,$7F
		dc.b   2,  7
		dc.b   0,  7
		dc.b   2,  7
		dc.b   0,  7
		dc.b   2, $B
		dc.b   0, $B
		dc.b   2, $B
		even
		; Pulsing thing against checkered background
		zoneanimdecl 1, Art_EHZPulseBall, ArtTile_Art_EHZPulseBall, 6, 2
		dc.b   0,  2
		dc.b   4,  6
		dc.b   4,  2
		even

		zoneanimend

AnimCue_HPZ:	zoneanimstart
		; Pulsing orb from HPZ
		zoneanimdecl 8, Art_HPZPulseOrb, ArtTile_Art_HPZPulseOrb_1, 6, 8
		dc.b   0
		dc.b   0
		dc.b   8
		dc.b $10
		dc.b $10
		dc.b   8
		even
		; Pulsing orb from HPZ
		zoneanimdecl 8, Art_HPZPulseOrb, ArtTile_Art_HPZPulseOrb_2, 6, 8
		dc.b   8
		dc.b $10
		dc.b $10
		dc.b   8
		dc.b   0
		dc.b   0
		even
		; Pulsing orb from HPZ
		zoneanimdecl 8, Art_HPZPulseOrb, ArtTile_Art_HPZPulseOrb_3, 6, 8
		dc.b $10
		dc.b   8
		dc.b   0
		dc.b   0
		dc.b   8
		dc.b $10
		even

		zoneanimend

; According to leftover resizing code, this was meant for the
; Chemical Plant Zone boss, which symbol tables refer to as "vaccume".
AnimCue_CPZ_Boss:	zoneanimstart
		; Lights
		zoneanimdecl 7, Art_CPZ_Lights, ArtTile_CPZ_Lights, 2, 4
		dc.b   0
		dc.b   4
		even
		; Conveyor
		zoneanimdecl 7, Art_CPZ_Conveyor, ArtTile_CPZ_Conveyor, 3, 8
		dc.b   0
		dc.b   8
		dc.b $10
		dc.b   0
		even
		; Pistons
		zoneanimdecl 7, Art_CPZ_Pistons, ArtTile_CPZ_Pistons, 4, 2
		dc.b   0
		dc.b   2
		dc.b   0
		dc.b   4
		even
		; Pressure Metre
		zoneanimdecl $B, Art_CPZ_Metre, ArtTile_CPZ_Metre, 4, 2
		dc.b   0
		dc.b   2
		dc.b   4
		dc.b   2
		even
		; Cross and Circle
		zoneanimdecl $F, Art_CPZ_Cross_Circle, ArtTile_CPZ_Cross_Circle, $A, 1
		dc.b   0
		dc.b   0
		dc.b   1
		dc.b   2
		dc.b   3
		dc.b   4
		dc.b   5
		dc.b   4
		dc.b   5
		dc.b   4
		even
		; Propeller
		zoneanimdecl 3, Art_CPZ_Propeller, ArtTile_CPZ_Propeller, 4, 4
		dc.b   0
		dc.b   4
		dc.b   8
		dc.b   4
		even
		; Surface Liquid
		zoneanimdecl 7, Art_CPZ_Liquid, ArtTile_CPZ_Liquid, 6, 3
		dc.b   0
		dc.b   3
		dc.b   6
		dc.b   9
		dc.b  $C
		dc.b  $F
		even
		; Conveyor
		zoneanimdecl 7, Art_CPZ_Conveyor_2, ArtTile_CPZ_Conveyor_2, 4, 1
		dc.b   0
		dc.b   1
		dc.b   2
		dc.b   3
		even

		zoneanimend

; ===========================================================================
; ---------------------------------------------------------------------------
; This seems to be a subroutine that would've shifted the background blocks
; of Chemical Plant Zone once the player reached a certain X position,
; lasting exactly two screens. This can also be found in the final at
; $40200 in the ROM, with the only difference being its level ID, which
; was updated to match Chemical Plant's final ID ($0D instead of 02)
;
; To see the effect for yourself, add a branch to it at the
; start of LoadTilesAsYouMove and change $FFFF7500/$FFFF7D00 to
; $FFFF0000/$FFFF0800 (to make it more visible)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; sub_1AC1E: ShiftCPZBackground:
		cmpi.b	#id_CPZ,(Current_Zone).w	; is this Chemical Plant Zone?
		beq.s	loc_1AC28			; if yes, branch

locret_1AC26:
		rts
; ===========================================================================
; this shifts all blocks of the chunks $EA-$ED and $FA-$FD one block to the
; left and the last block in each row (chunk $ED/$FD) to the beginning
; i.e. rotates the blocks to the left by one

loc_1AC28:
		move.w	(Camera_X_pos).w,d0
		cmpi.w	#$1940,d0
		blo.s	locret_1AC26
		cmpi.w	#$1F80,d0
		bhs.s	locret_1AC26
		subq.b	#1,(CPZ_UnkScroll_Timer).w
		bpl.s	locret_1AC26
		move.b	#7,(CPZ_UnkScroll_Timer).w
		move.b	#1,(Screen_redraw_flag).w
		lea	(v_ram_start+$7500).l,a1
		bsr.s	sub_1AC58
		lea	(v_ram_start+$7D00).l,a1

sub_1AC58:
		move.w	#8-1,d1

loc_1AC5C:
		move.w	(a1),d0
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		adda.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		adda.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		adda.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	d0,(a1)+
		suba.w	#$180,a1
		dbf	d1,loc_1AC5C
		rts
; End of function ShiftCPZBackground

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load animated blocks
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; LoadMap16Delta:
LoadAnimatedBlocks:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		move.w	AnimPatMaps(pc,d0.w),d0
		lea	AnimPatMaps(pc,d0.w),a0
		tst.w	(a0)
		beq.s	locret_1AD1A
		lea	(v_16x16).w,a1
		adda.w	(a0)+,a1
		move.w	(a0)+,d1
		tst.w	(Two_player_mode).w
		bne.s	LoadLevelBlocks_2P
; loc_1AD14:
LoadLevelBlocks:
		move.w	(a0)+,(a1)+
		dbf	d1,LoadLevelBlocks

locret_1AD1A:
		rts
; ---------------------------------------------------------------------------
; loc_1AD1C:
LoadLevelBlocks_2P:
		move.w	(a0)+,d0
	if FixBugs
		move.w	d0,d2
		andi.w	#nontile_mask,d0	; d0 holds the preserved non-tile data
		andi.w	#tile_mask,d2		; d2 holds the tile index
		lsr.w	#1,d2			; half tile index
		or.w	d2,d0			; put them back together
	else
		; Bug: 'd1', the loop counter, is overwritten with VRAM data.
		; To fix this, change 'd1' to 'd2'.
		move.w	d0,d1
		andi.w	#nontile_mask,d0	; d0 holds the preserved non-tile data
		andi.w	#tile_mask,d1		; d1 holds the tile index (overwrites loop counter!)
		lsr.w	#1,d1			; half tile index
		or.w	d1,d0			; put them back together
	endif
		move.w	d0,(a1)+
		dbf	d1,LoadLevelBlocks_2P
		rts
; End of function LoadAnimatedBlocks

; ===========================================================================
; like with the animated stage art, this already lists stages up to $0F and
; includes an entry for the final HPZ level slot, and this time even lists
; CPZ's final level slot
; Map16Delta_Index:
AnimPatMaps:
		dc.w APM_EHZ-AnimPatMaps	; GHZ
		dc.w APM_None-AnimPatMaps	; LZ
		dc.w APM_CPZ-AnimPatMaps	; CPZ
		dc.w APM_EHZ-AnimPatMaps	; EHZ
		dc.w APM_HPZ-AnimPatMaps	; HPZ
		dc.w APM_EHZ-AnimPatMaps	; HTZ
		dc.w APM_None-AnimPatMaps	; 06
		dc.w APM_None-AnimPatMaps	; 07
		dc.w APM_HPZ-AnimPatMaps	; 08
		dc.w APM_None-AnimPatMaps	; 09
		dc.w APM_None-AnimPatMaps	; 0A
		dc.w APM_None-AnimPatMaps	; 0B
		dc.w APM_None-AnimPatMaps	; 0C
		dc.w APM_CPZ-AnimPatMaps	; 0D
		dc.w APM_None-AnimPatMaps	; 0E
		dc.w APM_None-AnimPatMaps	; 0F

begin_animpat macro {INTLABEL}
__LABEL__ label *
__LABEL___Len := __LABEL___End - __LABEL___Blocks
	dc.w Block_Table_End-Block_Table - __LABEL___Len
	dc.w bytesToWcnt(__LABEL___Len)
__LABEL___Blocks:
    endm

APM_EHZ:	begin_animpat
		dc.w make_block_tile(ArtTile_Art_EHZMountains+$2,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$4,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_EHZMountains+$3,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$5,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_EHZMountains+$6,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$8,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_EHZMountains+$7,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$9,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_EHZMountains+$A,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$C,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_EHZMountains+$B,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$D,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_EHZMountains+$E,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$10,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_EHZMountains+$F,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$11,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_EHZMountains+$12,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$14,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_EHZMountains+$13,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$15,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_EHZMountains+$16,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$18,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_EHZMountains+$17,0,0,2,0),make_block_tile(ArtTile_Art_EHZMountains+$19,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_EHZMountains+$1A,0,0,3,0),make_block_tile(ArtTile_Art_EHZMountains+$1C,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_EHZMountains+$1B,0,0,3,0),make_block_tile(ArtTile_Art_EHZMountains+$1D,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_EHZMountains+$1E,0,0,3,0),make_block_tile(ArtTile_Art_EHZMountains+$20,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_EHZMountains+$1F,0,0,3,0),make_block_tile(ArtTile_Art_EHZMountains+$21,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_EHZPulseBall+$0,0,0,2,0),make_block_tile(ArtTile_Art_EHZPulseBall+$0,1,0,2,0)
		dc.w make_block_tile(ArtTile_Art_EHZPulseBall+$1,0,0,2,0),make_block_tile(ArtTile_Art_EHZPulseBall+$1,1,0,2,0)

		dc.w make_block_tile(ArtTile_Checkers+$0,0,0,2,0),make_block_tile(ArtTile_Art_EHZPulseBall+$0,0,0,2,0)
		dc.w make_block_tile(ArtTile_Checkers+$1,0,0,2,0),make_block_tile(ArtTile_Art_EHZPulseBall+$1,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_EHZPulseBall+$0,1,0,2,0),make_block_tile(ArtTile_Checkers+$0,1,0,2,0)
		dc.w make_block_tile(ArtTile_Art_EHZPulseBall+$1,1,0,2,0),make_block_tile(ArtTile_Checkers+$1,1,0,2,0)

		dc.w make_block_tile(ArtTile_Art_Flowers1+$0,0,0,3,0),make_block_tile(ArtTile_Art_Flowers1+$0,1,0,3,0)
		dc.w make_block_tile(ArtTile_Art_Flowers1+$1,0,0,3,0),make_block_tile(ArtTile_Art_Flowers1+$1,1,0,3,0)

		dc.w make_block_tile(ArtTile_Art_Flowers2+$0,0,0,3,1),make_block_tile(ArtTile_Art_Flowers2+$0,1,0,3,1)
		dc.w make_block_tile(ArtTile_Art_Flowers2+$1,0,0,3,1),make_block_tile(ArtTile_Art_Flowers2+$1,1,0,3,1)

		dc.w make_block_tile(ArtTile_Art_Flowers3+$0,0,0,3,0),make_block_tile(ArtTile_Art_Flowers3+$0,1,0,3,0)
		dc.w make_block_tile(ArtTile_Art_Flowers3+$1,0,0,3,0),make_block_tile(ArtTile_Art_Flowers3+$1,1,0,3,0)

		dc.w make_block_tile(ArtTile_Art_Flowers4+$0,0,0,3,1),make_block_tile(ArtTile_Art_Flowers4+$0,1,0,3,1)
		dc.w make_block_tile(ArtTile_Art_Flowers4+$1,0,0,3,1),make_block_tile(ArtTile_Art_Flowers4+$1,1,0,3,1)
APM_EHZ_End:

APM_None:	dc.w 0
APM_None_End:

APM_Unk:
		dc.w (Block_Table_End-Block_Table)-$B80 ; Bug: This should be (Block_Table_End-Block_Table)-$138
		dc.w bytesToWcnt($138)
		dc.w make_block_tile($3A0+$1,0,0,2,0),make_block_tile($3A0+$2,0,0,2,0)
		dc.w make_block_tile($3A0+$3,0,0,2,0),make_block_tile($3A0+$4,0,0,2,0)

		dc.w make_block_tile($3A0+$5,0,0,2,0),make_block_tile($3A0+$6,0,0,2,0)
		dc.w make_block_tile($3A0+$7,0,0,2,0),make_block_tile($3A0+$8,0,0,2,0)

		dc.w make_block_tile($3A0+$9,0,0,2,0),make_block_tile($3A0+$A,0,0,2,0)
		dc.w make_block_tile($3A0+$B,0,0,2,0),make_block_tile($3A0+$C,0,0,2,0)

		dc.w make_block_tile($3A0+$D,0,0,2,0),make_block_tile($3A0+$E,0,0,2,0)
		dc.w make_block_tile($3A0+$F,0,0,2,0),make_block_tile($3A0+$10,0,0,2,0)

		dc.w make_block_tile($3A0+$11,0,0,2,0),make_block_tile($3A0+$12,0,0,2,0)
		dc.w make_block_tile($3A0+$13,0,0,2,0),make_block_tile($3A0+$14,0,0,2,0)

		dc.w make_block_tile($3A0+$15,0,0,2,0),make_block_tile($3A0+$16,0,0,2,0)
		dc.w make_block_tile($3A0+$17,0,0,2,0),make_block_tile($3A0+$18,0,0,2,0)

		dc.w make_block_tile($3A0+$19,0,0,2,0),make_block_tile($3A0+$1A,0,0,2,0)
		dc.w make_block_tile($3A0+$1B,0,0,2,0),make_block_tile($3A0+$1C,0,0,2,0)

		dc.w make_block_tile($3A0+$1D,0,0,2,0),make_block_tile($3A0+$1E,0,0,2,0)
		dc.w make_block_tile($3A0+$1F,0,0,2,0),make_block_tile($3A0+$20,0,0,2,0)

		dc.w make_block_tile($3A0+$21,0,0,2,0),make_block_tile($3A0+$22,0,0,2,0)
		dc.w make_block_tile($3A0+$23,0,0,2,0),make_block_tile($3A0+$24,0,0,2,0)

		dc.w make_block_tile($3A0+$0,0,0,3,0),make_block_tile($3A0+$0,0,0,3,0)
		dc.w make_block_tile($3A0+$0,0,0,3,0),make_block_tile($3A0+$0,0,0,3,0)

		dc.w make_block_tile($3A0+$0,0,0,3,0),make_block_tile($3A0+$0,0,0,3,0)
		dc.w make_block_tile($3A0+$0,0,0,3,0),make_block_tile($3A0+$0,0,0,3,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($340+$0,0,0,3,0),make_block_tile($340+$4,0,0,3,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($340+$8,0,0,3,0),make_block_tile($340+$C,0,0,3,0)

		dc.w make_block_tile($340+$1,0,0,3,0),make_block_tile($340+$5,0,0,3,0)
		dc.w make_block_tile($340+$2,0,0,3,0),make_block_tile($340+$6,0,0,3,0)

		dc.w make_block_tile($340+$9,0,0,3,0),make_block_tile($340+$D,0,0,3,0)
		dc.w make_block_tile($340+$A,0,0,3,0),make_block_tile($340+$E,0,0,3,0)

		dc.w make_block_tile($340+$3,0,0,3,0),make_block_tile($340+$7,0,0,3,0)
		dc.w make_block_tile($340+$18,0,0,2,0),make_block_tile($340+$19,0,0,2,0)

		dc.w make_block_tile($340+$B,0,0,3,0),make_block_tile($340+$F,0,0,3,0)
		dc.w make_block_tile($340+$1A,0,0,2,0),make_block_tile($340+$1B,0,0,2,0)

		dc.w make_block_tile($380+$0,0,0,3,0),make_block_tile($380+$4,0,0,3,0)
		dc.w make_block_tile($380+$1,0,0,3,0),make_block_tile($380+$5,0,0,3,0)

		dc.w make_block_tile($380+$8,0,0,3,0),make_block_tile($380+$C,0,0,3,0)
		dc.w make_block_tile($380+$9,0,0,3,0),make_block_tile($380+$D,0,0,3,0)

		dc.w make_block_tile($380+$2,0,0,3,0),make_block_tile($380+$6,0,0,3,0)
		dc.w make_block_tile($380+$3,0,0,3,0),make_block_tile($380+$7,0,0,3,0)

		dc.w make_block_tile($380+$A,0,0,3,0),make_block_tile($380+$E,0,0,3,0)
		dc.w make_block_tile($380+$B,0,0,3,0),make_block_tile($380+$F,0,0,3,0)

		dc.w make_block_tile($390+$0,0,0,3,0),make_block_tile($390+$4,0,0,3,0)
		dc.w make_block_tile($390+$1,0,0,3,0),make_block_tile($390+$5,0,0,3,0)

		dc.w make_block_tile($390+$8,0,0,3,0),make_block_tile($390+$C,0,0,3,0)
		dc.w make_block_tile($390+$9,0,0,3,0),make_block_tile($390+$D,0,0,3,0)

		dc.w make_block_tile($390+$2,0,0,3,0),make_block_tile($390+$6,0,0,3,0)
		dc.w make_block_tile($390+$3,0,0,3,0),make_block_tile($390+$7,0,0,3,0)

		dc.w make_block_tile($390+$A,0,0,3,0),make_block_tile($390+$E,0,0,3,0)
		dc.w make_block_tile($390+$B,0,0,3,0),make_block_tile($390+$F,0,0,3,0)

		dc.w make_block_tile($370+$8,0,0,2,0),make_block_tile($370+$9,0,0,2,0)
		dc.w make_block_tile($370+$A,0,0,2,0),make_block_tile($370+$B,0,0,2,0)

		dc.w make_block_tile($370+$C,0,0,2,0),make_block_tile($370+$D,0,0,2,0)
		dc.w make_block_tile($370+$E,0,0,2,0),make_block_tile($370+$F,0,0,2,0)

		dc.w make_block_tile($350+$C,0,0,1,0),make_block_tile($350+$D,0,0,1,0)
		dc.w make_block_tile($350+$E,0,0,1,0),make_block_tile($350+$F,0,0,1,0)

		dc.w make_block_tile($350+$10,0,0,1,0),make_block_tile($350+$11,0,0,1,0)
		dc.w make_block_tile($350+$12,0,0,1,0),make_block_tile($350+$13,0,0,1,0)

		dc.w make_block_tile($350+$14,0,0,1,0),make_block_tile($350+$15,0,0,1,0)
		dc.w make_block_tile($350+$16,0,0,1,0),make_block_tile($350+$17,0,0,1,0)

		dc.w make_block_tile($350+$18,0,0,1,0),make_block_tile($350+$19,0,0,1,0)
		dc.w make_block_tile($350+$1A,0,0,1,0),make_block_tile($350+$1B,0,0,1,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($360+$C,0,0,3,0),make_block_tile($360+$D,0,0,3,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($360+$E,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile($360+$F,0,0,3,0),make_block_tile($360+$10,0,0,3,0)
		dc.w make_block_tile($360+$11,0,0,3,0),make_block_tile($360+$12,0,0,3,0)

		dc.w make_block_tile($360+$13,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($360+$14,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile($360+$15,0,0,3,0),make_block_tile($360+$16,0,0,3,0)
		dc.w make_block_tile($350+$8,0,0,2,0),make_block_tile($350+$9,0,0,2,0)

		dc.w make_block_tile($360+$17,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($350+$A,0,0,2,0),make_block_tile($350+$B,0,0,2,0)

		dc.w make_block_tile($370+$8,0,0,2,1),make_block_tile($370+$9,0,0,2,1)
		dc.w make_block_tile($370+$A,0,0,2,1),make_block_tile($370+$B,0,0,2,1)

		dc.w make_block_tile($370+$C,0,0,2,1),make_block_tile($370+$D,0,0,2,1)
		dc.w make_block_tile($370+$E,0,0,2,1),make_block_tile($370+$F,0,0,2,1)
APM_Unk_End:

APM_CPZ:	begin_animpat
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$1,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$1,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$1,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$1,0,0,2,0)

		dc.w make_block_tile(ArtTile_CPZ_Buildings+$2,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$2,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$3,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$3,0,0,2,0)

		dc.w make_block_tile(ArtTile_CPZ_Buildings+$4,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$4,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$5,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$5,0,0,2,0)

		dc.w make_block_tile(ArtTile_CPZ_Buildings+$6,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$6,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$7,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$7,0,0,2,0)
APM_CPZ_End:

APM_HPZ:	begin_animpat
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$0,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$1,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$2,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$3,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$4,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$5,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$6,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$7,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$0,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$1,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$2,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$3,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$4,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$5,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$6,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$7,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$0,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$1,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$2,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$3,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$4,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$5,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$6,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$7,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$0,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$1,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$2,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$3,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$4,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$5,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$6,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$7,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$0,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$1,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$2,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$3,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$4,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$5,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$6,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$7,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$0,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$1,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$2,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$3,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$4,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$5,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$6,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$7,0,0,2,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$0,0,0,3,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$2,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$1,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$4,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$3,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$6,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$5,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$7,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$0,0,0,3,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$2,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$1,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$4,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$3,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$6,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$5,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$7,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$0,0,0,3,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$2,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$1,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$4,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$3,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$6,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$5,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$7,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$0,0,0,2,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$2,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$1,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$4,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$3,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$6,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$5,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$7,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$0,0,0,2,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$2,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$1,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$4,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$3,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$6,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$5,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$7,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$0,0,0,2,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$2,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$1,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$4,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$3,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$6,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$5,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$7,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
APM_HPZ_End:

		jmpTos	; Empty

		include	"obj/21 HUD.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_obj21:	include	"mappings/sprite/obj21.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to add points to the score counter
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


AddPoints:
		move.b	#1,(f_scorecount).w
		lea	(v_score).w,a3
		add.l	d0,(a3)
		move.l	#999999,d1
		cmp.l	(a3),d1
		bhi.s	.belowmax
		move.l	d1,(a3)

.belowmax:
		move.l	(a3),d0
		cmp.l	(v_scorelife).w,d0
		blo.s	.noextralife
		addi.l	#5000,(v_scorelife).w
		tst.b	(v_megadrive).w			; is this a Japanese console?
		bmi.s	.noextralife			; if not, branch
		addq.b	#1,(v_lives).w
		addq.b	#1,(f_lifecount).w
		move.w	#bgm_ExtraLife,d0
		jmp	(QueueSound1).l

.noextralife:
		rts
; End of function AddPoints
; ===========================================================================

		include	"_Include/HUD Update.asm"

Art_HUD:	binclude	"art/uncompressed/HUD Numbers.bin"
		even
Art_LivesNums:	binclude	"art/uncompressed/Lives Counter Numbers.bin"
		even

		jmpTos	JmpTo9_Adjust2PArtPointer
; ===========================================================================

		include	"obj/DebugMode.asm"
		include	"_Include/DebugList.asm"

		jmpTos0	JmpTo10_Adjust2PArtPointer
; ===========================================================================

		include	"_Include/LevelHeaders.asm"
		include	"_Include/Pattern Load Cues.asm"

; --------------------------------------------------------------------------------------
; Leftover art from an unknown game, overwrites the other Sonic 1 PLC entries
; --------------------------------------------------------------------------------------
		binclude	"art/uncompressed/leftovers/1C318.bin"
		even

; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------
AngleMap_S1:	binclude	"collision/S1/Angle Map.bin"
AngleMap_S1_End:
		even
AngleMap:	binclude	"collision/Curve and resistance mapping.bin"
AngleMap_End:
		even
CollArray1_S1:	binclude	"collision/S1/Collision Array (Normal).bin"
CollArray1_S1_End:
		even
CollArray2_S1:	binclude	"collision/S1/Collision Array (Rotated).bin"
CollArray2_S1_End:
		even
CollArray1:	binclude	"collision/Collision array 1.bin"
CollArray1_End:
		even
CollArray2:	binclude	"collision/Collision array 2.bin"
CollArray2_End:
		even
ColP_GHZ:	binclude	"collision/S1/GHZ1.bin"
		even
ColS_GHZ:	binclude	"collision/S1/GHZ2.bin"
		even
ColP_EHZ:	binclude	"collision/EHZ primary 16x16 collision index.bin"
		even
ColS_EHZ:	binclude	"collision/EHZ secondary 16x16 collision index.bin"
		even
ColP_CPZ:	binclude	"collision/CPZ primary 16x16 collision index.bin"
		even
ColS_CPZ:	binclude	"collision/CPZ secondary 16x16 collision index.bin"
		even
ColP_HPZ:	binclude	"collision/HPZ primary 16x16 collision index.bin"
		even
ColS_HPZ:	binclude	"collision/HPZ secondary 16x16 collision index.bin"
		even

; ---------------------------------------------------------------------------
; Special Stage layouts
; ---------------------------------------------------------------------------
S1SS_1:	binclude	"sslayout/1.eni"
		even
S1SS_2:	binclude	"sslayout/2.eni"
		even
S1SS_3:	binclude	"sslayout/3.eni"
		even
S1SS_4:	binclude	"sslayout/4.eni"
		even
S1SS_5:	binclude	"sslayout/5 (JP1).eni"
		even
S1SS_6:	binclude	"sslayout/6 (JP1).eni"
		even

; ---------------------------------------------------------------------------
; Animated uncompressed graphics
; ---------------------------------------------------------------------------
Art_Flowers1:	binclude	"art/uncompressed/EHZ and HTZ flowers - 1.bin"
		even
Art_Flowers2:	binclude	"art/uncompressed/EHZ and HTZ flowers - 2.bin"
		even
Art_Flowers3:	binclude	"art/uncompressed/EHZ and HTZ flowers - 3.bin"
		even
Art_Flowers4:	binclude	"art/uncompressed/EHZ and HTZ flowers - 4.bin"
		even
Art_EHZPulseBall:	binclude	"art/uncompressed/Pulsing ball against checkered background (EHZ).bin"
		even
Art_HPZUnusedBg:	binclude	"art/uncompressed/HPZ unused background.bin"
		even
Art_HPZPulseOrb:	binclude	"art/uncompressed/Pulsing orb (HPZ).bin"
		even
Art_CPZ_Lights:	binclude	"art/uncompressed/CPZ Lights.bin"
		even
Art_CPZ_Conveyor:	binclude	"art/uncompressed/CPZ Conveyor.bin"
		even
Art_CPZ_Pistons:	binclude	"art/uncompressed/CPZ Pistons.bin"
		even
Art_CPZ_Metre:	binclude	"art/uncompressed/CPZ Metre.bin"
		even
Art_CPZ_Cross_Circle:	binclude	"art/uncompressed/CPZ Cross and Circle.bin"
		even
Art_CPZ_Propeller:	binclude	"art/uncompressed/CPZ Propeller.bin"
		even
Art_CPZ_Liquid:	binclude	"art/uncompressed/CPZ Liquid.bin"
		even
Art_CPZ_Conveyor_2:	binclude	"art/uncompressed/CPZ Conveyor 2.bin"
		even

; ---------------------------------------------------------------------------
; Level layout index
; Format: foreground, background, leftover/unused
; ---------------------------------------------------------------------------
Level_Index:	dc.w Level_GHZ1-Level_Index,Level_GHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_GHZ2-Level_Index,Level_GHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_GHZ3-Level_Index,Level_GHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_EHZ1-Level_Index,Level_EHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_EHZ2-Level_Index,Level_EHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_EHZ1-Level_Index,Level_EHZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_EHZ2-Level_Index,Level_EHZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_HPZ1-Level_Index,Level_HPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HPZ1-Level_Index,Level_HPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HPZ1-Level_Index,Level_HPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HPZ1-Level_Index,Level_HPZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_HTZ1-Level_Index,Level_HTZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HTZ2-Level_Index,Level_HTZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HTZ1-Level_Index,Level_HTZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_HTZ2-Level_Index,Level_HTZBg-Level_Index,Level_Null-Level_Index

		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index
		dc.w Level_CPZ1-Level_Index,Level_CPZBg-Level_Index,Level_Null-Level_Index

Level_GHZ1:	binclude	"level/layout/S1/ghz1.bin"
		even
Level_GHZ2:	binclude	"level/layout/S1/ghz2.bin"
		even
Level_GHZ3:	binclude	"level/layout/S1/ghz3.bin"
		even
Level_GHZBg:	binclude	"level/layout/S1/ghzbg.bin"
		even
Level_EHZ1:	binclude	"level/layout/EHZ_1.bin"
		even
Level_EHZ2:	binclude	"level/layout/EHZ_2.bin"
		even
Level_EHZBg:	binclude	"level/layout/EHZ_BG.bin"
		even
Level_HTZ1:	binclude	"level/layout/HTZ_1.bin"
		even
Level_HTZ2:	binclude	"level/layout/HTZ_2.bin"
		even
Level_HTZBg:	binclude	"level/layout/HTZ_BG.bin"
		even
Level_CPZ1:	binclude	"level/layout/CPZ_1.bin"
		even
Level_HPZ1:	binclude	"level/layout/HPZ_1.bin"
		even
Level_CPZBg:	binclude	"level/layout/CPZ_BG.bin"
		even
Level_HPZBg:	binclude	"level/layout/HPZ_BG.bin"
		even
Level_Null:	dc.l	0

Art_BigRing:	binclude	"art/uncompressed/Giant Ring.bin"
		even
		align 4

; --------------------------------------------------------------------------------------
; leftover level layouts from a	previous build
; --------------------------------------------------------------------------------------
		binclude	"leftovers/level/layout/HTZ_2.bin"
		even
Level_HTZBg_PB:	binclude	"level/layout/HTZ_BG.bin"
		even
Level_CPZ1_PB:	binclude	"level/layout/CPZ_1.bin"
		even
Level_HPZ1_PB:	binclude	"level/layout/HPZ_1.bin"
		even
Level_CPZBg_PB:	binclude	"level/layout/CPZ_BG.bin"
		even
Level_HPZBg_PB:	binclude	"level/layout/HPZ_BG.bin"
		even
Level_Null_PB:	dc.l	0

;----------------------------------------------------
; A duplicate copy of the big ring art
;----------------------------------------------------
Art_BigRing_PB:	binclude	"art/uncompressed/Giant Ring.bin"
		even
		align 4
		; cut-off piece of uncompressed giant ring art
		dc.w	$EEEE,$EEEE
		binclude	"leftovers/art/uncompressed/Giant Ring.bin"
		even

; --------------------------------------------------------------------------------------
; level mappings	(16x16 and 256x256)
; --------------------------------------------------------------------------------------
		binclude	"leftovers/mappings/16x16/2EB00.unc"
		even
		binclude	"leftovers/mappings/256x256/2EC00.unc"
		even

; --------------------------------------------------------------------------------------
; leftover art - full 128 character ASCII table
; --------------------------------------------------------------------------------------
		binclude	"art/uncompressed/leftovers/128 char ASCII.bin"
		even

; --------------------------------------------------------------------------------------
; Leftover level mappings and palettes from a previous build
; --------------------------------------------------------------------------------------
		binclude	"leftovers/mappings/256x256/31000.unc"
		even
		binclude	"leftovers/32000.bin"
		even
		dc.l	0
		binclude	"leftovers/mappings/16x16/36004.unc"
		even
		binclude	"leftovers/mappings/256x256/364D4.unc"
		even

; ---------------------------------------------------------------------------
; Sprite locations index
; ---------------------------------------------------------------------------
ObjPos_Index:	dc.w ObjPos_GHZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_LZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_CPZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_CPZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_CPZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_CPZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_EHZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_EHZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_EHZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_EHZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_HPZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HPZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HPZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HPZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_HTZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HTZ2-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HTZ3-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_HTZ1-ObjPos_Index,ObjPos_Null-ObjPos_Index

		dc.w ObjPos_S1Ending-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_S1Ending-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_S1Ending-ObjPos_Index,ObjPos_Null-ObjPos_Index
		dc.w ObjPos_S1Ending-ObjPos_Index,ObjPos_Null-ObjPos_Index

		; platform objects in LZ/SBZ (unused)
		dc.w ObjPos_S1LZ1pf1-ObjPos_Index,ObjPos_S1LZ1pf2-ObjPos_Index
		dc.w ObjPos_S1LZ2pf1-ObjPos_Index,ObjPos_S1LZ2pf2-ObjPos_Index
		dc.w ObjPos_S1LZ3pf1-ObjPos_Index,ObjPos_S1LZ3pf2-ObjPos_Index
		dc.w ObjPos_S1LZ1pf1-ObjPos_Index,ObjPos_S1LZ1pf2-ObjPos_Index
		dc.w ObjPos_S1SBZ1pf1-ObjPos_Index,ObjPos_S1SBZ1pf2-ObjPos_Index
		dc.w ObjPos_S1SBZ1pf3-ObjPos_Index,ObjPos_S1SBZ1pf4-ObjPos_Index
		dc.w ObjPos_S1SBZ1pf5-ObjPos_Index,ObjPos_S1SBZ1pf6-ObjPos_Index
		dc.w ObjPos_S1SBZ1pf1-ObjPos_Index,ObjPos_S1SBZ1pf2-ObjPos_Index
		dc.w $FFFF,	0,	0

ObjPos_GHZ1:	binclude	"level/objects/GHZ_1.bin"
		even
ObjPos_GHZ2:	binclude	"level/objects/GHZ_2.bin"
		even
ObjPos_GHZ3:	binclude	"level/objects/GHZ_3.bin"
		even
ObjPos_LZ1:	binclude	"level/objects/LZ_1.bin"
		even
ObjPos_LZ2:	binclude	"level/objects/LZ_2.bin"
		even
ObjPos_LZ3:	binclude	"level/objects/LZ_3.bin"
		even
ObjPos_S1LZ1pf1:
		binclude	"level/objects/S1/lz1pf1.bin"
		even
ObjPos_S1LZ1pf2:
		binclude	"level/objects/S1/lz1pf2.bin"
		even
ObjPos_S1LZ2pf1:
		binclude	"level/objects/S1/lz2pf1.bin"
		even
ObjPos_S1LZ2pf2:
		binclude	"level/objects/S1/lz2pf2.bin"
		even
ObjPos_S1LZ3pf1:
		binclude	"level/objects/S1/lz3pf1.bin"
		even
ObjPos_S1LZ3pf2:
		binclude	"level/objects/S1/lz3pf2.bin"
		even
ObjPos_CPZ1:	binclude	"level/objects/CPZ_1.bin"
		even
ObjPos_CPZ2:	binclude	"level/objects/CPZ_2.bin"
		even
ObjPos_CPZ3:	binclude	"level/objects/CPZ_3.bin"
		even
ObjPos_EHZ1:	binclude	"level/objects/EHZ_1.bin"
		even
ObjPos_EHZ2:	binclude	"level/objects/EHZ_2.bin"
		even
ObjPos_EHZ3:	binclude	"level/objects/EHZ_3.bin"
		even
ObjPos_HPZ1:	binclude	"level/objects/HPZ_1.bin"
		even
ObjPos_HPZ2:	binclude	"level/objects/HPZ_2.bin"
		even
ObjPos_HPZ3:	binclude	"level/objects/HPZ_3.bin"
		even
ObjPos_HTZ1:	binclude	"level/objects/HTZ_1.bin"
		even
ObjPos_HTZ2:	binclude	"level/objects/HTZ_2.bin"
		even
ObjPos_HTZ3:	binclude	"level/objects/S1/fz.bin"
		even
ObjPos_S1SBZ1pf1:
		binclude	"level/objects/S1/sbz1pf1.bin"
		even
ObjPos_S1SBZ1pf2:
		binclude	"level/objects/S1/sbz1pf2.bin"
		even
ObjPos_S1SBZ1pf3:
		binclude	"level/objects/S1/sbz1pf3.bin"
		even
ObjPos_S1SBZ1pf4:
		binclude	"level/objects/S1/sbz1pf4.bin"
		even
ObjPos_S1SBZ1pf5:
		binclude	"level/objects/S1/sbz1pf5.bin"
		even
ObjPos_S1SBZ1pf6:
		binclude	"level/objects/S1/sbz1pf6.bin"
		even
ObjPos_S1Ending:
		binclude	"level/objects/S1/ending.bin"
		even
ObjPos_Null:	dc.w $FFFF,	0,	0

; ---------------------------------------------------------------------------
; Leftover symbol tables due to compiler weirdness; these are formatted
; with a Unix ($0A) line break instead of a DOS ($0D0A) line break and it's
; also using big-endian integers, which suggest Sonic 2 wasn't developed in
; DOS (or at least a little-endian environment.)
; in addition, the locations that can be extracted don't even match up with
; the prototype.
;
; Read more about it here:
; https://clownacy.wordpress.com/2022/03/30/everything-that-i-know-about-sonic-the-hedgehogs-source-code/
; https://tcrf.net/Proto:Sonic_the_Hedgehog_2_(Genesis)/Nick_Arcade_Prototype/Symbol_Tables
; ---------------------------------------------------------------------------
		binclude	"leftovers/symbols/symbol1.bin"
		even
		binclude	"leftovers/symbols/symbol1a.bin"
		even
		binclude	"leftovers/4DB08.bin"
		even
		binclude	"leftovers/symbols/symbol2.bin"
		even
		binclude	"leftovers/4FB08.bin"
		even

; ---------------------------------------------------------------------------
; Ring layouts; one entry per act, four entries per zone
; ---------------------------------------------------------------------------
RingPos_Index:	dc.w RingPos_GHZ1-RingPos_Index
		dc.w RingPos_GHZ2-RingPos_Index
		dc.w RingPos_GHZ3-RingPos_Index
		dc.w RingPos_GHZ1-RingPos_Index

		dc.w RingPos_LZ1-RingPos_Index
		dc.w RingPos_LZ2-RingPos_Index
		dc.w RingPos_LZ3-RingPos_Index
		dc.w RingPos_LZ1-RingPos_Index

		dc.w RingPos_CPZ1-RingPos_Index
		dc.w RingPos_GHZ2-RingPos_Index
		dc.w RingPos_GHZ3-RingPos_Index
		dc.w RingPos_GHZ1-RingPos_Index

		dc.w RingPos_EHZ1-RingPos_Index
		dc.w RingPos_EHZ2-RingPos_Index
		dc.w RingPos_HTZ1-RingPos_Index
		dc.w RingPos_HTZ2-RingPos_Index

		dc.w RingPos_HPZ1-RingPos_Index
		dc.w RingPos_GHZ2-RingPos_Index
		dc.w RingPos_GHZ3-RingPos_Index
		dc.w RingPos_GHZ1-RingPos_Index

		dc.w RingPos_HTZ1-RingPos_Index
		dc.w RingPos_HTZ2-RingPos_Index
		dc.w RingPos_LZ3-RingPos_Index
		dc.w RingPos_LZ1-RingPos_Index

RingPos_GHZ1:	binclude	"level/rings/GHZ_1.bin"
		even
RingPos_GHZ2:	binclude	"level/rings/GHZ_2.bin"
		even
RingPos_GHZ3:	binclude	"level/rings/GHZ_3.bin"
		even
RingPos_LZ1:	binclude	"level/rings/LZ_1.bin"
		even
RingPos_LZ2:	binclude	"level/rings/LZ_2.bin"
		even
RingPos_LZ3:	binclude	"level/rings/LZ_3.bin"
		even
RingPos_HPZ1:	binclude	"level/rings/HPZ_1.bin"
		even
RingPos_EHZ1:	binclude	"level/rings/EHZ_1.bin"
		even
RingPos_EHZ2:	binclude	"level/rings/EHZ_2.bin"
		even
RingPos_HTZ1:	binclude	"level/rings/HTZ_1.bin"
		even
RingPos_HTZ2:	binclude	"level/rings/HTZ_2.bin"
		even
RingPos_CPZ1:	binclude	"level/rings/CPZ_1.bin"
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Yet another symbol table that doesn't match up with the prototype
; There's also code strewn in here which are related with an earlier prototype
; than Nick Arcade.
; ---------------------------------------------------------------------------

; 0x50A9C
		binclude	"leftovers/50A9C.bin"
		even

		binclude	"leftovers/symbols/symbol3.bin"
		even

	phase $1412C
		include	"leftovers/obj/14 HTZ Seesaw.asm"

word_14480:
		dc.w	 -8,  -$1C,  -$2F,  -$1C,    -8
byte_1448A:
		dc.b  $14, $14,	$16, $18, $1A, $1C, $1A
		dc.b  $18, $16,	$14, $13, $12, $11, $10
		dc.b   $F,  $E,	 $D,  $C,  $B,	$A,   9
		dc.b	8,   7,	  6,   5,   4,	 3,   2
		dc.b	1,   0,	 -1,  -2,  -3,	-4,  -5
		dc.b   -6,  -7,	 -8,  -9, -$A, -$B, -$C
		dc.b  -$D, -$E,	-$E, -$E, -$E, -$E, -$E
byte_144BB:
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5,   5
		dc.b	5,   5,	  5,   5,   5,	 5
		even
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Map_Obj14_PB:	binclude	"mappings/sprite/obj14_a.bin"
		even
; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Map_Obj14b_PB:	binclude	"mappings/sprite/obj14_b.bin"
		even

		jmpTos	; Empty
	dephase

		binclude	"leftovers/symbols/symbol4.bin"
		even

	phase $157E0
		include	"leftovers/obj/4B Buzzer.asm"
; ===========================================================================
; animation script
; off_15A18:
Ani_Obj4B_PB:	dc.w byte_15A20-Ani_Obj4B_PB
		dc.w byte_15A23-Ani_Obj4B_PB
		dc.w byte_15A27-Ani_Obj4B_PB
		dc.w byte_15A2B-Ani_Obj4B_PB
byte_15A20:	dc.b  $F,  0,$FF
byte_15A23:	dc.b   2,  3,  4,$FF
byte_15A27:	dc.b   3,  5,  6,$FF
byte_15A2B:	dc.b   9,  1,  1,  1,  1,  1,$FD,  0
		even
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_Obj4B_PB:	binclude	"mappings/sprite/obj4B.bin"
		even
	dephase

		binclude	"leftovers/symbols/symbol5.bin"
		even

	phase $14F5C
		include	"leftovers/obj/50 Aquis.asm"

Ani_Obj50_PB:	dc.w .byte_163B0-Ani_Obj50_PB
		dc.w .byte_163B3-Ani_Obj50_PB
		dc.w .byte_163BB-Ani_Obj50_PB
		dc.w .byte_163C1-Ani_Obj50_PB
		dc.w .byte_163C5-Ani_Obj50_PB
		dc.w .byte_163C8-Ani_Obj50_PB
		dc.w .byte_163CB-Ani_Obj50_PB
		dc.w .byte_163CF-Ani_Obj50_PB
.byte_163B0:	dc.b  $E,  0,$FF
.byte_163B3:	dc.b   5,  3,  4,  3,  4,  3,  4,$FF
.byte_163BB:	dc.b   3,  5,  6,  7,  6,$FF
.byte_163C1:	dc.b   3,  1,  2,$FF
.byte_163C5:	dc.b   1,  5,$FF
.byte_163C8:	dc.b  $E,  8,$FF
.byte_163CB:	dc.b   1,  9, $A,$FF
.byte_163CF:	dc.b   5, $B, $C, $B, $C, $B, $C,$FF
		even
Map_Obj50_PB:	dc.w .word_163F2-Map_Obj50_PB
		dc.w .word_1640C-Map_Obj50_PB
		dc.w .word_16416-Map_Obj50_PB
		dc.w .word_16420-Map_Obj50_PB
		dc.w .word_16442-Map_Obj50_PB
		dc.w .word_16464-Map_Obj50_PB
		dc.w .word_1646E-Map_Obj50_PB
		dc.w .word_16478-Map_Obj50_PB
		dc.w .word_16482-Map_Obj50_PB
		dc.w .word_1648C-Map_Obj50_PB
		dc.w .word_164AE-Map_Obj50_PB
		dc.w .word_164D0-Map_Obj50_PB
		dc.w .word_164FA-Map_Obj50_PB
.word_163F2:	dc.w 3
		dc.w $E80D,    0,    0,$FFF0
		dc.w $F809,  $16,   $B,$FFF8
		dc.w  $805,  $24,  $12,$FFF8
.word_1640C:	dc.w 1
		dc.w $F805,  $28,  $14,$FFF8
.word_16416:	dc.w 1
		dc.w $F805,  $2C,  $16,$FFF8
.word_16420:	dc.w 4
		dc.w $E809,    8,    4,$FFF0
		dc.w $E801,   $E,    7,	   8
		dc.w $F809,  $16,   $B,$FFF8
		dc.w  $805,  $24,  $12,$FFF8
.word_16442:	dc.w 4
		dc.w $E809,  $10,    8,$FFF0
		dc.w $E801,   $E,    7,	   8
		dc.w $F809,  $16,   $B,$FFF8
		dc.w  $805,  $24,  $12,$FFF8
.word_16464:	dc.w 1
		dc.w $F801,  $30,  $18,$FFFC
.word_1646E:	dc.w 1
		dc.w $F801,  $32,  $19,$FFFC
.word_16478:	dc.w 1
		dc.w $F801,  $34,  $1A,$FFFC
.word_16482:	dc.w 1
		dc.w $F80D,  $36,  $1B,$FFF0
.word_1648C:	dc.w 4
		dc.w $E80D,    0,    0,$FFF0
		dc.w $F805,  $1C,   $E,$FFF8
		dc.w $F801,  $20,  $10,	   8
		dc.w  $805,  $24,  $12,$FFF8
.word_164AE:	dc.w 4
		dc.w $E80D,    0,    0,$FFF0
		dc.w $F805,  $1C,   $E,$FFF8
		dc.w $F801,  $22,  $11,	   8
		dc.w  $805,  $24,  $12,$FFF8
.word_164D0:	dc.w 5
		dc.w $E809,    8,    4,$FFF0
		dc.w $E801,   $E,    7,	   8
		dc.w $F805,  $1C,   $E,$FFF8
		dc.w $F801,  $20,  $10,	   8
		dc.w  $805,  $24,  $12,$FFF8
.word_164FA:	dc.w 5
		dc.w $E809,  $10,    8,$FFF0
		dc.w $E801,   $E,    7,	   8
		dc.w $F805,  $1C,   $E,$FFF8
		dc.w $F801,  $22,  $11,	   8
		dc.w  $805,  $24,  $12,$FFF8

		include	"leftovers/obj/51 Aquis Child.asm"
	dephase

		binclude	"leftovers/symbols/symbol6.bin"
		even

	phase $14DF8
		include	"leftovers/obj/4F Redz.asm"
; ===========================================================================
; animation script
Ani_Obj4F_PB:	dc.w .byte_15EB8-Ani_Obj4F_PB
		dc.w .byte_15EBB-Ani_Obj4F_PB
.byte_15EB8:	dc.b   9,  1,$FF
.byte_15EBB:	dc.b   9,  0,  1,  2,  1,$FF
		even
; ---------------------------------------------------------------------------
; Sprite mappings - Redz (dinosaur badnik) from HPZ
; ---------------------------------------------------------------------------
Map_Obj4F_PB:	binclude	"mappings/sprite/obj4F.bin"
		even

		jmpTos0	; Empty
	dephase

		binclude	"leftovers/symbols/symbol7.bin"

	phase $164F8
		include	"leftovers/obj/53 Masher.asm"
; ===========================================================================
; animation script
Ani_Obj53_PB:	dc.w .byte_17572-Ani_Obj53_PB
		dc.w .byte_17576-Ani_Obj53_PB
		dc.w .byte_1757A-Ani_Obj53_PB
.byte_17572:	dc.b   7,  0,  1,$FF
.byte_17576:	dc.b   3,  0,  1,$FF
.byte_1757A:	dc.b   7,  0,$FF
		even
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_Obj53_PB:	binclude	"mappings/sprite/obj53.bin"
		even

		jmpTos0	; Empty
	dephase

		binclude	"leftovers/symbols/symbol8.bin"
		even

	phase $16200
		include	"leftovers/obj/4E Gator.asm"

Ani_Obj4E_PB:	dc.w .byte_172F4-Ani_Obj4E_PB
		dc.w .byte_172FC-Ani_Obj4E_PB
		dc.w .byte_172FF-Ani_Obj4E_PB
.byte_172F4:	dc.b   3,  0,  4,  2,  3,  1,  5,$FF
.byte_172FC:	dc.b  $F,  0,$FF
.byte_172FF:	dc.b   3,  6, $A,  8,  9,  7, $B,$FF
		even

Map_Obj4E_PB:	dc.w .word_17320-Map_Obj4E_PB
		dc.w .word_17342-Map_Obj4E_PB
		dc.w .word_17364-Map_Obj4E_PB
		dc.w .word_17386-Map_Obj4E_PB
		dc.w .word_173A8-Map_Obj4E_PB
		dc.w .word_173CA-Map_Obj4E_PB
		dc.w .word_173EC-Map_Obj4E_PB
		dc.w .word_1740E-Map_Obj4E_PB
		dc.w .word_17430-Map_Obj4E_PB
		dc.w .word_17452-Map_Obj4E_PB
		dc.w .word_17474-Map_Obj4E_PB
		dc.w .word_17496-Map_Obj4E_PB
.word_17320:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $20,  $10,	  $C
.word_17342:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $24,  $12,	  $C
.word_17364:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $28,  $14,	  $C
.word_17386:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $20,  $10,	  $C
.word_173A8:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $24,  $12,	  $C
.word_173CA:	dc.w 4
		dc.w $F80E,    0,    0,$FFE4
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $28,  $14,	  $C
.word_173EC:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $20,  $10,	  $C
.word_1740E:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $24,  $12,	  $C
.word_17430:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1C,   $E,	   4
		dc.w	 5,  $28,  $14,	  $C
.word_17452:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $20,  $10,	  $C
.word_17474:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $24,  $12,	  $C
.word_17496:	dc.w 4
		dc.w $F00B,   $C,    6,$FFEC
		dc.w $F805,  $18,   $C,	   4
		dc.w	 1,  $1E,   $F,	   4
		dc.w	 5,  $28,  $14,	  $C

	dephase

		binclude	"leftovers/symbols/symbol9.bin"
		even

	phase $15D78
		include	"leftovers/obj/4C BBat.asm"

Ani_Obj4C_PB:	dc.w .byte_16FC2-Ani_Obj4C_PB
		dc.w .byte_16FC6-Ani_Obj4C_PB
		dc.w .byte_16FD5-Ani_Obj4C_PB
		dc.w .byte_16FE6-Ani_Obj4C_PB
.byte_16FC2:	dc.b   1,  0,  5,$FF
.byte_16FC6:	dc.b   1,  1,  6,  1,  6,  2,  7,  2,  7,  1,  6,  1,  6,$FD,  0
.byte_16FD5:	dc.b   1,  1,  6,  1,  6,  2,  7,  3,  8,  4,  9,  4,  9,  3,  8,$FE
		dc.b  $A
.byte_16FE6:	dc.b   3, $A, $B, $C, $D, $E,$FF
		even

Map_Obj4C_PB:	dc.w .word_1700C-Map_Obj4C_PB
		dc.w .word_1702E-Map_Obj4C_PB
		dc.w .word_17050-Map_Obj4C_PB
		dc.w .word_17072-Map_Obj4C_PB
		dc.w .word_17094-Map_Obj4C_PB
		dc.w .word_170AE-Map_Obj4C_PB
		dc.w .word_170D0-Map_Obj4C_PB
		dc.w .word_170F2-Map_Obj4C_PB
		dc.w .word_17114-Map_Obj4C_PB
		dc.w .word_17136-Map_Obj4C_PB
		dc.w .word_17150-Map_Obj4C_PB
		dc.w .word_1716A-Map_Obj4C_PB
		dc.w .word_17184-Map_Obj4C_PB
		dc.w .word_17196-Map_Obj4C_PB
		dc.w .word_171A8-Map_Obj4C_PB
.word_1700C:	dc.w 4
		dc.w $F005,    0,    0,$FFF8
		dc.w	 5,    4,    2,$FFF8
		dc.w $F00B,    8,    4,	   5
		dc.w $F00B, $808, $804,$FFE3
.word_1702E:	dc.w 4
		dc.w $F005,    0,    0,$FFF8
		dc.w	 5,    4,    2,$FFF8
		dc.w $F60D,  $14,   $A,	   5
		dc.w $F60D, $814, $80A,$FFDB
.word_17050:	dc.w 4
		dc.w $F005,    0,    0,$FFF8
		dc.w	 5,    4,    2,$FFF8
		dc.w $F80D,  $1C,   $E,	   4
		dc.w $F80D, $81C, $80E,$FFDC
.word_17072:	dc.w 4
		dc.w $F005,    0,    0,$FFF8
		dc.w	 5,    4,    2,$FFF8
		dc.w $F805,  $24,  $12,$FFEC
		dc.w $F805,  $28,  $14,	   4
.word_17094:	dc.w 3
		dc.w $F801,  $2C,  $16,	   0
		dc.w $F005,    0,    0,$FFF8
		dc.w	 5,    4,    2,$FFF8
.word_170AE:	dc.w 4
		dc.w $F005,    0,    0,$FFF8
		dc.w	 5,  $2E,  $17,$FFF8
		dc.w $F00B,    8,    4,	   5
		dc.w $F00B, $808, $804,$FFE3
.word_170D0:	dc.w 4
		dc.w $F005,    0,    0,$FFF8
		dc.w	 5,  $2E,  $17,$FFF8
		dc.w $F60D,  $14,   $A,	   5
		dc.w $F60D, $814, $80A,$FFDB
.word_170F2:	dc.w 4
		dc.w $F005,    0,    0,$FFF8
		dc.w	 5,  $2E,  $17,$FFF8
		dc.w $F80D,  $1C,   $E,	   4
		dc.w $F80D, $81C, $80E,$FFDC
.word_17114:	dc.w 4
		dc.w $F005,    0,    0,$FFF8
		dc.w	 5,  $2E,  $17,$FFF8
		dc.w $F805,  $28,  $14,	   4
		dc.w $F805,  $24,  $12,$FFEC
.word_17136:	dc.w 3
		dc.w $F801,  $2C,  $16,	   0
		dc.w $F005,    0,    0,$FFF8
		dc.w	 5,  $2E,  $17,$FFF8
.word_17150:	dc.w 3
		dc.w $F007,  $32,  $19,$FFF8
		dc.w $F80D,  $1C,   $E,	   4
		dc.w $F80D, $81C, $80E,$FFDC
.word_1716A:	dc.w 3
		dc.w $F007,  $32,  $19,$FFF8
		dc.w $F805,  $28,  $14,	   4
		dc.w $F805,  $24,  $12,$FFEC
.word_17184:	dc.w 2
		dc.w $F801,  $2C,  $16,	   0
		dc.w $F007,  $32,  $19,$FFF8
.word_17196:	dc.w 2
		dc.w $F801, $82C, $816,$FFF8
		dc.w $F007,  $32,  $19,$FFF8
.word_171A8:	dc.w 3
		dc.w $F007,  $32,  $19,$FFF8
		dc.w $F805, $828, $814,$FFEC
		dc.w $F805, $824, $812,	   4

		jmpTos0	; Empty
	dephase

		binclude	"leftovers/symbols/symbol10.bin"
		even

	phase $15AC8
		include	"leftovers/obj/4A Octus.asm"

Ani_Obj4A_PB:	dc.w .byte_16C98-Ani_Obj4A_PB
		dc.w .byte_16C9B-Ani_Obj4A_PB
		dc.w .byte_16CA0-Ani_Obj4A_PB
.byte_16C98:	dc.b  $F,  0,$FF
.byte_16C9B:	dc.b   3,  1,  2,  3,$FF
.byte_16CA0:	dc.b   2,  5,  6,$FF
		even

Map_Obj4A_PB:	dc.w .word_16CB2-Map_Obj4A_PB
		dc.w .word_16CC4-Map_Obj4A_PB
		dc.w .word_16CDE-Map_Obj4A_PB
		dc.w .word_16CF8-Map_Obj4A_PB
		dc.w .word_16D12-Map_Obj4A_PB
		dc.w .word_16D1C-Map_Obj4A_PB
		dc.w .word_16D26-Map_Obj4A_PB
.word_16CB2:	dc.w 2
		dc.w $F00D,    0,    0,$FFF0
		dc.w	$D,    8,    4,$FFF0
.word_16CC4:	dc.w 3
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 9,  $10,    8,$FFE8
		dc.w	 9,  $16,   $B,	   0
.word_16CDE:	dc.w 3
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 9,  $1C,   $E,$FFE8
		dc.w	 9,  $22,  $11,	   0
.word_16CF8:	dc.w 3
		dc.w $F00D,    0,    0,$FFF0
		dc.w	 9,  $28,  $14,$FFE8
		dc.w	 9,  $2E,  $17,	   0
.word_16D12:	dc.w 1
		dc.w $F001,  $34,  $1A,$FFF7
.word_16D1C:	dc.w 1
		dc.w $F201,  $36,  $1B,$FFF0
.word_16D26:	dc.w 1
		dc.w $F201,  $38,  $1C,$FFF0

		jmpTos0	; Empty
	dephase

		binclude	"leftovers/symbols/symbol11.bin"
		even

	phase $16890
		include	"leftovers/obj/57 EHZ Boss (Part 3).asm"
		include	"leftovers/obj/58 EHZ Boss (Part 4).asm"

Ani_Obj58_PB:	dc.w .byte_18000-Ani_Obj58_PB
		dc.w .byte_18004-Ani_Obj58_PB
		dc.w .byte_1801A-Ani_Obj58_PB
.byte_18000:	dc.b   1,  5,  6,$FF
.byte_18004:	dc.b   1,  1,  1,  1,  2,  2,  2,  3,  3,  3,  4,  4,  4,  0,  0,  0
		dc.b   0,  0,  0,  0,  0,$FF
.byte_1801A:	dc.b   1,  0,  0,  0,  0,  0,  0,  0,  0,  4,  4,  4,  3,  3,  3,  2
		dc.b   2,  2,  1,  1,  1,  5,  6,$FE,  2
		even

Map_Obj58_PB:	dc.w .word_18042-Map_Obj58_PB
		dc.w .word_1804C-Map_Obj58_PB
		dc.w .word_18076-Map_Obj58_PB
		dc.w .word_180A0-Map_Obj58_PB
		dc.w .word_180BA-Map_Obj58_PB
		dc.w .word_180D4-Map_Obj58_PB
		dc.w .word_180EE-Map_Obj58_PB
.word_18042:	dc.w 1
		dc.w $D805,    0,    0,	   2
.word_1804C:	dc.w 5
		dc.w $D805,    4,    2,	   2
		dc.w $D80D,   $C,    6,	 $12
		dc.w $D80D,   $C,    6,	 $32
		dc.w $D80D,   $C,    6,$FFE2
		dc.w $D80D,   $C,    6,$FFC2
.word_18076:	dc.w 5
		dc.w $D805,    4,    2,	   2
		dc.w $D80D,   $C,    6,	 $12
		dc.w $D805,    8,    4,	 $32
		dc.w $D80D,   $C,    6,$FFE2
		dc.w $D805,    8,    4,$FFD2
.word_180A0:	dc.w 3
		dc.w $D805,    4,    2,	   2
		dc.w $D80D,   $C,    6,	 $12
		dc.w $D80D,   $C,    6,$FFE2
.word_180BA:	dc.w 3
		dc.w $D805,    4,    2,	   2
		dc.w $D805,    8,    4,	 $12
		dc.w $D805,    8,    4,$FFF2
.word_180D4:	dc.w 3
		dc.w $D805,    0,    0,	   2
		dc.w $D80D,   $C,    6,	 $12
		dc.w $D80D,   $C,    6,	 $32
.word_180EE:	dc.w 3
		dc.w $D805,    4,    2,	   2
		dc.w $D80D,   $C,    6,$FFE2
		dc.w $D80D,   $C,    6,$FFC2

Ani_Obj58a_PB:	dc.w .byte_1810E-Ani_Obj58a_PB
		dc.w .byte_18113-Ani_Obj58a_PB
		dc.w .byte_18117-Ani_Obj58a_PB
.byte_1810E:	dc.b   5,  1,  2,  3,$FF
.byte_18113:	dc.b   1,  4,  5,$FF
.byte_18117:	dc.b   1,  6,  7,$FF
		even

Map_Obj58a_PB:	dc.w .word_1812E-Map_Obj58a_PB
		dc.w .word_18148-Map_Obj58a_PB
		dc.w .word_18152-Map_Obj58a_PB
		dc.w .word_1815C-Map_Obj58a_PB
		dc.w .word_18166-Map_Obj58a_PB
		dc.w .word_18170-Map_Obj58a_PB
		dc.w .word_1817A-Map_Obj58a_PB
		dc.w .word_18184-Map_Obj58a_PB
.word_1812E:	dc.w 3
		dc.w $F00F,    0,    0,$FFD0
		dc.w $F00F,  $10,    8,$FFF0
		dc.w $F00F,  $20,  $10,	 $10
.word_18148:	dc.w 1
		dc.w $F00F,  $30,  $18,$FFF0
.word_18152:	dc.w 1
		dc.w $F00F,  $40,  $20,$FFF0
.word_1815C:	dc.w 1
		dc.w $F00F,  $50,  $28,$FFF0
.word_18166:	dc.w 1
		dc.w $F00F,  $60,  $30,$FFF0
.word_18170:	dc.w 1
		dc.w $F00F,$1060,$1030,$FFF0
.word_1817A:	dc.w 1
		dc.w $F00F,  $70,  $38,$FFF0
.word_18184:	dc.w 1
		dc.w $F00F,$1070,$1038,$FFF0

	dephase

		binclude	"leftovers/symbols/symbol12.bin"
		even

	phase $165F8
		include	"leftovers/obj/54 Snail.asm"
; ---------------------------------------------------------------------------
Ani_Obj54_PB:	dc.w .byte_17818-Ani_Obj54_PB
		dc.w .byte_1781C-Ani_Obj54_PB
.byte_17818:	dc.b   5,  0,  1,$FF
.byte_1781C:	dc.b   1,  0,  1,$FF
		even
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_Obj54_PB:	dc.w	.internal_0006-Map_Obj54_PB
		dc.w	.internal_0018-Map_Obj54_PB
		dc.w	.internal_002A-Map_Obj54_PB
.internal_0006:	dc.w 2
		dc.w $F00F, 0, 0, $FFF0
		dc.w $109, $14, $A, $FFF4
.internal_0018:	dc.w 2
		dc.w $F00F, 0, 0, $FFF0
		dc.w $109, $1014, $100A, $FFF4
.internal_002A:	dc.w 1
		dc.w $FA05, $10, 8, $FFE9

	dephase

		binclude	"leftovers/symbols/symbol13.bin"
		even

	phase $17CC4
		include	"leftovers/obj/S1/3D Boss - Green Hill (part 1).asm"

; =============== S U B	R O U T	I N E =======================================


BossDefeated_PB:
		move.b	(Vint_runcount+3).w,d0
		andi.b	#7,d0
		bne.s	.locret_18EA0
		jsr	($DAA2).l	;	FindFreeObj
		bne.s	.locret_18EA0
		_move.b	#id_Obj3F,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		jsr	($2AF0).l	;	RandomNumber
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,obX(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,obY(a1)

.locret_18EA0:
		rts
; End of function BossDefeated_PB


; =============== S U B	R O U T	I N E =======================================


BossMove_PB:
		move.l	objoff_30(a0),d2
		move.l	objoff_38(a0),d3
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,objoff_30(a0)
		move.l	d3,objoff_38(a0)
		rts
; End of function BossMove_PB

		include "leftovers/obj/S1/3D Boss - Green Hill (part 2).asm"
		include "leftovers/obj/S1/48 Eggman's Swinging Ball.asm"

Ani_Eggman_PB:	dc.w .byte_192E0-Ani_Eggman_PB
		dc.w .byte_192E3-Ani_Eggman_PB
		dc.w .byte_192E7-Ani_Eggman_PB
		dc.w .byte_192EB-Ani_Eggman_PB
		dc.w .byte_192EF-Ani_Eggman_PB
		dc.w .byte_192F3-Ani_Eggman_PB
		dc.w .byte_192F7-Ani_Eggman_PB
		dc.w .byte_192FB-Ani_Eggman_PB
		dc.w .byte_192FE-Ani_Eggman_PB
		dc.w .byte_19302-Ani_Eggman_PB
		dc.w .byte_19306-Ani_Eggman_PB
		dc.w .byte_19309-Ani_Eggman_PB
.byte_192E0:	dc.b  $F,  0,$FF
.byte_192E3:	dc.b   5,  1,  2,$FF
.byte_192E7:	dc.b   3,  1,  2,$FF
.byte_192EB:	dc.b   1,  1,  2,$FF
.byte_192EF:	dc.b   4,  3,  4,$FF
.byte_192F3:	dc.b $1F,  5,  1,$FF
.byte_192F7:	dc.b   3,  6,  1,$FF
.byte_192FB:	dc.b  $F, $A,$FF
.byte_192FE:	dc.b   3,  8,  9,$FF
.byte_19302:	dc.b   1,  8,  9,$FF
.byte_19306:	dc.b  $F,  7,$FF
.byte_19309:	dc.b   2,  9,  8, $B, $C, $B, $C,  9,  8,$FE,  2
		even

Map_Eggman_PB:	dc.w .word_1932E-Map_Eggman_PB
		dc.w .word_19360-Map_Eggman_PB
		dc.w .word_19372-Map_Eggman_PB
		dc.w .word_19384-Map_Eggman_PB
		dc.w .word_1939E-Map_Eggman_PB
		dc.w .word_193B8-Map_Eggman_PB
		dc.w .word_193D2-Map_Eggman_PB
		dc.w .word_193EC-Map_Eggman_PB
		dc.w .word_1940E-Map_Eggman_PB
		dc.w .word_19418-Map_Eggman_PB
		dc.w .word_19422-Map_Eggman_PB
		dc.w .word_19424-Map_Eggman_PB
		dc.w .word_19436-Map_Eggman_PB
.word_1932E:	dc.w 6
		dc.w $EC01,   $A,    5,$FFE4
		dc.w $EC05,   $C,    6,	  $C
		dc.w $FC0E,$2010,$2008,$FFE4
		dc.w $FC0E,$201C,$200E,	   4
		dc.w $140C,$2028,$2014,$FFEC
		dc.w $1400,$202C,$2016,	  $C
.word_19360:	dc.w 2
		dc.w $E404,    0,    0,$FFF4
		dc.w $EC0D,    2,    1,$FFEC
.word_19372:	dc.w 2
		dc.w $E404,    0,    0,$FFF4
		dc.w $EC0D,  $35,  $1A,$FFEC
.word_19384:	dc.w 3
		dc.w $E408,  $3D,  $1E,$FFF4
		dc.w $EC09,  $40,  $20,$FFEC
		dc.w $EC05,  $46,  $23,	   4
.word_1939E:	dc.w 3
		dc.w $E408,  $4A,  $25,$FFF4
		dc.w $EC09,  $4D,  $26,$FFEC
		dc.w $EC05,  $53,  $29,	   4
.word_193B8:	dc.w 3
		dc.w $E408,  $57,  $2B,$FFF4
		dc.w $EC09,  $5A,  $2D,$FFEC
		dc.w $EC05,  $60,  $30,	   4
.word_193D2:	dc.w 3
		dc.w $E404,  $64,  $32,	   4
		dc.w $E404,    0,    0,$FFF4
		dc.w $EC0D,  $35,  $1A,$FFEC
.word_193EC:	dc.w 4
		dc.w $E409,  $66,  $33,$FFF4
		dc.w $E408,  $57,  $2B,$FFF4
		dc.w $EC09,  $5A,  $2D,$FFEC
		dc.w $EC05,  $60,  $30,	   4
.word_1940E:	dc.w 1
		dc.w  $405,  $2D,  $16,	 $22
.word_19418:	dc.w 1
		dc.w  $405,  $31,  $18,	 $22
.word_19422:	dc.w 0
.word_19424:	dc.w 2
		dc.w	 8, $12A, $195,	 $22
		dc.w  $808,$112A,$1995,	 $22
.word_19436:	dc.w 2
		dc.w $F80B, $12D, $199,	 $22
		dc.w	 1, $139, $1AB,	 $3A

Map_BossItems_PB:	dc.w .word_19458-Map_BossItems_PB
		dc.w .word_19462-Map_BossItems_PB
		dc.w .word_19474-Map_BossItems_PB
		dc.w .word_1947E-Map_BossItems_PB
		dc.w .word_19488-Map_BossItems_PB
		dc.w .word_19492-Map_BossItems_PB
		dc.w .word_194B4-Map_BossItems_PB
		dc.w .word_194C6-Map_BossItems_PB
.word_19458:	dc.w 1
		dc.w $F805,    0,    0,$FFF8
.word_19462:	dc.w 2
		dc.w $FC04,    4,    2,$FFF8
		dc.w $F805,    0,    0,$FFF8
.word_19474:	dc.w 1
		dc.w $FC00,    6,    3,$FFFC
.word_1947E:	dc.w 1
		dc.w $1409,    7,    3,$FFF4
.word_19488:	dc.w 1
		dc.w $1405,   $D,    6,$FFF8
.word_19492:	dc.w 4
		dc.w $F004,  $11,    8,$FFF8
		dc.w $F801,  $13,    9,$FFF8
		dc.w $F801, $813, $809,	   0
		dc.w  $804,  $15,   $A,$FFF8
.word_194B4:	dc.w 2
		dc.w	 5,  $17,   $B,	   0
		dc.w	 0,  $1B,   $D,	 $10
.word_194C6:	dc.w 2
		dc.w $1804,  $1C,   $E,	   0
		dc.w	$B,  $1E,   $F,	 $10

	dephase

		binclude	"leftovers/symbols/symbol14.bin"
		even

	phase $175A8
		include	"leftovers/obj/S1/8A Credits.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings
; ---------------------------------------------------------------------------
Map_Cred_PB:	dc.w	Map_Cred_PB_0016-Map_Cred_PB
	dc.w	Map_Cred_PB_0088-Map_Cred_PB
	dc.w	Map_Cred_PB_010A-Map_Cred_PB
	dc.w	Map_Cred_PB_015C-Map_Cred_PB
	dc.w	Map_Cred_PB_021E-Map_Cred_PB
	dc.w	Map_Cred_PB_02C0-Map_Cred_PB
	dc.w	Map_Cred_PB_0392-Map_Cred_PB
	dc.w	Map_Cred_PB_044C-Map_Cred_PB
	dc.w	Map_Cred_PB_0546-Map_Cred_PB
	dc.w	Map_Cred_PB_05C0-Map_Cred_PB
	dc.w	Map_Cred_PB_0602-Map_Cred_PB
Map_Cred_PB_0016:	dc.w $E
	dc.w $F805, $2E, $17, $FF88
	dc.w $F805, $26, $13, $FF98
	dc.w $F805, $1A, $D, $FFA8
	dc.w $F801, $46, $23, $FFB8
	dc.w $F805, $1E, $F, $FFC0
	dc.w $F805, $3E, $1F, $FFD8
	dc.w $F805, $E, 7, $FFE8
	dc.w $F805, 4, 2, $FFF8
	dc.w $F809, 8, 4, 8
	dc.w $F805, $2E, $17, $28
	dc.w $F805, $3E, $1F, $38
	dc.w $F805, 4, 2, $48
	dc.w $F805, $5C, $2E, $58
	dc.w $F805, $5C, $2E, $68
Map_Cred_PB_0088:	dc.w $10
	dc.w $D805, 0, 0, $FF80
	dc.w $D805, 4, 2, $FF90
	dc.w $D809, 8, 4, $FFA0
	dc.w $D805, $E, 7, $FFB4
	dc.w $D805, $12, 9, $FFD0
	dc.w $D805, $16, $B, $FFE0
	dc.w $D805, 4, 2, $FFF0
	dc.w $D805, $1A, $D, 0
	dc.w $805, $1E, $F, $FFC8
	dc.w $805, 4, 2, $FFD8
	dc.w $805, $22, $11, $FFE8
	dc.w $805, $26, $13, $FFF8
	dc.w $805, $16, $B, 8
	dc.w $805, $2A, $15, $20
	dc.w $805, 4, 2, $30
	dc.w $805, $2E, $17, $44
Map_Cred_PB_010A:	dc.w $A
	dc.w $D805, $12, 9, $FF80
	dc.w $D805, $22, $11, $FF90
	dc.w $D805, $26, $13, $FFA0
	dc.w $D805, 0, 0, $FFB0
	dc.w $D805, $22, $11, $FFC0
	dc.w $D805, 4, 2, $FFD0
	dc.w $D809, 8, 4, $FFE0
	dc.w $805, $2A, $15, $FFE8
	dc.w $805, $32, $19, $FFF8
	dc.w $805, $36, $1B, 8
Map_Cred_PB_015C:	dc.w $18
	dc.w $D805, $1E, $F, $FF88
	dc.w $D805, $3A, $1D, $FF98
	dc.w $D805, 4, 2, $FFA8
	dc.w $D805, $22, $11, $FFB8
	dc.w $D805, 4, 2, $FFC8
	dc.w $D805, $1E, $F, $FFD8
	dc.w $D805, $3E, $1F, $FFE8
	dc.w $D805, $E, 7, $FFF8
	dc.w $D805, $22, $11, 8
	dc.w $D805, $42, $21, $20
	dc.w $D805, $E, 7, $30
	dc.w $D805, $2E, $17, $40
	dc.w $D801, $46, $23, $50
	dc.w $D805, 0, 0, $58
	dc.w $D805, $1A, $D, $68
	dc.w $805, $48, $24, $FFC0
	dc.w $801, $46, $23, $FFD0
	dc.w $805, 0, 0, $FFD8
	dc.w $801, $46, $23, $FFE8
	dc.w $805, $2E, $17, $FFF0
	dc.w $805, $16, $B, 0
	dc.w $805, 4, 2, $10
	dc.w $805, $1A, $D, $20
	dc.w $805, $42, $21, $30
Map_Cred_PB_021E:	dc.w $14
	dc.w $D005, $42, $21, $FFA0
	dc.w $D005, $E, 7, $FFB0
	dc.w $D005, $2E, $17, $FFC0
	dc.w $D001, $46, $23, $FFD0
	dc.w $D005, 0, 0, $FFD8
	dc.w $D005, $1A, $D, $FFE8
	dc.w 5, $4C, $26, $FFE8
	dc.w 1, $46, $23, $FFF8
	dc.w 5, $1A, $D, 4
	dc.w 5, $2A, $15, $14
	dc.w 5, 4, 2, $24
	dc.w $2005, $12, 9, $FFD0
	dc.w $2005, $3A, $1D, $FFE0
	dc.w $2005, $E, 7, $FFF0
	dc.w $2005, $1A, $D, 0
	dc.w $2001, $46, $23, $10
	dc.w $2005, $50, $28, $18
	dc.w $2005, $22, $11, $30
	dc.w $2001, $46, $23, $40
	dc.w $2005, $E, 7, $48
Map_Cred_PB_02C0:	dc.w $1A
	dc.w $D805, $2E, $17, $FF98
	dc.w $D805, $26, $13, $FFA8
	dc.w $D805, $32, $19, $FFB8
	dc.w $D805, $1A, $D, $FFC8
	dc.w $D805, $54, $2A, $FFD8
	dc.w $D805, $12, 9, $FFF8
	dc.w $D805, $22, $11, 8
	dc.w $D805, $26, $13, $18
	dc.w $D805, $42, $21, $28
	dc.w $D805, $32, $19, $38
	dc.w $D805, $1E, $F, $48
	dc.w $D805, $E, 7, $58
	dc.w $809, 8, 4, $FF88
	dc.w $805, 4, 2, $FF9C
	dc.w $805, $2E, $17, $FFAC
	dc.w $805, 4, 2, $FFBC
	dc.w $805, $3E, $1F, $FFCC
	dc.w $805, $26, $13, $FFDC
	dc.w $805, $1A, $D, $FFF8
	dc.w $805, 4, 2, 8
	dc.w $805, $58, $2C, $18
	dc.w $805, 4, 2, $28
	dc.w $809, 8, 4, $38
	dc.w $805, $32, $19, $4C
	dc.w $805, $22, $11, $5C
	dc.w $805, 4, 2, $6C
Map_Cred_PB_0392:	dc.w $17
	dc.w $D005, $2E, $17, $FF98
	dc.w $D005, $26, $13, $FFA8
	dc.w $D005, $32, $19, $FFB8
	dc.w $D005, $1A, $D, $FFC8
	dc.w $D005, $54, $2A, $FFD8
	dc.w $D005, $12, 9, $FFF8
	dc.w $D005, $22, $11, 8
	dc.w $D005, $26, $13, $18
	dc.w $D005, 0, 0, $28
	dc.w $D005, $22, $11, $38
	dc.w $D005, 4, 2, $48
	dc.w $D009, 8, 4, $58
	dc.w 5, $4C, $26, $FFD0
	dc.w 1, $46, $23, $FFE0
	dc.w 9, 8, 4, $FFE8
	dc.w 1, $46, $23, $FFFC
	dc.w 5, $3E, $1F, 4
	dc.w 5, 4, 2, $14
	dc.w $2009, 8, 4, $FFD0
	dc.w $2005, 4, 2, $FFE4
	dc.w $2005, $1E, $F, $FFF4
	dc.w $2005, $58, $2C, 4
	dc.w $2005, $2A, $15, $14
Map_Cred_PB_044C:	dc.w $1F
	dc.w $D805, $2E, $17, $FF80
	dc.w $D805, $12, 9, $FF90
	dc.w $D805, $E, 7, $FFA0
	dc.w $D805, $1E, $F, $FFB0
	dc.w $D801, $46, $23, $FFC0
	dc.w $D805, 4, 2, $FFC8
	dc.w $D805, $16, $B, $FFD8
	dc.w $D805, $3E, $1F, $FFF8
	dc.w $D805, $3A, $1D, 8
	dc.w $D805, 4, 2, $18
	dc.w $D805, $1A, $D, $28
	dc.w $D805, $58, $2C, $38
	dc.w $D805, $2E, $17, $48
	dc.w 5, $5C, $2E, $FFB0
	dc.w 5, $32, $19, $FFC0
	dc.w 5, $4C, $26, $FFD0
	dc.w 1, $46, $23, $FFE0
	dc.w 5, $26, $13, $FFE8
	dc.w 9, 8, 4, 0
	dc.w 1, $46, $23, $14
	dc.w 5, $1A, $D, $1C
	dc.w 5, $E, 7, $2C
	dc.w 5, 0, 0, $3C
	dc.w 1, $46, $23, $4C
	dc.w 5, $2E, $17, $54
	dc.w 5, $3A, $1D, $64
	dc.w 1, $46, $23, $74
	dc.w $2005, $12, 9, $FFF8
	dc.w $2005, 4, 2, 8
	dc.w $2005, $12, 9, $18
	dc.w $2005, 4, 2, $28
Map_Cred_PB_0546:	dc.w $F
	dc.w $F805, $12, 9, $FF80
	dc.w $F805, $22, $11, $FF90
	dc.w $F805, $E, 7, $FFA0
	dc.w $F805, $2E, $17, $FFB0
	dc.w $F805, $E, 7, $FFC0
	dc.w $F805, $1A, $D, $FFD0
	dc.w $F805, $3E, $1F, $FFE0
	dc.w $F805, $E, 7, $FFF0
	dc.w $F805, $42, $21, 0
	dc.w $F805, $48, $24, $18
	dc.w $F805, $2A, $15, $28
	dc.w $F805, $2E, $17, $40
	dc.w $F805, $E, 7, $50
	dc.w $F805, 0, 0, $60
	dc.w $F805, 4, 2, $70
Map_Cred_PB_05C0:	dc.w 8
	dc.w $3005, $3E, $1F, $FFC0
	dc.w $3005, $22, $11, $FFD0
	dc.w $3005, $2A, $15, $FFE0
	dc.w $3005, 4, 2, $FFF8
	dc.w $3005, 0, 0, 8
	dc.w $3005, 4, 2, $18
	dc.w $3001, $46, $23, $28
	dc.w $3005, $1A, $D, $30
Map_Cred_PB_0602:	dc.w $11
	dc.w $E805, $2E, $17, $FFB4
	dc.w $E805, $26, $13, $FFC4
	dc.w $E805, $1A, $D, $FFD4
	dc.w $E801, $46, $23, $FFE4
	dc.w $E805, $1E, $F, $FFEC
	dc.w $E805, $3E, $1F, 4
	dc.w $E805, $E, 7, $14
	dc.w $E805, 4, 2, $24
	dc.w $E809, 8, 4, $34
	dc.w 5, $12, 9, $FFC0
	dc.w 5, $22, $11, $FFD0
	dc.w 5, $E, 7, $FFE0
	dc.w 5, $2E, $17, $FFF0
	dc.w 5, $E, 7, 0
	dc.w 5, $1A, $D, $10
	dc.w 5, $3E, $1F, $20
	dc.w 5, $2E, $17, $30

		jmpTos	; Empty
	dephase

		binclude	"leftovers/symbols/symbol15.bin"
		even

	phase $17194
		include	"leftovers/obj/55 EHZ Boss (Part 1).asm"
		include	"leftovers/obj/56 EHZ Boss (Part 2).asm"

Map_Obj55a_PB:	dc.w .word_184C2-Map_Obj55a_PB
		dc.w .word_184CC-Map_Obj55a_PB
.word_184C2:	dc.w 1
		dc.w	 5,    0,    0,	 $1C
.word_184CC:	dc.w 1
		dc.w	 5,    4,    2,	 $1C

Map_Obj55b_PB:	dc.w .word_184DE-Map_Obj55b_PB
		dc.w .word_184E8-Map_Obj55b_PB
		dc.w .word_184F2-Map_Obj55b_PB
		dc.w .word_184FC-Map_Obj55b_PB
.word_184DE:	dc.w 1
		dc.w $F805,    0,    0,$FFF8
.word_184E8:	dc.w 1
		dc.w $F805,    4,    2,$FFF8
.word_184F2:	dc.w 1
		dc.w $F805,    8,    4,$FFF8
.word_184FC:	dc.w 1
		dc.w $F805,   $C,    6,$FFF8

Map_Obj56_PB:	dc.w .word_18514-Map_Obj56_PB
		dc.w .word_1851E-Map_Obj56_PB
		dc.w .word_18528-Map_Obj56_PB
		dc.w .word_18532-Map_Obj56_PB
		dc.w .word_1853C-Map_Obj56_PB
		dc.w .word_18546-Map_Obj56_PB
		dc.w .word_18550-Map_Obj56_PB
.word_18514:	dc.w 1
		dc.w $F805,    0,    0,$FFF8
.word_1851E:	dc.w 1
		dc.w $F00F,    4,    2,$FFF0
.word_18528:	dc.w 1
		dc.w $F00F,  $14,   $A,$FFF0
.word_18532:	dc.w 1
		dc.w $F00F,  $24,  $12,$FFF0
.word_1853C:	dc.w 1
		dc.w $F00F,  $34,  $1A,$FFF0
.word_18546:	dc.w 1
		dc.w $F00F,  $44,  $22,$FFF0
.word_18550:	dc.w 1
		dc.w $F00F,  $54,  $2A,$FFF0

Ani_Obj55a_PB:	dc.w .byte_1855E-Ani_Obj55a_PB
		dc.w .byte_18561-Ani_Obj55a_PB
.byte_1855E:	dc.b  $F,  0,$FF
.byte_18561:	dc.b   7,  1,  2,$FF
		even

Map_Obj55_PB:	dc.w .word_1856C-Map_Obj55_PB
		dc.w .word_1858E-Map_Obj55_PB
		dc.w .word_185B0-Map_Obj55_PB
.word_1856C:	dc.w 4
		dc.w $F805,    0,    0,$FFE0
		dc.w  $805,    4,    2,$FFE0
		dc.w $F80F,    8,    4,$FFF0
		dc.w $F807,  $18,   $C,	 $10
.word_1858E:	dc.w 4
		dc.w $E805,  $28,  $14,$FFE0
		dc.w $E80D,  $30,  $18,$FFF0
		dc.w $E805,  $24,  $12,	 $10
		dc.w $D805,  $20,  $10,	   2
.word_185B0:	dc.w 4
		dc.w $E805,  $28,  $14,$FFE0
		dc.w $E80D,  $38,  $1C,$FFF0
		dc.w $E805,  $24,  $12,	 $10
		dc.w $D805,  $20,  $10,	   2

		jmpTos	; Empty
	dephase

		binclude	"leftovers/symbols/symbol16.bin"
		even

		dc.w   $26,  $13,$FFA8
		dc.w $D005,  $32,  $19,$FFB8
		dc.w $D005,  $1A,   $D,$FFC8; 4
		dc.w $D005,  $54,  $2A,$FFD8; 8
		dc.w $D005,  $12,    9,$FFF8; 12
		dc.w $D005,  $22,  $11,	   8; 16
		dc.w $D005,  $26,  $13,	 $18; 20
		dc.w $D005,    0,    0,	 $28; 24
		dc.w $D005,  $22,  $11,	 $38; 28
		dc.w $D005,    4,    2,	 $48; 32
		dc.w $D009,    8,    4,	 $58; 36
		dc.w	 5,  $4C,  $26,$FFD0; 40
		dc.w	 1,  $46,  $23,$FFE0; 44
		dc.w	 9,    8,    4,$FFE8; 48
		dc.w	 1,  $46,  $23,$FFFC; 52
		dc.w	 5,  $3E,  $1F,	   4; 56
		dc.w	 5,    4,    2,	 $14; 60
		dc.w $2009,    8,    4,$FFD0; 64
		dc.w $2005,    4,    2,$FFE4; 68
		dc.w $2005,  $1E,   $F,$FFF4; 72
		dc.w $2005,  $58,  $2C,	   4; 76
		dc.w $2005,  $2A,  $15,	 $14; 80
		dc.w $1F
		dc.w $D805,  $2E,  $17,$FF80
		dc.w $D805,  $12,    9,$FF90; 4
		dc.w $D805,   $E,    7,$FFA0; 8
		dc.w $D805,  $1E,   $F,$FFB0; 12
		dc.w $D801,  $46,  $23,$FFC0; 16
		dc.w $D805,    4,    2,$FFC8; 20
		dc.w $D805,  $16,   $B,$FFD8; 24
		dc.w $D805,  $3E,  $1F,$FFF8; 28
		dc.w $D805,  $3A,  $1D,	   8; 32
		dc.w $D805,    4,    2,	 $18; 36
		dc.w $D805,  $1A,   $D,	 $28; 40
		dc.w $D805,  $58,  $2C,	 $38; 44
		dc.w $D805,  $2E,  $17,	 $48; 48
		dc.w	 5,  $5C,  $2E,$FFB0; 52
		dc.w	 5,  $32,  $19,$FFC0; 56
		dc.w	 5,  $4C,  $26,$FFD0; 60
		dc.w	 1,  $46,  $23,$FFE0; 64
		dc.w	 5,  $26,  $13,$FFE8; 68
		dc.w	 9,    8,    4,	   0; 72
		dc.w	 1,  $46,  $23,	 $14; 76
		dc.w	 5,  $1A,   $D,	 $1C; 80
		dc.w	 5,   $E,    7,	 $2C; 84
		dc.w	 5,    0,    0,	 $3C; 88
		dc.w	 1,  $46,  $23,	 $4C; 92
		dc.w	 5,  $2E,  $17,	 $54; 96
		dc.w	 5,  $3A,  $1D,	 $64; 100
		dc.w	 1,  $46,  $23,	 $74; 104
		dc.w $2005,  $12,    9,$FFF8; 108
		dc.w $2005,    4,    2,	   8; 112
		dc.w $2005,  $12,    9,	 $18; 116
		dc.w $2005,    4,    2,	 $28; 120
		dc.w $F
		dc.w $F805,  $12,    9,$FF80
		dc.w $F805,  $22,  $11,$FF90; 4
		dc.w $F805,   $E,    7,$FFA0; 8
		dc.w $F805,  $2E,  $17,$FFB0; 12
		dc.w $F805,   $E,    7,$FFC0; 16
		dc.w $F805,  $1A,   $D,$FFD0; 20
		dc.w $F805,  $3E,  $1F,$FFE0; 24
		dc.w $F805,   $E,    7,$FFF0; 28
		dc.w $F805,  $42,  $21,	   0; 32
		dc.w $F805,  $48,  $24,	 $18; 36
		dc.w $F805,  $2A,  $15,	 $28; 40
		dc.w $F805,  $2E,  $17,	 $40; 44
		dc.w $F805,   $E,    7,	 $50; 48
		dc.w $F805,    0,    0,	 $60; 52
		dc.w $F805,    4,    2,	 $70; 56
		dc.w 8
		dc.w $3005,  $3E,  $1F,$FFC0
		dc.w $3005,  $22,  $11,$FFD0; 4
		dc.w $3005,  $2A,  $15,$FFE0; 8
		dc.w $3005,    4,    2,$FFF8; 12
		dc.w $3005,    0,    0,	   8; 16
		dc.w $3005,    4,    2,	 $18; 20
		dc.w $3001,  $46,  $23,	 $28; 24
		dc.w $3005,  $1A,   $D,	 $30; 28
		dc.w $11
		dc.w $E805,  $2E,  $17,$FFB4
		dc.w $E805,  $26,  $13,$FFC4; 4
		dc.w $E805,  $1A,   $D,$FFD4; 8
		dc.w $E801,  $46,  $23,$FFE4; 12
		dc.w $E805,  $1E,   $F,$FFEC; 16
		dc.w $E805,  $3E,  $1F,	   4; 20
		dc.w $E805,   $E,    7,	 $14; 24
		dc.w $E805,    4,    2,	 $24; 28
		dc.w $E809,    8,    4,	 $34; 32
		dc.w	 5,  $12,    9,$FFC0; 36
		dc.w	 5,  $22,  $11,$FFD0; 40
		dc.w	 5,   $E,    7,$FFE0; 44
		dc.w	 5,  $2E,  $17,$FFF0; 48
		dc.w	 5,   $E,    7,	   0; 52
		dc.w	 5,  $1A,   $D,	 $10; 56
		dc.w	 5,  $3E,  $1F,	 $20; 60
		dc.w	 5,  $2E,  $17,	 $30; 64

		jmpTos	; Empty

		binclude	"leftovers/symbols/symbol17.bin"
		even

	phase $1718C
		include	"leftovers/obj/55 EHZ Boss (Part 1) (Earlier).asm"
		include	"leftovers/obj/56 EHZ Boss (Part 2) (Earlier).asm"

Map_Obj55a_PB2:	dc.w .word_184C2-Map_Obj55a_PB2
		dc.w .word_184CC-Map_Obj55a_PB2
.word_184C2:	dc.w 1
		dc.w	 5,    0,    0,	 $1C
.word_184CC:	dc.w 1
		dc.w	 5,    4,    2,	 $1C

Map_Obj55b_PB2:	dc.w .word_184DE-Map_Obj55b_PB2
		dc.w .word_184E8-Map_Obj55b_PB2
		dc.w .word_184F2-Map_Obj55b_PB2
		dc.w .word_184FC-Map_Obj55b_PB2
.word_184DE:	dc.w 1
		dc.w $F805,    0,    0,$FFF8
.word_184E8:	dc.w 1
		dc.w $F805,    4,    2,$FFF8
.word_184F2:	dc.w 1
		dc.w $F805,    8,    4,$FFF8
.word_184FC:	dc.w 1
		dc.w $F805,   $C,    6,$FFF8

Map_Obj56_PB2:	dc.w .word_18514-Map_Obj56_PB2
		dc.w .word_1851E-Map_Obj56_PB2
		dc.w .word_18528-Map_Obj56_PB2
		dc.w .word_18532-Map_Obj56_PB2
		dc.w .word_1853C-Map_Obj56_PB2
		dc.w .word_18546-Map_Obj56_PB2
		dc.w .word_18550-Map_Obj56_PB2
.word_18514:	dc.w 1
		dc.w $F805,    0,    0,$FFF8
.word_1851E:	dc.w 1
		dc.w $F00F,    4,    2,$FFF0
.word_18528:	dc.w 1
		dc.w $F00F,  $14,   $A,$FFF0
.word_18532:	dc.w 1
		dc.w $F00F,  $24,  $12,$FFF0
.word_1853C:	dc.w 1
		dc.w $F00F,  $34,  $1A,$FFF0
.word_18546:	dc.w 1
		dc.w $F00F,  $44,  $22,$FFF0
.word_18550:	dc.w 1
		dc.w $F00F,  $54,  $2A,$FFF0

Ani_Obj55a_PB2:	dc.w .byte_1855E-Ani_Obj55a_PB2
		dc.w .byte_18561-Ani_Obj55a_PB2
.byte_1855E:	dc.b  $F,  0,$FF
.byte_18561:	dc.b   7,  1,  2,$FF
		even

Map_Obj55_PB2:	dc.w .word_1856C-Map_Obj55_PB2
		dc.w .word_1858E-Map_Obj55_PB2
		dc.w .word_185B0-Map_Obj55_PB2
.word_1856C:	dc.w 4
		dc.w $F805,    0,    0,$FFE0
		dc.w  $805,    4,    2,$FFE0
		dc.w $F80F,    8,    4,$FFF0
		dc.w $F807,  $18,   $C,	 $10
.word_1858E:	dc.w 4
		dc.w $E805,  $28,  $14,$FFE0
		dc.w $E80D,  $30,  $18,$FFF0
		dc.w $E805,  $24,  $12,	 $10
		dc.w $D805,  $20,  $10,	   2
.word_185B0:	dc.w 4
		dc.w $E805,  $28,  $14,$FFE0
		dc.w $E80D,  $38,  $1C,$FFF0
		dc.w $E805,  $24,  $12,	 $10
		dc.w $D805,  $20,  $10,	   2

		jmpTos	; Empty
	dephase

		binclude	"leftovers/symbols/symbol18.bin"
		even

; ---------------------------------------------------------------------------
; Leftover source code of Debug Mode
; ---------------------------------------------------------------------------
		binclude	"leftovers/source code/Debug Mode.txt"
		even
		binclude	"leftovers/tilemaps/Title Emblem.eni"
		even
		binclude	"leftovers/tilemaps/Title Background.eni"
		even
		binclude	"leftovers/art/nemesis/8x8 - Title.nem"
		binclude	"leftovers/symbols/symbol19.bin"

	phase $187B0
		include	"leftovers/obj/sub TouchResponse.asm"

		jmpTos	; Empty
	dephase

		binclude	"leftovers/symbols/symbol20.bin"
		even

	phase $184AC
		include	"leftovers/obj/S1/3E Prison Capsule.asm"

Ani_Pri_PB:	dc.w .byte_19730-Ani_Pri_PB
		dc.w .byte_19730-Ani_Pri_PB
.byte_19730:	dc.b   2,  1,  3,$FF
		even

Map_Pri_PB:	dc.w .word_19742-Map_Pri_PB
		dc.w .word_1977C-Map_Pri_PB
		dc.w .word_19786-Map_Pri_PB
		dc.w .word_197B8-Map_Pri_PB
		dc.w .word_197C2-Map_Pri_PB
		dc.w .word_197D4-Map_Pri_PB
		dc.w .word_197DE-Map_Pri_PB
.word_19742:	dc.w 7
		dc.w $E00C,$2000,$2000,$FFF0
		dc.w $E80D,$2004,$2002,$FFE0
		dc.w $E80D,$200C,$2006,	   0
		dc.w $F80E,$2014,$200A,$FFE0
		dc.w $F80E,$2020,$2010,	   0
		dc.w $100D,$202C,$2016,$FFE0
		dc.w $100D,$2034,$201A,	   0
.word_1977C:	dc.w 1
		dc.w $F809,  $3C,  $1E,$FFF4
.word_19786:	dc.w 6
		dc.w	 8,$2042,$2021,$FFE0
		dc.w  $80C,$2045,$2022,$FFE0
		dc.w	 4,$2049,$2024,	 $10
		dc.w  $80C,$204B,$2025,	   0
		dc.w $100D,$202C,$2016,$FFE0
		dc.w $100D,$2034,$201A,	   0
.word_197B8:	dc.w 1
		dc.w $F809,  $4F,  $27,$FFF4
.word_197C2:	dc.w 2
		dc.w $E80E,$2055,$202A,$FFF0
		dc.w	$E,$2061,$2030,$FFF0
.word_197D4:	dc.w 1
		dc.w $F007,$206D,$2036,$FFF8
.word_197DE:	dc.w 0

	dephase

		binclude	"leftovers/symbols/symbol21.bin"
		even

	phase $18B48
; =============== S U B	R O U T	I N E =======================================

S1SS_ShowLayout_PB:
		bsr.w	sub_19CC2_PB	;	sub_19CC2
		bsr.w	sub_19F02_PB	;	sub_19F02
		move.w	d5,-(sp)
		lea	(v_ssbuffer3).w,a1
		move.b	(v_ssangle).w,d0
		andi.b	#$FC,d0
		jsr	($2B16).l	;	CalcSine
		move.w	d0,d4
		move.w	d1,d5
		muls.w	#$18,d4
		muls.w	#$18,d5
		moveq	#0,d2
		move.w	(Camera_X_pos).w,d2
		divu.w	#$18,d2
		swap	d2
		neg.w	d2
		addi.w	#-$B4,d2
		moveq	#0,d3
		move.w	(Camera_Y_pos).w,d3
		divu.w	#$18,d3
		swap	d3
		neg.w	d3
		addi.w	#-$B4,d3
		move.w	#$10-1,d7

.loc_19BD0:
		movem.w	d0-d2,-(sp)
		movem.w	d0-d1,-(sp)
		neg.w	d0
		muls.w	d2,d1
		muls.w	d3,d0
		move.l	d0,d6
		add.l	d1,d6
		movem.w	(sp)+,d0-d1
		muls.w	d2,d0
		muls.w	d3,d1
		add.l	d0,d1
		move.l	d6,d2
		move.w	#$10-1,d6

.loc_19BF2:
		move.l	d2,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		move.l	d1,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		add.l	d5,d2
		add.l	d4,d1
		dbf	d6,.loc_19BF2
		movem.w	(sp)+,d0-d2
		addi.w	#$18,d3
		dbf	d7,.loc_19BD0
		move.w	(sp)+,d5
		lea	(v_ssbuffer1).l,a0
		moveq	#0,d0
		move.w	(Camera_Y_pos).w,d0
		divu.w	#$18,d0
		mulu.w	#$80,d0
		adda.l	d0,a0
		moveq	#0,d0
		move.w	(Camera_X_pos).w,d0
		divu.w	#$18,d0
		adda.w	d0,a0
		lea	(v_ssbuffer3).w,a4
		move.w	#$10-1,d7

.loc_19C3E:
		move.w	#$10-1,d6

.loc_19C42:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	.loc_19C9A
		cmpi.b	#$4E,d0
		bhi.s	.loc_19C9A
		move.w	(a4),d3
		addi.w	#$120,d3
		cmpi.w	#$70,d3
		blo.s	.loc_19C9A
		cmpi.w	#$1D0,d3
		bhs.s	.loc_19C9A
		move.w	2(a4),d2
		addi.w	#$F0,d2
		cmpi.w	#$70,d2
		blo.s	.loc_19C9A
		cmpi.w	#$170,d2
		bhs.s	.loc_19C9A
		lea	(v_ssbuffer2).l,a5
		lsl.w	#3,d0
		lea	(a5,d0.w),a5
		movea.l	(a5)+,a1
		move.w	(a5)+,d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		movea.w	(a5)+,a3
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	.loc_19C9A
		jsr	($CB26).l	;	loc_D1CE

.loc_19C9A:
		addq.w	#4,a4
		dbf	d6,.loc_19C42
		lea	$70(a0),a0
		dbf	d7,.loc_19C3E
		move.b	d5,(v_spritecount).w
		cmpi.b	#80,d5
		beq.s	.loc_19CBA
		move.l	#0,(a2)
		rts
; ---------------------------------------------------------------------------

.loc_19CBA:
		move.b	#0,-5(a2)
		rts
; End of function S1SS_ShowLayout


; =============== S U B	R O U T	I N E =======================================


sub_19CC2_PB:
		lea	(v_ssbuffer2+$C).l,a1
		moveq	#0,d0
		move.b	(v_ssangle).w,d0
		lsr.b	#2,d0
		andi.w	#$F,d0
		moveq	#$23,d1

.loc_19CD6:
		move.w	d0,(a1)
		addq.w	#8,a1
		dbf	d1,.loc_19CD6
		lea	(v_ssbuffer2+5).l,a1
		subq.b	#1,(v_ani1_time).w
		bpl.s	.loc_19CFA
		move.b	#7,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#3,(v_ani1_frame).w

.loc_19CFA:
		move.b	(v_ani1_frame).w,$1D0(a1)
		subq.b	#1,(v_ani2_time).w
		bpl.s	.loc_19D16
		move.b	#7,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		andi.b	#1,(v_ani2_frame).w

.loc_19D16:
		move.b	(v_ani2_frame).w,d0
		move.b	d0,$138(a1)
		move.b	d0,$160(a1)
		move.b	d0,$148(a1)
		move.b	d0,$150(a1)
		move.b	d0,$1D8(a1)
		move.b	d0,$1E0(a1)
		move.b	d0,$1E8(a1)
		move.b	d0,$1F0(a1)
		move.b	d0,$1F8(a1)
		move.b	d0,$200(a1)
		subq.b	#1,(v_ani3_time).w
		bpl.s	.loc_19D58
		move.b	#4,(v_ani3_time).w
		addq.b	#1,(v_ani3_frame).w
		andi.b	#3,(v_ani3_frame).w

.loc_19D58:
		move.b	(v_ani3_frame).w,d0
		move.b	d0,$168(a1)
		move.b	d0,$170(a1)
		move.b	d0,$178(a1)
		move.b	d0,$180(a1)
		subq.b	#1,(v_ani0_time).w
		bpl.s	.loc_19D82
		move.b	#7,(v_ani0_time).w
		subq.b	#1,(v_ani0_frame).w
		andi.b	#7,(v_ani0_frame).w

.loc_19D82:
		lea	(v_ssbuffer2+$16).l,a1
		lea	(S1SS_WaRiVramSet_PB).l,a0
		moveq	#0,d0
		move.b	(v_ani0_frame).w,d0
		add.w	d0,d0
		lea	(a0,d0.w),a0
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		rts
; End of function sub_19CC2

; ---------------------------------------------------------------------------
S1SS_WaRiVramSet_PB:
		dc.w $142,$6142,$142,$142,$142,$142,$142,$6142
		dc.w $142,$6142,$142,$142,$142,$142,$142,$6142
		dc.w $2142,$142,$2142,$2142,$2142,$2142,$2142,$142
		dc.w $2142,$142,$2142,$2142,$2142,$2142,$2142,$142
		dc.w $4142,$2142,$4142,$4142,$4142,$4142,$4142,$2142
		dc.w $4142,$2142,$4142,$4142,$4142,$4142,$4142,$2142
		dc.w $6142,$4142,$6142,$6142,$6142,$6142,$6142,$4142
		dc.w $6142,$4142,$6142,$6142,$6142,$6142,$6142,$4142

; =============== S U B	R O U T	I N E =======================================


sub_19EEC_PB:
		lea	(v_ssitembuffer).l,a2
		move.w	#(v_ssitembuffer_end-v_ssitembuffer)/8-1,d0

.loc_19EF6:
		tst.b	(a2)
		beq.s	.locret_19F00
		addq.w	#8,a2
		dbf	d0,.loc_19EF6

.locret_19F00:
		rts
; End of function sub_19EEC


; =============== S U B	R O U T	I N E =======================================


sub_19F02_PB:
		lea	(v_ssitembuffer).l,a0
		move.w	#(v_ssitembuffer_end-v_ssitembuffer)/8-1,d7

.loc_19F0C:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	.loc_19F1A
		lsl.w	#2,d0
		movea.l	S1SS_AniIndex_PB-4(pc,d0.w),a1
		jsr	(a1)

.loc_19F1A:
		addq.w	#8,a0

.loc_19F1C:
		dbf	d7,.loc_19F0C
		rts
; End of function sub_19F02

; ---------------------------------------------------------------------------
S1SS_AniIndex_PB:
		dc.l .loc_19F3A
		dc.l .loc_19F6A
		dc.l .loc_19FA0
		dc.l .loc_19FD0
		dc.l .loc_1A006
		dc.l .loc_1A046
; ---------------------------------------------------------------------------

.loc_19F3A:
		subq.b	#1,2(a0)
		bpl.s	.locret_19F62
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	.byte_19F64(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	.locret_19F62
		clr.l	(a0)
		clr.l	4(a0)

.locret_19F62:
		rts
; ---------------------------------------------------------------------------
.byte_19F64:	dc.b $42,$43,$44,$45,0,0
; ---------------------------------------------------------------------------

.loc_19F6A:
		subq.b	#1,2(a0)
		bpl.s	.locret_19F98
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	.byte_19F9A(pc,d0.w),d0
		bne.s	.loc_19F96
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$25,(a1)
		rts
; ---------------------------------------------------------------------------

.loc_19F96:
		move.b	d0,(a1)

.locret_19F98:
		rts
; ---------------------------------------------------------------------------
.byte_19F9A:	dc.b $32,$33,$32,$33,0,0
; ---------------------------------------------------------------------------

.loc_19FA0:
		subq.b	#1,2(a0)
		bpl.s	.locret_19FC8
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	.byte_19FCA(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	.locret_19FC8
		clr.l	(a0)
		clr.l	4(a0)

.locret_19FC8:
		rts
; ---------------------------------------------------------------------------
.byte_19FCA:	dc.b $46,$47,$48,$49,0,0
; ---------------------------------------------------------------------------

.loc_19FD0:
		subq.b	#1,2(a0)
		bpl.s	.locret_19FFE
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	.byte_1A000(pc,d0.w),d0
		bne.s	.loc_19FFC
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$2B,(a1)
		rts
; ---------------------------------------------------------------------------

.loc_19FFC:
		move.b	d0,(a1)

.locret_19FFE:
		rts
; ---------------------------------------------------------------------------
.byte_1A000:	dc.b $2B,$31,$2B,$31,0,0
; ---------------------------------------------------------------------------

.loc_1A006:
		subq.b	#1,2(a0)
		bpl.s	.locret_1A03E
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	.byte_1A040(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	.locret_1A03E
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#4,(v_objspace+obRoutine).w
		move.w	#sfx_SSGoal,d0
		jsr	($12FC).l	;	QueueSound2

.locret_1A03E:
		rts
; ---------------------------------------------------------------------------
.byte_1A040:	dc.b $46,$47,$48,$49,0,0
; ---------------------------------------------------------------------------

.loc_1A046:
		subq.b	#1,2(a0)
		bpl.s	.locret_1A072
		move.b	#1,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	.byte_1A074(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	.locret_1A072
		move.b	4(a0),(a1)
		clr.l	(a0)
		clr.l	4(a0)

.locret_1A072:
		rts
; ---------------------------------------------------------------------------
.byte_1A074:	dc.b $4B,$4C,$4D,$4E,$4B,$4C,$4D,$4E,0,0

S1SS_LayoutIndex_PB:
		dc.l S1SS_1
		dc.l S1SS_2
		dc.l S1SS_3
		dc.l S1SS_4
		dc.l S1SS_5
		dc.l S1SS_6

S1SS_StartLoc_PB:
		dc.w  $3D0, $2E0
		dc.w  $328, $574
		dc.w  $4E4, $2E0
		dc.w  $3AD, $2E0
		dc.w  $340, $6B8
		dc.w  $49B, $358

; =============== S U B	R O U T	I N E =======================================


S1SS_Load_PB:
		moveq	#0,d0
		move.b	(v_lastspecial).w,d0
		addq.b	#1,(v_lastspecial).w
		cmpi.b	#6,(v_lastspecial).w
		blo.s	.loc_1A0C6
		move.b	#0,(v_lastspecial).w

.loc_1A0C6:
		cmpi.b	#6,(v_emeralds).w
		beq.s	.loc_1A0E8
		moveq	#0,d1
		move.b	(v_emeralds).w,d1
		subq.b	#1,d1
		blo.s	.loc_1A0E8
		lea	(v_emldlist).w,a3

.loc_1A0DC:
		cmp.b	(a3,d1.w),d0
		bne.s	.loc_1A0E4
		bra.s	S1SS_Load_PB
; ---------------------------------------------------------------------------

.loc_1A0E4:
		dbf	d1,.loc_1A0DC

.loc_1A0E8:
		lsl.w	#2,d0
		lea	S1SS_StartLoc_PB(pc,d0.w),a1
		move.w	(a1)+,(v_player+obX).w
		move.w	(a1)+,(v_player+obY).w
		movea.l	S1SS_LayoutIndex_PB(pc,d0.w),a0
		lea	(v_ssbuffer2).l,a1
		move.w	#make_art_tile(ArtTile_SS_Background_Clouds,0,0),d0
		jsr	($170E).l	;	EniDec
		lea	(v_ssbuffer1).l,a1
		move.w	#bytesToLcnt(v_ssbuffer2-v_ssbuffer1),d0

.loc_1A114:
		clr.l	(a1)+
		dbf	d0,.loc_1A114
		lea	(v_ssblockbuffer).l,a1
		lea	(v_ssbuffer2).l,a0
		moveq	#bytesToXcnt(v_ssblockbuffer_end-v_ssblockbuffer,$80),d1

.loc_1A128:
		moveq	#$40-1,d2

.loc_1A12A:
		move.b	(a0)+,(a1)+
		dbf	d2,.loc_1A12A
		lea	$40(a1),a1
		dbf	d1,.loc_1A128
		lea	(v_ssblocktypes+8).l,a1
		lea	(S1SS_MapIndex_PB).l,a0
		moveq	#bytesToXcnt(S1SS_MapIndex_PB_End-S1SS_MapIndex_PB,6),d1

.loc_1A146:
		move.l	(a0)+,(a1)+
		move.w	#0,(a1)+
		move.b	-4(a0),-1(a1)
		move.w	(a0)+,(a1)+
		dbf	d1,.loc_1A146
		lea	(v_ssitembuffer).l,a1
		move.w	#bytesToLcnt(v_ssitembuffer_end-v_ssitembuffer),d1

.loc_1A162:
		clr.l	(a1)+
		dbf	d1,.loc_1A162
		rts
; End of function S1SS_Load

; ---------------------------------------------------------------------------
S1SS_MapIndex_PB:
		include	"leftovers/_Include/Special Stage Mappings & VRAM Pointers.asm"
S1SS_MapIndex_PB_End:
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - 'R'
; ---------------------------------------------------------------------------
Map_SS_R_PB:	dc.w .byte_1B912-Map_SS_R_PB
		dc.w .byte_1B918-Map_SS_R_PB
		dc.w .byte_1B91E-Map_SS_R_PB
.byte_1B912:	dc.b 1
		dc.b $F4, $A, 0, 0, $F4
.byte_1B918:	dc.b 1
		dc.b $F4, $A, 0, 9, $F4
.byte_1B91E:	dc.b 0
		even
; ---------------------------------------------------------------------------
; Sprite mappings - Glass
; ---------------------------------------------------------------------------
Map_SS_Glass_PB:	dc.w .byte_1B928-Map_SS_Glass_PB
		dc.w .byte_1B92E-Map_SS_Glass_PB
		dc.w .byte_1B934-Map_SS_Glass_PB
		dc.w .byte_1B93A-Map_SS_Glass_PB
.byte_1B928:	dc.b 1
		dc.b $F4, $A, 0, 0, $F4
.byte_1B92E:	dc.b 1
		dc.b $F4, $A, 8, 0, $F4
.byte_1B934:	dc.b 1
		dc.b $F4, $A, $18, 0, $F4
.byte_1B93A:	dc.b 1
		dc.b $F4, $A, $10, 0, $F4
		even
; ---------------------------------------------------------------------------
; Sprite mappings - 'Up'
; ---------------------------------------------------------------------------
Map_SS_Up_PB:	dc.w .byte_1B944-Map_SS_Up_PB
		dc.w .byte_1B94A-Map_SS_Up_PB
.byte_1B944:	dc.b 1
		dc.b $F4, $A, 0, 0, $F4
.byte_1B94A:	dc.b 1
		dc.b $F4, $A, 0, $12, $F4
		even
; ---------------------------------------------------------------------------
; Sprite mappings - 'Down'
; ---------------------------------------------------------------------------
Map_SS_Down_PB:	dc.w .byte_1B954-Map_SS_Down_PB
		dc.w .byte_1B95A-Map_SS_Down_PB
.byte_1B954:	dc.b 1
		dc.b $F4, $A, 0, 9, $F4
.byte_1B95A:	dc.b 1
		dc.b $F4, $A, 0, $12, $F4
		even
; ---------------------------------------------------------------------------
; Sprite mappings - special stage chaos	emeralds
; ---------------------------------------------------------------------------
Map_SS_Chaos1_PB:	dc.w byte_1B96C_PB-Map_SS_Chaos1_PB
		dc.w byte_1B97E_PB-Map_SS_Chaos1_PB
Map_SS_Chaos2_PB:	dc.w byte_1B972_PB-Map_SS_Chaos2_PB
		dc.w byte_1B97E_PB-Map_SS_Chaos2_PB
Map_SS_Chaos3_PB:	dc.w byte_1B978_PB-Map_SS_Chaos3_PB
		dc.w byte_1B97E_PB-Map_SS_Chaos3_PB
byte_1B96C_PB:	dc.b 1
		dc.b $F8, 5, 0,	0, $F8
byte_1B972_PB:	dc.b 1
		dc.b $F8, 5, 0,	4, $F8
byte_1B978_PB:	dc.b 1
		dc.b $F8, 5, 0,	8, $F8
byte_1B97E_PB:	dc.b 1
		dc.b $F8, 5, 0,	$C, $F8
		even

		jmpTos	; Empty
	dephase

		binclude	"leftovers/symbols/symbol22.bin"
		even

	phase $19A2C
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to animate stage art
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; DynamicArtCues:
AniArt_Load_PB:
		bsr.w	ShiftCPZBackground_PB
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	DynArtCue_Index_PB+2(pc,d0.w),d1
		lea	DynArtCue_Index_PB(pc,d1.w),a2
		move.w	DynArtCue_Index_PB(pc,d0.w),d0
		jmp	DynArtCue_Index_PB(pc,d0.w)
; ---------------------------------------------------------------------------
		rts
; End of function AniArt_Load

; ---------------------------------------------------------------------------
; ZONE ANIMATION PROCEDURES AND SCRIPTS
;
; Each zone gets two entries in this jump table. The first entry points to the
; zone's animation procedure (usually Dynamic_Null, AKA none). The second points
; to the zone's animation script.
;
; Seems like stage IDs were already being shifted, since listings for $07-$0F
; can be found, alongside HPZ's art listed from $08 (its ID in the final).
; ---------------------------------------------------------------------------
DynArtCue_Index_PB:
		dc.w Dynamic_NullGHZ_PB-DynArtCue_Index_PB	; GHZ
		dc.w AnimCue_EHZ_PB-DynArtCue_Index_PB		; GHZ
		dc.w Dynamic_Null_PB-DynArtCue_Index_PB		; LZ
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB	; LZ
		dc.w Dynamic_Normal_PB-DynArtCue_Index_PB		; CPZ
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB	; CPZ
		dc.w Dynamic_Normal_PB-DynArtCue_Index_PB		; EHZ
		dc.w AnimCue_EHZ_PB-DynArtCue_Index_PB		; EHZ
		dc.w Dynamic_Normal_PB-DynArtCue_Index_PB		; HPZ
		dc.w AnimCue_HPZ_PB-DynArtCue_Index_PB		; HPZ
		dc.w Dynamic_Null_PB-DynArtCue_Index_PB		; HTZ
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB		; HTZ
		dc.w Dynamic_Null_PB-DynArtCue_Index_PB		; 06
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB	; 06
		dc.w Dynamic_Null_PB-DynArtCue_Index_PB		; 07
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB	; 07
		dc.w Dynamic_Normal_PB-DynArtCue_Index_PB		; 08
		dc.w AnimCue_HPZ_PB-DynArtCue_Index_PB		; 08
		dc.w Dynamic_Null_PB-DynArtCue_Index_PB		; 09
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB	; 09
		dc.w Dynamic_Null_PB-DynArtCue_Index_PB		; 0A
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB	; 0A
		dc.w Dynamic_Null_PB-DynArtCue_Index_PB		; 0B
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB	; 0B
		dc.w Dynamic_Null_PB-DynArtCue_Index_PB		; 0C
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB	; 0C
		dc.w Dynamic_Normal_PB-DynArtCue_Index_PB		; 0D
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB	; 0D
		dc.w Dynamic_Null_PB-DynArtCue_Index_PB		; 0E
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB	; 0E
		dc.w Dynamic_Null_PB-DynArtCue_Index_PB		; 0F
		dc.w AnimCue_CPZ_Boss_PB-DynArtCue_Index_PB	; 0F
; ===========================================================================

Dynamic_Null_PB:
		rts
; ===========================================================================

Dynamic_NullGHZ_PB:
		rts
; ===========================================================================

Dynamic_Normal_PB:
		lea	(Anim_Counters).w,a3
		move.w	(a2)+,d6			; Get number of scripts in list

.loc_1AACA:
		subq.b	#1,(a3)				; Tick down frame duration
		bpl.s	.loc_1AB10			; If frame isn't over, move on to next script

		moveq	#0,d0
		move.b	1(a3),d0			; Get current frame
		cmp.b	6(a2),d0			; Have we processed the last frame in the script?
		blo.s	.loc_1AAE0
		moveq	#0,d0				; If so, reset to first frame
		move.b	d0,1(a3)

.loc_1AAE0:
		addq.b	#1,1(a3)			; Consider this frame processed; set counter to next frame
		move.b	(a2),(a3)			; Set frame duration to global duration value
		bpl.s	.loc_1AAEE
		; If script uses per-frame durations, use those instead
		add.w	d0,d0
		move.b	9(a2,d0.w),(a3)			; Set frame duration to current frame's duration value

.loc_1AAEE:
		; Prepare for DMA transfer
		; Get relative address of frame's art
		move.b	8(a2,d0.w),d0			; Get tile ID
		lsl.w	#5,d0				; Turn it into an offset
		; Get VRAM destination address
		move.w	4(a2),d2
		; Get ROM source address
		move.l	(a2),d1				; Get start address of animated tile art
		andi.l	#$FFFFFF,d1
		add.l	d0,d1				; Offset into art, to get the address of new frame
		; Get size of art to be transferred
		moveq	#0,d3
		move.b	7(a2),d3
		lsl.w	#4,d3				; Turn it into actual size (in words)
		; Use d1, d2 and d3 to queue art for transfer
		jsr	($13A0).l	;	QueueDMATransfer

.loc_1AB10:
		move.b	6(a2),d0			; Get total size of frame data
		tst.b	(a2)				; Is per-frame duration data present?
		bpl.s	.loc_1AB1A			; If not, keep the current size; it's correct
		add.b	d0,d0				; Double size to account for the additional frame duration data

.loc_1AB1A:
		addq.b	#1,d0
		andi.w	#$FE,d0				; Round to next even address, if it isn't already
		lea	8(a2,d0.w),a2			; Advance to next script in list
		addq.w	#2,a3				; Advance to next script's slot in a3 (usually Anim_Counters)
		dbf	d6,.loc_1AACA
		rts
; ===========================================================================
AnimCue_EHZ_PB:	zoneanimstart
		; Flowers
		zoneanimdecl -1, $26D98, ArtTile_Art_Flowers1, 6, 2	;	Art_Flowers1
		dc.b   0,$7F		; Start of the script proper
		dc.b   2,$13
		dc.b   0,  7
		dc.b   2,  7
		dc.b   0,  7
		dc.b   2,  7
		even
		; Flowers
		zoneanimdecl -1, $26E18, ArtTile_Art_Flowers2, 8, 2	;	Art_Flowers2
		dc.b   2,$7F
		dc.b   0, $B
		dc.b   2, $B
		dc.b   0, $B
		dc.b   2,  5
		dc.b   0,  5
		dc.b   2,  5
		dc.b   0,  5
		even
		; Flowers
		zoneanimdecl 7, $26E98, ArtTile_Art_Flowers3, 2, 2	;	Art_Flowers3
		dc.b   0
		dc.b   2
		even
		; Flowers
		zoneanimdecl -1, $26F18, ArtTile_Art_Flowers4, 8, 2	;	Art_Flowers4
		dc.b   0,$7F
		dc.b   2,  7
		dc.b   0,  7
		dc.b   2,  7
		dc.b   0,  7
		dc.b   2, $B
		dc.b   0, $B
		dc.b   2, $B
		even
		; Pulsing thing against checkered background
		zoneanimdecl 1, $26F98, ArtTile_Art_EHZPulseBall, 6, 2	;	Art_EHZPulseBall
		dc.b   0,  2
		dc.b   4,  6
		dc.b   4,  2
		even

		zoneanimend

AnimCue_HPZ_PB:	zoneanimstart
		; Pulsing orb from HPZ
		zoneanimdecl 8, $27498, ArtTile_Art_HPZPulseOrb_1, 6, 8	;	Art_HPZPulseOrb
		dc.b   0
		dc.b   0
		dc.b   8
		dc.b $10
		dc.b $10
		dc.b   8
		even
		; Pulsing orb from HPZ
		zoneanimdecl 8, $27498, ArtTile_Art_HPZPulseOrb_2, 6, 8	;	Art_HPZPulseOrb
		dc.b   8
		dc.b $10
		dc.b $10
		dc.b   8
		dc.b   0
		dc.b   0
		even
		; Pulsing orb from HPZ
		zoneanimdecl 8, $27498, ArtTile_Art_HPZPulseOrb_3, 6, 8	;	Art_HPZPulseOrb
		dc.b $10
		dc.b   8
		dc.b   0
		dc.b   0
		dc.b   8
		dc.b $10
		even

		zoneanimend

; According to leftover resizing code, this was meant for the
; Chemical Plant Zone boss, which symbol tables refer to as "vaccume".
AnimCue_CPZ_Boss_PB:	zoneanimstart
		; Lights
		zoneanimdecl 7, $27798, ArtTile_CPZ_Lights, 2, 4	;	Art_CPZ_Lights
		dc.b   0
		dc.b   4
		even
		; Conveyor
		zoneanimdecl 7, $27898, ArtTile_CPZ_Conveyor, 3, 8	;	Art_CPZ_Conveyor
		dc.b   0
		dc.b   8
		dc.b $10
		dc.b   0
		even
		; Pistons
		zoneanimdecl 7, $27B98, ArtTile_CPZ_Pistons, 4, 2	;	Art_CPZ_Pistons
		dc.b   0
		dc.b   2
		dc.b   0
		dc.b   4
		even
		; Pressure Metre
		zoneanimdecl $B, $27C58, ArtTile_CPZ_Metre, 4, 2	;	Art_CPZ_Metre
		dc.b   0
		dc.b   2
		dc.b   4
		dc.b   2
		even
		; Cross and Circle
		zoneanimdecl $F, $27D18, ArtTile_CPZ_Cross_Circle, $A, 1	;	Art_CPZ_Cross_Circle
		dc.b   0
		dc.b   0
		dc.b   1
		dc.b   2
		dc.b   3
		dc.b   4
		dc.b   5
		dc.b   4
		dc.b   5
		dc.b   4
		even
		; Propeller
		zoneanimdecl 3, $27DD8, ArtTile_CPZ_Propeller, 4, 4	;	Art_CPZ_Propeller
		dc.b   0
		dc.b   4
		dc.b   8
		dc.b   4
		even
		; Surface Liquid
		zoneanimdecl 7, $27F58, ArtTile_CPZ_Liquid, 6, 3	;	Art_CPZ_Liquid
		dc.b   0
		dc.b   3
		dc.b   6
		dc.b   9
		dc.b  $C
		dc.b  $F
		even
		; Conveyor
		zoneanimdecl 7, $28198, ArtTile_CPZ_Conveyor_2, 4, 1	;	Art_CPZ_Conveyor_2
		dc.b   0
		dc.b   1
		dc.b   2
		dc.b   3
		even

		zoneanimend

; ===========================================================================
; ---------------------------------------------------------------------------
; This seems to be a subroutine that would've shifted the background blocks
; of Chemical Plant Zone once the player reached a certain X position,
; lasting exactly two screens. This can also be found in the final at
; $40200 in the ROM, with the only difference being its level ID, which
; was updated to match Chemical Plant's final ID ($0D instead of 02)
;
; To see the effect for yourself, add a branch to it at the
; start of LoadTilesAsYouMove and change $FFFF7500/$FFFF7D00 to
; $FFFF0000/$FFFF0800 (to make it more visible)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


; sub_1AC1E:
ShiftCPZBackground_PB:
		cmpi.b	#id_CPZ,(Current_Zone).w	; is this Chemical Plant Zone?
		beq.s	.loc_1AC28			; if yes, branch

.locret_1AC26:
		rts
; ===========================================================================
; this shifts all blocks of the chunks $EA-$ED and $FA-$FD one block to the
; left and the last block in each row (chunk $ED/$FD) to the beginning
; i.e. rotates the blocks to the left by one

.loc_1AC28:
		move.w	(Camera_X_pos).w,d0
		cmpi.w	#$1940,d0
		blo.s	.locret_1AC26
		cmpi.w	#$1F80,d0
		bhs.s	.locret_1AC26
		subq.b	#1,(CPZ_UnkScroll_Timer).w
		bpl.s	.locret_1AC26
		move.b	#7,(CPZ_UnkScroll_Timer).w
		move.b	#1,(Screen_redraw_flag).w
		lea	(v_ram_start+$7500).l,a1
		bsr.s	.sub_1AC58
		lea	(v_ram_start+$7D00).l,a1

.sub_1AC58:
		move.w	#8-1,d1

.loc_1AC5C:
		move.w	(a1),d0
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		adda.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		adda.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		adda.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	d0,(a1)+
		suba.w	#$180,a1
		dbf	d1,.loc_1AC5C
		rts
; End of function ShiftCPZBackground

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load animated blocks
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; LoadMap16Delta:
LoadAnimatedBlocks_PB:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		move.w	AnimPatMaps_PB(pc,d0.w),d0
		lea	AnimPatMaps_PB(pc,d0.w),a0
		tst.w	(a0)
		beq.s	LoadLevelBlocks_PB.locret_1AD1A
		lea	(v_16x16).w,a1
		adda.w	(a0)+,a1
		move.w	(a0)+,d1
		tst.w	(Two_player_mode).w
		bne.s	LoadLevelBlocks_2P_PB
; loc_1AD14:
LoadLevelBlocks_PB:
		move.w	(a0)+,(a1)+
		dbf	d1,LoadLevelBlocks_PB

.locret_1AD1A:
		rts
; ---------------------------------------------------------------------------
; loc_1AD1C:
LoadLevelBlocks_2P_PB:
		move.w	(a0)+,d0
		move.w	d0,d1
		andi.w	#nontile_mask,d0	; d0 holds the preserved non-tile data
		andi.w	#tile_mask,d1		; d1 holds the tile index (overwrites loop counter!)
		lsr.w	#1,d1			; half tile index
		or.w	d1,d0			; put them back together
		move.w	d0,(a1)+
		dbf	d1,LoadLevelBlocks_2P_PB
		rts
; End of function LoadAnimatedBlocks

; ===========================================================================
; like with the animated stage art, this already lists stages up to $0F and
; includes an entry for the final HPZ level slot, and this time even lists
; CPZ's final level slot
; Map16Delta_Index:
AnimPatMaps_PB:
		dc.w APM_EHZ_PB-AnimPatMaps_PB	; GHZ
		dc.w APM_None_PB-AnimPatMaps_PB	; LZ
		dc.w APM_CPZ_PB-AnimPatMaps_PB	; CPZ
		dc.w APM_EHZ_PB-AnimPatMaps_PB	; EHZ
		dc.w APM_HPZ_PB-AnimPatMaps_PB	; HPZ
		dc.w APM_None_PB-AnimPatMaps_PB	; HTZ
		dc.w APM_None_PB-AnimPatMaps_PB	; 06
		dc.w APM_None_PB-AnimPatMaps_PB	; 07
		dc.w APM_HPZ_PB-AnimPatMaps_PB	; 08
		dc.w APM_None_PB-AnimPatMaps_PB	; 09
		dc.w APM_None_PB-AnimPatMaps_PB	; 0A
		dc.w APM_None_PB-AnimPatMaps_PB	; 0B
		dc.w APM_None_PB-AnimPatMaps_PB	; 0C
		dc.w APM_CPZ_PB-AnimPatMaps_PB	; 0D
		dc.w APM_None_PB-AnimPatMaps_PB	; 0E
		dc.w APM_None_PB-AnimPatMaps_PB	; 0F

APM_EHZ_PB:	begin_animpat
		dc.w make_block_tile(ArtTile_Art_EHZPulseBall+$0,0,0,2,0),make_block_tile(ArtTile_Art_EHZPulseBall+$0,1,0,2,0)
		dc.w make_block_tile(ArtTile_Art_EHZPulseBall+$1,0,0,2,0),make_block_tile(ArtTile_Art_EHZPulseBall+$1,1,0,2,0)

		dc.w make_block_tile(ArtTile_Checkers+$0,0,0,2,0),make_block_tile(ArtTile_Art_EHZPulseBall+$0,0,0,2,0)
		dc.w make_block_tile(ArtTile_Checkers+$1,0,0,2,0),make_block_tile(ArtTile_Art_EHZPulseBall+$1,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_EHZPulseBall+$0,1,0,2,0),make_block_tile(ArtTile_Checkers+$0,1,0,2,0)
		dc.w make_block_tile(ArtTile_Art_EHZPulseBall+$1,1,0,2,0),make_block_tile(ArtTile_Checkers+$1,1,0,2,0)

		dc.w make_block_tile(ArtTile_Art_Flowers1+$0,0,0,3,0),make_block_tile(ArtTile_Art_Flowers1+$0,1,0,3,0)
		dc.w make_block_tile(ArtTile_Art_Flowers1+$1,0,0,3,0),make_block_tile(ArtTile_Art_Flowers1+$1,1,0,3,0)

		dc.w make_block_tile(ArtTile_Art_Flowers2+$0,0,0,3,1),make_block_tile(ArtTile_Art_Flowers2+$0,1,0,3,1)
		dc.w make_block_tile(ArtTile_Art_Flowers2+$1,0,0,3,1),make_block_tile(ArtTile_Art_Flowers2+$1,1,0,3,1)

		dc.w make_block_tile(ArtTile_Art_Flowers3+$0,0,0,3,0),make_block_tile(ArtTile_Art_Flowers3+$0,1,0,3,0)
		dc.w make_block_tile(ArtTile_Art_Flowers3+$1,0,0,3,0),make_block_tile(ArtTile_Art_Flowers3+$1,1,0,3,0)

		dc.w make_block_tile(ArtTile_Art_Flowers4+$0,0,0,3,1),make_block_tile(ArtTile_Art_Flowers4+$0,1,0,3,1)
		dc.w make_block_tile(ArtTile_Art_Flowers4+$1,0,0,3,1),make_block_tile(ArtTile_Art_Flowers4+$1,1,0,3,1)
APM_EHZ_PB_End:

APM_None_PB:	dc.w 0
APM_None_PB_End:

APM_Unk_PB:
		dc.w (Block_Table_End-Block_Table)-$B80 ; Bug: This should be (Block_Table_End-Block_Table)-$138
		dc.w bytesToWcnt($138)
		dc.w make_block_tile($3A0+$1,0,0,2,0),make_block_tile($3A0+$2,0,0,2,0)
		dc.w make_block_tile($3A0+$3,0,0,2,0),make_block_tile($3A0+$4,0,0,2,0)

		dc.w make_block_tile($3A0+$5,0,0,2,0),make_block_tile($3A0+$6,0,0,2,0)
		dc.w make_block_tile($3A0+$7,0,0,2,0),make_block_tile($3A0+$8,0,0,2,0)

		dc.w make_block_tile($3A0+$9,0,0,2,0),make_block_tile($3A0+$A,0,0,2,0)
		dc.w make_block_tile($3A0+$B,0,0,2,0),make_block_tile($3A0+$C,0,0,2,0)

		dc.w make_block_tile($3A0+$D,0,0,2,0),make_block_tile($3A0+$E,0,0,2,0)
		dc.w make_block_tile($3A0+$F,0,0,2,0),make_block_tile($3A0+$10,0,0,2,0)

		dc.w make_block_tile($3A0+$11,0,0,2,0),make_block_tile($3A0+$12,0,0,2,0)
		dc.w make_block_tile($3A0+$13,0,0,2,0),make_block_tile($3A0+$14,0,0,2,0)

		dc.w make_block_tile($3A0+$15,0,0,2,0),make_block_tile($3A0+$16,0,0,2,0)
		dc.w make_block_tile($3A0+$17,0,0,2,0),make_block_tile($3A0+$18,0,0,2,0)

		dc.w make_block_tile($3A0+$19,0,0,2,0),make_block_tile($3A0+$1A,0,0,2,0)
		dc.w make_block_tile($3A0+$1B,0,0,2,0),make_block_tile($3A0+$1C,0,0,2,0)

		dc.w make_block_tile($3A0+$1D,0,0,2,0),make_block_tile($3A0+$1E,0,0,2,0)
		dc.w make_block_tile($3A0+$1F,0,0,2,0),make_block_tile($3A0+$20,0,0,2,0)

		dc.w make_block_tile($3A0+$21,0,0,2,0),make_block_tile($3A0+$22,0,0,2,0)
		dc.w make_block_tile($3A0+$23,0,0,2,0),make_block_tile($3A0+$24,0,0,2,0)

		dc.w make_block_tile($3A0+$0,0,0,3,0),make_block_tile($3A0+$0,0,0,3,0)
		dc.w make_block_tile($3A0+$0,0,0,3,0),make_block_tile($3A0+$0,0,0,3,0)

		dc.w make_block_tile($3A0+$0,0,0,3,0),make_block_tile($3A0+$0,0,0,3,0)
		dc.w make_block_tile($3A0+$0,0,0,3,0),make_block_tile($3A0+$0,0,0,3,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($340+$0,0,0,3,0),make_block_tile($340+$4,0,0,3,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($340+$8,0,0,3,0),make_block_tile($340+$C,0,0,3,0)

		dc.w make_block_tile($340+$1,0,0,3,0),make_block_tile($340+$5,0,0,3,0)
		dc.w make_block_tile($340+$2,0,0,3,0),make_block_tile($340+$6,0,0,3,0)

		dc.w make_block_tile($340+$9,0,0,3,0),make_block_tile($340+$D,0,0,3,0)
		dc.w make_block_tile($340+$A,0,0,3,0),make_block_tile($340+$E,0,0,3,0)

		dc.w make_block_tile($340+$3,0,0,3,0),make_block_tile($340+$7,0,0,3,0)
		dc.w make_block_tile($340+$18,0,0,2,0),make_block_tile($340+$19,0,0,2,0)

		dc.w make_block_tile($340+$B,0,0,3,0),make_block_tile($340+$F,0,0,3,0)
		dc.w make_block_tile($340+$1A,0,0,2,0),make_block_tile($340+$1B,0,0,2,0)

		dc.w make_block_tile($380+$0,0,0,3,0),make_block_tile($380+$4,0,0,3,0)
		dc.w make_block_tile($380+$1,0,0,3,0),make_block_tile($380+$5,0,0,3,0)

		dc.w make_block_tile($380+$8,0,0,3,0),make_block_tile($380+$C,0,0,3,0)
		dc.w make_block_tile($380+$9,0,0,3,0),make_block_tile($380+$D,0,0,3,0)

		dc.w make_block_tile($380+$2,0,0,3,0),make_block_tile($380+$6,0,0,3,0)
		dc.w make_block_tile($380+$3,0,0,3,0),make_block_tile($380+$7,0,0,3,0)

		dc.w make_block_tile($380+$A,0,0,3,0),make_block_tile($380+$E,0,0,3,0)
		dc.w make_block_tile($380+$B,0,0,3,0),make_block_tile($380+$F,0,0,3,0)

		dc.w make_block_tile($390+$0,0,0,3,0),make_block_tile($390+$4,0,0,3,0)
		dc.w make_block_tile($390+$1,0,0,3,0),make_block_tile($390+$5,0,0,3,0)

		dc.w make_block_tile($390+$8,0,0,3,0),make_block_tile($390+$C,0,0,3,0)
		dc.w make_block_tile($390+$9,0,0,3,0),make_block_tile($390+$D,0,0,3,0)

		dc.w make_block_tile($390+$2,0,0,3,0),make_block_tile($390+$6,0,0,3,0)
		dc.w make_block_tile($390+$3,0,0,3,0),make_block_tile($390+$7,0,0,3,0)

		dc.w make_block_tile($390+$A,0,0,3,0),make_block_tile($390+$E,0,0,3,0)
		dc.w make_block_tile($390+$B,0,0,3,0),make_block_tile($390+$F,0,0,3,0)

		dc.w make_block_tile($370+$8,0,0,2,0),make_block_tile($370+$9,0,0,2,0)
		dc.w make_block_tile($370+$A,0,0,2,0),make_block_tile($370+$B,0,0,2,0)

		dc.w make_block_tile($370+$C,0,0,2,0),make_block_tile($370+$D,0,0,2,0)
		dc.w make_block_tile($370+$E,0,0,2,0),make_block_tile($370+$F,0,0,2,0)

		dc.w make_block_tile($350+$C,0,0,1,0),make_block_tile($350+$D,0,0,1,0)
		dc.w make_block_tile($350+$E,0,0,1,0),make_block_tile($350+$F,0,0,1,0)

		dc.w make_block_tile($350+$10,0,0,1,0),make_block_tile($350+$11,0,0,1,0)
		dc.w make_block_tile($350+$12,0,0,1,0),make_block_tile($350+$13,0,0,1,0)

		dc.w make_block_tile($350+$14,0,0,1,0),make_block_tile($350+$15,0,0,1,0)
		dc.w make_block_tile($350+$16,0,0,1,0),make_block_tile($350+$17,0,0,1,0)

		dc.w make_block_tile($350+$18,0,0,1,0),make_block_tile($350+$19,0,0,1,0)
		dc.w make_block_tile($350+$1A,0,0,1,0),make_block_tile($350+$1B,0,0,1,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($360+$C,0,0,3,0),make_block_tile($360+$D,0,0,3,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($360+$E,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile($360+$F,0,0,3,0),make_block_tile($360+$10,0,0,3,0)
		dc.w make_block_tile($360+$11,0,0,3,0),make_block_tile($360+$12,0,0,3,0)

		dc.w make_block_tile($360+$13,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($360+$14,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile($360+$15,0,0,3,0),make_block_tile($360+$16,0,0,3,0)
		dc.w make_block_tile($350+$8,0,0,2,0),make_block_tile($350+$9,0,0,2,0)

		dc.w make_block_tile($360+$17,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile($350+$A,0,0,2,0),make_block_tile($350+$B,0,0,2,0)

		dc.w make_block_tile($370+$8,0,0,2,1),make_block_tile($370+$9,0,0,2,1)
		dc.w make_block_tile($370+$A,0,0,2,1),make_block_tile($370+$B,0,0,2,1)

		dc.w make_block_tile($370+$C,0,0,2,1),make_block_tile($370+$D,0,0,2,1)
		dc.w make_block_tile($370+$E,0,0,2,1),make_block_tile($370+$F,0,0,2,1)
APM_Unk_PB_End:

APM_CPZ_PB:
		dc.w (Block_Table_End-Block_Table)-$F8
		dc.w bytesToWcnt($E0)
		dc.w make_block_tile(ArtTile_CPZ_Metre+$1,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$2,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$3,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$2,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$4,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$5,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Lights+$0,0,0,2,0),make_block_tile(ArtTile_CPZ_Lights+$1,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$5,1,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$4,1,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Lights+$2,0,0,2,0),make_block_tile(ArtTile_CPZ_Lights+$3,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Conveyor+$0,0,0,2,0),make_block_tile(ArtTile_CPZ_Conveyor+$1,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Conveyor+$2,0,0,2,0),make_block_tile(ArtTile_CPZ_Conveyor+$3,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Conveyor+$4,0,0,2,0),make_block_tile(ArtTile_CPZ_Conveyor+$5,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Conveyor+$6,0,0,2,0),make_block_tile(ArtTile_CPZ_Conveyor+$7,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Pistons+$0,0,0,3,1),make_block_tile(ArtTile_CPZ_Pistons+$1,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$E,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$F,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Conveyor_2+$0,0,0,2,0),make_block_tile(ArtTile_CPZ_Conveyor_2+$0,1,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Conveyor_2+$0,0,0,2,0),make_block_tile(ArtTile_CPZ_Conveyor_2+$0,1,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$11,0,0,2,0),make_block_tile(ArtTile_CPZ_Pistons+$1,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$11,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$F,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Pistons+$0,0,0,2,0),make_block_tile(ArtTile_CPZ_Pistons+$1,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$E,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$F,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$4,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$5,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Lights+$0,0,0,3,1),make_block_tile(ArtTile_CPZ_Lights+$1,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$5,1,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$4,1,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Lights+$2,0,0,3,1),make_block_tile(ArtTile_CPZ_Lights+$3,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Conveyor+$0,0,0,3,1),make_block_tile(ArtTile_CPZ_Conveyor+$1,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Conveyor+$2,0,0,3,1),make_block_tile(ArtTile_CPZ_Conveyor+$3,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Pistons+$0,0,0,3,1),make_block_tile(ArtTile_CPZ_Pistons+$1,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$E,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$F,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$12,0,0,3,1),make_block_tile(ArtTile_CPZ_Metre+$0,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$14,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$3,1,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Metre+$1,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$2,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$3,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$2,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$15,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$16,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$17,0,0,3,1),make_block_tile(ArtTile_CPZ_Cross_Circle+$0,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$17,0,0,3,1),make_block_tile(ArtTile_CPZ_Cross_Circle+$0,0,1,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$15,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$16,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$15,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$16,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$19,0,0,3,1),make_block_tile(ArtTile_CPZ_Metre+$0,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$16,1,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$1A,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Metre+$1,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$19,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Propeller+$0,0,0,3,1),make_block_tile(ArtTile_CPZ_Propeller+$1,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$0,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$1D,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Propeller+$2,0,0,3,1),make_block_tile(ArtTile_CPZ_Propeller+$3,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$1D,1,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$0,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Conveyor+$4,0,0,3,1),make_block_tile(ArtTile_CPZ_Conveyor+$5,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Conveyor+$6,0,0,3,1),make_block_tile(ArtTile_CPZ_Conveyor+$7,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$12,0,0,2,0),make_block_tile(ArtTile_CPZ_Metre+$0,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$14,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$3,1,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Liquid+$0,0,0,3,1),make_block_tile(ArtTile_CPZ_Liquid+$1,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$22,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$22,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Liquid+$2,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$23,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$22,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$24,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$15,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$16,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$19,0,0,2,0),make_block_tile(ArtTile_CPZ_Metre+$0,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$16,1,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$1A,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Metre+$1,0,0,2,0),make_block_tile(ArtTile_CPZ_Buildings+$19,0,0,2,0)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$11,0,0,3,1),make_block_tile(ArtTile_CPZ_Pistons+$1,0,0,3,1)
		dc.w make_block_tile(ArtTile_CPZ_Buildings+$11,0,0,3,1),make_block_tile(ArtTile_CPZ_Buildings+$F,0,0,3,1)
APM_CPZ_PB_End:

APM_HPZ_PB:	begin_animpat
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$0,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$1,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$2,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$3,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$4,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$5,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$6,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$7,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$0,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$1,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$2,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$3,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$4,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$5,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$6,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$7,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$0,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$1,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$2,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$3,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$4,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$5,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$6,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$7,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$0,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$1,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$2,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$3,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$4,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$5,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$6,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$7,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$0,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$1,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$2,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$3,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$4,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$5,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$6,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$7,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$0,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$1,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$2,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$3,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$4,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$5,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$6,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$7,0,0,2,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$0,0,0,3,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$2,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$1,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$4,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$3,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$6,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$5,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$7,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$0,0,0,3,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$2,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$1,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$4,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$3,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$6,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$5,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$7,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$0,0,0,3,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$2,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$1,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$4,0,0,3,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$3,0,0,3,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$6,0,0,3,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$5,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$7,0,0,3,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$0,0,0,2,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$2,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$1,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$4,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$3,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_1+$6,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$5,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_1+$7,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$0,0,0,2,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$2,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$1,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$4,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$3,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_2+$6,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$5,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_2+$7,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)

		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$0,0,0,2,0)
		dc.w make_block_tile(ArtTile_Level+$0,0,0,0,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$2,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$1,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$4,0,0,2,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$3,0,0,2,0),make_block_tile(ArtTile_Art_HPZPulseOrb_3+$6,0,0,2,0)

		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$5,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
		dc.w make_block_tile(ArtTile_Art_HPZPulseOrb_3+$7,0,0,2,0),make_block_tile(ArtTile_Level+$0,0,0,0,0)
APM_HPZ_PB_End:

		jmpTos	; Empty
	dephase

		binclude	"leftovers/symbols/symbol23.bin"
		even

	phase $19A22
		include	"leftovers/obj/S1/09 Sonic in Special Stage.asm"
		include	"leftovers/obj/10.asm"

	dephase

		binclude	"leftovers/symbols/symbol24.bin"
		even

	phase $1AB00
		include	"leftovers/obj/DebugMode.asm"
		include	"leftovers/_Include/DebugList.asm"

		jmpTos	; Empty
	dephase

		binclude	"leftovers/symbols/symbol25.bin"
		even

	phase $1A074
		include	"leftovers/obj/21 HUD.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_Obj21_PB:	dc.w Map_Obj21_PB_internal_0008-Map_Obj21_PB
		dc.w Map_Obj21_PB_internal_005A-Map_Obj21_PB
		dc.w Map_Obj21_PB_internal_00AC-Map_Obj21_PB
		dc.w Map_Obj21_PB_internal_00FE-Map_Obj21_PB
Map_Obj21_PB_internal_0008:	dc.w $A
		dc.w $800D, $A000, $A000, 0
		dc.w $800D, $A018, $A00C, $20
		dc.w $800D, $A020, $A010, $40
		dc.w $900D, $A010, $A008, 0
		dc.w $900D, $A028, $A014, $28
		dc.w $A00D, $A008, $A004, 0
		dc.w $A001, $A000, $A000, $20
		dc.w $A009, $A030, $A018, $30
		dc.w $4005, $810A, $8085, 0
		dc.w $400D, $A10E, $A087, $10
Map_Obj21_PB_internal_005A:	dc.w $A
		dc.w $800D, $A000, $A000, 0
		dc.w $800D, $A018, $A00C, $20
		dc.w $800D, $A020, $A010, $40
		dc.w $900D, $A010, $A008, 0
		dc.w $900D, $A028, $A014, $28
		dc.w $A00D, $8008, $8004, 0
		dc.w $A001, $8000, $8000, $20
		dc.w $A009, $A030, $A018, $30
		dc.w $4005, $810A, $8085, 0
		dc.w $400D, $A10E, $A087, $10
Map_Obj21_PB_internal_00AC:	dc.w $A
		dc.w $800D, $A000, $A000, 0
		dc.w $800D, $A018, $A00C, $20
		dc.w $800D, $A020, $A010, $40
		dc.w $900D, $8010, $8008, 0
		dc.w $900D, $A028, $A014, $28
		dc.w $A00D, $A008, $A004, 0
		dc.w $A001, $A000, $A000, $20
		dc.w $A009, $A030, $A018, $30
		dc.w $4005, $810A, $8085, 0
		dc.w $400D, $A10E, $A087, $10
Map_Obj21_PB_internal_00FE:	dc.w $A
		dc.w $800D, $A000, $A000, 0
		dc.w $800D, $A018, $A00C, $20
		dc.w $800D, $A020, $A010, $40
		dc.w $900D, $8010, $8008, 0
		dc.w $900D, $A028, $A014, $28
		dc.w $A00D, $8008, $8004, 0
		dc.w $A001, $8000, $8000, $20
		dc.w $A009, $A030, $A018, $30
		dc.w $4005, $810A, $8085, 0
		dc.w $400D, $A10E, $A087, $10

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to add points to the score counter
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


AddPoints_PB:
		move.b	#1,(f_scorecount).w
		lea	(v_score).w,a3
		add.l	d0,(a3)
		move.l	#999999,d1
		cmp.l	(a3),d1
		bhi.s	.belowmax
		move.l	d1,(a3)

.belowmax:
		move.l	(a3),d0
		cmp.l	(v_scorelife).w,d0
		blo.s	.noextralife
		addi.l	#5000,(v_scorelife).w
		tst.b	(v_megadrive).w			; is this a Japanese console?
		bmi.s	.noextralife			; if not, branch
		addq.b	#1,(v_lives).w
		addq.b	#1,(f_lifecount).w
		move.w	#bgm_ExtraLife,d0
		jmp	($12F6).l	;	QueueSound1

.noextralife:
		rts
; End of function AddPoints
; ===========================================================================

		include	"leftovers/_Include/HUD Update.asm"

Art_HUD_PB:	binclude	"art/uncompressed/HUD Numbers.bin"
		even
Art_LivesNums_PB:	binclude	"art/uncompressed/Lives Counter Numbers.bin"
		even

		jmpTos	; Empty
	dephase

		binclude	"leftovers/symbols/symbol26.bin"
		even
		binclude	"leftovers/symbols/symbol26a.bin"
		even

	phase $1C056
		include	"leftovers/_Include/LevelHeaders.asm"
		include	"leftovers/_Include/Pattern Load Cues.asm"

		binclude	"leftovers/art/uncompressed/cut-off/1C318.bin"
		even
	dephase

		binclude	"leftovers/symbols/symbol27.bin"
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Modified Type 1b 68000 Sound Driver
; Same as Sonic 1's, down to its location in the ROM
; ---------------------------------------------------------------------------
		include	"s1.sounddriver.asm"
		even

; ---------------------------------------------------------------------------
; Uncompressed graphics - Sonic and Tails
; ---------------------------------------------------------------------------
; This must be aligned to a bank in order to avoid issues with the DMA.
; But because all of the art is placed after the sound driver which already aligns with the bank,
; this fixes itself.
; The exact location in ROM that this is located at is 0x80000.
	if FixBugs=0
	; Ensure properly art alignment, unnessesary if the DMA bug fix is enabled for 128kb boundaries.
	align $8000
	endif
Art_Sonic:	binclude	"art/uncompressed/Sonic's art.bin"
		even
Map_Sonic:	include	"mappings/sprite/Sonic.asm"
Art_Tails:	binclude	"art/uncompressed/Tails' art.bin"
		even
SonicDynPLC:	include	"mappings/spriteDPLC/Sonic.asm"
Nem_Shield:	binclude	"art/nemesis/Shield.nem"
		even
Nem_Stars:	binclude	"art/nemesis/Stars.nem"
		even
Art_SplashDust:	binclude	"art/uncompressed/Dust and water splash.bin"
		even
Map_Tails:	include	"mappings/sprite/Tails.asm"
TailsDynPLC:	include	"mappings/spriteDPLC/Tails.asm"

; ---------------------------------------------------------------------------
; Compressed graphics - sega and title screen stuff
; ---------------------------------------------------------------------------
Nem_SegaLogo:	binclude	"art/nemesis/S1/Sega Logo (JP1).nem"
		even
Eni_SegaLogo:	binclude	"tilemaps/S1/Sega Logo (JP1).eni"
		even
Eni_TitleMap:	binclude	"tilemaps/Title Emblem.eni"
		even
Eni_TitleBg1:	binclude	"tilemaps/Title Background - 1.eni"
		even
Eni_TitleBg2:	binclude	"tilemaps/Title Background - 2.eni"
		even
Nem_Title:	binclude	"art/nemesis/8x8 - Title.nem"
		even
Nem_TitleSonicTails:	binclude	"art/nemesis/Title Sonic and Tails.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------
S1Nem_GHZFlowerBits:	binclude	"art/nemesis/S1/GHZ Flower Stalk.nem"
		even
Nem_SwingPlatform:	binclude	"art/nemesis/S1/GHZ Swinging Platform.nem"
		even
Nem_GHZ_Bridge:	binclude	"art/nemesis/S1/GHZ Bridge.nem"
		even
		binclude	"art/nemesis/S1/Unused - GHZ Block.nem"
		even
S1Nem_GHZRollingBall:	binclude	"art/nemesis/S1/GHZ Giant Ball.nem"
		even
S1Nem_GHZRollingSpikesLog:	binclude	"art/nemesis/S1/Unused - GHZ Log.nem"
		even
S1Nem_GHZLogSpikes:	binclude	"art/nemesis/S1/GHZ Spiked Log.nem"
		even
Nem_GHZ_Rock:	binclude	"art/nemesis/S1/GHZ Purple Rock.nem"
		even
S1Nem_GHZBreakableWall:	binclude	"art/nemesis/S1/GHZ Breakable Wall.nem"
		even
S1Nem_GHZWall:	binclude	"art/nemesis/S1/GHZ Edge Wall.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - EHZ stuff
; ---------------------------------------------------------------------------
Nem_EHZ_Fireball:	binclude	"art/nemesis/Fireball 1.nem"
		even
Nem_BurningLog:	binclude	"art/nemesis/Burning Log.nem"
		even
Nem_EHZ_Waterfall:	binclude	"art/nemesis/Waterfall tiles.nem"
		even
Nem_HTZ_Fireball:	binclude	"art/nemesis/Fireball 2.nem"
		even
Nem_EHZ_Bridge:	binclude	"art/nemesis/EHZ bridge.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - HTZ stuff
; ---------------------------------------------------------------------------
Nem_HTZ_Lift:	binclude	"art/nemesis/HTZ zip-line platform.nem"
		even
Nem_HTZ_AutomaticDoor:
		binclude	"art/nemesis/HTZ Autodoor.nem"
		even
Nem_HTZ_Seesaw:	binclude	"art/nemesis/See-saw in HTZ.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - HPZ stuff
; ---------------------------------------------------------------------------
Nem_HPZ_Bridge:	binclude	"art/nemesis/HPZ bridge.nem"
		even
Nem_HPZ_Waterfall:	binclude	"art/nemesis/HPZ waterfall.nem"
		even
Nem_HPZ_Emerald:	binclude	"art/nemesis/HPZ Emerald.nem"
		even
Nem_HPZ_Platform:	binclude	"art/nemesis/HPZ Platform.nem"
		even
Nem_HPZ_PulsingBall:	binclude	"art/nemesis/HPZ Pulsing Ball.nem"
		even
Nem_HPZ_Various:	binclude	"art/nemesis/HPZ Various.nem"
		even
Nem_UnusedDust:	binclude	"art/nemesis/Unused - Dust.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - CPZ stuff
; ---------------------------------------------------------------------------
Nem_CPZ_FloatingPlatform:	binclude	"art/nemesis/CPZ Floating Platform.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Nem_WaterSurface:	binclude	"art/nemesis/Water Surface.nem"
		even
Nem_Button:	binclude	"art/nemesis/Button.nem"
		even
Nem_VSpring2:	binclude	"art/nemesis/Vertical spring.nem"
		even
Nem_HSpring2:	binclude	"art/nemesis/Horizontal spring.nem"
		even
Nem_DSpring:	binclude	"art/nemesis/Diagonal spring.nem"
		even
Nem_HUD:	binclude	"art/nemesis/HUD.nem"
		even
Nem_Lives:	binclude	"art/nemesis/Sonic lives counter.nem"
		even
Nem_Ring:	binclude	"art/nemesis/Ring.nem"
		even
Nem_Monitors:	binclude	"art/nemesis/Monitor and contents.nem"
		even
Nem_VSpikes:	binclude	"art/nemesis/Spikes.nem"
		even
Nem_Points:	binclude	"art/nemesis/Numbers.nem"
		even
Nem_Lamppost:	binclude	"art/nemesis/Lamppost.nem"
		even
Nem_Signpost:	binclude	"art/nemesis/Signpost.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
Nem_Gator:	binclude	"art/nemesis/Gator.nem"
		even
Nem_Buzzer:	binclude	"art/nemesis/Buzzer.nem"
		even
Nem_BBat:	binclude	"art/nemesis/BBat.nem"
		even
Nem_Octus:	binclude	"art/nemesis/Octus.nem"
		even
Nem_Stegway:	binclude	"art/nemesis/Stegway.nem"
		even
Nem_Redz:	binclude	"art/nemesis/Redz.nem"
		even
Nem_BFish:	binclude	"art/nemesis/BFish.nem"
		even
Nem_Aquis:	binclude	"art/nemesis/Aquis.nem"
		even
Nem_RollingBall:	binclude	"art/nemesis/Ball.nem"
		even
Nem_MotherBubbler:	binclude	"art/nemesis/Unused - Bubbler's Mother.nem"
		even
Nem_Bubbler:	binclude	"art/nemesis/Unused - Bubbler.nem"
		even
Nem_Snail:	binclude	"art/nemesis/Snail badnik from EHZ.nem"
		even
Nem_Crawl:	binclude	"art/nemesis/Crawl badnik.nem"
		even
Nem_Masher:	binclude	"art/nemesis/Masher.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - bosses
; ---------------------------------------------------------------------------
Nem_BossShip:	binclude	"art/nemesis/Boss Ship.nem"
		even
Nem_CPZ_ProtoBoss:	binclude	"art/nemesis/CPZ boss.nem"
		even
Nem_BigExplosion:	binclude	"art/nemesis/Large explosion.nem"
		even
Nem_BossShipBoost:	binclude	"art/nemesis/Boss Ship Boost.nem"
		even
Nem_Smoke:	binclude	"art/nemesis/Smoke trail from CPZ boss.nem"
		even
Nem_EHZ_Boss:	binclude	"art/nemesis/EHZ boss.nem"
		even
Nem_EHZ_Boss_Blades:	binclude	"art/nemesis/Chopper blades for EHZ boss.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - enemies (S1)
; ---------------------------------------------------------------------------
Nem_BallHog:	binclude	"art/nemesis/S1/Enemy Ball Hog.nem"
		even
Nem_Crabmeat:	binclude	"art/nemesis/S1/Enemy Crabmeat.nem"
		even
Nem_GHZBuzzbomber:	binclude	"art/nemesis/S1/Enemy Buzz Bomber.nem"
		even
Nem_UnkExplosion:	binclude	"art/nemesis/S1/Unused - Explosion.nem"
		even
Nem_Burrobot:	binclude	"art/nemesis/S1/Enemy Burrobot.nem"
		even
Nem_Chopper:	binclude	"art/nemesis/S1/Enemy Chopper.nem"
		even
Nem_Jaws:	binclude	"art/nemesis/S1/Enemy Jaws.nem"
		even
Nem_Roller:	binclude	"art/nemesis/S1/Enemy Roller.nem"
		even
Nem_Motobug:	binclude	"art/nemesis/S1/Enemy Motobug.nem"
		even
Nem_Newtron:	binclude	"art/nemesis/S1/Enemy Newtron.nem"
		even
Nem_Yadrin:	binclude	"art/nemesis/S1/Enemy Yadrin.nem"
		even
Nem_Basaran:	binclude	"art/nemesis/S1/Enemy Basaran.nem"
		even
Nem_Splats:	binclude	"art/nemesis/S1/Enemy Splats.nem"
		even
Nem_Bomb:	binclude	"art/nemesis/S1/Enemy Bomb.nem"
		even
Nem_Orbinaut:	binclude	"art/nemesis/S1/Enemy Orbinaut.nem"
		even
Nem_Caterkiller:	binclude	"art/nemesis/S1/Enemy Caterkiller.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - various (S1)
; ---------------------------------------------------------------------------
Nem_TitleCard:	binclude	"art/nemesis/S1/Title Cards.nem"
		even
Nem_Explosion:	binclude	"art/nemesis/S1/Explosion.nem"
		even
Nem_GameOver:	binclude	"art/nemesis/S1/Game Over.nem"
		even
Nem_HSpring:	binclude	"art/nemesis/S1/Spring Horizontal.nem"
		even
Nem_VSpring:	binclude	"art/nemesis/S1/Spring Vertical.nem"
		even
Nem_BigFlash:	binclude	"art/nemesis/S1/Giant Ring Flash.nem"
		even
Nem_BonusPoints:	binclude	"art/nemesis/S1/Hidden Bonuses.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
Nem_SonicContinue:	binclude	"art/nemesis/S1/Continue Screen Sonic.nem"
		even
Nem_MiniSonic:	binclude	"art/nemesis/S1/Continue Screen Stuff.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
Nem_Bunny:	binclude	"art/nemesis/S1/Animal Rabbit.nem"
		even
Nem_Chicken:	binclude	"art/nemesis/S1/Animal Chicken.nem"
		even
Nem_Penguin:	binclude	"art/nemesis/S1/Animal Penguin.nem"
		even
Nem_Seal:	binclude	"art/nemesis/S1/Animal Seal.nem"
		even
Nem_Pig:	binclude	"art/nemesis/S1/Animal Pig.nem"
		even
Nem_Flicky:	binclude	"art/nemesis/S1/Animal Flicky.nem"
		even
Nem_Squirrel:	binclude	"art/nemesis/S1/Animal Squirrel.nem"
		even

; ---------------------------------------------------------------------------
; Level Data
; ---------------------------------------------------------------------------
Map16_EHZ:	binclude	"mappings/16x16/EHZ.unc"
Map16_EHZ_End:
		even
Nem_EHZ:binclude	"art/nemesis/8x8 - EHZ.nem"
		even
Map16_HTZ:	binclude	"mappings/16x16/HTZ.unc"
Map16_HTZ_End:
		even
Nem_HTZ:	binclude	"art/nemesis/8x8 - HTZ.nem"
		even
Nem_HTZ_AniPlaceholders:	binclude	"art/nemesis/HTZ Ani Placeholders.nem"
		even
Map128_EHZ:	binclude	"mappings/128x128/EHZ_HTZ.unc"
		even
Map16_HPZ:	binclude	"mappings/16x16/HPZ.unc"
Map16_HPZ_End:
		even
Nem_HPZ:binclude	"art/nemesis/8x8 - HPZ.nem"
		even
Map128_HPZ:	binclude	"mappings/128x128/HPZ.unc"
		even
Map16_CPZ:	binclude	"mappings/16x16/CPZ.unc"
Map16_CPZ_End:
		even
Nem_CPZ:	binclude	"art/nemesis/8x8 - CPZ.nem"
		even
Nem_CPZ_Buildings:	binclude	"art/nemesis/CPZ Buildings.nem"
		even
Map128_CPZ:	binclude	"mappings/128x128/CPZ.unc"
		even
Map16_GHZ:	binclude	"mappings/16x16/GHZ.unc"
Map16_GHZ_End:
		even
Nem_GHZ:	binclude	"art/nemesis/8x8 - GHZ.nem"
		even
Nem_GHZ2:	binclude	"art/nemesis/8x8 - GHZ2.nem"
		even
; Comparatively to the source compressors for KCC, this is one is better in size by 0.06%
; Maybe this could be from slightly after KCC was finalized? Who knows!
Map128_GHZ:	binclude	"mappings/128x128/GHZ.kcc"
		even
	if PaddingOptimization=0
; duplicate chunk end data from the above
		dc.w 0, $7F00, $BFA, 0, 0
	endif

; ---------------------------------------------------------------------------
; Compressed graphics - bosses and ending sequence
; ---------------------------------------------------------------------------
Nem_TryAgain:	binclude	"art/nemesis/S1/cut-off/Ending - Try Again.nem"
		even
Kos_EndFlowers:	binclude	"art/kosinski/S1/Flowers at Ending.kos"
		even
Nem_EndFlower:	binclude	"art/nemesis/S1/Ending - Flowers.nem"
		even
Nem_CreditText:	binclude	"art/nemesis/S1/Ending - Credits.nem"
		even
Nem_EndStH:	binclude	"art/nemesis/S1/Ending - StH Logo.nem"
		even

	if PaddingOptimization=0
; --------------------------------------------------------------------------------------
; ToeJam & Earl REV00 data, likely due to it once occupying the cartridge, best
; just to remove it given it takes up ONE TENTH of the cartridge space
; --------------------------------------------------------------------------------------
Leftover_E1670:	binclude	"leftovers/E1670.bin"
		even

		cnop	-1,2<<lastbit(*-1)
		even
	endif
EndOfRom: