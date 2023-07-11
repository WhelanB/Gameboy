SPRITE_LOC EQU $C100

; File full of helper functions - need to cleanup register usage here
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

; Reset the background scroll back to 0, 0
ResetBGScroll:
    xor a
    ld [rSCX], a
    ld [rSCY], a
    ret

StepFadeOutDefaultPallete:
    cp $10
    jr z, .black
    cp $06
    jr z, .darkgrey
    cp $02
    jr z, .lightgrey
    jr .ret
.black
    ld a, [rBGP]
    cp $E4
    jr nz, .darkgrey
    ld a, $E0
    ld [rBGP], a
    ld [rOBP0], a
    jr .ret
.darkgrey
    ld a, [rBGP]
    cp $E0
    jr nz, .lightgrey
    ld a, $C0
    ld [rBGP], a
    ld [rOBP0], a
    jr .ret
.lightgrey
    ld a, [rBGP]
    cp $C0
    jr nz, .white
    ld a, $00
    ld [rBGP], a
    ld [rOBP0], a
    jr .ret
.white
.ret
    ret

StepFadeInDefaultPallete:
    cp $10
    jr z, .black
    cp $06
    jr z, .darkgrey
    cp $02
    jr z, .lightgrey
    jr .ret
.black
    ld a, [rBGP]
    cp $00
    jr nz, .darkgrey
    ld a, $C0
    ld [rBGP], a
    ld [rOBP0], a
    jr .ret
.darkgrey
    ld a, [rBGP]
    cp $C0
    jr nz, .lightgrey
    ld a, $E0
    ld [rBGP], a
    ld [rOBP0], a
    jr .ret
.lightgrey
    ld a, [rBGP]
    cp $E0
    jr nz, .white
    ld a, $E4
    ld [rBGP], a
    ld [rOBP0], a
    jr .ret
.white
.ret
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
    push bc ; Store BC
    ld a, c ; Load Y position into A
    ld h, $00 ; Load 0 into H
    cp $00 ; Check if Y pos is 0
    jr z, .skipY ; If it is, we can skip

    ld l, c ; Load Y position into L
rept 5
    add hl ; Multiply y pos by 5 for some reason?
endr
.skipY
    ld c, b ; Load X position into C
    ld b, $00 ; Load 0 into B
    add hl, bc ; Add the X pos to the total
    add hl, de ; Add the total to the memory address
    ld a, [hl] ; Load the Tile Id
    pop bc ; Restore BC
    ret ; Return


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

; Get World Position of Top Left of Tile (doesn't support slopes/half tiles)
; Includes adjustments for sprite position offset (sprite top left is not 0,0!)
; Input and Output in B,C (X,Y)
GetTileBottomRightWorldPosition:
rept 3 ; mull by 2^3 (8)
    sla b
    sla c
endr
    ld a, b
    add $10
    ld b, a

    ld a, c
    add $18
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

; Check if one sprite position intersects with another (8x8)
; @param bc - X1Y1 position of the first sprite
; @param hl - X2Y2 position of the second sprite
; @return a - zero if no overlap, one if overlap
checkOverlap:
    ld a, b ; Load X1
    add a, $08 ; Add the width
    cp h ; Compare against X2
    jr c, .retNoColl

    ld a, h ; Load X2
    add a, $08 ; Add the width
    ld h, a
    ld a, b
    cp h ; Compare against X1
    jr nc, .lte 

    ld a, c ; Load Y1
    add a, $08 ; Add the height
    cp l ; Compare against Y2
    jr c, .retNoColl

    ld a, l ; Load Y2
    add a, $08 ; Add the height
    ld l, a
    ld a, c
    cp l ; Compare against Y1
    jr nc, .lte 

.retColl
    ld a, $01
    ret
.lte
    jr nz, .retNoColl
    jp .retNoColl
.retNoColl
    xor a
    ret


; Check if one sprite position intersects with another (8x16)
; @param bc - X1Y1 position of the first sprite
; @param hl - X2Y2 position of the second sprite
; @return a - zero if no overlap, one if overlap
checkOverlapLarge:
    ld a, b ; Load X1
    add a, $08 ; Add the width
    cp h ; Compare against X2
    jr c, .retNoColl

    ld a, h ; Load X2
    add a, $08 ; Add the width
    ld h, a
    ld a, b
    cp h ; Compare against X1
    jr nc, .lte 

    ld a, c ; Load Y1
    add a, $10 ; Add the height
    cp l ; Compare against Y2
    jr c, .retNoColl

    ld a, l ; Load Y2
    add a, $10 ; Add the height
    ld l, a
    ld a, c
    cp l ; Compare against Y1
    jr nc, .lte 

.retColl
    ld a, $01
    ret
.lte
    jr nz, .retNoColl
    jp .retNoColl
.retNoColl
    xor a
    ret

; Check if a point is contained within the bounds of an 8x16 sprite
; @param bc - X1Y1 position of the first sprite
; @param hl - X2Y2 position to check
; @return a - zero if not contained, one if contained
checkPointInSpriteLarge:
    ld a, b ; Load X1
    add a, $08 ; Add the width
    cp h ; Compare against X2
    jr c, .retNoColl

    ld a, b
    cp h ; Compare against X1
    jr nc, .lte 

    ld a, c ; Load Y1
    add a, $10 ; Add the height
    cp l ; Compare against Y2
    jr c, .retNoColl

    ld a, c
    cp l ; Compare against Y1
    jr nc, .lte 

.retColl
    ld a, $01
    ret
.lte
    jr nz, .retNoColl
    jp .retNoColl
.retNoColl
    xor a
    ret