;----------------------------------------------------
; Object 03 - collision	index switcher (in loops)
;----------------------------------------------------

Obj03:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj03_Index(pc,d0.w),d1
		jsr	Obj03_Index(pc,d1.w)
		tst.w	(Debug_mode_flag).w
		beq.w	MarkObjGone2
		jmp	(MarkObjGone).l
; ---------------------------------------------------------------------------
Obj03_Index:	dc.w Obj03_Init-Obj03_Index
		dc.w loc_13EB4-Obj03_Index
		dc.w loc_13FB6-Obj03_Index
; ---------------------------------------------------------------------------

Obj03_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Obj03,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ring,1,0),obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#16,obActWid(a0)
		move.b	#5,obPriority(a0)
		move.b	obSubtype(a0),d0
		btst	#2,d0
		beq.s	loc_13EA4
		addq.b	#2,obRoutine(a0)
		andi.w	#7,d0
		move.b	d0,obFrame(a0)
		andi.w	#(Obj03_Data_End-Obj03_Data)/2-1,d0
		add.w	d0,d0
		move.w	Obj03_Data(pc,d0.w),objoff_32(a0)
		bra.w	loc_13FB6
; ---------------------------------------------------------------------------
Obj03_Data:
		dc.w $20
		dc.w $40
		dc.w $80
		dc.w $100
Obj03_Data_End:
; ---------------------------------------------------------------------------

loc_13EA4:
		andi.w	#(Obj03_Data_End-Obj03_Data)/2-1,d0
		move.b	d0,obFrame(a0)
		add.w	d0,d0
		move.w	Obj03_Data(pc,d0.w),objoff_32(a0)

loc_13EB4:
		tst.w	(Debug_placement_mode).w
		bne.w	locret_13FB4
		move.w	objoff_30(a0),d5
		move.w	obX(a0),d0
		move.w	d0,d1
		subq.w	#8,d0
		addq.w	#8,d1
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		lea	(Collision_Switch_Players).l,a2
		moveq	#(Collision_Switch_Players_End-Collision_Switch_Players)/4-1,d6

loc_13EE0:
		move.l	(a2)+,d4
		beq.w	loc_13FA8
		movea.l	d4,a1
		move.w	obX(a1),d4
		cmp.w	d0,d4
		blo.w	loc_13F10
		cmp.w	d1,d4
		bhs.w	loc_13F10
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blo.w	loc_13F10
		cmp.w	d3,d4
		bhs.w	loc_13F10
		ori.w	#$8000,d5
		bra.w	loc_13FA8
; ---------------------------------------------------------------------------

loc_13F10:
		tst.w	d5
		bpl.w	loc_13FA8
		swap	d0
		move.b	obSubtype(a0),d0
		bpl.s	loc_13F26
		btst	#1,obStatus(a1)
		bne.s	loc_13FA2

loc_13F26:
		move.w	obX(a1),d4
		cmp.w	obX(a0),d4
		blo.s	loc_13F62
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)
		btst	#3,d0
		beq.s	loc_13F4E
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_13F4E:
		bclr	#7,obGfx(a1)
		btst	#5,d0
		beq.s	loc_13F92
		bset	#7,obGfx(a1)
		bra.s	loc_13F92
; ---------------------------------------------------------------------------

loc_13F62:
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)
		btst	#4,d0
		beq.s	loc_13F80
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_13F80:
		bclr	#7,obGfx(a1)
		btst	#6,d0
		beq.s	loc_13F92
		bset	#7,obGfx(a1)

loc_13F92:
		tst.w	(Debug_mode_flag).w
		beq.s	loc_13FA2
		move.w	#sfx_Lamppost,d0
		jsr	(QueueSound2).l

loc_13FA2:
		swap	d0
		andi.w	#$7FFF,d5

loc_13FA8:
		add.l	d5,d5
		dbf	d6,loc_13EE0
		swap	d5
		move.b	d5,objoff_30(a0)

locret_13FB4:
		rts
; ---------------------------------------------------------------------------

loc_13FB6:
		tst.w	(Debug_placement_mode).w
		bne.w	locret_140B6
		move.w	objoff_30(a0),d5
		move.w	obX(a0),d0
		move.w	d0,d1
		move.w	objoff_32(a0),d4
		sub.w	d4,d0
		add.w	d4,d1
		move.w	obY(a0),d2
		move.w	d2,d3
		subq.w	#8,d2
		addq.w	#8,d3
		lea	(Collision_Switch_Players).l,a2
		moveq	#(Collision_Switch_Players_End-Collision_Switch_Players)/4-1,d6

loc_13FE2:
		move.l	(a2)+,d4
		beq.w	loc_140AA
		movea.l	d4,a1
		move.w	obX(a1),d4
		cmp.w	d0,d4
		blo.w	loc_14012
		cmp.w	d1,d4
		bhs.w	loc_14012
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blo.w	loc_14012
		cmp.w	d3,d4
		bhs.w	loc_14012
		ori.w	#$8000,d5
		bra.w	loc_140AA
; ---------------------------------------------------------------------------

loc_14012:
		tst.w	d5
		bpl.w	loc_140AA
		swap	d0
		move.b	obSubtype(a0),d0
		bpl.s	loc_14028
		btst	#1,obStatus(a1)
		bne.s	loc_140A4

loc_14028:
		move.w	obY(a1),d4
		cmp.w	obY(a0),d4
		blo.s	loc_14064
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)
		btst	#3,d0
		beq.s	loc_14050
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_14050:
		bclr	#7,obGfx(a1)
		btst	#5,d0
		beq.s	loc_14094
		bset	#7,obGfx(a1)
		bra.s	loc_14094
; ---------------------------------------------------------------------------

loc_14064:
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)
		btst	#4,d0
		beq.s	loc_14082
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_14082:
		bclr	#7,obGfx(a1)
		btst	#6,d0
		beq.s	loc_14094
		bset	#7,obGfx(a1)

loc_14094:
		tst.w	(Debug_mode_flag).w
		beq.s	loc_140A4
		move.w	#sfx_Lamppost,d0
		jsr	(QueueSound2).l

loc_140A4:
		swap	d0
		andi.w	#$7FFF,d5

loc_140AA:
		add.l	d5,d5
		dbf	d6,loc_13FE2
		swap	d5
		move.b	d5,objoff_30(a0)

locret_140B6:
		rts
; ---------------------------------------------------------------------------
Collision_Switch_Players:
		dc.l v_player
		dc.l v_player2
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
Collision_Switch_Players_End: