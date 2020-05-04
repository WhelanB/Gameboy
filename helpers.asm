SPRITE_LOC EQU $C100

SECTION "Helpers", ROM0

; Wait for v-blank
WaitVBlank:
    ldh a, [rLY] ; NOTE: ldh is a shorter and faster version of ld for addresses in the $FF00-$FFFF range
    cp 144
    jr c, WaitVBlank
    ret
    
; Only call these during V-blank
TurnOffLCD:
    ld a, [rLCDC]
    and a, LCDCF_OFF ; Clear bit
    ld [rLCDC], a ; set LCD controller value
    ret

TurnOnLCD:
    ld a, [rLCDC]
    and a, LCDCF_ON ; Clear bit
    ld [rLCDC], a ; set LCD controller value
    ret

; Returns buttons pressed in a
SampleInput: ; Taken from Nintendo GB Programming manual, updated to use hardware.inc definitions
    ld a, P1F_5 ; Set bit 5 to request button info in lower nibble
    ld [rP1], a
    ld a, [rP1] ; Read button info
    ld a, [rP1] ; Nintendo suggests reading button info twice to ensure write (does it need to be debounced?)
    cpl ; Invert so inputs are high
    and P1F_INPUT_MASK
    swap a ; Swap nibbles so button info is upper nibble
    ld b, a
    ld a, P1F_4
    ld [rP1], a
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1] ; Nintendo again!
    cpl
    and P1F_INPUT_MASK
    or b
    ret

LoadBGLoc:
    ld a, [rSCX]
    ld b, a
    ld a, [rSCY]
    ld c, a
    ret
; Decrements SCX, and returns value in A
ScrollBGRight:
    ld a, [rSCX]
    dec a
    ld [rSCX], a
    ret

; Increments SCX, and returns value in A
ScrollBGLeft:
    ld a, [rSCX]
    inc a
    ld [rSCX], a
    ret

; Decrements SCY, and returns value in A
ScrollBGDown:
    ld a, [rSCY]
    dec a
    ld [rSCY], a
    ret

; Increments SCY, and returns value in A
ScrollBGUp:    
    ld a, [rSCY]
    inc a
    ld [rSCY], a
    ret

; Decrements SCX, and returns value in A
; Limited to the 32x32 tiles of the background layer
ScrollBGRightLim:
    ld a, [rSCX]
    cp $00
    jr z, .return
    dec a
    ld [rSCX], a
.return
    ret

; Increments SCX, and returns value in A
; Limited to the 32x32 tiles of the background layer
ScrollBGLeftLim:
    ld a, [rSCX]
    cp $60
    jr z, .return
    inc a
    ld [rSCX], a
.return
    ret

; Decrements SCY, and returns value in A
; Limited to the 32x32 tiles of the background layer
ScrollBGDownLim:
    ld a, [rSCY]
    cp $00
    jr z, .return
    dec a
    ld [rSCY], a
.return
    ret

; Increments SCY, and returns value in A
; Limited to the 32x32 tiles of the background layer
ScrollBGUpLim:    
    ld a, [rSCY]
    cp $70
    jr z, .return
    inc a
    ld [rSCY], a
.return
    ret

; Get tilemap position which location H,L is occupying
; input and output in HL (X,Y)
WorldToTileMap:
    ; Correct X-Pos for sprite offset
    ld a, h
    sub $08
    ld h, a

    ; Correct Y-Pos for sprite offset
    ld a, l
    sub $10
    ld l, a
rept 3 ; divide by 2^3 (8)
    srl h
    srl l
endr
    ret

; Get tile at tile position B,C (X,Y)
; Tilemap offset in DE ($9800)
; Tile address in hl
; Tile ID in A
GetTileAtPosition:
    push bc
    ld a, c
    ld h, $00
    cp $00
    jr z, .skipY

    ld l, c 
rept 5
    add hl
endr
.skipY
    ld c, b
    ld b, $00
    add hl, bc
    add hl, de
    ld a, [hl]
    pop bc
    ret

; Get World Position of Top Left of Tile (doesn't support slopes/half tiles)
; Includes adjustments for sprite position offset (sprite top left is not 0,0!)
; Input and Output in B,C (X,Y)
GetTileTopLeftWorldPosition:
rept 3 ; mull by 2^3 (8)
    sla b
    sla c
endr
    ld a, b
    add $08
    ld b, a

    ld a, c
    add $10
    ld c, a
    ret

negateNumber:
    CPL
    add $01
    ret



; Convert an 8-bit world coordinate to screen coordinates
; Games like Super Mario Land keep Mario centered + scroll background to move
; But 
; input and output in HL (X,Y)
; Screen coordinates in BC (X,Y)
; needs to be updated to return some out of bounds coordinate if wrap-around occurs
WorldToScreenCoord:
    ld a, h ; Load X pos into a
    sub a, b ; Subtract scroll from x pos
    ld h, a ; Store in h
    ld a, l ; Repeat for y pos
    sub a, c
    ld l, a
    ret

;memCopy
; Copies a range of values from one location to another
; Params:
; de - A pointer to the memory to be copied
; bc - The amount of data to copy
; hl - A pointer to the beginning of the destination buffer
memCopy:
    ld a, [de] ; Grab a byte
    ld [hli], a ; Place it into loc
    inc de ; get next byte
    dec bc ; decrement size counter
    ld a, b ; check if size counter is 0
    or c
    jr nz, memCopy ; keep going if not zero
    ret

memClear:
    xor a
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, memClear
    ret

; Copy a null terminated string (excluding null) to memory
; @param de A pointer to the string to be copied
; @param hl A pointer to the beginning of the destination buffer
; @return de A pointer to the byte after the source string's terminating byte
; @return hl A pointer to the byte after the last copied byte
; @return a Zero
; @return flags C reset, Z set
stringCopy:
    ld a, [de]
    inc de
    and a
    ret z
    ld [hli], a
    jr stringCopy