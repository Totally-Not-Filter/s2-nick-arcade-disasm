; ---------------------------------------------------------------------------
; Object 1F - Crabmeat enemy (GHZ, SYZ)
; ---------------------------------------------------------------------------

Obj1F:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Crab_Index(pc,d0.w),d1
		jmp	Crab_Index(pc,d1.w)
; ===========================================================================
Crab_Index:
ptr_Crab_Main:		dc.w Crab_Main-Crab_Index
ptr_Crab_Action:	dc.w Crab_Action-Crab_Index
ptr_Crab_Delete:	dc.w Crab_Delete-Crab_Index
ptr_Crab_BallMain:	dc.w Crab_BallMain-Crab_Index
ptr_Crab_BallMove:	dc.w Crab_BallMove-Crab_Index

id_Crab_Main = ptr_Crab_Main-Crab_Index	; 0
id_Crab_Action = ptr_Crab_Action-Crab_Index	; 2
id_Crab_Delete = ptr_Crab_Delete-Crab_Index	; 4
id_Crab_BallMain = ptr_Crab_BallMain-Crab_Index	; 6
id_Crab_BallMove = ptr_Crab_BallMove-Crab_Index	; 8

crab_timedelay = objoff_30
crab_mode = objoff_32
; ===========================================================================

Crab_Main:	; Routine 0
		move.b	#$10,obHeight(a0)
		move.b	#8,obWidth(a0)
		move.l	#Map_obj1F,obMap(a0)
		move.w	#make_art_tile(ArtTile_Crabmeat,0,0),obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#6,obColType(a0)
		move.b	#$15,obActWid(a0)
		bsr.w	ObjectMoveAndFall
		jsr	(ObjHitFloor).l	; find floor
		tst.w	d1
		bpl.s	.floornotfound
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0)

.floornotfound:
		rts
; ===========================================================================

Crab_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	.index(pc,d0.w),d1
		jsr	.index(pc,d1.w)
		lea	(Ani_obj1F).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
.index:		dc.w .waittofire-.index
		dc.w .walkonfloor-.index
; ===========================================================================

.waittofire:
		subq.w	#1,crab_timedelay(a0) ; subtract 1 from time delay
		bpl.s	.dontmove
		tst.b	obRender(a0)
		bpl.s	.movecrab
		bchg	#1,crab_mode(a0)
		bne.s	.fire

.movecrab:
		addq.b	#2,ob2ndRout(a0)
		move.w	#127,crab_timedelay(a0) ; set time delay to approx 2 seconds
		move.w	#$80,obVelX(a0)	; move Crabmeat	to the right
		bsr.w	Crab_SetAni
		addq.b	#3,d0
		move.b	d0,obAnim(a0)
		bchg	#0,obStatus(a0)
		bne.s	.noflip
		neg.w	obVelX(a0)	; change direction

.dontmove:
.noflip:
		rts
; ===========================================================================

.fire:
		move.w	#59,crab_timedelay(a0)
		move.b	#6,obAnim(a0)	; use firing animation
		bsr.w	FindFreeObj
		bne.s	.failleft
		_move.b	#id_Obj1F,obID(a1) ; load left fireball
		move.b	#id_Crab_BallMain,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		subi.w	#$10,obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#-$100,obVelX(a1)

.failleft:
		bsr.w	FindFreeObj
		bne.s	.failright
		_move.b	#id_Obj1F,obID(a1) ; load right fireball
		move.b	#id_Crab_BallMain,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		addi.w	#$10,obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$100,obVelX(a1)

.failright:
		rts
; ===========================================================================

.walkonfloor:
		subq.w	#1,crab_timedelay(a0)
		bmi.s	loc_966E
		bsr.w	ObjectMove
		bchg	#0,crab_mode(a0)
		bne.s	loc_9654
		move.w	obX(a0),d3
		addi.w	#$10,d3
		btst	#0,obStatus(a0)
		beq.s	loc_9640
		subi.w	#$20,d3

loc_9640:
		jsr	(ObjHitFloor2).l
		cmpi.w	#-8,d1
		blt.s	loc_966E
		cmpi.w	#$C,d1
		bge.s	loc_966E
		rts
; ===========================================================================

loc_9654:
		jsr	(ObjHitFloor).l
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Crab_SetAni
		addq.b	#3,d0
		move.b	d0,obAnim(a0)
		rts
; ===========================================================================

loc_966E:
		subq.b	#2,ob2ndRout(a0)
		move.w	#59,crab_timedelay(a0)
		move.w	#0,obVelX(a0)
		bsr.w	Crab_SetAni
		move.b	d0,obAnim(a0)
		rts
; ---------------------------------------------------------------------------
; Subroutine to	set the	correct	animation for a	Crabmeat
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Crab_SetAni:
		moveq	#0,d0
		move.b	obAngle(a0),d3
		bmi.s	loc_96A4
		cmpi.b	#6,d3
		blo.s	locret_96A2
		moveq	#1,d0
		btst	#0,obStatus(a0)
		bne.s	locret_96A2
		moveq	#2,d0

locret_96A2:
		rts
; ===========================================================================

loc_96A4:
		cmpi.b	#-6,d3
		bhi.s	locret_96B6
		moveq	#2,d0
		btst	#0,obStatus(a0)
		bne.s	locret_96B6
		moveq	#1,d0

locret_96B6:
		rts
; End of function Crab_SetAni

; ===========================================================================

Crab_Delete:	; Routine 4
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Sub-object - missile that the	Crabmeat throws
; ---------------------------------------------------------------------------

Crab_BallMain:	; Routine 6
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj1F,obMap(a0)
		move.w	#make_art_tile(ArtTile_Crabmeat,0,0),obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#$87,obColType(a0)
		move.b	#8,obActWid(a0)
		move.w	#-$400,obVelY(a0)
		move.b	#7,obAnim(a0)

Crab_BallMove:	; Routine 8
		lea	(Ani_obj1F).l,a1
		bsr.w	AnimateSprite
		bsr.w	ObjectMoveAndFall
		move.w	(Camera_Max_Y_pos).w,d0
		addi.w	#224,d0
		cmp.w	obY(a0),d0
		blo.w	DeleteObject
		bra.w	DisplaySprite