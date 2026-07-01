;----------------------------------------------------
; Object 11 - Bridge
;----------------------------------------------------

Obj11:
		btst	#6,obRender(a0)
		bne.w	loc_7BB8
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj11_Index(pc,d0.w),d1
		jmp	Obj11_Index(pc,d1.w)
; ---------------------------------------------------------------------------

loc_7BB8:
		moveq	#3,d0
		bra.w	DisplaySprite3
; ---------------------------------------------------------------------------
Obj11_Index:	dc.w loc_7BC6-Obj11_Index
		dc.w loc_7CC8-Obj11_Index
		dc.w loc_7D5A-Obj11_Index
		dc.w loc_7D5E-Obj11_Index
; ---------------------------------------------------------------------------

loc_7BC6:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj11_GHZ,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Bridge,2,0),obGfx(a0)
		move.b	#3,obPriority(a0)
		cmpi.b	#id_EHZ,(Current_Zone).w
		bne.s	loc_7BFA
		move.l	#Map_obj11_EHZ,obMap(a0)
		move.w	#make_art_tile(ArtTile_EHZ_Bridge,2,0),obGfx(a0)
		move.b	#3,obPriority(a0)

loc_7BFA:
		cmpi.b	#id_HPZ,(Current_Zone).w
		bne.s	loc_7C14
		addq.b	#4,obRoutine(a0)
		move.l	#Map_obj11_HPZ,obMap(a0)
		move.w	#make_art_tile(ArtTile_HPZ_Bridge,3,0),obGfx(a0)

loc_7C14:
		bsr.w	Adjust2PArtPointer
		move.b	#4,obRender(a0)
		move.b	#128,obActWid(a0)
		move.w	obY(a0),d2
		move.w	d2,objoff_3C(a0)
		move.w	obX(a0),d3
		lea	obSubtype(a0),a2
		moveq	#0,d1
		move.b	(a2),d1
		move.w	d1,d0
		lsr.w	#1,d0
		lsl.w	#4,d0
		sub.w	d0,d3
		swap	d1
		move.w	#8,d1
		bsr.s	sub_7C76
		move.w	obSubtype(a1),d0
		subq.w	#8,d0
		move.w	d0,obX(a1)
		move.l	a1,objoff_30(a0)
		swap	d1
		subq.w	#8,d1
		bls.s	loc_7C74
		move.w	d1,d4
		bsr.s	sub_7C76
		move.l	a1,objoff_34(a0)
		move.w	d4,d0
		add.w	d0,d0
		add.w	d4,d0
		move.w	sub2_x_pos(a1,d0.w),d0
		subq.w	#8,d0
		move.w	d0,obX(a1)

loc_7C74:
		bra.s	loc_7CC8

; =============== S U B	R O U T	I N E =======================================


sub_7C76:
		bsr.w	FindNextFreeObj
		bne.s	locret_7CC6
		_move.b	obID(a0),obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		bset	#6,obRender(a1)
		move.b	#64,mainspr_width(a1)
		move.b	d1,mainspr_childsprites(a1)
		subq.b	#1,d1
		lea	subspr_data(a1),a2

loc_7CB6:
		move.w	d3,(a2)+
		move.w	d2,(a2)+
		move.w	#0,(a2)+
		addi.w	#$10,d3
		dbf	d1,loc_7CB6

locret_7CC6:
		rts
; End of function sub_7C76

; ---------------------------------------------------------------------------

loc_7CC8:
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		bne.s	loc_7CDE
		tst.b	objoff_3E(a0)
		beq.s	loc_7D0A
		subq.b	#4,objoff_3E(a0)
		bra.s	loc_7D06
; ---------------------------------------------------------------------------

loc_7CDE:
		andi.b	#$10,d0
		beq.s	loc_7CFA
		move.b	objoff_3F(a0),d0
		sub.b	objoff_3B(a0),d0
		beq.s	loc_7CFA
		bhs.s	loc_7CF6
		addq.b	#1,objoff_3F(a0)
		bra.s	loc_7CFA
; ---------------------------------------------------------------------------

loc_7CF6:
		subq.b	#1,objoff_3F(a0)

loc_7CFA:
		cmpi.b	#$40,objoff_3E(a0)
		beq.s	loc_7D06
		addq.b	#4,objoff_3E(a0)

loc_7D06:
		bsr.w	sub_7F36

loc_7D0A:
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1
		add.w	d2,d2
		moveq	#8,d3
		move.w	obX(a0),d4
		bsr.w	sub_7DC0

loc_7D22:
		tst.w	(Two_player_mode).w
		beq.s	loc_7D2A
		rts
; ---------------------------------------------------------------------------

loc_7D2A:
		out_of_range.s	loc_7D3E
		rts
; ---------------------------------------------------------------------------

loc_7D3E:
		movea.l	objoff_30(a0),a1
		bsr.w	DeleteChild
		cmpi.b	#8,obSubtype(a0)
		bls.s	loc_7D56
		movea.l	objoff_34(a0),a1
		bsr.w	DeleteChild

loc_7D56:
		bra.w	DeleteObject
; ---------------------------------------------------------------------------

loc_7D5A:
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------

loc_7D5E:
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		bne.s	loc_7D74
		tst.b	objoff_3E(a0)
		beq.s	loc_7DA0
		subq.b	#4,objoff_3E(a0)
		bra.s	loc_7D9C
; ---------------------------------------------------------------------------

loc_7D74:
		andi.b	#$10,d0
		beq.s	loc_7D90
		move.b	objoff_3F(a0),d0
		sub.b	objoff_3B(a0),d0
		beq.s	loc_7D90
		bhs.s	loc_7D8C
		addq.b	#1,objoff_3F(a0)
		bra.s	loc_7D90
; ---------------------------------------------------------------------------

loc_7D8C:
		subq.b	#1,objoff_3F(a0)

loc_7D90:
		cmpi.b	#$40,objoff_3E(a0)
		beq.s	loc_7D9C
		addq.b	#4,objoff_3E(a0)

loc_7D9C:
		bsr.w	sub_7F36

loc_7DA0:
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1
		add.w	d2,d2
		moveq	#8,d3
		move.w	obX(a0),d4
		bsr.w	sub_7DC0
		bsr.w	sub_7E60
		bra.w	loc_7D22

; =============== S U B	R O U T	I N E =======================================


sub_7DC0:
		lea	(v_player2).w,a1
		moveq	#4,d6
		moveq	#$3B,d5
		movem.l	d1-d4,-(sp)
		bsr.s	sub_7DDA
		movem.l	(sp)+,d1-d4
		lea	(v_player).w,a1
		subq.b	#1,d6
		moveq	#$3F,d5
; End of function sub_7DC0


; =============== S U B	R O U T	I N E =======================================


sub_7DDA:
		btst	d6,obStatus(a0)
		beq.s	loc_7E3E
		btst	#1,obStatus(a1)
		bne.s	loc_7DFA
		moveq	#0,d0
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_7DFA
		cmp.w	d2,d0
		blo.s	loc_7E08

loc_7DFA:
		bclr	#3,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_7E08:
		lsr.w	#4,d0
		move.b	d0,(a0,d5.w)
		movea.l	objoff_30(a0),a2
		cmpi.w	#8,d0
		blo.s	loc_7E20
		movea.l	objoff_34(a0),a2
		subi.w	#8,d0

loc_7E20:
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	sub2_y_pos(a2,d0.w),d0
		subq.w	#8,d0
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_7E3E:
		move.w	d1,-(sp)
		bsr.w	sub_F880
		move.w	(sp)+,d1
		btst	d6,obStatus(a0)
		beq.s	locret_7E5E
		moveq	#0,d0
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		lsr.w	#4,d0
		move.b	d0,(a0,d5.w)

locret_7E5E:
		rts
; End of function sub_7DDA


; =============== S U B	R O U T	I N E =======================================


sub_7E60:
		moveq	#0,d0
		tst.w	(v_player+obVelX).w
		bne.s	loc_7E72
		move.b	(Vint_runcount+3).w,d0
		andi.w	#$1C,d0
		lsr.w	#1,d0

loc_7E72:
		moveq	#0,d2
		move.b	byte_7E9E+1(pc,d0.w),d2
		swap	d2
		move.b	byte_7E9E(pc,d0.w),d2
		moveq	#0,d0
		tst.w	(v_player2+obVelX).w
		bne.s	loc_7E90
		move.b	(Vint_runcount+3).w,d0
		andi.w	#$1C,d0
		lsr.w	#1,d0

loc_7E90:
		moveq	#0,d6
		move.b	byte_7E9E+1(pc,d0.w),d6
		swap	d6
		move.b	byte_7E9E(pc,d0.w),d6
		bra.s	loc_7EAE
; ---------------------------------------------------------------------------
byte_7E9E:
		dc.b 1,  2,  1,  2,  1,  2,  1,  2,  0,  1,  0,  0,  0,  0,  0,  1
		even
; ---------------------------------------------------------------------------

loc_7EAE:
		moveq	#-2,d3
		moveq	#-2,d4
		move.b	obStatus(a0),d0
		andi.b	#8,d0
		beq.s	loc_7EC0
		move.b	objoff_3F(a0),d3

loc_7EC0:
		move.b	obStatus(a0),d0
		andi.b	#$10,d0
		beq.s	loc_7ECE
		move.b	objoff_3B(a0),d4

loc_7ECE:
		movea.l	objoff_30(a0),a1
		lea	sub9_mapframe+next_subspr(a1),a2
		lea	sub2_mapframe(a1),a1
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		subq.b	#1,d1
		moveq	#0,d5

loc_7EE4:
		moveq	#0,d0
		subq.w	#1,d3
		cmp.b	d3,d5
		bne.s	loc_7EEE
		move.w	d2,d0

loc_7EEE:
		addq.w	#2,d3
		cmp.b	d3,d5
		bne.s	loc_7EF6
		move.w	d2,d0

loc_7EF6:
		subq.w	#1,d3
		subq.w	#1,d4
		cmp.b	d4,d5
		bne.s	loc_7F00
		move.w	d6,d0

loc_7F00:
		addq.w	#2,d4
		cmp.b	d4,d5
		bne.s	loc_7F08
		move.w	d6,d0

loc_7F08:
		subq.w	#1,d4
		cmp.b	d3,d5
		bne.s	loc_7F14
		swap	d2
		move.w	d2,d0
		swap	d2

loc_7F14:
		cmp.b	d4,d5
		bne.s	loc_7F1E
		swap	d6
		move.w	d6,d0
		swap	d6

loc_7F1E:
		move.b	d0,(a1)
		addq.w	#1,d5
		addq.w	#6,a1
		cmpa.w	a2,a1
		bne.s	loc_7F30
		movea.l	objoff_34(a0),a1
		lea	sub2_mapframe(a1),a1

loc_7F30:
		dbf	d1,loc_7EE4
		rts
; End of function sub_7E60


; =============== S U B	R O U T	I N E =======================================


sub_7F36:
		move.b	objoff_3E(a0),d0
		bsr.w	CalcSine
		move.w	d0,d4
		lea	(Obj11_BendData2).l,a4
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsl.w	#4,d0
		moveq	#0,d3
		move.b	objoff_3F(a0),d3
		move.w	d3,d2
		add.w	d0,d3
		moveq	#0,d5
		lea	(Obj11_BendData-$80).l,a5
		move.b	(a5,d3.w),d5

loc_7F64:
		andi.w	#$F,d3
		lsl.w	#4,d3
		lea	(a4,d3.w),a3
		movea.l	objoff_30(a0),a1
		lea	sub9_y_pos+next_subspr(a1),a2
		lea	sub2_y_pos(a1),a1

loc_7F7A:
		moveq	#0,d0
		move.b	(a3)+,d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	objoff_3C(a0),d0
		move.w	d0,(a1)
		addq.w	#6,a1
		cmpa.w	a2,a1
		bne.s	loc_7F9A
		movea.l	objoff_34(a0),a1
		lea	sub2_y_pos(a1),a1

loc_7F9A:
		dbf	d2,loc_7F7A
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		moveq	#0,d3
		move.b	objoff_3F(a0),d3
		addq.b	#1,d3
		sub.b	d0,d3
		neg.b	d3
		bmi.s	locret_7FE4
		move.w	d3,d2
		lsl.w	#4,d3
		lea	(a4,d3.w),a3
		adda.w	d2,a3
		subq.w	#1,d2
		blo.s	locret_7FE4

loc_7FC0:
		moveq	#0,d0
		move.b	-(a3),d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	objoff_3C(a0),d0
		move.w	d0,(a1)
		addq.w	#6,a1
		cmpa.w	a2,a1
		bne.s	loc_7FE0
		movea.l	objoff_34(a0),a1
		lea	sub2_y_pos(a1),a1

loc_7FE0:
		dbf	d2,loc_7FC0

locret_7FE4:
		rts
; End of function sub_7F36

; ---------------------------------------------------------------------------
Obj11_BendData:
		dc.b   2,  4,  6,  8,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0,  0,  0
		dc.b   2,  4,  6,  8, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0,  0
		dc.b   2,  4,  6,  8, $A, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0
		dc.b   2,  4,  6,  8, $A, $C, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0
		dc.b   2,  4,  6,  8, $A, $C, $C, $A,  8,  6,  4,  2,  0,  0,  0,  0
		dc.b   2,  4,  6,  8, $A, $C, $E, $C, $A,  8,  6,  4,  2,  0,  0,  0
		dc.b   2,  4,  6,  8, $A, $C, $E, $E, $C, $A,  8,  6,  4,  2,  0,  0
		dc.b   2,  4,  6,  8, $A, $C, $E,$10, $E, $C, $A,  8,  6,  4,  2,  0
		dc.b   2,  4,  6,  8, $A, $C, $E,$10,$10, $E, $C, $A,  8,  6,  4,  2
Obj11_BendData2:
		dc.b $FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		dc.b $B5,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		dc.b $7E,$DB,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		dc.b $61,$B5,$EC,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		dc.b $4A,$93,$CD,$F3,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		dc.b $3E,$7E,$B0,$DB,$F6,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
		dc.b $38,$6D,$9D,$C5,$E4,$F8,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0
		dc.b $31,$61,$8E,$B5,$D4,$EC,$FB,$FF,  0,  0,  0,  0,  0,  0,  0,  0
		dc.b $2B,$56,$7E,$A2,$C1,$DB,$EE,$FB,$FF,  0,  0,  0,  0,  0,  0,  0
		dc.b $25,$4A,$73,$93,$B0,$CD,$E1,$F3,$FC,$FF,  0,  0,  0,  0,  0,  0
		dc.b $1F,$44,$67,$88,$A7,$BD,$D4,$E7,$F4,$FD,$FF,  0,  0,  0,  0,  0
		dc.b $1F,$3E,$5C,$7E,$98,$B0,$C9,$DB,$EA,$F6,$FD,$FF,  0,  0,  0,  0
		dc.b $19,$38,$56,$73,$8E,$A7,$BD,$D1,$E1,$EE,$F8,$FE,$FF,  0,  0,  0
		dc.b $19,$38,$50,$6D,$83,$9D,$B0,$C5,$D8,$E4,$F1,$F8,$FE,$FF,  0,  0
		dc.b $19,$31,$4A,$67,$7E,$93,$A7,$BD,$CD,$DB,$E7,$F3,$F9,$FE,$FF,  0
		dc.b $19,$31,$4A,$61,$78,$8E,$A2,$B5,$C5,$D4,$E1,$EC,$F4,$FB,$FE,$FF