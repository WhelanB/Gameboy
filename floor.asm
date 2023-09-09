; Can optimise this to use bitfield and consume less memory

SECTION "Floor", ROM0
FLOOR_SIZE EQU $0A ; The number of floor tiles
SOLID_TILE EQU $67
DAMAGE_TILE EQU $65
AIR_TILE EQU $2C

; init_beans
; This iterates over the area of WRAM allocated for floor, and sets all tiles to SOLID_TILE
init_floor:
    xor a
    ld [FLOOR_DIRTY], a
    ld hl, $C400
.repeat
    inc hl
    ld [hl], SOLID_TILE
    inc hl
    ld [hl], SOLID_TILE
    inc a
    cp FLOOR_SIZE ; If index != pool size, repeat 
    jr nz, .repeat
    ret ; Otherwise, return


; damage_tile
; damage a specific floor tile
; @param a The index of the tile to damage (0 - FLOOR_SIZE)
damage_tile:
    ld hl, FLOOR_MEM_CHUNK
    ld c, a
    xor a
    ld b, a
    add hl, bc
    ld a, [hl]
    cp $67
    jr nz, .airTile
    ld a, $65
    ld [hl], a
    inc hl
    ld [hl], a
    jr .stop
.airTile
    ld a, $2C
    ld [hl], a
    inc hl
    ld [hl], a
.stop
    ld a, $01
    ld [FLOOR_DIRTY], a
    ret

update_floor:
    ld a, [FLOOR_DIRTY]
    cp $01
    jr nz, .stop
    
    call TurnOffLCD

    ld de, FLOOR_MEM_CHUNK
    ld bc, FLOOR_SIZE * 2
    ld hl, $9A00
    call memCopy
    ld a, %10000111 ;
    ld [rLCDC], a ; Enable LCD, Sprites and Background
    xor a
    ld [FLOOR_DIRTY], a
.stop
    ret

; de - A pointer to the memory to be copied
; bc - The amount of data to copy
; hl - A pointer to the beginning of the destination buffer




SECTION "Floor WRAM", WRAM0[$C400] ; Bean scratchpad
FLOOR_DIRTY DS 1
FLOOR_MEM_CHUNK : DS FLOOR_SIZE * 2 ; Block out enough memory for remaining bean instances (pool size is compile time)