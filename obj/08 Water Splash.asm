; ---------------------------------------------------------------------------
; Object 08 - water splash
; ---------------------------------------------------------------------------

Obj08:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj08_Index(pc,d0.w),d1
		jmp	Obj08_Index(pc,d1.w)
; ===========================================================================
Obj08_Index:	dc.w Obj08_Init-Obj08_Index
		dc.w Obj08_Display-Obj08_Index
		dc.w Obj08_Delete-Obj08_Index
; ===========================================================================

Obj08_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_obj08,obMap(a0)
		ori.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#16,obActWid(a0)
		move.w	#make_art_tile(ArtTile_LZ_Splash,2,0),obGfx(a0)
		bsr.w	Adjust2PArtPointer
		move.w	(v_player+obX).w,obX(a0)
	if FixBugs
		cmpa.w	#v_splash,a0
		beq.s	Obj08_Display
		move.w	(v_player2+obX).w,obX(a0)
	endif

Obj08_Display:
		move.w	(v_waterpos1).w,obY(a0)
		lea	(Ani_obj08).l,a1
		jsr	(AnimateSprite).l
		jmp	(DisplaySprite).l
; ===========================================================================

Obj08_Delete:
		jmp	(DeleteObject).l