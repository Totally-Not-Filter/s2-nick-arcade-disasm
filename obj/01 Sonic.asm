; ===========================================================================
; ---------------------------------------------------------------------------
; Object 01 - Sonic
; ---------------------------------------------------------------------------

Obj01:
		tst.w	(Debug_placement_mode).w	; is debug mode being used?
		beq.s	Obj01_Normal			; if not, branch
		jmp	(DebugMode).l
; ===========================================================================

Obj01_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj01_Index(pc,d0.w),d1
		jmp	Obj01_Index(pc,d1.w)
; ===========================================================================
Obj01_Index:	dc.w Obj01_Init-Obj01_Index
		dc.w Obj01_Control-Obj01_Index
		dc.w Obj01_Hurt-Obj01_Index
		dc.w Obj01_Dead-Obj01_Index
		dc.w Obj01_ResetLevel-Obj01_Index
; ===========================================================================
; Obj01_Main:
Obj01_Init:
		addq.b	#2,obRoutine(a0)		; => Obj01_Control
		move.b	#19,obHeight(a0)		; this sets Sonic's collision height (2*pixels)
		move.b	#9,obWidth(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#2,obPriority(a0)
		move.b	#24,obActWid(a0)
		move.b	#4,obRender(a0)
		move.w	#$600,(Sonic_top_speed).w	; set Sonic's top speed
		move.w	#$C,(Sonic_acceleration).w	; set Sonic's acceleration
		move.w	#$80,(Sonic_deceleration).w	; set Sonic's deceleration
		move.b	#$C,top_solid_bit(a0)
		move.b	#$D,lrb_solid_bit(a0)
		move.b	#0,flips_remaining(a0)
		move.b	#4,flip_speed(a0)
		move.w	#0,(Sonic_Pos_Record_Index).w
		move.w	#bytesToWcnt($80),d2

loc_FA88:
		bsr.w	Sonic_RecordPos
		move.w	#0,(a1,d0.w)
		dbf	d2,loc_FA88

; ---------------------------------------------------------------------------
; Normal state for Sonic
; ---------------------------------------------------------------------------

Obj01_Control:
		tst.w	(Debug_mode_flag).w		; is debug cheat enabled?
		beq.s	loc_FAB0			; if not, branch
		btst	#bitB,(v_jpadpress1).w		; is button B pressed?
		beq.s	loc_FAB0			; if not, branch
		move.w	#1,(Debug_placement_mode).w	; change Sonic into ring/item
		clr.b	(f_lockctrl).w			; unlock control
		rts
; -----------------------------------------------------------------------
loc_FAB0:
		tst.b	(f_lockctrl).w			; are controls locked?
		bne.s	loc_FABC			; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w	; copy new held buttons, to enable joypad

loc_FABC:
		btst	#0,(f_playerctrl).w		; is Sonic interacting with another object that holds him in place or controls his movement somehow?
		bne.s	Obj01_ControlsLock		; if yes, branch to skip Sonic's control
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Obj01_Modes(pc,d0.w),d1
		jsr	Obj01_Modes(pc,d1.w)		; run Sonic's movement control code

Obj01_ControlsLock:
		bsr.s	Sonic_Display
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Water
		move.b	(Primary_Angle).w,angleright(a0)
		move.b	(Secondary_Angle).w,angleleft(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	loc_FAFE
		tst.b	obAnim(a0)
		bne.s	loc_FAFE
		move.b	obPrevAni(a0),obAnim(a0)

loc_FAFE:
		bsr.w	Sonic_Animate
		tst.b	(f_playerctrl).w
		bmi.s	loc_FB0E
		jsr	(TouchResponse).l

loc_FB0E:
		bra.w	LoadSonicDynPLC

; ===========================================================================
; secondary states under state Obj01_Control
Obj01_Modes:	dc.w Obj01_MdNormal-Obj01_Modes
		dc.w Obj01_MdAir-Obj01_Modes
		dc.w Obj01_MdRoll-Obj01_Modes
		dc.w Obj01_MdJump-Obj01_Modes
; Used for when invincibility wears off
MusicList_Sonic:dc.b bgm_GHZ
		dc.b bgm_LZ
		dc.b bgm_MZ
		dc.b bgm_SLZ
		dc.b bgm_SYZ
		dc.b bgm_SBZ
		even

; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Display:
		move.w	flashtime(a0),d0
		beq.s	Obj01_Display
		subq.w	#1,flashtime(a0)
		lsr.w	#3,d0
		bhs.s	Obj01_ChkInvin
; loc_FB2E:
Obj01_Display:
		jsr	(DisplaySprite).l
; loc_FB34:
Obj01_ChkInvin:						; Checks if invincibility has expired and (should) disables it if it has
		tst.b	(v_invinc).w
		beq.s	Obj01_ChkShoes
		tst.w	invtime(a0)
		beq.s	Obj01_ChkShoes
	if FixBugs=0
		; This branch causes the invincibility timer to be disabled.
		; Strangely, Tails' version doesn't have this.
		bra.s	Obj01_ChkShoes
	endif
		subq.w	#1,invtime(a0)
		bne.s	Obj01_ChkShoes
		tst.b	(f_lockscreen).w
		bne.s	Obj01_RmvInvin
		cmpi.w	#12,(v_air).w
		blo.s	Obj01_RmvInvin
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		cmpi.w	#(id_LZ<<8)+3,(Current_ZoneAndAct).w	; Leftover check from Sonic 1 for SBZ3
		bne.s	loc_FB66
		moveq	#5,d0

loc_FB66:
		lea	MusicList_Sonic(pc),a1
		move.b	(a1,d0.w),d0
		jsr	(QueueSound1).l
; loc_FB74:
Obj01_RmvInvin:
		move.b	#0,(v_invinc).w
; loc_FB7A:
Obj01_ChkShoes:						; Checks if Speed Shoes have expired and disables them if they have.
		tst.b	(v_shoes).w
		beq.s	Obj01_ExitChk
		tst.w	shoetime(a0)
		beq.s	Obj01_ExitChk
		subq.w	#1,shoetime(a0)
		bne.s	Obj01_ExitChk
		move.w	#$600,(Sonic_top_speed).w
		move.w	#$C,(Sonic_acceleration).w
		move.w	#$80,(Sonic_deceleration).w
		move.b	#0,(v_shoes).w
		move.w	#bgm_Slowdown,d0
		jmp	(QueueSound1).l
; ---------------------------------------------------------------------------
; locret_FBAE:
Obj01_ExitChk:
		rts
; End of function Sonic_Display


; ---------------------------------------------------------------------------
; Subroutine to record Sonic's previous positions for invincibility stars
; and input/status flags for Tails' AI to follow
; ---------------------------------------------------------------------------

; loc_FBB2: CopySonicMovesForTails:
Sonic_RecordPos:
		move.w	(Sonic_Pos_Record_Index).w,d0
		lea	(Sonic_Pos_Record_Buf).w,a1
		lea	(a1,d0.w),a1
		move.w	obX(a0),(a1)+
		move.w	obY(a0),(a1)+
		addq.b	#4,(Sonic_Pos_Record_Index+1).w

		lea	(Sonic_Stat_Record_Buf).w,a1
		move.w	(v_jpadhold1).w,(a1,d0.w)
		rts
; End of function Sonic_RecordPos

; ===========================================================================
; ---------------------------------------------------------------------------
; Seemingly an earlier subroutine to copy Sonic's status flags for Tails' AI
; ---------------------------------------------------------------------------

Unused_RecordPos:
		move.w	(RecordPos_Unused).w,d0
		subq.b	#4,d0
		lea	(Tails_Pos_Record_Buf).w,a1
		lea	(a1,d0.w),a2
		move.w	obX(a0),d1
		swap	d1
		move.w	obY(a0),d1
		cmp.l	(a2),d1
		beq.s	locret_FC02
		addq.b	#4,d0
		lea	(a1,d0.w),a2
		move.w	obX(a0),(a2)+
		move.w	obY(a0),(a2)
		addq.b	#4,(RecordPos_Unused+1).w

locret_FC02:
		rts
; End of subroutine Unused_RecordPos


; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; loc_FC06:
Sonic_Water:
		tst.b	(Water_flag).w
		bne.s	Obj01_InWater

locret_FC0A:
		rts
; ---------------------------------------------------------------------------
; loc_FC0E: Obj01_InLevelWithWater:
Obj01_InWater:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0			; is Sonic above water?
		bge.s	Obj01_OutWater			; if yes, branch

		bset	#6,obStatus(a0)			; set underwater flag
		bne.s	locret_FC0A			; if already underwater, branch

		bsr.w	ResumeMusic
		move.b	#id_Obj0A,(v_sonicbubbles).w		; load Obj0A (sonic's breathing bubbles) at $FFFFB340
		move.b	#$81,(v_sonicbubbles+obSubtype).w
		move.w	#$300,(Sonic_top_speed).w
		move.w	#6,(Sonic_acceleration).w
		move.w	#$40,(Sonic_deceleration).w
		asr.w	obVelX(a0)
		asr.w	obVelY(a0)			; memory oprands can only be shifted one at a time
		asr.w	obVelY(a0)
		beq.s	locret_FC0A
		move.b	#id_Obj08,(v_splash).w		; splash animation
		move.w	#sfx_Splash,d0			; splash sound
		jmp	(QueueSound2).l
; ---------------------------------------------------------------------------
; Obj01_NotInWater:
Obj01_OutWater:
		bclr	#6,obStatus(a0)			; unset underwater flag
		beq.s	locret_FC0A			; if already unset, branch

		bsr.w	ResumeMusic
		move.w	#$600,(Sonic_top_speed).w
		move.w	#$C,(Sonic_acceleration).w
		move.w	#$80,(Sonic_deceleration).w
		asl.w	obVelY(a0)
		beq.w	locret_FC0A
		move.b	#id_Obj08,(v_splash).w		; splash animation
		cmpi.w	#-$1000,obVelY(a0)
		bgt.s	loc_FC98
		move.w	#-$1000,obVelY(a0)		; limit upward y velocity exiting the water

loc_FC98:
		move.w	#sfx_Splash,d0			; splash sound
		jmp	(QueueSound2).l
; End of function Sonic_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Start of subroutine Obj01_MdNormal
; Called if Sonic is neither airborne nor rolling this frame
; ---------------------------------------------------------------------------

Obj01_MdNormal:
		bsr.w	Sonic_CheckSpindash
		bsr.w	Sonic_Jump
		bsr.w	Sonic_SlopeResist
		bsr.w	Sonic_Move
		bsr.w	Sonic_Roll
		bsr.w	Sonic_LevelBound
		jsr	(ObjectMove).l
		bsr.w	AnglePos
		bsr.w	Sonic_SlopeRepel
		rts
; End of subroutine Obj01_MdNormal

; ===========================================================================
; Start of subroutine Obj01_MdAir
; Called if Sonic is airborne, but not in a ball (thus, probably not jumping)
; Obj01_MdJump:
Obj01_MdAir:
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_ChgJumpDir
		bsr.w	Sonic_LevelBound
		jsr	(ObjectMoveAndFall).l
		btst	#6,obStatus(a0)			; is Sonic underwater?
		beq.s	loc_FCEA			; if not, branch
		subi.w	#$28,obVelY(a0)			; reduce gravity by $28 ($38-$28=$10)

loc_FCEA:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_DoLevelCollision
		rts
; End of subroutine Obj01_MdAir

; ===========================================================================
; Start of subroutine Obj01_MdRoll
; Called if Sonic is in a ball, but not airborne (thus, probably rolling)

Obj01_MdRoll:
		bsr.w	Sonic_Jump
		bsr.w	Sonic_RollRepel
		bsr.w	Sonic_RollSpeed
		bsr.w	Sonic_LevelBound
		jsr	(ObjectMove).l
		bsr.w	AnglePos
		bsr.w	Sonic_SlopeRepel
		rts
; End of subroutine Obj01_MdRoll

; ===========================================================================
; Start of subroutine Obj01_MdJump
; Called if Sonic is in a ball and airborne (he could be jumping but not necessarily)
; Notes: This is identical to Obj01_MdAir, at least at this outer level.
;        Why they gave it a separate copy of the code, I don't know.
; Obj01_MdJump2:
Obj01_MdJump:
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_ChgJumpDir
		bsr.w	Sonic_LevelBound
		jsr	(ObjectMoveAndFall).l
		btst	#6,obStatus(a0)			; is Sonic underwater?
		beq.s	loc_FD34			; if not, branch
		subi.w	#$28,obVelY(a0)			; reduce gravity by $28 ($38-$28=$10)

loc_FD34:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_DoLevelCollision
		rts
; End of subroutine Obj01_MdJump


; ---------------------------------------------------------------------------
; Subroutine to make Sonic walk/run
; ---------------------------------------------------------------------------

Sonic_Move:
		move.w	(Sonic_top_speed).w,d6
		move.w	(Sonic_acceleration).w,d5
		move.w	(Sonic_deceleration).w,d4
		tst.b	(f_slidemode).w
		bne.w	Obj01_Traction
		tst.w	locktime(a0)
		bne.w	Obj01_UpdateSpeedOnGround
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		beq.s	loc_FD66			; if not, branch
		bsr.w	Sonic_MoveLeft

loc_FD66:
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
		beq.s	loc_FD72			; if not, branch
		bsr.w	Sonic_MoveRight

loc_FD72:
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0				; is Sonic on a slope?
		bne.w	Obj01_UpdateSpeedOnGround	; if yes, branch
		tst.w	obInertia(a0)			; is Sonic moving?
		bne.w	Obj01_UpdateSpeedOnGround	; if yes, branch
		bclr	#5,obStatus(a0)
		cmpi.b	#AniIDSonAni_WallRecoil2,obAnim(a0)
		beq.s	loc_FD9E
		move.b	#AniIDSonAni_Wait,obAnim(a0)	; use "standing" animation

loc_FD9E:
		btst	#3,obStatus(a0)
		beq.s	Sonic_Balance
		moveq	#0,d0
		move.b	standonobject(a0),d0
		lsl.w	#object_size_bits,d0
		lea	(v_player).w,a1			; a1=character
		lea	(a1,d0.w),a1			; a1=object
		tst.b	obStatus(a1)
		bmi.s	Sonic_LookUp
		moveq	#0,d1
		move.b	obActWid(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2
		add.w	obX(a0),d1
		sub.w	obX(a1),d1
		cmpi.w	#4,d1
		blt.s	loc_FE00
		cmp.w	d2,d1
		bge.s	loc_FDF0
		bra.s	Sonic_LookUp
; ---------------------------------------------------------------------------

Sonic_Balance:
		jsr	(ChkFloorEdge).l
		cmpi.w	#$C,d1
		blt.s	Sonic_LookUp
		cmpi.b	#3,angleright(a0)
		bne.s	loc_FDF8

loc_FDF0:
		bclr	#0,obStatus(a0)
		bra.s	loc_FE06
; ---------------------------------------------------------------------------

loc_FDF8:
		cmpi.b	#3,angleleft(a0)
		bne.s	Sonic_LookUp

loc_FE00:
		bset	#0,obStatus(a0)

loc_FE06:
		move.b	#AniIDSonAni_Balance,obAnim(a0)
		bra.s	Obj01_UpdateSpeedOnGround
; ---------------------------------------------------------------------------

Sonic_LookUp:
		btst	#bitUp,(v_jpadhold2).w	; is up being pressed?
		beq.s	Sonic_Duck			; if not, branch
		move.b	#AniIDSonAni_LookUp,obAnim(a0)	; use "looking up" animation
		bra.s	Obj01_UpdateSpeedOnGround
; ---------------------------------------------------------------------------

Sonic_Duck:
		btst	#bitDn,(v_jpadhold2).w	; is down being pressed?
		beq.s	Obj01_UpdateSpeedOnGround	; if not, branch
		move.b	#AniIDSonAni_Duck,obAnim(a0)	; use "ducking" animation

; ---------------------------------------------------------------------------
; updates Sonic's speed on the ground
; ---------------------------------------------------------------------------
; loc_FE2C:
Obj01_UpdateSpeedOnGround:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0	; is left/right being pressed?
		bne.s	Obj01_Traction			; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	Obj01_Traction
		bmi.s	Obj01_SettleLeft

; slow down when facing right and not pressing a direction
; Obj01_SettleRight:
		sub.w	d5,d0
		bhs.s	loc_FE46
		move.w	#0,d0

loc_FE46:
		move.w	d0,obInertia(a0)
		bra.s	Obj01_Traction
; ---------------------------------------------------------------------------
; slow down when facing left and not pressing a direction
; loc_FE4C:
Obj01_SettleLeft:
		add.w	d5,d0
		bhs.s	loc_FE54
		move.w	#0,d0

loc_FE54:
		move.w	d0,obInertia(a0)

; increase or decrease speed on the ground
; loc_FE58:
Obj01_Traction:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)

; stops Sonic from running through walls that meet the ground
; loc_FE76:
Obj01_CheckWallsOnGround:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0
		bmi.s	locret_FEF6
		move.b	#$40,d1				; rotate 90 degress clockwise
		tst.w	obInertia(a0)			; check if Sonic's moving
		beq.s	locret_FEF6			; if not, branch
		bmi.s	loc_FE8E			; if negative, branch
		neg.w	d1				; rotate counterclockwise

loc_FE8E:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	CalcRoomInFront
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_FEF6
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_FEF2
		cmpi.b	#$40,d0
		beq.s	loc_FED8
		cmpi.b	#$80,d0
		beq.s	loc_FED2
		cmpi.w	#$600,obVelX(a0)		; is Sonic at max speed?
		bge.s	Sonic_WallRecoil		; if yes, branch
		add.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_FED2:
		sub.w	d1,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_FED8:
		cmpi.w	#-$600,obVelX(a0)		; is Sonic at max speed?
		ble.s	Sonic_WallRecoil		; if yes, branch
		sub.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_FEF2:
		add.w	d1,obVelY(a0)

locret_FEF6:
		rts

; ---------------------------------------------------------------------------
; Subroutine to recoil Sonic off a wall if moving a top speed
; ---------------------------------------------------------------------------

Sonic_WallRecoil:
		move.b	#4,obRoutine(a0)
		bsr.w	Sonic_ResetOnFloor
		bset	#1,obStatus(a0)
		move.w	#-$200,d0
		tst.w	obVelX(a0)
		bpl.s	Sonic_WallRecoil_Right
		neg.w	d0

Sonic_WallRecoil_Right:
		move.w	d0,obVelX(a0)
		move.w	#-$400,obVelY(a0)
		move.w	#0,obInertia(a0)
		move.b	#AniIDSonAni_WallRecoil1,obAnim(a0)
		move.b	#1,ob2ndRout(a0)
		move.w	#sfx_Death,d0
		jsr	(QueueSound2).l
		rts
; End of function Sonic_Move


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_FF44
		bpl.s	Sonic_TurnLeft

loc_FF44:
		bset	#0,obStatus(a0)
		bne.s	loc_FF58
		bclr	#5,obStatus(a0)
		move.b	#1,obPrevAni(a0)

loc_FF58:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_FF64
		move.w	d1,d0

loc_FF64:
		move.w	d0,obInertia(a0)
		move.b	#AniIDSonAni_Walk,obAnim(a0)
		rts
; ---------------------------------------------------------------------------
; loc_FF70:
Sonic_TurnLeft:
		sub.w	d4,d0
		bhs.s	loc_FF78
		move.w	#-$80,d0

loc_FF78:
		move.w	d0,obInertia(a0)
	if FixBugs
		move.b	obAngle(a0),d1
		addi.b	#$20,d1
		andi.b	#$C0,d1
	else
		; These three instructions partially overwrite the inertia value in
		; 'd0'! This causes the character to trigger their skidding
		; animation at different speeds depending on whether they're going
		; right or left. To fix this, make these instructions use 'd1'
		; instead.
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
	endif
		bne.s	locret_FFA6
		cmpi.w	#$400,d0
		blt.s	locret_FFA6
		move.b	#AniIDSonAni_Stop,obAnim(a0)
		bclr	#0,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr	(QueueSound2).l

locret_FFA6:
		rts
; End of function Sonic_MoveLeft


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveRight:
		move.w	obInertia(a0),d0
		bmi.s	Sonic_TurnRight
		bclr	#0,obStatus(a0)
		beq.s	loc_FFC2
		bclr	#5,obStatus(a0)
		move.b	#1,obPrevAni(a0)

loc_FFC2:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_FFCA
		move.w	d6,d0

loc_FFCA:
		move.w	d0,obInertia(a0)
		move.b	#AniIDSonAni_Walk,obAnim(a0)
		rts
; ---------------------------------------------------------------------------
; loc_FFD6:
Sonic_TurnRight:
		add.w	d4,d0
		bhs.s	loc_FFDE
		move.w	#$80,d0

loc_FFDE:
		move.w	d0,obInertia(a0)
	if FixBugs
		move.b	obAngle(a0),d1
		addi.b	#$20,d1
		andi.b	#$C0,d1
	else
		; These three instructions partially overwrite the inertia value in
		; 'd0'! This causes the character to trigger their skidding
		; animation at different speeds depending on whether they're going
		; right or left. To fix this, make these instructions use 'd1'
		; instead.
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
	endif
		bne.s	locret_1000C
		cmpi.w	#-$400,d0
		bgt.s	locret_1000C
		move.b	#AniIDSonAni_Stop,obAnim(a0)
		bset	#0,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr	(QueueSound2).l

locret_1000C:
		rts
; End of function Sonic_MoveRight


; =============== S U B	R O U T	I N E =======================================


Sonic_RollSpeed:
		move.w	(Sonic_top_speed).w,d6
		asl.w	#1,d6
		move.w	(Sonic_acceleration).w,d5
		asr.w	#1,d5
		move.w	(Sonic_deceleration).w,d4
		asr.w	#2,d4
		tst.b	(f_slidemode).w
		bne.w	loc_1008A
		tst.w	locktime(a0)
		bne.s	loc_10046
		btst	#bitL,(v_jpadhold2).w
		beq.s	loc_1003A
		bsr.w	Sonic_RollLeft

loc_1003A:
		btst	#bitR,(v_jpadhold2).w
		beq.s	loc_10046
		bsr.w	Sonic_RollRight

loc_10046:
		move.w	obInertia(a0),d0
		beq.s	loc_10068
		bmi.s	loc_1005C
		sub.w	d5,d0
		bhs.s	loc_10056
		move.w	#0,d0

loc_10056:
		move.w	d0,obInertia(a0)
		bra.s	loc_10068
; ---------------------------------------------------------------------------

loc_1005C:
		add.w	d5,d0
		bhs.s	loc_10064
		move.w	#0,d0

loc_10064:
		move.w	d0,obInertia(a0)

loc_10068:
		tst.w	obInertia(a0)
		bne.s	loc_1008A
		bclr	#2,obStatus(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#AniIDSonAni_Wait,obAnim(a0)
		subq.w	#5,obY(a0)

loc_1008A:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		cmpi.w	#$1000,d1
		ble.s	loc_100AE
		move.w	#$1000,d1

loc_100AE:
		cmpi.w	#-$1000,d1
		bge.s	loc_100B8
		move.w	#-$1000,d1

loc_100B8:
		move.w	d1,obVelX(a0)
		bra.w	Obj01_CheckWallsOnGround
; End of function Sonic_RollSpeed


; =============== S U B	R O U T	I N E =======================================


Sonic_RollLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_100C8
		bpl.s	loc_100D6

loc_100C8:
		bset	#0,obStatus(a0)
		move.b	#AniIDSonAni_Roll,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_100D6:
		sub.w	d4,d0
		bhs.s	loc_100DE
		move.w	#-$80,d0

loc_100DE:
		move.w	d0,obInertia(a0)
		rts
; End of function Sonic_RollLeft


; =============== S U B	R O U T	I N E =======================================


Sonic_RollRight:
		move.w	obInertia(a0),d0
		bmi.s	loc_100F8
		bclr	#0,obStatus(a0)
		move.b	#AniIDSonAni_Roll,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_100F8:
		add.w	d4,d0
		bhs.s	loc_10100
		move.w	#$80,d0

loc_10100:
		move.w	d0,obInertia(a0)
		rts
; End of function Sonic_RollRight


; =============== S U B	R O U T	I N E =======================================


Sonic_ChgJumpDir:
		move.w	(Sonic_top_speed).w,d6
		move.w	(Sonic_acceleration).w,d5
		asl.w	#1,d5
		btst	#4,obStatus(a0)
		bne.s	loc_10150
		move.w	obVelX(a0),d0
		btst	#bitL,(v_jpadhold2).w
		beq.s	loc_10136
		bset	#0,obStatus(a0)
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_10136
		move.w	d1,d0

loc_10136:
		btst	#bitR,(v_jpadhold2).w
		beq.s	loc_1014C
		bclr	#0,obStatus(a0)
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_1014C
		move.w	d6,d0

loc_1014C:
		move.w	d0,obVelX(a0)

loc_10150:
		cmpi.w	#$60,(Camera_Y_pos_bias).w
		beq.s	loc_10162
		bhs.s	loc_1015E
		addq.w	#4,(Camera_Y_pos_bias).w

loc_1015E:
		subq.w	#2,(Camera_Y_pos_bias).w

loc_10162:
		cmpi.w	#-$400,obVelY(a0)
		blo.s	locret_10190
		move.w	obVelX(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_10190
		bmi.s	loc_10184
		sub.w	d1,d0
		bhs.s	loc_1017E
		move.w	#0,d0

loc_1017E:
		move.w	d0,obVelX(a0)
		rts
; ---------------------------------------------------------------------------

loc_10184:
		sub.w	d1,d0
		blo.s	loc_1018C
		move.w	#0,d0

loc_1018C:
		move.w	d0,obVelX(a0)

locret_10190:
		rts
; End of function Sonic_ChgJumpDir


; =============== S U B	R O U T	I N E =======================================

; Sonic_LevelBoundaries:
Sonic_LevelBound:
		move.l	obX(a0),d1
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		swap	d1
		move.w	(Camera_Min_X_pos).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0
		bhi.s	loc_101FA
		move.w	(Camera_Max_X_pos).w,d0
		addi.w	#$128,d0
		tst.b	(f_lockscreen).w
		bne.s	loc_101C0
		addi.w	#$40,d0

loc_101C0:
		cmp.w	d1,d0
		bls.s	loc_101FA

loc_101C4:
		move.w	(Camera_Max_Y_pos).w,d0
	if FixBugs
		; The original code does not consider that the camera boundary
		; may be in the middle of lowering itself, which is why going
		; down the S-tunnel in Green Hill Zone Act 1 fast enough can
		; kill Sonic.
		move.w	(Camera_Max_Y_pos_target).w,d1
		cmp.w	d0,d1
		blo.s	.skip
		move.w	d1,d0
.skip:
	endif
		addi.w	#224,d0
		cmp.w	obY(a0),d0
		blt.s	loc_101D4
		rts
; ---------------------------------------------------------------------------

loc_101D4:
	if FixBugs
		; a2 needs to be set here, otherwise KillCharacter
		; will access a dangling pointer!
		movea.l	a0,a2
	endif
		cmpi.w	#(id_SBZ<<8)+1,(Current_ZoneAndAct).w
		bne.w	JmpTo_KillCharacter
		cmpi.w	#$2000,(v_player+obX).w
		blo.w	JmpTo_KillCharacter
		clr.b	(v_lastlamp).w
		move.w	#1,(Level_Inactive_flag).w
		move.w	#(id_LZ<<8)+3,(Current_ZoneAndAct).w
		rts
; ---------------------------------------------------------------------------

loc_101FA:
		move.w	d0,obX(a0)
		move.w	#0,obX+2(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obInertia(a0)
		bra.s	loc_101C4
; End of function Sonic_LevelBound


; =============== S U B	R O U T	I N E =======================================


Sonic_Roll:
		tst.b	(f_slidemode).w
		bne.s	Obj01_NoRoll
		move.w	obInertia(a0),d0
		bpl.s	loc_10220
		neg.w	d0

loc_10220:
		cmpi.w	#$80,d0
		blo.s	Obj01_NoRoll
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0
		bne.s	Obj01_NoRoll
		btst	#bitDn,(v_jpadhold2).w
		bne.s	loc_1023A

Obj01_NoRoll:
		rts
; ---------------------------------------------------------------------------

loc_1023A:
		btst	#2,obStatus(a0)
		beq.s	Obj01_DoRoll
		rts
; ---------------------------------------------------------------------------

Obj01_DoRoll:
		bset	#2,obStatus(a0)
		move.b	#14,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#AniIDSonAni_Roll,obAnim(a0)
		addq.w	#5,obY(a0)
		move.w	#sfx_Roll,d0
		jsr	(QueueSound2).l
		tst.w	obInertia(a0)
		bne.s	locret_10276
		move.w	#$200,obInertia(a0)

locret_10276:
		rts
; End of function Sonic_Roll


; =============== S U B	R O U T	I N E =======================================


Sonic_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	locret_1031C
		moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_13102
		cmpi.w	#6,d1
		blt.w	locret_1031C
		move.w	#$680,d2
		btst	#6,obStatus(a0)
		beq.s	loc_102AA
		move.w	#$380,d2

loc_102AA:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,jumping(a0)
		clr.b	sticktoconvex(a0)
		move.w	#sfx_Jump,d0
		jsr	(QueueSound2).l
		move.b	#19,obHeight(a0)
		move.b	#9,obWidth(a0)
		btst	#2,obStatus(a0)
		bne.s	loc_1031E
		move.b	#14,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#AniIDSonAni_Roll,obAnim(a0)
		bset	#2,obStatus(a0)
		addq.w	#5,obY(a0)

locret_1031C:
		rts
; ---------------------------------------------------------------------------

loc_1031E:
		bset	#4,obStatus(a0)
		rts
; End of function Sonic_Jump


; =============== S U B	R O U T	I N E =======================================


Sonic_JumpHeight:
		tst.b	jumping(a0)
		beq.s	loc_10352
		move.w	#-$400,d1
		btst	#6,obStatus(a0)
		beq.s	loc_1033C
		move.w	#-$200,d1

loc_1033C:
		cmp.w	obVelY(a0),d1
		ble.s	locret_10350
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0
		bne.s	locret_10350
		move.w	d1,obVelY(a0)

locret_10350:
		rts
; ---------------------------------------------------------------------------

loc_10352:
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	locret_10360
		move.w	#-$FC0,obVelY(a0)

locret_10360:
		rts
; End of function Sonic_JumpHeight

; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash
; ---------------------------------------------------------------------------

; Sonic_Spindash:
Sonic_CheckSpindash:
		tst.b	spindash_flag(a0)
		bne.s	Sonic_UpdateSpindash
		cmpi.b	#AniIDSonAni_Duck,obAnim(a0)
		bne.s	locret_10394
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	locret_10394
		move.b	#AniIDSonAni_Spindash,obAnim(a0)
		move.w	#sfx_Roll,d0
		jsr	(QueueSound2).l
		addq.l	#4,sp
		move.b	#1,spindash_flag(a0)

locret_10394:
		rts
; ===========================================================================
; loc_10396:
Sonic_UpdateSpindash:
		move.b	(v_jpadhold2).w,d0
		btst	#bitDn,d0
		bne.s	Sonic_ChargingSpindash

		; unleash the charged spindash and start rolling quickly:
		move.b	#14,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#AniIDSonAni_Roll,obAnim(a0)
		addq.w	#5,obY(a0)			; add the difference between Sonic's rolling and standing heights
		move.b	#0,spindash_flag(a0)
	if FixBugs
		; To fix a bug in 'ScrollHoriz', we need an extra variable, so this
		; code has been modified to make the delay value only a single byte.
		; This is used by the fixed 'ScrollHoriz'.
		move.b	#$20,(Horiz_scroll_delay_val).w
		; Back up the position array index for later.
		move.b	(Sonic_Pos_Record_Index+1).w,(Horiz_scroll_delay_val+1).w
	else
		move.w	#$2000,(Horiz_scroll_delay_val).w
	endif
		move.w	#$800,obInertia(a0)
		btst	#0,obStatus(a0)
		beq.s	loc_103D4
		neg.w	obInertia(a0)

loc_103D4:
		bset	#2,obStatus(a0)
		rts
; ===========================================================================
; loc_103DC:
Sonic_ChargingSpindash:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	loc_103EA
		nop

loc_103EA:
		addq.l	#4,sp
		rts
; End of function Sonic_CheckSpindash


; =============== S U B	R O U T	I N E =======================================


Sonic_SlopeResist:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bhs.s	locret_10422
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		beq.s	locret_10422
		bmi.s	loc_1041E
		tst.w	d0
		beq.s	locret_1041C
		add.w	d0,obInertia(a0)

locret_1041C:
		rts
; ---------------------------------------------------------------------------

loc_1041E:
		add.w	d0,obInertia(a0)

locret_10422:
		rts
; End of function Sonic_SlopeResist


; =============== S U B	R O U T	I N E =======================================


Sonic_RollRepel:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bhs.s	locret_1045E
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	#$50,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		bmi.s	loc_10454
		tst.w	d0
		bpl.s	loc_1044E
		asr.l	#2,d0

loc_1044E:
		add.w	d0,obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_10454:
		tst.w	d0
		bmi.s	loc_1045A
		asr.l	#2,d0

loc_1045A:
		add.w	d0,obInertia(a0)

locret_1045E:
		rts
; End of function Sonic_RollRepel


; =============== S U B	R O U T	I N E =======================================


Sonic_SlopeRepel:
		nop
		tst.b	sticktoconvex(a0)
		bne.s	locret_1049A
		tst.w	locktime(a0)
		bne.s	loc_1049C
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	locret_1049A
		move.w	obInertia(a0),d0
		bpl.s	loc_10484
		neg.w	d0

loc_10484:
		cmpi.w	#$280,d0
		bhs.s	locret_1049A
		clr.w	obInertia(a0)
		bset	#1,obStatus(a0)
		move.w	#30,locktime(a0)

locret_1049A:
		rts
; ---------------------------------------------------------------------------

loc_1049C:
		subq.w	#1,locktime(a0)
		rts
; End of function Sonic_SlopeRepel


; =============== S U B	R O U T	I N E =======================================


Sonic_JumpAngle:
		move.b	obAngle(a0),d0
		beq.s	loc_104BC
		bpl.s	loc_104B2
		addq.b	#2,d0
		bhs.s	loc_104B0
		moveq	#0,d0

loc_104B0:
		bra.s	loc_104B8
; ---------------------------------------------------------------------------

loc_104B2:
		subq.b	#2,d0
		bhs.s	loc_104B8
		moveq	#0,d0

loc_104B8:
		move.b	d0,obAngle(a0)

loc_104BC:
		move.b	flip_angle(a0),d0
		beq.s	locret_104FA
		tst.w	obInertia(a0)
		bmi.s	loc_104E0
		move.b	flip_speed(a0),d1
		add.b	d1,d0
		bhs.s	loc_104DE
		subq.b	#1,flips_remaining(a0)
		bhs.s	loc_104DE
		move.b	#0,flips_remaining(a0)
		moveq	#0,d0

loc_104DE:
		bra.s	loc_104F6
; ---------------------------------------------------------------------------

loc_104E0:
		move.b	flip_speed(a0),d1
		sub.b	d1,d0
		bhs.s	loc_104F6
		subq.b	#1,flips_remaining(a0)
		bhs.s	loc_104F6
		move.b	#0,flips_remaining(a0)
		moveq	#0,d0

loc_104F6:
		move.b	d0,flip_angle(a0)

locret_104FA:
		rts
; End of function Sonic_JumpAngle


; =============== S U B	R O U T	I N E =======================================

; Sonic_Floor:
Sonic_DoLevelCollision:
		move.l	#v_colladdr1,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	loc_10514
		move.l	#v_colladdr2,(Collision_addr).w

loc_10514:
		move.b	lrb_solid_bit(a0),d5
		move.w	obVelX(a0),d1
		move.w	obVelY(a0),d2
		jsr	(CalcAngle).l
		subi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_105E4
		cmpi.b	#$80,d0
		beq.w	loc_10646
		cmpi.b	#$C0,d0
		beq.w	loc_106A2
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_10558
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_10558:
		bsr.w	sub_132EE
		tst.w	d1
		bpl.s	loc_1056A
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_1056A:
		bsr.w	loc_13146
		tst.w	d1
		bpl.s	locret_105E2
		move.b	obVelY(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	loc_10582
		cmp.b	d2,d0
		blt.s	locret_105E2

loc_10582:
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#AniIDSonAni_Walk,obAnim(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_105C0
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_105B2
		asr.w	obVelY(a0)
		bra.s	loc_105D4
; ---------------------------------------------------------------------------

loc_105B2:
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_105C0:
		move.w	#0,obVelX(a0)
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	loc_105D4
		move.w	#$FC0,obVelY(a0)

loc_105D4:
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_105E2
		neg.w	obInertia(a0)

locret_105E2:
		rts
; ---------------------------------------------------------------------------

loc_105E4:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_105FE
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_105FE:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_10618
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_10616
		move.w	#0,obVelY(a0)

locret_10616:
		rts
; ---------------------------------------------------------------------------

loc_10618:
		tst.w	obVelY(a0)
		bmi.s	locret_10644
		bsr.w	loc_13146
		tst.w	d1
		bpl.s	locret_10644
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#AniIDSonAni_Walk,obAnim(a0)
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_10644:
		rts
; ---------------------------------------------------------------------------

loc_10646:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_10658
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_10658:
		bsr.w	sub_132EE
		tst.w	d1
		bpl.s	loc_1066A
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_1066A:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	locret_106A0
		sub.w	d1,obY(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_1068A
		move.w	#0,obVelY(a0)
		rts
; ---------------------------------------------------------------------------

loc_1068A:
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_106A0
		neg.w	obInertia(a0)

locret_106A0:
		rts
; ---------------------------------------------------------------------------

loc_106A2:
		bsr.w	sub_132EE
		tst.w	d1
		bpl.s	loc_106BC
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts
; ---------------------------------------------------------------------------

loc_106BC:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_106D6
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_106D4
		move.w	#0,obVelY(a0)

locret_106D4:
		rts
; ---------------------------------------------------------------------------

loc_106D6:
		tst.w	obVelY(a0)
		bmi.s	locret_10702
		bsr.w	loc_13146
		tst.w	d1
		bpl.s	locret_10702
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#AniIDSonAni_Walk,obAnim(a0)
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_10702:
		rts
; End of function Sonic_DoLevelCollision


; =============== S U B	R O U T	I N E =======================================


Sonic_ResetOnFloor:
		btst	#4,obStatus(a0)
		beq.s	loc_10712
		nop
		nop
		nop

loc_10712:
		bclr	#5,obStatus(a0)
		bclr	#1,obStatus(a0)
		bclr	#4,obStatus(a0)
		btst	#2,obStatus(a0)
		beq.s	loc_10748
		bclr	#2,obStatus(a0)
		move.b	#19,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#AniIDSonAni_Walk,obAnim(a0)
		subq.w	#5,obY(a0)

loc_10748:
		move.b	#0,jumping(a0)
		move.w	#0,(v_itembonus).w
		move.b	#0,flip_angle(a0)
		rts
; End of function Sonic_ResetOnFloor

; ---------------------------------------------------------------------------

Obj01_Hurt:
		tst.b	ob2ndRout(a0)
		bmi.w	Sonic_HurtInstantRecover
		jsr	(ObjectMove).l
		addi.w	#$30,obVelY(a0)
		btst	#6,obStatus(a0)
		beq.s	loc_1077E
		subi.w	#$20,obVelY(a0)

loc_1077E:
		bsr.w	Sonic_HurtStop
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Animate
		bsr.w	LoadSonicDynPLC
		jmp	(DisplaySprite).l

; =============== S U B	R O U T	I N E =======================================


Sonic_HurtStop:
	if FixBugs
		; a2 needs to be set here, otherwise KillCharacter
		; will access a dangling pointer!
		movea.l	a0,a2
	endif
		move.w	(Camera_Max_Y_pos).w,d0
	if FixBugs
		; The original code does not consider that the camera boundary
		; may be in the middle of lowering itself, which is why going
		; down the S-tunnel in Green Hill Zone Act 1 fast enough can
		; kill Sonic.
		move.w	(Camera_Max_Y_pos_target).w,d1
		cmp.w	d0,d1
		blo.s	.skip
		move.w	d1,d0
.skip:
	endif
		addi.w	#224,d0
		cmp.w	obY(a0),d0
		blo.w	JmpTo_KillCharacter
		bsr.w	Sonic_DoLevelCollision
		btst	#1,obStatus(a0)
		bne.s	locret_107E6
		moveq	#0,d0
		move.w	d0,obVelY(a0)
		move.w	d0,obVelX(a0)
		move.w	d0,obInertia(a0)
		tst.b	ob2ndRout(a0)
		beq.s	loc_107D6
		move.b	#-1,ob2ndRout(a0)
		move.b	#AniIDSonAni_WallRecoil2,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_107D6:
		move.b	#AniIDSonAni_Walk,obAnim(a0)
		subq.b	#2,obRoutine(a0)
		move.w	#120,flashtime(a0)

locret_107E6:
		rts
; End of function Sonic_HurtStop

	if RemoveJmpTos
JmpTo_KillCharacter ; JmpTo
		jmp	(KillCharacter).l
	endif

; ---------------------------------------------------------------------------

Sonic_HurtInstantRecover:
		cmpi.b	#AniIDSonAni_WallRecoil2,obAnim(a0)
		bne.s	loc_107FA
		move.b	(v_jpadpress1).w,d0
		andi.b	#btnUp+btnDn+btnL+btnR+btnABC,d0
		beq.s	loc_10804

loc_107FA:
		subq.b	#2,obRoutine(a0)
		move.b	#0,ob2ndRout(a0)

loc_10804:
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Animate
		bsr.w	LoadSonicDynPLC
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------
; Obj01_Death:
Obj01_Dead:
		bsr.w	Sonic_GameOver
		jsr	(ObjectMoveAndFall).l
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Animate
		bsr.w	LoadSonicDynPLC
		jmp	(DisplaySprite).l

; =============== S U B	R O U T	I N E =======================================


Sonic_GameOver:
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
	if FixBugs
		bge.w	locret_108B4
	else
		bhs.w	locret_108B4
	endif
		move.w	#-$38,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		clr.b	(f_timecount).w
		addq.b	#1,(f_lifecount).w
		subq.b	#1,(v_lives).w
		bne.s	loc_10888
		move.w	#0,restartime(a0)
		move.b	#id_Obj39,(v_gameovertext1).w
		move.b	#id_Obj39,(v_gameovertext2).w
		move.b	#1,(v_gameovertext2+obFrame).w
		clr.b	(f_timeover).w

loc_10876:
		move.w	#bgm_GameOver,d0
		jsr	(QueueSound1).l
		moveq	#plcid_GameOver,d0
		jmp	(LoadPLC).l
; ---------------------------------------------------------------------------

loc_10888:
		move.w	#60,restartime(a0)
		tst.b	(f_timeover).w
		beq.s	locret_108B4
		move.w	#0,restartime(a0)
		move.b	#id_Obj39,(v_gameovertext1).w
		move.b	#id_Obj39,(v_gameovertext2).w
		move.b	#2,(v_gameovertext1+obFrame).w
		move.b	#3,(v_gameovertext2+obFrame).w
		bra.s	loc_10876
; ---------------------------------------------------------------------------

locret_108B4:
		rts
; End of function Sonic_GameOver

; ---------------------------------------------------------------------------

Obj01_ResetLevel:
		tst.w	restartime(a0)
		beq.s	locret_108C8
		subq.w	#1,restartime(a0)
		bne.s	locret_108C8
		move.w	#1,(Level_Inactive_flag).w

locret_108C8:
		rts

; =============== S U B	R O U T	I N E =======================================


Sonic_Animate:
		lea	(SonicAniData).l,a1
		moveq	#0,d0
		move.b	obAnim(a0),d0
		cmp.b	obPrevAni(a0),d0
		beq.s	loc_108EC
		move.b	d0,obPrevAni(a0)
		move.b	#0,obAniFrame(a0)
		move.b	#0,obTimeFrame(a0)
	if FixBugs
		bclr	#5,obStatus(a0)
	endif

loc_108EC:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1
		move.b	(a1),d0
		bmi.s	loc_1095C
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		subq.b	#1,obTimeFrame(a0)
		bpl.s	locret_1092A
		move.b	d0,obTimeFrame(a0)
; End of function Sonic_Animate


; =============== S U B	R O U T	I N E =======================================


sub_10912:
		moveq	#0,d1
		move.b	obAniFrame(a0),d1
		move.b	1(a1,d1.w),d0
		cmpi.b	#$F0,d0
		bhs.s	loc_1092C

loc_10922:
		move.b	d0,obFrame(a0)
		addq.b	#1,obAniFrame(a0)

locret_1092A:
		rts
; ---------------------------------------------------------------------------

loc_1092C:
		addq.b	#1,d0
		bne.s	loc_1093C
		move.b	#0,obAniFrame(a0)
		move.b	1(a1),d0
		bra.s	loc_10922
; ---------------------------------------------------------------------------

loc_1093C:
		addq.b	#1,d0
		bne.s	loc_10950
		move.b	2(a1,d1.w),d0
		sub.b	d0,obAniFrame(a0)
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0
		bra.s	loc_10922
; ---------------------------------------------------------------------------

loc_10950:
		addq.b	#1,d0
		bne.s	locret_1095A
		move.b	2(a1,d1.w),obAnim(a0)

locret_1095A:
		rts
; End of function sub_10912

; ---------------------------------------------------------------------------

loc_1095C:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	locret_1092A
		addq.b	#1,d0
		bne.w	loc_10A44
		moveq	#0,d0
		move.b	flip_angle(a0),d0
		bne.w	loc_109EA
		moveq	#0,d1
		move.b	obAngle(a0),d0
	if FixBugs
		; Fix off-by-one-radian error (this was implemented in S2/S3K)
		ble.s	.notoffbyone				; on a flat surface or ascending slope? if yes, branch
		subq.b	#1,d0					; adjust off-by-one angle on descending slopes
.notoffbyone:
	endif
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	loc_10984
		not.b	d0

loc_10984:
		addi.b	#$10,d0
		bpl.s	loc_1098C
		moveq	#3,d1

loc_1098C:
		andi.b	#$FC,obRender(a0)
		eor.b	d1,d2
		or.b	d2,obRender(a0)
		btst	#5,obStatus(a0)
		bne.w	loc_10A88
		lsr.b	#4,d0
		andi.b	#6,d0
		move.w	obInertia(a0),d2
		bpl.s	loc_109B0
		neg.w	d2

loc_109B0:
		lea	(SonicAni_Run).l,a1
		cmpi.w	#$600,d2
		bhs.s	loc_109C2
		lea	(SonicAni_Walk).l,a1

loc_109C2:
		move.b	d0,d1
		lsr.b	#1,d1
		add.b	d1,d0
		add.b	d0,d0
		add.b	d0,d0
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	loc_109D8
		moveq	#0,d2

loc_109D8:
		lsr.w	#8,d2
		lsr.w	#1,d2
		move.b	d2,obTimeFrame(a0)
		bsr.w	sub_10912
		add.b	d3,obFrame(a0)
		rts
; ---------------------------------------------------------------------------

loc_109EA:
		move.b	flip_angle(a0),d0
		moveq	#0,d1
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	loc_10A1E
		andi.b	#$FC,obRender(a0)
		moveq	#0,d2
		or.b	d2,obRender(a0)
		addi.b	#$B,d0
		divu.w	#$16,d0
		addi.b	#$9B,d0
		move.b	d0,obFrame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ---------------------------------------------------------------------------

loc_10A1E:
		moveq	#3,d2
		andi.b	#$FC,obRender(a0)
		or.b	d2,obRender(a0)
		neg.b	d0
		addi.b	#$8F,d0
		divu.w	#$16,d0
		addi.b	#$9B,d0
		move.b	d0,obFrame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ---------------------------------------------------------------------------

loc_10A44:
		addq.b	#1,d0
		bne.s	loc_10A88
		move.w	obInertia(a0),d2
		bpl.s	loc_10A50
		neg.w	d2

loc_10A50:
		lea	(SonicAni_Roll2).l,a1
		cmpi.w	#$600,d2
		bhs.s	loc_10A62
		lea	(SonicAni_Roll).l,a1

loc_10A62:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	loc_10A6C
		moveq	#0,d2

loc_10A6C:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	sub_10912
; ---------------------------------------------------------------------------

loc_10A88:
		move.w	obInertia(a0),d2
		bmi.s	loc_10A90
		neg.w	d2

loc_10A90:
		addi.w	#$800,d2
		bpl.s	loc_10A98
		moveq	#0,d2

loc_10A98:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0)
		lea	(SonicAni_Push).l,a1
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	sub_10912
; End of function Sonic_Animate
; ===========================================================================
; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
SonicAniData:	dc.w SonicAni_Walk-SonicAniData
		dc.w SonicAni_Run-SonicAniData
		dc.w SonicAni_Roll-SonicAniData
		dc.w SonicAni_Roll2-SonicAniData
		dc.w SonicAni_Push-SonicAniData
		dc.w SonicAni_Wait-SonicAniData
		dc.w SonicAni_Balance-SonicAniData
		dc.w SonicAni_LookUp-SonicAniData
		dc.w SonicAni_Duck-SonicAniData
		dc.w SonicAni_Spindash-SonicAniData
		dc.w SonicAni_WallRecoil1-SonicAniData
		dc.w SonicAni_WallRecoil2-SonicAniData
		dc.w SonicAni_WailRecoil3-SonicAniData
		dc.w SonicAni_Stop-SonicAniData
		dc.w SonicAni_Float1-SonicAniData
		dc.w SonicAni_Float2-SonicAniData
		dc.w SonicAni_Spring-SonicAniData
		dc.w SonicAni_Hang-SonicAniData
		dc.w SonicAni_S1Leap1-SonicAniData
		dc.w SonicAni_S1Leap2-SonicAniData
		dc.w SonicAni_S1Surf-SonicAniData
		dc.w SonicAni_Bubble-SonicAniData
		dc.w SonicAni_Burnt-SonicAniData
		dc.w SonicAni_Drown-SonicAniData
		dc.w SonicAni_Death-SonicAniData
		dc.w SonicAni_S1Shrink-SonicAniData
		dc.w SonicAni_Hurt-SonicAniData
		dc.w SonicAni_WaterSlide-SonicAniData
		dc.w SonicAni_Blank-SonicAniData
		dc.w SonicAni_Float3-SonicAniData
		dc.w SonicAni_S1Float4-SonicAniData
SonicAni_Walk:	dc.b $FF,$10,$11,$12,$13,$14,$15,$16,$17, $C, $D, $E, $F,$FF
SonicAni_Run:	dc.b $FF,$3C,$3D,$3E,$3F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
SonicAni_Roll:	dc.b $FE,$6C,$70,$6D,$70,$6E,$70,$6F,$70,$FF
SonicAni_Roll2:	dc.b $FE,$6C,$70,$6D,$70,$6E,$70,$6F,$70,$FF
SonicAni_Push:	dc.b $FD,$77,$78,$79,$7A,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
SonicAni_Wait:	dc.b   7,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
		dc.b   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  2
		dc.b   3,  3,  3,  4,  4,  5,  5,$FE,  4
SonicAni_Balance:	dc.b	7,$89,$8A,$FF
SonicAni_LookUp:	dc.b   5,  6,  7,$FE,  1
SonicAni_Duck:	dc.b   5,$7F,$80,$FE,  1
SonicAni_Spindash:	dc.b	 0,$71,$72,$71,$73,$71,$74,$71,$75,$71,$76,$71,$FF
SonicAni_WallRecoil1:	dc.b $3F,$82,$FF
SonicAni_WallRecoil2:	dc.b   7, 8, 8, 9,$FD,	5
SonicAni_WailRecoil3:	dc.b   7,  9,$FD,  5
SonicAni_Stop:	dc.b   3,$81,$82,$83,$84,$85,$86,$87,$88,$FE,  2
SonicAni_Float1:	dc.b   7,$94,$96,$FF
SonicAni_Float2:	dc.b   7,$91,$92,$93,$94,$95,$FF
SonicAni_Spring:	dc.b $2F,$7E,$FD,  0
SonicAni_Hang:	dc.b	 5,$8F,$90,$FF
SonicAni_S1Leap1:	dc.b	$F,$43,$43,$43,$FE,  1
SonicAni_S1Leap2:	dc.b	$F,$43,$44,$FE,	 1
SonicAni_S1Surf:	dc.b $3F,$49,$FF
SonicAni_Bubble:	dc.b  $B,$97,$97,$12,$13,$FD,  0
SonicAni_Burnt:	dc.b $20,$9A,$FF
SonicAni_Drown:	dc.b $20,$99,$FF
SonicAni_Death:	dc.b $20,$98,$FF
SonicAni_S1Shrink:	dc.b	 3,$4E,$4F,$50,$51,$52,	 0,$FE,	 1
SonicAni_Hurt:	dc.b $40,$8D,$FF
SonicAni_WaterSlide:	dc.b	  9,$8D,$8E,$FF
SonicAni_Blank:	dc.b $77,  0,$FD,  0
SonicAni_Float3:	dc.b   3,$91,$92,$93,$94,$95,$FF
SonicAni_S1Float4:	dc.b   3,$3C,$FD,  0
		even

; ---------------------------------------------------------------------------
; Sonic pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


LoadSonicDynPLC:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		cmp.b	(Sonic_LastLoadedDPLC).w,d0
		beq.s	locret_10C34
		move.b	d0,(Sonic_LastLoadedDPLC).w
		lea	(SonicDynPLC).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	locret_10C34
		move.w	#tiles_to_bytes(ArtTile_Sonic),d4
; loc_10C08:
SPLC_ReadEntry:
		moveq	#0,d1
		move.w	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		addi.l	#Art_Sonic,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,SPLC_ReadEntry

locret_10C34:
		rts
; End of function LoadSonicDynPLC