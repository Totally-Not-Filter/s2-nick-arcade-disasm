; ---------------------------------------------------------------------------
; Object 14 - HTZ see-saw
; ---------------------------------------------------------------------------

Obj14:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj14_Index(pc,d0.w),d1
		jsr	Obj14_Index(pc,d1.w)
		out_of_range.w	DeleteObject,objoff_30(a0)
	if FixBugs
		jmp	(DisplaySprite).l
	else
		bra.w	DisplaySprite
	endif
; ---------------------------------------------------------------------------
Obj14_Index:	dc.w loc_14CD2-Obj14_Index
		dc.w loc_14D40-Obj14_Index
		dc.w locret_14DF2-Obj14_Index
		dc.w loc_14E3C-Obj14_Index
		dc.w loc_14E9C-Obj14_Index
		dc.w loc_14F30-Obj14_Index
; ---------------------------------------------------------------------------

loc_14CD2:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj14,obMap(a0)
		move.w	#make_art_tile(ArtTile_HTZ_Seesaw,0,0),obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#48,obActWid(a0)
		move.w	obX(a0),objoff_30(a0)
		tst.b	obSubtype(a0)
		bne.s	loc_14D2C
		bsr.w	FindNextFreeObj
		bne.s	loc_14D2C
		_move.b	#id_Obj14,obID(a1)
		addq.b	#6,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.l	a0,objoff_3C(a1)

loc_14D2C:
		btst	#0,obStatus(a0)
		beq.s	loc_14D3A
		move.b	#2,obFrame(a0)

loc_14D3A:
		move.b	obFrame(a0),objoff_3A(a0)

loc_14D40:
		move.b	objoff_3A(a0),d1
		btst	#3,obStatus(a0)
		beq.s	loc_14D9A
		moveq	#2,d1
		lea	(v_player).w,a1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bhs.s	loc_14D60
		neg.w	d0
		moveq	#0,d1

loc_14D60:
		cmpi.w	#8,d0
		bhs.s	loc_14D68
		moveq	#1,d1

loc_14D68:
		btst	#4,obStatus(a0)
		beq.s	loc_14DBE
		moveq	#2,d2
		lea	(v_player2).w,a1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bhs.s	loc_14D84
		neg.w	d0
		moveq	#0,d2

loc_14D84:
		cmpi.w	#8,d0
		bhs.s	loc_14D8C
		moveq	#1,d2

loc_14D8C:
		add.w	d2,d1
		cmpi.w	#3,d1
		bne.s	loc_14D96
		addq.w	#1,d1

loc_14D96:
		lsr.w	#1,d1
		bra.s	loc_14DBE
; ---------------------------------------------------------------------------

loc_14D9A:
		btst	#4,obStatus(a0)
		beq.s	loc_14DBE
		moveq	#2,d1
		lea	(v_player2).w,a1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bhs.s	loc_14DB6
		neg.w	d0
		moveq	#0,d1

loc_14DB6:
		cmpi.w	#8,d0
		bhs.s	loc_14DBE
		moveq	#1,d1

loc_14DBE:
		bsr.w	sub_14E10
		lea	(byte_14FFE).l,a2
		btst	#0,obFrame(a0)
		beq.s	loc_14DD6
		lea	(byte_1502F).l,a2

loc_14DD6:
		lea	(v_player).w,a1
		move.w	obVelY(a1),objoff_38(a0)
		move.w	obX(a0),-(sp)
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#8,d3
		move.w	(sp)+,d4
		bra.w	sub_F7DC
; ---------------------------------------------------------------------------

locret_14DF2:
		rts
; ---------------------------------------------------------------------------
		moveq	#2,d1
		lea	(v_player).w,a1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bhs.s	loc_14E08
		neg.w	d0
		moveq	#0,d1

loc_14E08:
		cmpi.w	#8,d0
		bhs.s	sub_14E10
		moveq	#1,d1

; =============== S U B	R O U T	I N E =======================================


sub_14E10:
		move.b	obFrame(a0),d0
		cmp.b	d1,d0
		beq.s	locret_14E3A
		bhs.s	loc_14E1C
		addq.b	#2,d0

loc_14E1C:
		subq.b	#1,d0
		move.b	d0,obFrame(a0)
		move.b	d1,objoff_3A(a0)
		bclr	#0,obRender(a0)
		btst	#1,obFrame(a0)
		beq.s	locret_14E3A
		bset	#0,obRender(a0)

locret_14E3A:
		rts
; End of function sub_14E10

; ---------------------------------------------------------------------------

loc_14E3C:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj14b,obMap(a0)
		move.w	#make_art_tile(ArtTile_HTZ_Seesaw,0,0),obGfx(a0)
		bsr.w	Adjust2PArtPointer
		ori.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#$8B,obColType(a0)
		move.b	#12,obActWid(a0)
		move.w	obX(a0),objoff_30(a0)
		addi.w	#$28,obX(a0)
		addi.w	#$10,obY(a0)
		move.w	obY(a0),objoff_34(a0)
		move.b	#1,obFrame(a0)
		btst	#0,obStatus(a0)
		beq.s	loc_14E9C
		subi.w	#$50,obX(a0)
		move.b	#2,objoff_3A(a0)

loc_14E9C:
		movea.l	objoff_3C(a0),a1
		moveq	#0,d0
		move.b	objoff_3A(a0),d0
		sub.b	objoff_3A(a1),d0
		beq.s	loc_14EF2
		bhs.s	loc_14EB0
		neg.b	d0

loc_14EB0:
		move.w	#-$818,d1
		move.w	#-$114,d2
		cmpi.b	#1,d0
		beq.s	loc_14ED6
		move.w	#-$AF0,d1
		move.w	#-$CC,d2
		cmpi.w	#$A00,objoff_38(a1)
		blt.s	loc_14ED6
		move.w	#-$E00,d1
		move.w	#-$A0,d2

loc_14ED6:
		move.w	d1,obVelY(a0)
		move.w	d2,obVelX(a0)
		move.w	obX(a0),d0
		sub.w	objoff_30(a0),d0
		bhs.s	loc_14EEC
		neg.w	obVelX(a0)

loc_14EEC:
		addq.b	#2,obRoutine(a0)
		bra.s	loc_14F30
; ---------------------------------------------------------------------------

loc_14EF2:
		lea	(word_14FF4).l,a2
		moveq	#0,d0
		move.b	obFrame(a1),d0
		move.w	#$28,d2
		move.w	obX(a0),d1
		sub.w	objoff_30(a0),d1
		bhs.s	loc_14F10
		neg.w	d2
		addq.w	#2,d0

loc_14F10:
		add.w	d0,d0
		move.w	objoff_34(a0),d1
		add.w	(a2,d0.w),d1
		move.w	d1,obY(a0)
		add.w	objoff_30(a0),d2
		move.w	d2,obX(a0)
		clr.w	obY+2(a0)
		clr.w	obX+2(a0)
		rts
; ---------------------------------------------------------------------------

loc_14F30:
		tst.w	obVelY(a0)
		bpl.s	loc_14F4E
		jsrto	JmpTo_ObjectMoveAndFall
		move.w	objoff_34(a0),d0
		subi.w	#$2F,d0
		cmp.w	obY(a0),d0
		bgt.s	locret_14F4C
		jsrto	JmpTo_ObjectMoveAndFall

locret_14F4C:
		rts
; ---------------------------------------------------------------------------

loc_14F4E:
		jsrto	JmpTo_ObjectMoveAndFall
		movea.l	objoff_3C(a0),a1
		lea	(word_14FF4).l,a2
		moveq	#0,d0
		move.b	obFrame(a1),d0
		move.w	obX(a0),d1
		sub.w	objoff_30(a0),d1
		bhs.s	loc_14F6E
		addq.w	#2,d0

loc_14F6E:
		add.w	d0,d0
		move.w	objoff_34(a0),d1
		add.w	(a2,d0.w),d1
		cmp.w	obY(a0),d1
		bgt.s	locret_14FC2
		movea.l	objoff_3C(a0),a1
		moveq	#2,d1
		tst.w	obVelX(a0)
		bmi.s	loc_14F8C
		moveq	#0,d1

loc_14F8C:
		move.b	d1,objoff_3A(a1)
		move.b	d1,objoff_3A(a0)
		cmp.b	obFrame(a1),d1
		beq.s	loc_14FB6
		lea	(v_player).w,a2
		bclr	#3,obStatus(a1)
		beq.s	loc_14FA8
		bsr.s	sub_14FC4

loc_14FA8:
		lea	(v_player2).w,a2
		bclr	#4,obStatus(a1)
		beq.s	loc_14FB6
		bsr.s	sub_14FC4

loc_14FB6:
		clr.w	obVelX(a0)
		clr.w	obVelY(a0)
		subq.b	#2,obRoutine(a0)

locret_14FC2:
		rts

; =============== S U B	R O U T	I N E =======================================


sub_14FC4:
		move.w	obVelY(a0),obVelY(a2)
		neg.w	obVelY(a2)
		bset	#1,obStatus(a2)
		bclr	#3,obStatus(a2)
		clr.b	jumping(a2)
		move.b	#AniIDSonAni_Spring,obAnim(a2)
		move.b	#2,obRoutine(a2)
		move.w	#sfx_Spring,d0
		jmp	(QueueSound2).l
; End of function sub_14FC4