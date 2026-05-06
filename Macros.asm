; ---------------------------------------------------------------------------
; I run the main 68k RAM addresses through this function
; to let them work in both 16-bit and 32-bit addressing modes.
ramaddr function x,-(-x)&$FFFFFFFF

; ---------------------------------------------------------------------------
; Set a VRAM address via the VDP control port.
; input: 16-bit VRAM address, control port (default is (vdp_control_port).l)
; ---------------------------------------------------------------------------

locVRAM:	macro loc,controlport
		if ("controlport"=="")
		move.l	#($40000000+(((loc)&$3FFF)<<16)+(((loc)&$C000)>>14)),(vdp_control_port).l
		else
		move.l	#($40000000+(((loc)&$3FFF)<<16)+(((loc)&$C000)>>14)),controlport
		endif
		endm

; ---------------------------------------------------------------------------
; DMA copy data from 68K (ROM/RAM) to the VRAM
; input: source, length, destination
; ---------------------------------------------------------------------------

writeVRAM:	macro source,destination
		lea	(vdp_control_port).l,a5
		move.l	#$94000000+((((source_end-source)>>1)&$FF00)<<8)+$9300+(((source_end-source)>>1)&$FF),(a5)
		move.l	#$96000000+(((source>>1)&$FF00)<<8)+$9500+((source>>1)&$FF),(a5)
		move.w	#$9700+((((source>>1)&$FF0000)>>16)&$7F),(a5)
		move.w	#$4000+((destination)&$3FFF),(a5)
		move.w	#$80+(((destination)&$C000)>>14),(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		endm

; ---------------------------------------------------------------------------
; DMA copy data from 68K (ROM/RAM) to the CRAM
; input: source, length, destination
; ---------------------------------------------------------------------------

writeCRAM:	macro source,destination
		lea	(vdp_control_port).l,a5
		move.l	#$94000000+((((source_end-source)>>1)&$FF00)<<8)+$9300+(((source_end-source)>>1)&$FF),(a5)
		move.l	#$96000000+(((source>>1)&$FF00)<<8)+$9500+((source>>1)&$FF),(a5)
		move.w	#$9700+((((source>>1)&$FF0000)>>16)&$7F),(a5)
		move.w	#$C000+(destination&$3FFF),(a5)
		move.w	#$80+((destination&$C000)>>14),(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		endm

; ---------------------------------------------------------------------------
; DMA fill VRAM with a value
; input: value, length, destination
; ---------------------------------------------------------------------------

fillVRAM:	macro byte,start,end
		lea	(vdp_control_port).l,a5
		move.w	#$8F01,(a5) ; Set increment to 1, since DMA fill writes bytes
		move.l	#$94000000+((((end)-(start)-1)&$FF00)<<8)+$9300+(((end)-(start)-1)&$FF),(a5)
		move.w	#$9780,(a5)
		move.l	#$40000080+(((start)&$3FFF)<<16)+(((start)&$C000)>>14),(a5)
		move.w	#(byte)|(byte)<<8,(vdp_data_port).l
.wait:		move.w	(a5),d1
		btst	#1,d1
		bne.s	.wait
		move.w	#$8F02,(a5) ; Set increment back to 2, since the VDP usually operates on words
		endm

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at 4 bytes per iteration
bytesToLcnt function n,n>>2-1

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at 2 bytes per iteration
bytesToWcnt function n,n>>1-1

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at x bytes per iteration
bytesToXcnt function n,x,n/x-1

; macros for defining animated PLC script lists
zoneanimstart macro {INTLABEL}
__LABEL__ label *
zoneanimcount := 0
zoneanimcur := "__LABEL__"
	dc.w zoneanimcount___LABEL__	; Number of scripts for a zone (-1)
	endm

zoneanimend macro
zoneanimcount_{"\{zoneanimcur}"} = zoneanimcount-1
	endm

zoneanimdeclanonid := 0

zoneanimdecl macro duration,artaddr,vramaddr,numentries,numvramtiles
zoneanimdeclanonid := zoneanimdeclanonid + 1
start:
	dc.l (duration&$FF)<<24|artaddr
	dc.w tiles_to_bytes(vramaddr)
	dc.b numentries, numvramtiles
zoneanimcount := zoneanimcount + 1
	endm

; fills a region of 68k RAM with 0
clearRAM macro startaddr,endaddr
	if startaddr>endaddr
		fatal "Starting address of clearRAM \{startaddr} is after ending address \{endaddr}."
	elseif startaddr==endaddr
		warning "clearRAM is clearing zero bytes. Turning this into a nop instead."
		exitm
	endif
	if ((startaddr)&$8000)==0
		lea	(startaddr).l,a1
	else
		lea	(startaddr).w,a1
	endif
		moveq	#0,d0
	if ((startaddr)&1)
		move.b	d0,(a1)+
	endif
		move.w	#bytesToLcnt((endaddr-startaddr) - ((startaddr)&1)),d1
.loop:		move.l	d0,(a1)+
		dbf	d1,.loop
	if (((endaddr-startaddr) - ((startaddr)&1))&2)
		move.w	d0,(a1)+
	endif
	if (((endaddr-startaddr) - ((startaddr)&1))&1)
		move.b	d0,(a1)+
	endif
		endm

; ---------------------------------------------------------------------------
; stop the Z80
; ---------------------------------------------------------------------------

stopZ80:	macro
		move.w	#$100,(z80_bus_request).l
		endm

; ---------------------------------------------------------------------------
; wait for Z80 to stop
; ---------------------------------------------------------------------------

waitZ80:	macro
.wait:	btst	#0,(z80_bus_request).l
		bne.s	.wait
		endm

; ---------------------------------------------------------------------------
; reset the Z80
; ---------------------------------------------------------------------------

resetZ80:	macro
		move.w	#$100,(z80_reset).l
		endm

resetZ80a:	macro
		move.w	#0,(z80_reset).l
		endm

; ---------------------------------------------------------------------------
; start the Z80
; ---------------------------------------------------------------------------

startZ80:	macro
		move.w	#0,(z80_bus_request).l
		endm

; ---------------------------------------------------------------------------
; disable interrupts
; ---------------------------------------------------------------------------

disable_ints:	macro
		move.w	#$2700,sr
		endm

; ---------------------------------------------------------------------------
; enable interrupts
; ---------------------------------------------------------------------------

enable_ints:	macro
		move.w	#$2300,sr
		endm

; ---------------------------------------------------------------------------
; disable display
; ---------------------------------------------------------------------------

disable_display:	macro
		move.w	(v_vdp_buffer1).w,d0		; get buffered copy of VDP register $81
		andi.b	#%10111111,d0			; clear bit 6 (disable display; fill with background color)
		move.w	d0,(vdp_control_port).l		; write to VDP
		endm

; ---------------------------------------------------------------------------
; enable display
; ---------------------------------------------------------------------------

enable_display:	macro
		move.w	(v_vdp_buffer1).w,d0		; get buffered copy of VDP register $81
		ori.b	#%01000000,d0			; set bit 6 (enable display)
		move.w	d0,(vdp_control_port).l		; write to VDP
		endm

; ---------------------------------------------------------------------------
; check if object moves out of range (Sonic 1)
; input: location to jump to if out of range, x-axis pos (obX(a0) by default)
; ---------------------------------------------------------------------------

out_of_range_s1:	macro exit,specpos
		if ("specpos"<>"")
		move.w	specpos,d0		; get object position (if specified as not obX)
		else
		move.w	obX(a0),d0	; get object position
		endif
		andi.w	#-$80,d0	; round down to nearest $80
		move.w	(Camera_X_pos).w,d1 ; get screen position
		subi.w	#128,d1
		andi.w	#-$80,d1
		sub.w	d1,d0		; approx distance between object and screen
		cmpi.w	#128+320+192,d0
		bhi.ATTRIBUTE	exit
		endm

; ---------------------------------------------------------------------------
; check if object moves out of range
; input: location to jump to if out of range, x-axis pos (obX(a0) by default)
; ---------------------------------------------------------------------------

out_of_range:	macro exit,specpos
		if ("specpos"<>"")
		move.w	specpos,d0		; get object position (if specified as not obX)
		else
		move.w	obX(a0),d0	; get object position
		endif
		andi.w	#-$80,d0	; round down to nearest $80
		sub.w	(Camera_X_pos_coarse).w,d0		; approx distance between object and screen
		cmpi.w	#128+320+192,d0
		bhi.ATTRIBUTE	exit
		endm

; ---------------------------------------------------------------------------
; check if object moves out of range
; input: location to jump to if out of range, x-axis pos (obX(a0) by default)
; ---------------------------------------------------------------------------

out_of_range_p2:	macro exit,specpos
		if ("specpos"<>"")
		move.w	specpos,d0		; get object position (if specified as not obX)
		else
		move.w	obX(a0),d0	; get object position
		endif
		andi.w	#-$80,d0	; round down to nearest $80
		move.w	d0,d1	; save object position for player 2
		sub.w	(Camera_X_pos_coarse).w,d0		; approx distance between object and screen
		cmpi.w	#128+320+192,d0
		bhi.ATTRIBUTE	exit
		endm

; ---------------------------------------------------------------------------
; check if object moves out of range for the second player
; works in conjunction with out_of_range_p2
; ---------------------------------------------------------------------------

out_of_range_p2_sub:	macro exit
		sub.w	(Camera_X_pos_coarse_P2).w,d1		; approx distance between object and screen
		cmpi.w	#128+320+192,d1
		bhi.ATTRIBUTE	exit
		endm

; ---------------------------------------------------------------------------
; Copy a tilemap from 68K (ROM/RAM) to the VRAM without using DMA
; input: source, destination, width [cells], height [cells]
; ---------------------------------------------------------------------------

copyTilemap:	macro source,destination,width,height
		lea	(source).l,a1
		locVRAM	destination,d0
		moveq	#width-1,d1
		moveq	#height-1,d2
		bsr.w	PlaneMapToVRAM_H40
		endm

; ---------------------------------------------------------------------------
; incbin compatibility macro for AS
; ---------------------------------------------------------------------------

incbin:		macro path
		binclude path
		endm

; macros to convert from tile index to art tiles, block mapping or VRAM address.
make_art_tile function addr,pal,pri,((pri&1)<<15)|((pal&3)<<13)|(addr&tile_mask)
make_art_tile_2p function addr,pal,pri,((pri&1)<<15)|((pal&3)<<13)|((addr&tile_mask)>>1)
make_block_tile function addr,flx,fly,pal,pri,((pri&1)<<15)|((pal&3)<<13)|((fly&1)<<12)|((flx&1)<<11)|(addr&tile_mask)
make_block_tile_2p function addr,flx,fly,pal,pri,((pri&1)<<15)|((pal&3)<<13)|((fly&1)<<12)|((flx&1)<<11)|((addr&tile_mask)>>1)
tiles_to_bytes function addr,((addr&$7FF)<<5)
make_block_tile_pair function addr,flx,fly,pal,pri,((make_block_tile(addr,flx,fly,pal,pri)<<16)|make_block_tile(addr,flx,fly,pal,pri))
make_block_tile_pair_2p function addr,flx,fly,pal,pri,((make_block_tile_2p(addr,flx,fly,pal,pri)<<16)|make_block_tile_2p(addr,flx,fly,pal,pri))

; function to calculate the location of a tile in plane mappings
planeLoc function width,col,line,(((width * line) + col) * 2)

; some variables and functions to help define those constants (redefined before a new set of IDs)
offset :=	0					; this is the start of the pointer table
ptrsize :=	1					; this is the size of a pointer (should be 1 if the ID is a multiple of the actual size)
idstart :=	0					; value to add to all IDs

; function using these variables
id function ptr,((ptr-offset)/ptrsize+idstart)