; ---------------------------------------------------------------------------
; Constants
; ---------------------------------------------------------------------------

Size_of_SegaPCM:	equ $6978
Size_of_DAC_driver_guess:	equ $1760

; Clocks
Master_Clock:    equ 53693175
M68000_Clock:    equ Master_Clock/7
Z80_Clock:       equ Master_Clock/15
FM_Sample_Rate:  equ M68000_Clock/(6*6*4)
PSG_Sample_Rate: equ Z80_Clock/16

; VDP addressses
vdp_data_port:		equ $C00000
vdp_control_port:	equ $C00004
vdp_counter:	equ $C00008
psg_input:		equ $C00011
debug_reg:		equ $C0001C

; Z80 addresses
z80_ram:	equ $A00000			; start of Z80 RAM
z80_dac_timpani_pitch:	equ z80_ram+zTimpani_Pitch
z80_dac_status:	equ z80_ram+zDAC_Status
z80_dac_sample:	equ z80_ram+zDAC_Sample
z80_ram_end:	equ $A02000			; end of non-reserved Z80 RAM
ym2612_a0:	equ $A04000
ym2612_d0:	equ $A04001
ym2612_a1:	equ $A04002
ym2612_d1:	equ $A04003
z80_bus_request:	equ $A11100
z80_reset:	equ $A11200

; I/O addresses
console_version:	equ $A10001
port_1_data_hi:		equ $A10002
port_1_data:		equ $A10003
port_2_data_hi:		equ $A10004
port_2_data:		equ $A10005
port_1_control_hi:	equ $A10008
port_1_control:		equ $A10009
port_2_control_hi:	equ $A1000A
port_2_control:		equ $A1000B
expansion_control_hi:	equ $A1000C
expansion_control:	equ $A1000D

; Misc addresses
sram_port:		equ $A130F1
security_addr:	equ $A14000

; VRAM data
vram_window:	equ $A000				; window namespace
vram_fg:	equ $C000				; foreground namespace
vram_bg:	equ $E000				; background namespace
vram_fg_2p:	equ $A000				; foreground namespace
vram_bg_2p:	equ $8000				; background namespace
vram_sprites:	equ $F800				; sprite table
vram_hscroll:	equ $FC00				; horizontal scroll table
tile_size:	equ 8*8/2
plane_size_64x32:	equ 64*32*2

palette_size:	equ $80

; Sonic 1 Constants
S1_EndOfRom:	equ $80000			; Sonic 1 End of Rom size

; ===========================================================================
; ---------------------------------------------------------------------------
; Object Status Table offsets
; ---------------------------------------------------------------------------

; Object variables
obID:		equ 0					; object ID number
obRender:	equ 1					; bitfield for x/y flip, display mode
obGfx:		equ 2					; palette line & VRAM setting (2 bytes)
obMap:		equ 4					; mappings address (4 bytes)
obX:		equ 8					; x-axis position (2-4 bytes)
obScreenY:	equ $A					; y-axis position for screen-fixed items (2 bytes)
obY:		equ $C					; y-axis position (2-4 bytes)
obVelX:		equ $10					; x-axis velocity (2 bytes)
obVelY:		equ $12					; y-axis velocity (2 bytes)
obInertia:	equ $14					; potential speed (2 bytes)
obHeight:	equ $16					; height/2
obWidth:	equ $17					; width/2
obPriority:	equ $18					; sprite stack priority -- 0 is front
obActWid:	equ $19					; action width
obFrame:	equ $1A					; current frame displayed
obAniFrame:	equ $1B					; current frame in animation script
obAnim:		equ $1C					; current animation
obPrevAni:	equ $1D					; previous animation
obTimeFrame:	equ $1E					; time to next frame
obDelayAni:	equ $1F					; time to delay animation
obColType:	equ $20					; collision response type
obColProp:	equ $21					; collision extra property
obStatus:	equ $22					; orientation or mode
obRespawnNo:	equ $23					; respawn list index number
obRoutine:	equ $24					; routine number
ob2ndRout:	equ $25					; secondary routine number
obAngle:	equ $26					; angle
obSubtype:	equ $28					; object subtype
obSolid:	equ ob2ndRout				; solid status flag

top_solid_bit:	equ	$3E 			; the bit to check for top solidity (either $C or $E)
lrb_solid_bit:	equ	$3F 			; the bit to check for left/right/bottom solidity (either $D or $F)

obTopSolidBit:	equ $3E					; bit to check for top solidity (either $C or $E)
obLRBSolidBit:	equ $3F					; bit to check for left/right/bottom solidity (either $D or $F)

; Object variables used by Sonic/Tails
flip_angle:	equ $27 ; angle about the x axis (360 degrees = 256) (twist/tumble)
flips_remaining: equ $2C ; number of flip revolutions remaining
flip_speed:	equ $2D ; number of flip revolutions per frame / 256
locktime:	equ $2E	; temporary D-Pad control lock timer (2 bytes)
flashtime:	equ $30	; time between flashes after getting hit (2 bytes)
invtime:	equ $32	; time left for invincibility (2 bytes)
shoetime:	equ $34	; time left for speed shoes (2 bytes)
angleright:	equ $36	; angle of floor on Sonic's right side
angleleft:	equ $37	; angle of floor on Sonic's left side
sticktoconvex:	equ $38	; flag set while running on an SBZ gear
spindash_flag:	equ $39	; 0 for normal, 1 for charging a spindash or forced rolling
restartime:	equ $3A	; time left before level restarts after dying (2 bytes)
jumping:	equ $3C	; flag set while Sonic is jumping
standonobject:	equ $3D	; object index Sonic stands on

; Miscellaneous object scratch-RAM
objoff_25:	equ $25
objoff_26:	equ $26
objoff_27:	equ $27
objoff_29:	equ $29
objoff_2A:	equ $2A
objoff_2B:	equ $2B
objoff_2C:	equ $2C
objoff_2D:	equ $2D
objoff_2E:	equ $2E
objoff_2F:	equ $2F
objoff_30:	equ $30
objoff_32:	equ $32
objoff_33:	equ $33
objoff_34:	equ $34
objoff_35:	equ $35
objoff_36:	equ $36
objoff_37:	equ $37
objoff_38:	equ $38
objoff_39:	equ $39
objoff_3A:	equ $3A
objoff_3B:	equ $3B
objoff_3C:	equ $3C
objoff_3D:	equ $3D
objoff_3E:	equ $3E
objoff_3F:	equ $3F

object_size_bits:	equ 6
object_size:	equ 1<<object_size_bits

; ---------------------------------------------------------------------------
; when childsprites are activated (i.e. bit #6 of render_flags set)
next_subspr	= 6
mainspr_mapframe	= $B
mainspr_width	= $E
mainspr_childsprites = $F	; amount of child sprites
mainspr_height	= $14
subspr_data	= $10
sub2_x_pos	= subspr_data+next_subspr*0+0	;x_vel
sub2_y_pos	= subspr_data+next_subspr*0+2	;y_vel
sub2_mapframe	= subspr_data+next_subspr*0+5
sub3_x_pos	= subspr_data+next_subspr*1+0	;y_radius
sub3_y_pos	= subspr_data+next_subspr*1+2	;priority
sub3_mapframe	= subspr_data+next_subspr*1+5	;anim_frame
sub4_x_pos	= subspr_data+next_subspr*2+0	;anim
sub4_y_pos	= subspr_data+next_subspr*2+2	;anim_frame_duration
sub4_mapframe	= subspr_data+next_subspr*2+5	;collision_property
sub5_x_pos	= subspr_data+next_subspr*3+0	;status
sub5_y_pos	= subspr_data+next_subspr*3+2	;routine
sub5_mapframe	= subspr_data+next_subspr*3+5
sub6_x_pos	= subspr_data+next_subspr*4+0	;subtype
sub6_y_pos	= subspr_data+next_subspr*4+2
sub6_mapframe	= subspr_data+next_subspr*4+5
sub7_x_pos	= subspr_data+next_subspr*5+0
sub7_y_pos	= subspr_data+next_subspr*5+2
sub7_mapframe	= subspr_data+next_subspr*5+5
sub8_x_pos	= subspr_data+next_subspr*6+0
sub8_y_pos	= subspr_data+next_subspr*6+2
sub8_mapframe	= subspr_data+next_subspr*6+5
sub9_x_pos	= subspr_data+next_subspr*7+0
sub9_y_pos	= subspr_data+next_subspr*7+2
sub9_mapframe	= subspr_data+next_subspr*7+5

; Levels
id_GHZ:	equ 0
id_LZ:	equ 1
id_CPZ:	equ 2
id_MZ:	equ 2
id_EHZ:	equ 3
id_SLZ:	equ 3
id_HPZ:	equ 4
id_SYZ:	equ 4
id_HTZ:	equ 5
id_SBZ:	equ 5
id_EndZ:	equ 6
id_SS:	equ 7

; Colours
cBlack:	equ $000				; colour black
cWhite:	equ $EEE				; colour white
cBlue:	equ $E00				; colour blue
cGreen:	equ $0E0				; colour green
cRed:	equ $00E				; colour red
cYellow:	equ cGreen+cRed				; colour yellow
cAqua:	equ cGreen+cBlue			; colour aqua
cMagenta:	equ cBlue+cRed				; colour magenta
cCyan:	equ $880				; colour cyan
; ---------------------------------------------------------------------------
; Controller Buttons

; Buttons bit numbers
bitUp:	EQU	0
bitDn:	EQU	1
bitL:	EQU	2
bitR:	EQU	3
bitB:	EQU	4
bitC:	EQU	5
bitA:	EQU	6
bitStart:	EQU	7
; Buttons masks (1 << x == pow(2, x))
btnUp:	EQU	1<<bitUp		; $01
btnDn:	EQU	1<<bitDn		; $02
btnL:	EQU	1<<bitL			; $04
btnR:	EQU	1<<bitR			; $08
btnB:	EQU	1<<bitB			; $10
btnC:	EQU	1<<bitC			; $20
btnA:	EQU	1<<bitA			; $40
btnABC:	EQU	btnA+btnB+btnC		; $70
btnStart:	EQU	1<<bitStart		; $80
; ---------------------------------------------------------------------------
; Art tile stuff
flip_x	=	(1<<11)
flip_y	=	(1<<12)
palette_bit_0	=	5
palette_bit_1	=	6
palette_line_0	=	(0<<13)
palette_line_1	=	(1<<13)
palette_line_2	=	(2<<13)
palette_line_3	=	(3<<13)
high_priority_bit	=	7
high_priority	=	(1<<15)
palette_mask	=	$6000
tile_mask	=	$7FF
nontile_mask	=	$F800
drawing_mask	=	$7FFF

; Animation IDs
	phase 0
AniIDSonAni_Walk:		ds.b 1
AniIDSonAni_Run:		ds.b 1
AniIDSonAni_Roll:		ds.b 1
AniIDSonAni_Roll2:		ds.b 1
AniIDSonAni_Push:		ds.b 1
AniIDSonAni_Wait:		ds.b 1
AniIDSonAni_Balance:	ds.b 1
AniIDSonAni_LookUp:		ds.b 1
AniIDSonAni_Duck:		ds.b 1
AniIDSonAni_Spindash:	ds.b 1
AniIDSonAni_WallRecoil1:	ds.b 1
AniIDSonAni_WallRecoil2:	ds.b 1
AniIDSonAni_WailRecoil3:	ds.b 1
AniIDSonAni_Stop:		ds.b 1
AniIDSonAni_Float:		ds.b 1
AniIDSonAni_Float2:		ds.b 1
AniIDSonAni_Spring:		ds.b 1
AniIDSonAni_S1Hang:		ds.b 1
AniIDSonAni_S1Leap1:	ds.b 1
AniIDSonAni_S1Leap2:	ds.b 1
AniIDSonAni_S1Surf:		ds.b 1
AniIDSonAni_Bubble:		ds.b 1
AniIDSonAni_Burnt:		ds.b 1
AniIDSonAni_Drown:		ds.b 1
AniIDSonAni_Death:		ds.b 1
AniIDSonAni_S1Shrink:	ds.b 1
AniIDSonAni_Hurt:		ds.b 1
AniIDSonAni_WaterSlide:	ds.b 1
AniIDSonAni_Blank:		ds.b 1
AniIDSonAni_Float3:		ds.b 1
AniIDSonAni_S1Float4:	ds.b 1
	dephase
	!org 0

	phase 0
AniIDTailsAni_Walk:		ds.b 1
AniIDTailsAni_Run:		ds.b 1
AniIDTailsAni_Roll:		ds.b 1
AniIDTailsAni_Roll2:		ds.b 1
AniIDTailsAni_Push:		ds.b 1
AniIDTailsAni_Wait:		ds.b 1
AniIDTailsAni_Balance:	ds.b 1
AniIDTailsAni_LookUp:		ds.b 1
AniIDTailsAni_Duck:		ds.b 1
AniIDTailsAni_Spindash:	ds.b 1
AniIDTailsAni_WallRecoil1:	ds.b 1
AniIDTailsAni_WallRecoil2:	ds.b 1
AniIDTailsAni_WailRecoil3:	ds.b 1
AniIDTailsAni_Stop:		ds.b 1
AniIDTailsAni_Fly:		ds.b 1
AniIDTailsAni_Float2:		ds.b 1
AniIDTailsAni_Spring:		ds.b 1
AniIDTailsAni_Hang:		ds.b 1
AniIDTailsAni_Leap1:	ds.b 1
AniIDTailsAni_Leap2:	ds.b 1
AniIDTailsAni_Surf:		ds.b 1
AniIDTailsAni_Bubble:		ds.b 1
AniIDTailsAni_Burnt:		ds.b 1
AniIDTailsAni_Drown:		ds.b 1
AniIDTailsAni_Death:		ds.b 1
AniIDTailsAni_Shrink:	ds.b 1
AniIDTailsAni_Hurt:		ds.b 1
AniIDTailsAni_WaterSlide:	ds.b 1
AniIDTailsAni_Blank:		ds.b 1
AniIDTailsAni_Float3:		ds.b 1
AniIDTailsAni_Float4:	ds.b 1
	dephase
	!org 0

; ===========================================================================
; ---------------------------------------------------------------------------
; V-Int routines
offset :=	Vint_SwitchTbl
ptrsize :=	1
idstart :=	0

VintID_Lag =	id(Vint_Lag_ptr)	; 0
VintID_SEGA =	id(Vint_SEGA_ptr)	; 2
VintID_Title =	id(Vint_Title_ptr)	; 4
VintID_Unused6 =	id(Vint_Unused6_ptr)	; 6
VintID_Level =	id(Vint_Level_ptr)	; 8
VintID_S1SS =	id(Vint_S1SS_ptr)	; $A
VintID_TitleCard =	id(Vint_TitleCard_ptr)	; $C
VintID_UnusedE =	id(Vint_UnusedE_ptr)	; $E
VintID_Pause =	id(Vint_Pause_ptr)	; $10
VintID_Fade =	id(Vint_Fade_ptr)	; $12
VintID_PCM =	id(Vint_PCM_ptr)	; $14
VintID_SSResults =	id(Vint_SSResults_ptr)	; $16
VintID_TitleCard2 =	id(Vint_TitleCard2_ptr)	; $18

; Game modes
offset :=	GameModeArray
ptrsize :=	1
idstart :=	0
GameModeID_SegaScreen =		id(GameMode_SegaScreen)	; 0
GameModeID_TitleScreen =	id(GameMode_TitleScreen) ; 4
GameModeID_Demo =		id(GameMode_Demo)	; 8
GameModeID_Level =		id(GameMode_Level)	; $C
GameModeID_SpecialStage =	id(GameMode_SpecialStage) ; $10
GameModeID_ContinueScreen:	equ $14			; $14 ; referenced despite it not existing
GameModeID_S1Ending:		equ $18			; $18 ; referenced despite it not existing
GameModeID_S1Credits:		equ $1C			; $1C ; referenced despite it not existing
GameModeID_S1End: 			equ	GameModeID_S1Credits	; $1C ; referenced despite it not existing
GameModeID_End: 			equ	GameModeID_SpecialStage	; $10
GameModeFlag_TitleCard:		equ 7			; flag bit
GameModeID_TitleCard:		equ 1<<GameModeFlag_TitleCard ; $80 ; flag mask

; ---------------------------------------------------------------------------
	include "s1.sounddriver.ram.asm"

; Main RAM
	phase	($FE0000)
RAM_debug_start:	ds.b	$8000

RAM_debug_demo_record:	ds.w	$2000

RAM_debug_demo_record_2P:	ds.w	$2000

RAM_debug_end:
	dephase

	phase	ramaddr($FFFF0000)
v_ram_start:
RAM_Start:

Chunk_Table:		ds.w	64*$100			; 128x128 tile mappings ($8000 bytes)
Chunk_Table_End:

v_128x128	=	Chunk_Table
v_128x128_end	=	Chunk_Table_End

Level_Layout:		ds.b	$1000			; level layout buffer ($1000 bytes)
Level_Layout_End:

v_lvllayout	=	Level_Layout
v_lvllayout_end	=	Level_Layout_End
v_lvllayoutbg	=	Level_Layout+$80

Block_Table:		ds.w	4*$300			; 16x16 tile mappings ($1800 bytes)
Block_Table_End:

v_16x16	=	Block_Table
v_16x16_end	=	Block_Table_End

TempArray_LayerDef:	ds.b	$200			; background scroll buffer
Decomp_Buffer:		ds.b	$200			; Nemesis graphics decompression buffer
Decomp_Buffer_End:

v_bgscroll_buffer	=	TempArray_LayerDef
v_ngfx_buffer	=	Decomp_Buffer
v_ngfx_buffer_end	=	Decomp_Buffer_End

Object_Display_Lists:	ds.b	$400			; sprite display queue, in order of priority
Object_Display_Lists_End:

v_spritequeue	=	Object_Display_Lists
v_spritequeue_end	=	Object_Display_Lists_End

v_objspace:		ds.b	object_size*$80		; object variable space ($40 bytes per object)
v_objspace_end:

; 2P mode reserves 6 'blocks' of 12 RAM slots at the end.
Dynamic_Object_RAM_2P_End = v_objspace_end - ($C * 6) * object_size

; Title screen objects
v_titlesonic	= v_objspace+object_size*1		; object variable space for Sonic in the title screen ($40 bytes)
v_titletails	= v_objspace+object_size*2		; object variable space for the "SONIC TEAM PRESENTS" text ($40 bytes)
v_pressstart	= v_objspace+object_size*2		; object variable space for the "PRESS START BUTTON" text ($40 bytes)
v_titletm	= v_objspace+object_size*3		; object variable space for the trademark symbol ($40 bytes)
v_ttlsonichide	= v_objspace+object_size*4		; object variable space for hiding part of Sonic ($40 bytes)

; Level objects
v_player	= v_objspace+object_size*0		; object variable space for Sonic ($40 bytes)
v_player2	= v_objspace+object_size*1		; object variable space for Tails ($40 bytes)
v_player2tails	= v_objspace+object_size*7		; object variable space for Tails' Tails ($40 bytes)
v_hud		= v_objspace+object_size*14		; object variable space for the HUD ($40 bytes)

v_titlecard	= v_objspace+object_size*2		; object variable space for the title card ($100 bytes)
v_ttlcardname	= v_titlecard+object_size*0		; object variable space for the title card zone name text ($40 bytes)
v_ttlcardzone	= v_titlecard+object_size*1		; object variable space for the title card "ZONE" text ($40 bytes)
v_ttlcardact	= v_titlecard+object_size*2		; object variable space for the title card act text ($40 bytes)
v_ttlcardoval	= v_titlecard+object_size*3		; object variable space for the title card oval ($40 bytes)

v_gameovertext1	= v_objspace+object_size*2		; object variable space for the "GAME"/"TIME" in "GAME OVER"/"TIME OVER" text ($40 bytes)
v_gameovertext2	= v_objspace+object_size*3		; object variable space for the "OVER" in "GAME OVER"/"TIME OVER" text ($40 bytes)

v_shieldobj	= v_objspace+object_size*6		; object variable space for the shield ($40 bytes)
v_starsobj1	= v_objspace+object_size*8		; object variable space for the invincibility stars #1 ($40 bytes)
v_starsobj2	= v_objspace+object_size*9		; object variable space for the invincibility stars #2 ($40 bytes)
v_starsobj3	= v_objspace+object_size*10		; object variable space for the invincibility stars #3 ($40 bytes)
v_starsobj4	= v_objspace+object_size*11		; object variable space for the invincibility stars #4 ($40 bytes)

v_splash	= v_objspace+object_size*12		; object variable space for the water splash ($40 bytes)
v_sonicbubbles	= v_objspace+object_size*13		; object variable space for the bubbles that come out of Sonic's mouth/drown countdown ($40 bytes)
v_watersurface1	= v_objspace+object_size*30		; object variable space for the water surface #1 ($40 bytes)
v_watersurface2	= v_objspace+object_size*31		; object variable space for the water surface #1 ($40 bytes)

v_endcard	= v_objspace+object_size*23		; object variable space for the level results card ($1C0 bytes)
v_endcardsonic	= v_endcard+object_size*0		; object variable space for the level results card "SONIC HAS" text ($40 bytes)
v_endcardpassed	= v_endcard+object_size*1		; object variable space for the level results card "PASSED" text ($40 bytes)
v_endcardact	= v_endcard+object_size*2		; object variable space for the level results card act text ($40 bytes)
v_endcardscore	= v_endcard+object_size*3		; object variable space for the level results card score tally ($40 bytes)
v_endcardtime	= v_endcard+object_size*4		; object variable space for the level results card time bonus tally ($40 bytes)
v_endcardring	= v_endcard+object_size*5		; object variable space for the level results card ring bonus tally ($40 bytes)
v_endcardoval	= v_endcard+object_size*6		; object variable space for the level results card oval ($40 bytes)

v_lvlobjspace	= v_objspace+object_size*32		; level object variable space ($1800 bytes)
v_lvlobjend	= v_lvlobjspace+object_size*96
v_objend	= v_lvlobjend

; Special Stage objects
v_ssrescard	= v_objspace+object_size*23		; object variable space for the Special Stage results card ($140 bytes)
v_ssrestext	= v_ssrescard+object_size*0		; object variable space for the Special Stage results card text ($40 bytes)
v_ssresscore	= v_ssrescard+object_size*1		; object variable space for the Special Stage results card score tally ($40 bytes)
v_ssresring	= v_ssrescard+object_size*2		; object variable space for the Special Stage results card ring bonus tally ($40 bytes)
v_ssresoval	= v_ssrescard+object_size*3		; object variable space for the Special Stage results card oval ($40 bytes)
v_ssrescontinue	= v_ssrescard+object_size*4		; object variable space for the Special Stage results card continue icon ($40 bytes)
v_ssresemeralds	= v_objspace+object_size*32		; object variable space for the emeralds in the Special Stage results ($180 bytes)

; Continue screen objects
v_continuetext	= v_objspace+object_size*1		; object variable space for the continue screen text ($40 bytes)
v_continuelight	= v_objspace+object_size*2		; object variable space for the continue screen light spot ($40 bytes)
v_continueicon	= v_objspace+object_size*3		; object variable space for the continue screen icon ($40 bytes)

; Ending objects
v_endemeralds	= v_objspace+object_size*16		; object variable space for the emeralds in the ending ($180 bytes)
v_endemeralds_end	= v_objspace+object_size*32
v_endlogo	= v_objspace+object_size*16		; object variable space for the logo in the ending ($40 bytes)

; Credits objects
v_credits	= v_objspace+object_size*2		; object variable space for the credits text ($40 bytes)
v_endeggman	= v_objspace+object_size*2		; object variable space for Eggman after the credits ($40 bytes)
v_tryagain	= v_objspace+object_size*3		; object variable space for the "TRY AGAIN" text ($40 bytes)
v_eggmanchaos	= v_objspace+object_size*32		; object variable space for the emeralds juggled by Eggman ($180 bytes)

Primary_Collision:	ds.b	$600
Primary_Collision_End:

v_colladdr1	=		Primary_Collision
v_colladdr1_end	=	Primary_Collision_End

Secondary_Collision:	ds.b	$600
Secondary_Collision_End:

v_colladdr2	=		Secondary_Collision
v_colladdr2_end	=	Secondary_Collision_End

VDP_Command_Buffer:	ds.w	7*$12			; stores 18 ($12) VDP commands to issue the next time ProcessDMAQueue is called
VDP_Command_Buffer_Slot:	ds.l	1		; stores the address of the next open slot for a queued VDP command

Sprite_Table_2P:	ds.b	$280			; 2 player sprite table
Sprite_Table_2P_end:
			ds.b	$80			; unused

v_hscrolltablebuffer:	ds.b	$380			; scrolling table data
v_hscrolltablebuffer_end:
			ds.b	$80			; would be unused, but data from v_hscrolltablebuffer can spill into here
v_hscrolltablebuffer_end_padded:

Sonic_Stat_Record_Buf:	ds.b	$100
Sonic_Pos_Record_Buf:	ds.b	$100
Tails_Pos_Record_Buf:	ds.b	$100
Tails_Pos_Record_Buf_Dup:	ds.b	$100

Ring_Positions:		ds.b	$600
Ring_Positions_End:

Camera_RAM:

Camera_Positions:
Camera_X_pos:		ds.l	1
Camera_Y_pos:		ds.l	1
Camera_BG_X_pos:	ds.l	1			; only used sometimes as the layer deformation makes it sort of redundant
Camera_BG_Y_pos:	ds.l	1
Camera_BG2_X_pos:	ds.l	1			; used in CPZ
Camera_BG2_Y_pos:	ds.l	1			; used in CPZ
Camera_BG3_X_pos:	ds.l	1			; unused (only initialised at beginning of level)?
Camera_BG3_Y_pos:	ds.l	1			; unused (only initialised at beginning of level)?
Camera_Positions_End:

v_screenposx	=	Camera_X_pos
v_screenposy	=	Camera_Y_pos
v_bgscreenposx	=	Camera_BG_X_pos
v_bgscreenposy	=	Camera_BG_Y_pos
v_bg2screenposx	=	Camera_BG2_X_pos
v_bg2screenposy	=	Camera_BG2_Y_pos
v_bg3screenposx	=	Camera_BG3_X_pos
v_bg3screenposy	=	Camera_BG3_Y_pos

Camera_Positions_P2:
Camera_X_pos_P2:	ds.l	1
Camera_Y_pos_P2:	ds.l	1
Camera_BG_X_pos_P2:	ds.l	1			; only used sometimes as the layer deformation makes it sort of redundant
Camera_BG_Y_pos_P2:	ds.l	1
Camera_BG2_X_pos_P2:	ds.l	1			; unused (only initialised at beginning of level)?
Camera_BG2_Y_pos_P2:	ds.l	1
Camera_BG3_X_pos_P2:	ds.l	1			; unused (only initialised at beginning of level)?
Camera_BG3_Y_pos_P2:	ds.l	1
Camera_Positions_P2_End:

Block_Crossed_Flags:
Horiz_block_crossed_flag:	ds.b	1		; toggles between 0 and $10 when you cross a block boundary horizontally
Verti_block_crossed_flag:	ds.b	1		; toggles between 0 and $10 when you cross a block boundary vertically
Horiz_block_crossed_flag_BG:	ds.b	1		; toggles between 0 and $10 when background camera crosses a block boundary horizontally
Verti_block_crossed_flag_BG:	ds.b	1		; toggles between 0 and $10 when background camera crosses a block boundary vertically
Horiz_block_crossed_flag_BG2:	ds.b	1		; used in CPZ
			ds.b	1			; $FFFFEE45 ; seems unused
Horiz_block_crossed_flag_BG3:	ds.b	1
			ds.b	1			; $FFFFEE47 ; seems unused
Block_Crossed_Flags_End:

Block_Crossed_Flags_P2:
Horiz_block_crossed_flag_P2:	ds.b	1		; toggles between 0 and $10 when you cross a block boundary horizontally
Verti_block_crossed_flag_P2:	ds.b	1		; toggles between 0 and $10 when you cross a block boundary vertically
			ds.b	6			; $FFFFEE4A-$FFFFEE4F ; seems unused
Block_Crossed_Flags_P2_End:

Scroll_Flags_All:
Scroll_flags:		ds.w	1			; bitfield ; bit 0 = redraw top row, bit 1 = redraw bottom row, bit 2 = redraw left-most column, bit 3 = redraw right-most column
Scroll_flags_BG:	ds.w	1			; bitfield ; bits 0-3 as above, bit 4 = redraw top row (except leftmost block), bit 5 = redraw bottom row (except leftmost block), bits 6-7 = as bits 0-1
Scroll_flags_BG2:	ds.w	1			; bitfield ; essentially unused; bit 0 = redraw left-most column, bit 1 = redraw right-most column
Scroll_flags_BG3:	ds.w	1			; bitfield ; for CPZ; bits 0-3 as Scroll_flags_BG but using Y-dependent BG camera; bits 4-5 = bits 2-3; bits 6-7 = bits 2-3
Scroll_Flags_All_End:

Scroll_Flags_All_P2:
Scroll_flags_P2:	ds.w	1			; bitfield ; bit 0 = redraw top row, bit 1 = redraw bottom row, bit 2 = redraw left-most column, bit 3 = redraw right-most column
Scroll_flags_BG_P2:	ds.w	1			; bitfield ; bits 0-3 as above, bit 4 = redraw top row (except leftmost block), bit 5 = redraw bottom row (except leftmost block), bits 6-7 = as bits 0-1
Scroll_flags_BG2_P2:	ds.w	1			; bitfield ; essentially unused; bit 0 = redraw left-most column, bit 1 = redraw right-most column
Scroll_flags_BG3_P2:	ds.w	1			; bitfield ; for CPZ; bits 0-3 as Scroll_flags_BG but using Y-dependent BG camera; bits 4-5 = bits 2-3; bits 6-7 = bits 2-3
Scroll_Flags_All_P2_End:

Camera_Positions_Copy:
Camera_RAM_copy:	ds.l	2			; copied over every V-int
Camera_BG_copy:		ds.l	2			; copied over every V-int
Camera_BG2_copy:	ds.l	2			; copied over every V-int
Camera_BG3_copy:	ds.l	2			; copied over every V-int
Camera_Positions_Copy_End:

Camera_Positions_Copy_P2:
Camera_P2_copy:		ds.l	8			; copied over every V-int
Camera_Positions_Copy_P2_End:

Scroll_Flags_Copy_All:
Scroll_flags_copy:	ds.w	1			; copied over every V-int
Scroll_flags_BG_copy:	ds.w	1			; copied over every V-int
Scroll_flags_BG2_copy:	ds.w	1			; copied over every V-int
Scroll_flags_BG3_copy:	ds.w	1			; copied over every V-int
Scroll_Flags_Copy_All_End:

Scroll_Flags_Copy_All_P2:
Scroll_flags_copy_P2:	ds.w	1			; copied over every V-int
Scroll_flags_BG_copy_P2:	ds.w	1		; copied over every V-int
Scroll_flags_BG2_copy_P2:	ds.w	1		; copied over every V-int
Scroll_flags_BG3_copy_P2:	ds.w	1		; copied over every V-int
Scroll_Flags_Copy_All_P2_End:

Camera_Difference:
Camera_X_pos_diff:	ds.w	1			; (new X pos - old X pos) * 256
Camera_Y_pos_diff:	ds.w	1			; (new Y pos - old Y pos) * 256
Camera_Difference_End:

Camera_BG_X_pos_diff:	ds.w	1			; Effective camera change used in WFZ ending and HTZ screen shake
Camera_BG_Y_pos_diff:	ds.w	1			; Effective camera change used in WFZ ending and HTZ screen shake

Camera_Difference_P2:
Camera_X_pos_diff_P2:	ds.w	1			; (new X pos - old X pos) * 256
Camera_Y_pos_diff_P2:	ds.w	1			; (new Y pos - old Y pos) * 256
Camera_Difference_P2_End:
			ds.b	4			; $FFFFEEBC-$FFFFEEBF ; seems unused

Camera_Min_X_pos_target:	ds.w	1		; unused, except on write in LevelSizeLoad...
Camera_Max_X_pos_target:	ds.w	1		; unused
Camera_Min_Y_pos_target:	ds.w	1		; same as above. The write being a long also overwrites the address below
Camera_Max_Y_pos_target:	ds.w	1

Camera_Boundaries:
Camera_Min_X_pos:	ds.w	1
Camera_Max_X_pos:	ds.w	1
Camera_Min_Y_pos:	ds.w	1
Camera_Max_Y_pos:	ds.w	1
Camera_Boundaries_End:

v_limitleft2	=		Camera_Min_X_pos
v_limitright2	=		Camera_Max_X_pos
v_limittop2	=		Camera_Min_Y_pos
v_limitbtm2	=		Camera_Max_Y_pos

Camera_Delay:
Horiz_scroll_delay_val:	ds.w	1			; if its value is a, where a != 0, X scrolling will be based on the player's X position a-1 frames ago
Sonic_Pos_Record_Index:	ds.w	1			; into Sonic_Pos_Record_Buf and Sonic_Stat_Record_Buf
Camera_Delay_End:

Camera_Delay_P2:
Horiz_scroll_delay_val_P2:	ds.w	1
Tails_Pos_Record_Index:	ds.w	1			; into Tails_Pos_Record_Buf
Camera_Delay_P2_End:

Camera_Y_pos_bias:	ds.w	1			; added to y position for lookup/lookdown, $60 is center
Camera_Y_pos_bias_End:

Camera_Y_pos_bias_P2:	ds.w	1			; for Tails
Camera_Y_pos_bias_P2_End:

Deform_lock:		ds.b	1			; set to 1 to stop all deformation
			ds.b	1			; $FFFFEEDD ; seems unused
Camera_Max_Y_Pos_Changing:	ds.b	1
Dynamic_Resize_Routine:	ds.b	1
RecordPos_Unused:	ds.w	1			; $FFFFEEE0-$FFFFEEE1
Camera_BG_X_offset:	ds.w	1			; Used to control background scrolling in X in WFZ ending and HTZ screen shake
Camera_BG_Y_offset:	ds.w	1			; Used to control background scrolling in Y in WFZ ending and HTZ screen shake
HTZ_Terrain_Delay:	ds.w	1			; During HTZ screen shake, this is a delay between rising and sinking terrain during which there is no shaking
HTZ_Terrain_Direction:	ds.b	1			; During HTZ screen shake, 0 if terrain/lava is rising, 1 if lowering
			ds.b	3			; $FFFFEEE9-$FFFFEEEB ; seems unused
Vscroll_Factor_P2_HInt:	ds.l	1
Camera_X_pos_copy:	ds.l	1
Camera_Y_pos_copy:	ds.l	1

Camera_Boundaries_P2:
Tails_Min_X_pos:	ds.w	1
Tails_Max_X_pos:	ds.w	1
Tails_Min_Y_pos:	ds.w	1			; seems not actually implemented (only written to)
Tails_Max_Y_pos:	ds.w	1
Camera_Boundaries_P2_End:

Camera_RAM_End:

Block_cache:		ds.w	512/16*2		; Width of plane in blocks, with each block getting two words.
			ds.b	$80			; unused

v_snddriver_ram:	SMPS_RAM			; sound driver state
			ds.b	$40			; unused
v_gamemode:		ds.b	1			; game mode (00=Sega; 04=Title; 08=Demo; 0C=Level; 10=SS; 14=Cont; 18=End; 1C=Credit; +8C=PreLevel)
			ds.b	1			; unused
v_jpadhold2:		ds.b	1			; joypad input - held, duplicate
v_jpadpress2:		ds.b	1			; joypad input - pressed, duplicate
v_jpadhold1:		ds.b	1			; joypad input - held
v_jpadpress1:		ds.b	1			; joypad input - pressed
v_2Pjpadhold:		ds.b	1			; joypad input - held
v_2Pjpadpress:		ds.b	1			; joypad input - pressed
			ds.b	4			; unused
v_vdp_buffer1:		ds.w	1			; VDP instruction buffer
			ds.b	6			; unused
v_generictimer:		ds.w	1			; the length of a demo in frames
v_scrposy_vdp:		ds.w	1			; screen position y (VDP)
v_bgscrposy_vdp:	ds.w	1			; background screen position y (VDP)
v_scrposx_vdp:		ds.w	1			; screen position x (VDP)
v_bgscrposx_vdp:	ds.w	1			; background screen position x (VDP)
v_bg3scrposy_vdp:	ds.w	1
v_bg3scrposx_vdp:	ds.w	1
			ds.b	2			; unused
v_hbla_hreg:		ds.w	1			; VDP H.interrupt register buffer (8Axx)
v_hbla_line 		= v_hbla_hreg+1			; screen line where water starts and palette is changed by HBlank
v_pfade_start:		ds.b	1			; palette fading - start position in bytes
v_pfade_size:		ds.b	1			; palette fading - number of colours

v_misc_variables:
v_vbla_0e_counter:	ds.b	1			; tracks how many times vertical interrupts routine 0E occured (pretty much unused because routine 0E is unused)
			ds.b	1			; unused
v_vbla_routine:		ds.b	1			; VBlank - routine counter
			ds.b	1			; unused
v_spritecount:		ds.b	1			; number of sprites on-screen
			ds.b	5			; unused
v_pcyc_num:		ds.w	1			; palette cycling - current reference number
v_pcyc_time:		ds.w	1			; palette cycling - time until the next change
v_random:		ds.l	1			; pseudo random number buffer
f_pause:		ds.w	1			; flag set to pause the game
			ds.b	4			; unused
v_vdp_buffer2:		ds.w	1			; VDP instruction buffer
			ds.b	2			; unused
f_hbla_pal:		ds.w	1			; flag set to change palette during HBlank (0000 = no; 0001 = change)
v_waterpos1:		ds.w	1			; water height, actual
v_waterpos2:		ds.w	1			; water height, ignoring sway
v_waterpos3:		ds.w	1			; water height, next target
f_water:		ds.b	1			; flag set for water
v_wtr_routine:		ds.b	1			; water event - routine counter
f_wtr_state:		ds.b	1			; water palette state when water is above/below the screen (00 = partly/all dry; 01 = all underwater)
f_doupdatesinhblank:	ds.b	1			; defers performing various tasks to the Horizontal Interrupt (H-Blank)
v_pal_buffer:		ds.b	$30			; palette data buffer (used for palette cycling)
v_misc_variables_end:

v_plc_buffer:		ds.b	6*16			; pattern load cues buffer (maximum $10 PLCs)
v_plc_buffer_only_end:
v_plc_ptrnemcode:	ds.l	1			; pointer for nemesis decompression code ($1502 or $150C)
v_plc_repeatcount:	ds.l	1
v_plc_paletteindex:	ds.l	1
v_plc_previousrow:	ds.l	1
v_plc_dataword:		ds.l	1
v_plc_shiftvalue:	ds.l	1
v_plc_patternsleft:	ds.w	1
v_plc_framepatternsleft:ds.w	1
			ds.b	4			; unused
v_plc_buffer_end:

v_levelvariables:					; variables that are reset between levels
Tails_unused1:		ds.w	1			; set to 0 in Tails_Control, otherwise unused
Tails_control_counter:	ds.w	1
Tails_respawn_counter:	ds.w	1
Tails_unused_counter:	ds.w	1		; apart of an unused routine for Tails's CPU.
Tails_CPU_routine:	ds.w	1
			ds.b	6			; unused

Rings_manager_routine:	ds.b	1
Level_started_flag:	ds.b	1
Ring_start_addr:	ds.w	1
Ring_end_addr:		ds.w	1
Ring_start_addr_P2:	ds.w	1
Ring_end_addr_P2:	ds.w	1
			ds.b	6			; unused

Screen_redraw_flag:		ds.b	1
CPZ_UnkScroll_Timer:	ds.b	1
			ds.b	$E			; unused

Water_flag:		ds.b	1
			ds.b	$F			; unused

Demo_button_index_2P:	ds.w	1			; index into button press demo data, for player 2
Demo_press_counter_2P:	ds.w	1			; frames remaining until next button press, for player 2
			ds.b	$1C			; unused

Sonic_top_speed:	ds.w	1
Sonic_acceleration:	ds.w	1
Sonic_deceleration:	ds.w	1
Sonic_LastLoadedDPLC:	ds.b	1
			ds.b	1			; $FFFFF767 ; seems unused
Primary_Angle:		ds.b	1
			ds.b	1			; $FFFFF769 ; seems unused
Secondary_Angle:	ds.b	1
			ds.b	1			; $FFFFF76B ; seems unused

Obj_placement_routine:	ds.b	1
			ds.b	1			; $FFFFF76D ; seems unused
Camera_X_pos_last:	ds.w	1			; Camera_X_pos_coarse from the previous frame
Camera_X_pos_last_End:

Object_Manager_Addresses:
Obj_load_addr_right:	ds.l	1			; contains the address of the next object to load when moving right
Obj_load_addr_left:	ds.l	1			; contains the address of the last object loaded when moving left
Object_Manager_Addresses_End:

Object_Manager_Addresses_P2:
Obj_load_addr_right_P2:	ds.l	1
Obj_load_addr_left_P2:	ds.l	1
Object_Manager_Addresses_P2_End:

Object_manager_2P_RAM:					; The next 16 bytes belong to this.
Object_RAM_block_indices:	ds.b	6		; seems to be an array of horizontal chunk positions, used for object position range checks
Player_1_loaded_object_blocks:	ds.b	3
Player_2_loaded_object_blocks:	ds.b	3

Camera_X_pos_last_P2:	ds.w	1
Camera_X_pos_last_P2_End:

Obj_respawn_index_P2:	ds.b	2			; respawn table indices of the next objects when moving left or right for the second player
Obj_respawn_index_P2_End:
Object_manager_2P_RAM_End:

Demo_button_index:	ds.w	1			; index into button press demo data, for player 1
Demo_press_counter:	ds.b	1			; frames remaining until next button press, for player 1
			ds.b	1			; $FFFFF793 ; seems unused
PalChangeSpeed:		ds.w	1
Collision_addr:		ds.l	1
v_collindex	=	Collision_addr
v_palss_num:		ds.w	1			; palette cycling in Special Stage - reference number
v_palss_time:		ds.w	1			; palette cycling in Special Stage - time until next change
v_palss_index:		ds.w	1			; palette cycling in Special Stage - index into palette cycle 2 (unused?)
v_ssbganim:		ds.w	1			; Special Stage background animation
			ds.b	5			; seems unused
Boss_defeated_flag:
v_bossstatus:		ds.b	1
			ds.b	2			; seems unused

f_lockscreen:		ds.b	1
			ds.b	$13			; unused

v_gfxbigring:		ds.w	1			; settings for giant ring graphics loading
			ds.b	7			; unused

f_wtunnelmode:		ds.b	1			; LZ water tunnel mode
f_playerctrl:		ds.b	1			; Player control override flags (object ineraction, control enable)
f_wtunnelallow:		ds.b	1			; LZ water tunnels (00 = enabled; 01 = disabled)
f_slidemode:		ds.b	1			; LZ water slide mode
			ds.b	1			; unused

f_lockctrl:		ds.b	1
f_bigring:		ds.b	1			; flag set when Sonic collects the giant ring
			ds.b	2			; unused

v_itembonus:		ds.w	1			; item bonus from broken enemies, blocks etc.
v_timebonus:		ds.w	1			; time bonus at the end of an act
v_ringbonus:		ds.w	1			; ring bonus at the end of an act
f_endactbonus:		ds.b	1			; time/ring bonus update flag at the end of an act
			ds.b	1			; unused
v_lz_deform:		ds.w	1			; LZ deformation offset, in units of $80

Camera_X_pos_coarse:	ds.w	1			; (Camera_X_pos - 128) / 256
Camera_X_pos_coarse_End:

Camera_X_pos_coarse_P2:	ds.w	1
Camera_X_pos_coarse_P2_End:

Tails_LastLoadedDPLC:	ds.b	1
TailsTails_LastLoadedDPLC:	ds.b	1

f_switch:		ds.b	$10			; flags set when Sonic stands on a switch

Anim_Counters:		ds.b	$10

v_levelvariables_end:

Sprite_Table:		ds.b	$280			; Sprite attribute table buffer
Sprite_Table_end:

v_palette_water_fading = Sprite_Table_end-palette_size	; duplicate underwater palette, used for transitions ($80 bytes)

v_palette_water:	; main underwater palette
v_palette_water_line_1:	ds.b $20
v_palette_water_line_2:	ds.b $20
v_palette_water_line_3:	ds.b $20
v_palette_water_line_4:	ds.b $20
v_palette_water_end:

v_palette:		; main palette
v_palette_line_1:	ds.b $20
v_palette_line_2:	ds.b $20
v_palette_line_3:	ds.b $20
v_palette_line_4:	ds.b $20
v_palette_end:

v_palette_fading:	; duplicate palette, used for transitions
v_palette_fading_line_1:ds.b $20
v_palette_fading_line_2:ds.b $20
v_palette_fading_line_3:ds.b $20
v_palette_fading_line_4:ds.b $20
v_palette_fading_end:

v_objstate:		ds.b	$C0			; object state list
v_objstate_end:
			ds.b	$140			; stack
v_systemstack:
v_crossresetram:					; RAM beyond this point is only cleared on a cold-boot
			ds.b	2			; unused
Level_Inactive_flag:	ds.w	1			; (2 bytes)
Timer_frames:		ds.w	1			; (2 bytes)
Debug_object:		ds.w	1			; (2 bytes)
Debug_placement_mode:	ds.w	1			; (2 bytes)
Debug_Accel_Timer:	ds.b	1			; (1 byte)
Debug_Speed:		ds.b	1			; (1 byte)

Vint_runcount:		ds.l	1			; (4 bytes)

Current_ZoneAndAct	= Current_Zone
Current_Zone:
v_zone:			ds.b	1			; (1 byte)
Current_Act:
v_act:			ds.b	1			; (1 byte)
v_lives:		ds.b	1			; (1 byte)
			ds.b	1			; unused
v_air:			ds.w	1			; air remaining while underwater
v_airbyte = v_air+1					; low byte for air
v_lastspecial:		ds.b	1			; last special stage number
			ds.b	1			; unused
v_continues:		ds.b	1			; number of continues
			ds.b	1			; unused
f_timeover:		ds.b	1			; time over flag
v_lifecount:		ds.b	1			; lives counter value (for actual number, see "v_lives")
f_lifecount:		ds.b	1			; lives counter update flag
f_ringcount:		ds.b	1			; ring counter update flag
f_timecount:		ds.b	1			; time counter update flag
f_scorecount:		ds.b	1			; score counter update flag
v_rings:		ds.w	1			; rings
v_ringbyte = v_rings+1					; low byte for rings
v_time:			ds.l	1			; time
v_timemin = v_time+1					; time - minutes
v_timesec = v_time+2					; time - seconds
v_timecent = v_time+3					; time - centiseconds
v_score:		ds.l	1			; score
			ds.b	2			; unused
v_shield:		ds.b	1			; shield status (00 = no; 01 = yes)
v_invinc:		ds.b	1			; invinciblity status (00 = no; 01 = yes)
v_shoes:		ds.b	1			; speed shoes status (00 = no; 01 = yes)
v_unused1:		ds.b	1			; an unused fourth player status (Goggles?)

v_lastlamp:		ds.b	2			; number of the last lamppost you hit
v_lamp_xpos:		ds.w	1			; x-axis for Sonic to respawn at lamppost
v_lamp_ypos:		ds.w	1			; y-axis for Sonic to respawn at lamppost
v_lamp_rings:		ds.w	1			; rings stored at lamppost
v_lamp_time:		ds.l	1			; time stored at lamppost
v_lamp_dle:		ds.b	1			; dynamic level event routine counter at lamppost
			ds.b	1			; unused
v_lamp_limitbtm:	ds.w	1			; level bottom boundary at lamppost
v_lamp_scrx:		ds.w	1			; x-axis screen at lamppost
v_lamp_scry:		ds.w	1			; y-axis screen at lamppost
v_lamp_bgscrx:		ds.w	1			; x-axis BG screen at lamppost
v_lamp_bgscry:		ds.w	1			; y-axis BG screen at lamppost
v_lamp_bg2scrx:		ds.w	1			; x-axis BG2 screen at lamppost
v_lamp_bg2scry:		ds.w	1			; y-axis BG2 screen at lamppost
v_lamp_bg3scrx:		ds.w	1			; x-axis BG3 screen at lamppost
v_lamp_bg3scry:		ds.w	1			; y-axis BG3 screen at lamppost
v_lamp_wtrpos:		ds.w	1			; water position at lamppost
v_lamp_wtrrout:		ds.b	1			; water routine at lamppost
v_lamp_wtrstat:		ds.b	1			; water state at lamppost
v_lamp_lives:		ds.b	1			; lives counter at lamppost
			ds.b	2			; unused
v_emeralds:		ds.b	1			; number of chaos emeralds
v_emldlist:		ds.b	6			; which individual emeralds you have (00 = no; 01 = yes)
v_oscillate:		ds.w	1			; oscillation bitfield
v_timingandscreenvariables:
v_timingvariables:
			ds.b	$40			; values which oscillate - for swinging platforms, et al
			ds.b	$20			; unused
v_ani0_time:		ds.b	1			; synchronised sprite animation 0 - time until next frame (used for synchronised animations)
v_ani0_frame:		ds.b	1			; synchronised sprite animation 0 - current frame
v_ani1_time:		ds.b	1			; synchronised sprite animation 1 - time until next frame
v_ani1_frame:		ds.b	1			; synchronised sprite animation 1 - current frame
v_ani2_time:		ds.b	1			; synchronised sprite animation 2 - time until next frame
v_ani2_frame:		ds.b	1			; synchronised sprite animation 2 - current frame
v_ani3_time:		ds.b	1			; synchronised sprite animation 3 - time until next frame
v_ani3_frame:		ds.b	1			; synchronised sprite animation 3 - current frame
v_ani3_buf:		ds.w	1			; synchronised sprite animation 3 - info buffer
			ds.b	$26			; unused
v_limittopdb:		ds.w	1			; level upper boundary, buffered for debug mode
v_limitbtmdb:		ds.w	1			; level bottom boundary, buffered for debug mode
			ds.b	$8C			; unused
v_timingvariables_end:

v_levseldelay:		ds.w	1			; level select - time until change when up/down is held
v_levselitem:		ds.w	1			; level select - item selected
v_levselsound:		ds.w	1			; level select - sound selected
			ds.b	$3A			; unused

v_scorelife:		ds.l	1			; points required for an extra life (JP1 only)
			ds.b	$1C			; unused

f_levselcheat:		ds.b	1			; level select cheat flag
f_slomocheat:		ds.b	1			; slow motion & frame advance cheat flag
f_debugcheat:		ds.b	1			; debug mode cheat flag
f_creditscheat:		ds.b	1			; hidden credits & press start cheat flag
v_title_dcount:		ds.w	1			; number of times the d-pad is pressed on title screen
v_title_ccount:		ds.w	1			; number of times C is pressed on title screen
Two_player_mode:	ds.w	1
Two_player_mode_lo	= Two_player_mode+1
word_FFEA:		ds.w	1
v_objstate_debug:	ds.w	1			; a copy of v_objstate, earlier code suggests it was used for debug mode
Obj_respawn_index_P2_debug:	ds.w	1	; a copy of Obj_respawn_index_P2, earlier code suggests it was used for debug mode

f_demo:			ds.w	1			; demo mode flag (0 = no; 1 = yes; $8001 = ending)
v_demonum:		ds.w	1			; demo level number (not the same as the level number)
v_creditsnum:		ds.w	1			; credits index number
			ds.b	2			; unused
v_megadrive:		ds.b	1			; Megadrive machine type
			ds.b	1			; unused
Debug_mode_flag:	ds.w	1
v_init:			ds.l	1			; 'init' text string
v_ram_end:
    if * > 0	; Don't declare more space than the RAM can contain!
	fatal "The RAM variable declarations are too large by $\{*} bytes."
    endif
	dephase

; Special stage
v_ssangle		= ramaddr($FFFFF780)
v_ssrotate		= ramaddr($FFFFF782)
v_ssbuffer1		= v_ram_start
v_ssblockbuffer		= v_ssbuffer1+$1020		; ($2000 bytes)
v_ssblockbuffer_end	= v_ssblockbuffer+$80*$40
v_ssbuffer2		= v_ram_start+$4000
v_ssblocktypes		= v_ssbuffer2
v_ssitembuffer		= v_ssbuffer2+$400		; ($100 bytes)
v_ssitembuffer_end	= v_ssitembuffer+$100
v_ssbuffer3		= v_ram_start+$8000
v_ssscroll_buffer	= v_ngfx_buffer+$100

; Error handler
	phase v_objstate
v_regbuffer:		ds.b	$40			; stores registers d0-a7 during an error event
v_spbuffer:		ds.l	1			; stores most recent sp address
v_errortype:		ds.b	1			; error type
	dephase
	!org 0
; ---------------------------------------------------------------------------
; I/O Area
HW_Version:			equ $A10001
HW_Port_1_Data:			equ $A10003
HW_Port_2_Data:			equ $A10005
HW_Expansion_Data:		equ $A10007
HW_Port_1_Control:		equ $A10009
HW_Port_2_Control:		equ $A1000B
HW_Expansion_Control:		equ $A1000D
HW_Port_1_TxData:		equ $A1000F
HW_Port_1_RxData:		equ $A10011
HW_Port_1_SCtrl:		equ $A10013
HW_Port_2_TxData:		equ $A10015
HW_Port_2_RxData:		equ $A10017
HW_Port_2_SCtrl:		equ $A10019
HW_Expansion_TxData:		equ $A1001B
HW_Expansion_RxData:		equ $A1001D
HW_Expansion_SCtrl:		equ $A1001F

; Background music
offset :=	MusicIndex
ptrsize :=	4
idstart :=	$81

bgm__First =	idstart
bgm_GHZ =	id(ptr_mus81)
bgm_LZ =	id(ptr_mus82)
bgm_MZ =	id(ptr_mus83)
bgm_SLZ =	id(ptr_mus84)
bgm_SYZ =	id(ptr_mus85)
bgm_SBZ =	id(ptr_mus86)
bgm_Invincible =	id(ptr_mus87)
bgm_ExtraLife =	id(ptr_mus88)
bgm_SS =	id(ptr_mus89)
bgm_Title =	id(ptr_mus8A)
bgm_Ending =	id(ptr_mus8B)
bgm_Boss =	id(ptr_mus8C)
bgm_FZ =	id(ptr_mus8D)
bgm_GotThrough =	id(ptr_mus8E)
bgm_GameOver =	id(ptr_mus8F)
bgm_Continue =	id(ptr_mus90)
bgm_Credits =	id(ptr_mus91)
bgm_Drowning =	id(ptr_mus92)
bgm_Emerald =	id(ptr_mus93)
bgm__Last =	id(ptr_musend)-1

; Sound effects
offset :=	SoundIndex
ptrsize :=	4
idstart :=	$A0

sfx__First =	idstart
sfx_Jump =	id(ptr_sndA0)
sfx_Lamppost =	id(ptr_sndA1)
sfx_A2 =	id(ptr_sndA2)
sfx_Death =	id(ptr_sndA3)
sfx_Skid =	id(ptr_sndA4)
sfx_A5 =	id(ptr_sndA5)
sfx_HitSpikes =	id(ptr_sndA6)
sfx_Push =	id(ptr_sndA7)
sfx_SSGoal =	id(ptr_sndA8)
sfx_SSItem =	id(ptr_sndA9)
sfx_Splash =	id(ptr_sndAA)
sfx_AB =	id(ptr_sndAB)
sfx_HitBoss =	id(ptr_sndAC)
sfx_Bubble =	id(ptr_sndAD)
sfx_Fireball =	id(ptr_sndAE)
sfx_Shield =	id(ptr_sndAF)
sfx_Saw =	id(ptr_sndB0)
sfx_Electric =	id(ptr_sndB1)
sfx_Drown =	id(ptr_sndB2)
sfx_Flamethrower =	id(ptr_sndB3)
sfx_Bumper =	id(ptr_sndB4)
sfx_Ring =	id(ptr_sndB5)
sfx_SpikesMove =	id(ptr_sndB6)
sfx_Rumbling =	id(ptr_sndB7)
sfx_B8 =	id(ptr_sndB8)
sfx_Collapse =	id(ptr_sndB9)
sfx_SSGlass =	id(ptr_sndBA)
sfx_Door =	id(ptr_sndBB)
sfx_Teleport =	id(ptr_sndBC)
sfx_ChainStomp =	id(ptr_sndBD)
sfx_Roll =	id(ptr_sndBE)
sfx_Continue =	id(ptr_sndBF)
sfx_Basaran =	id(ptr_sndC0)
sfx_BreakItem =	id(ptr_sndC1)
sfx_Warning =	id(ptr_sndC2)
sfx_GiantRing =	id(ptr_sndC3)
sfx_Bomb =	id(ptr_sndC4)
sfx_Cash =	id(ptr_sndC5)
sfx_RingLoss =	id(ptr_sndC6)
sfx_ChainRise =	id(ptr_sndC7)
sfx_Burning =	id(ptr_sndC8)
sfx_Bonus =	id(ptr_sndC9)
sfx_EnterSS =	id(ptr_sndCA)
sfx_WallSmash =	id(ptr_sndCB)
sfx_Spring =	id(ptr_sndCC)
sfx_Switch =	id(ptr_sndCD)
sfx_RingLeft =	id(ptr_sndCE)
sfx_Signpost =	id(ptr_sndCF)
sfx__Last =	id(ptr_sndend)-1

; Special sound effects
offset :=	SpecSoundIndex
ptrsize :=	4
idstart :=	$D0

spec__First =	idstart
sfx_Waterfall =	id(ptr_sndD0)
spec__Last =	id(ptr_specend)-1

offset :=	Sound_ExIndex
ptrsize :=	4
idstart :=	$E0

flg__First =	idstart
bgm_Fade =	id(ptr_flgE0)
sfx_Sega =	id(ptr_flgE1)
bgm_Speedup =	id(ptr_flgE2)
bgm_Slowdown =	id(ptr_flgE3)
bgm_Stop =	id(ptr_flgE4)
flg__Last =	id(ptr_flgend)-1

; Boss locations
; The main values are based on where the camera boundaries mainly lie
; The end values are where the camera scrolls towards after defeat
boss_ghz_x:	equ $2960		; Green Hill Zone
boss_ghz_y:	equ $300
boss_ghz_end:	equ boss_ghz_x+$160

boss_lz_x:	equ $1DE0		; Labyrinth Zone
boss_lz_y:	equ $C0
boss_lz_end:	equ boss_lz_x+$250

boss_mz_x:	equ $1800		; Marble Zone
boss_mz_y:	equ $210
boss_mz_end:	equ boss_mz_x+$160

boss_slz_x:	equ $2000		; Star Light Zone
boss_slz_y:	equ $210
boss_slz_end:	equ boss_slz_x+$160

boss_syz_x:	equ $2C00		; Spring Yard Zone
boss_syz_y:	equ $4CC
boss_syz_end:	equ boss_syz_x+$140

boss_sbz2_x:	equ $2050		; Scrap Brain Zone Act 2 Cutscene
boss_sbz2_y:	equ $510

boss_fz_x:	equ $2450		; Final Zone
boss_fz_y:	equ $510
boss_fz_end:	equ boss_fz_x+$2B0

; Tile VRAM Locations

; Shared
ArtTile_GHZ_MZ_Swing:		equ $380
ArtTile_GHZ_Swing:	equ $4D0
ArtTile_MZ_SYZ_Caterkiller:	equ $4FF
ArtTile_GHZ_SLZ_Smashable_Wall:	equ $50F

; Green Hill Zone
ArtTile_GHZ_Flower_4:		equ ArtTile_Level+$340
ArtTile_GHZ_Edge_Wall:		equ $34C
ArtTile_GHZ_Flower_Stalk:	equ ArtTile_Level+$358
ArtTile_GHZ_Big_Flower_1:	equ ArtTile_Level+$35C
ArtTile_GHZ_Small_Flower:	equ ArtTile_Level+$36C
ArtTile_GHZ_Waterfall:		equ ArtTile_Level+$378
ArtTile_GHZ_Flower_3:		equ ArtTile_Level+$380
ArtTile_GHZ_Bridge:		equ $4C6
ArtTile_GHZ_Big_Flower_2:	equ ArtTile_Level+$390
ArtTile_GHZ_Spike_Pole:		equ $398
ArtTile_GHZ_Giant_Ball:		equ $3AA
ArtTile_GHZ_Purple_Rock:	equ $6C0

; Marble Zone
ArtTile_MZ_Block:		equ $2B8
ArtTile_MZ_Animated_Magma:	equ ArtTile_Level+$2D2
ArtTile_MZ_Animated_Lava:	equ ArtTile_Level+$2E2
ArtTile_MZ_Torch:		equ ArtTile_Level+$2F2
ArtTile_MZ_Spike_Stomper:	equ $300
ArtTile_MZ_Fireball:		equ $345
ArtTile_MZ_Glass_Pillar:	equ $38E
ArtTile_MZ_Lava:		equ $3A8

; Spring Yard Zone
ArtTile_SYZ_Bumper:		equ $380
ArtTile_SYZ_Big_Spikeball:	equ $396
ArtTile_SYZ_Spikeball_Chain:	equ $3BA

; Labyrinth Zone
ArtTile_LZ_Block_1:		equ $1E0
ArtTile_LZ_Block_2:		equ $1F0
ArtTile_LZ_Splash:		equ $259
ArtTile_LZ_Gargoyle:		equ $2E9
ArtTile_LZ_Water_Surface:	equ $300
ArtTile_LZ_Spikeball_Chain:	equ $310
ArtTile_LZ_Flapping_Door:	equ $328
ArtTile_LZ_Bubbles:		equ $348
ArtTile_LZ_Moving_Block:	equ $3BC
ArtTile_LZ_Door:		equ $3C4
ArtTile_LZ_Harpoon:		equ $3CC
ArtTile_LZ_Pole:		equ $3DE
ArtTile_LZ_Push_Block:		equ $3DE
ArtTile_LZ_Blocks:		equ $3E6
ArtTile_LZ_Conveyor_Belt:	equ $3F6
ArtTile_LZ_Sonic_Drowning:	equ $440
ArtTile_LZ_Rising_Platform:	equ ArtTile_LZ_Blocks+$69
ArtTile_LZ_Orbinaut:		equ $467
ArtTile_LZ_Cork:		equ ArtTile_LZ_Blocks+$11A

; Star Light Zone
ArtTile_SLZ_Seesaw:		equ $374
ArtTile_SLZ_Fan:		equ $3A0
ArtTile_SLZ_Pylon:		equ $3CC
ArtTile_SLZ_Swing:		equ $3DC
ArtTile_SLZ_Orbinaut:		equ $429
ArtTile_SLZ_Fireball:		equ $480
ArtTile_SLZ_Fireball_Launcher:	equ $4D8
ArtTile_SLZ_Collapsing_Floor:	equ $4E0
ArtTile_SLZ_Spikeball:		equ $4F0

; Scrap Brain Zone
ArtTile_SBZ_Caterkiller:	equ $2B0
ArtTile_SBZ_Moving_Block_Short:	equ $2C0
ArtTile_SBZ_Door:		equ $2E8
ArtTile_SBZ_Girder:		equ $2F0
ArtTile_SBZ_Disc:		equ $344
ArtTile_SBZ_Junction:		equ $348
ArtTile_SBZ_Swing:		equ $391
ArtTile_SBZ_Saw:		equ $3B5
ArtTile_SBZ_Flamethrower:	equ $3D9
ArtTile_SBZ_Collapsing_Floor:	equ $3F5
ArtTile_SBZ_Orbinaut:		equ $429
ArtTile_SBZ_Smoke_Puff_1:	equ ArtTile_Level+$448
ArtTile_SBZ_Smoke_Puff_2:	equ ArtTile_Level+$454
ArtTile_SBZ_Moving_Block_Long:	equ $460
ArtTile_SBZ_Horizontal_Door:	equ $46F
ArtTile_SBZ_Electric_Orb:	equ $47E
ArtTile_SBZ_Trap_Door:		equ $492
ArtTile_SBZ_Vanishing_Block:	equ $4C3
ArtTile_SBZ_Spinning_Platform:	equ $4DF

; Final Zone
ArtTile_FZ_Boss:		equ $300
ArtTile_FZ_Eggman_Fleeing:	equ $3A0
ArtTile_FZ_Eggman_No_Vehicle:	equ $470

; General Level Art
ArtTile_Level:			equ $000
ArtTile_Ball_Hog:		equ $302
ArtTile_Bomb:			equ $400
ArtTile_Crabmeat:		equ $400
ArtTile_Missile_Disolve:	equ $41C ; Unused
ArtTile_Spikes:			equ $434
ArtTile_S1_Spikes:		equ $4A0
ArtTile_Buzz_Bomber:		equ $444
ArtTile_Chopper:		equ $470
ArtTile_Yadrin:			equ $47B
ArtTile_Lamppost:		equ $47C
ArtTile_Jaws:			equ $486
ArtTile_Newtron:		equ $49B
ArtTile_Burrobot:		equ $4A6
ArtTile_Basaran:		equ $4B8
ArtTile_Roller:			equ $4B8
ArtTile_Moto_Bug:		equ $4E0
ArtTile_Button:			equ $50F
ArtTile_S1_Spring_Horizontal:	equ $4A8
ArtTile_S1_Spring_Vertical:	equ $4B8
ArtTile_Shield:			equ $4BE
ArtTile_Invincibility:		equ $4DE
ArtTile_Game_Over:		equ $55E
ArtTile_Title_Card:		equ $580
ArtTile_Animal_1:		equ $580
ArtTile_Animal_2:		equ $592
ArtTile_Explosion:		equ $5A0
ArtTile_Monitor:		equ $680
ArtTile_HUD:			equ $6CA
ArtTile_Sonic:			equ $780
ArtTile_Points:			equ $4AC
ArtTile_Tails:			equ $7A0
ArtTile_TailsTails:		equ $7B0
ArtTile_Ring:			equ $6BC
ArtTile_Lives_Counter:		equ $7D4
ArtTile_Water_Surface:		equ $400
ArtTile_Spring_Horizontal:	equ $470
ArtTile_Spring_Vertical:	equ $45C
ArtTile_Spring_Diagonal:	equ $43C

ArtTile_S1_Ring:		equ $7B2

; Eggman
ArtTile_Eggman:			equ $400
ArtTile_Eggman_Weapons:		equ $46C
ArtTile_Eggman_Button:		equ $4A4
ArtTile_Eggman_Spikeball:	equ $518
ArtTile_Eggman_Trap_Floor:	equ $518
ArtTile_Eggman_Exhaust:		equ ArtTile_Eggman+$12A

; End of Level
ArtTile_Giant_Ring:		equ $400
ArtTile_Giant_Ring_Flash:	equ $462
ArtTile_Prison_Capsule:		equ $49D
ArtTile_Hidden_Points:		equ $4B6
ArtTile_Warp:			equ $541
ArtTile_Mini_Sonic:		equ $551
ArtTile_Bonuses:		equ $570
ArtTile_Signpost:		equ $680

; Sega Screen
ArtTile_Sega_Tiles:		equ $000

; Title Screen
ArtTile_Title_Japanese_Text:	equ $000
ArtTile_Title_Foreground:	equ $000
ArtTile_Title_Sonic_And_Tails:	equ $200
ArtTile_Title_Sonic:		equ $300
ArtTile_Title_Trademark:	equ $510
ArtTile_Level_Select_Font:	equ $680

; Continue Screen
ArtTile_Continue_Sonic:		equ $500
ArtTile_Continue_Number:	equ $6FC

; Ending
ArtTile_Ending_Flowers:		equ $3A0
ArtTile_Ending_Emeralds:	equ $3C5
ArtTile_Ending_Sonic:		equ $3E1
ArtTile_Ending_Eggman:		equ $524
ArtTile_Ending_Rabbit:		equ $553
ArtTile_Ending_Chicken:		equ $565
ArtTile_Ending_Penguin:		equ $573
ArtTile_Ending_Seal:		equ $585
ArtTile_Ending_Pig:		equ $593
ArtTile_Ending_Flicky:		equ $5A5
ArtTile_Ending_Squirrel:	equ $5B3
ArtTile_Ending_STH:		equ $5C5

; Try Again Screen
ArtTile_Try_Again_Emeralds:	equ $3C5
ArtTile_Try_Again_Eggman:	equ $3E1

; Special Stage
ArtTile_SS_Background_Clouds:	equ $000
ArtTile_SS_Background_Fish:	equ $051
ArtTile_SS_Wall:		equ $142
ArtTile_SS_Plane_1:		equ $200
ArtTile_SS_Bumper:		equ $23B
ArtTile_SS_Goal:		equ $251
ArtTile_SS_Up_Down:		equ $263
ArtTile_SS_R_Block:		equ $2F0
ArtTile_SS_Plane_2:		equ $300
ArtTile_SS_Extra_Life:		equ $370
ArtTile_SS_Emerald_Sparkle:	equ $3F0
ArtTile_SS_Plane_3:		equ $400
ArtTile_SS_Red_White_Block:	equ $470
ArtTile_SS_Ghost_Block:		equ $4F0
ArtTile_SS_Plane_4:		equ $500
ArtTile_SS_W_Block:		equ $570
ArtTile_SS_Glass:		equ $5F0
ArtTile_SS_Plane_5:		equ $600
ArtTile_SS_Plane_6:		equ $700
ArtTile_SS_Emerald:		equ $770
ArtTile_SS_Zone_1:		equ $797
ArtTile_SS_Zone_2:		equ $7A0
ArtTile_SS_Zone_3:		equ $7A9
ArtTile_SS_Zone_4:		equ $797
ArtTile_SS_Zone_5:		equ $7A0
ArtTile_SS_Zone_6:		equ $7A9

; Special Stage Results
ArtTile_SS_Results_Emeralds:	equ $541

; Font
ArtTile_Sonic_Team_Font:	equ $0A6
ArtTile_Credits_Font:		equ $5A0

; Error Handler
ArtTile_Error_Handler_Font:	equ $7C0

; EHZ, HTZ
ArtTile_Checkers:		equ ArtTile_Level+$158
ArtTile_Art_Flowers1:		equ $394
ArtTile_Art_Flowers2:		equ $396
ArtTile_Art_Flowers3:		equ $398
ArtTile_Art_Flowers4:		equ $39A
ArtTile_HTZ:			equ ArtTile_Level+$1FC
ArtTile_EHZ_Shield:			equ $560

; CPZ
ArtTile_CPZ_Buildings:		equ $3D0
ArtTile_CPZ_Lights:		equ $480
ArtTile_CPZ_Conveyor:		equ $484
ArtTile_CPZ_Pistons:		equ $48C
ArtTile_CPZ_Metre:		equ $48E
ArtTile_CPZ_Cross_Circle:	equ $490
ArtTile_CPZ_Propeller:		equ $491
ArtTile_CPZ_Liquid:		equ $495
ArtTile_CPZ_Conveyor_2:		equ $498

; HPZ
ArtTile_Art_HPZPulseOrb_1:	equ $2E8
ArtTile_Art_HPZPulseOrb_2:	equ $2F0
ArtTile_Art_HPZPulseOrb_3:	equ $2F8
ArtTile_HPZ_Bridge:		equ $300
ArtTile_HPZ_Waterfall:		equ $315
ArtTile_HPZ_Platform:		equ $34A
ArtTile_HPZ_Orb:		equ $35A
ArtTile_HPZ_Various:		equ $37C
ArtTile_HPZ_Emerald:		equ $392

; ---------------------------------------------------------------------------
; Level-specific objects and badniks.

; EHZ
ArtTile_Art_EHZPulseBall:	equ $39C
ArtTile_Fireball:		equ $39E
ArtTile_Waterfall:		equ $3AE
ArtTile_EHZ_Bridge:		equ $3C6
ArtTile_Buzzer:			equ $3E6
ArtTile_Buzzer_Fireball:	equ $3BE	; Actually unused
ArtTile_Snail:			equ $402
ArtTile_Masher:			equ $41C
ArtTile_Art_EHZMountains:	equ $500

; EHZ boss
ArtTile_ArtNem_Eggpod_1:	equ $460
ArtTile_ArtNem_EHZBoss:	equ $4C0
ArtTile_ArtNem_EggChoppers:	equ $540

; CPZ
ArtTile_CPZ_Platform:		equ $400
ArtTile_CPZ_Float_Platform:	equ $418
ArtTile_CPZ_Water_Surface:	equ $440

; CPZ boss
ArtTile_ArtNem_EggpodJets_1:	equ $418
ArtTile_ArtNem_Eggpod_3:	equ $420
ArtTile_ArtNem_CPZBoss:	equ $500
ArtTile_ArtNem_BossSmoke_1:	equ $570

; HPZ
ArtTile_Redz:			equ $500
ArtTile_BBat:			equ $530

; HTZ
ArtTile_Rexon:			equ $37E
ArtTile_HTZ_Fireball:		equ $3AE
ArtTile_HTZ_AutomaticDoor:	equ $3BE
ArtTile_HTZ_Seesaw:		equ $3CE
ArtTile_Sol:			equ $3DE
ArtTile_HtzZipline:		equ $3E6
ArtTile_HtzValveBarrier:	equ $426
ArtTile_HTZMountains:	equ $500
ArtTile_Spiker:			equ $520

; Unused
ArtTile_Gator:			equ $300
ArtTile_Early_Buzzer:		equ $32C
ArtTile_Early_BBat:		equ $350
ArtTile_Stegway:		equ $3C4
ArtTile_BFish:			equ $530
ArtTile_Aquis:			equ $570
ArtTile_Aquis_Child:		equ $4E0
ArtTile_Octus:			equ $38A
ArtTile_Octus_Child:		equ $4C6