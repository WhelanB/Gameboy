SECTION "Tongue", ROM0


init_tongue:
    xor a ; Zero out the next 4 values in memory
    ld [TONGUE_LENGTH], a
    ld [TONGUE_FIRED], a
    ld [TONGUE_ATTRIBUTE], a
    ld [TONGUE_EATING], a
    ld a, $6E
    ld [TONGUE_SPRITE], a ; Set tongue sprite
    ld a, $25 ; 3f
    ld [rNR10], a
    ld a, $84 ; a1
    ld [rNR11], a
    ld a, $45 ; 00
    ld [rNR12], a
    ld a, $9A
    ld [rNR13], a ; Play noise
    ld a, $86
    ld [rNR14], a

jumpToPlayerPosOffset:
    ld a, [PLAYER_FACING] ; Check which way player is facing (originally this was direct sum but need to set sprite rot)
    cp $00 ; if it is zero, player is facing left
    jr z, .handleLeftXPos
.handleRightXPos
    ld a, [PLAYER_X]
    add a, $03
    ld [TONGUE_X], a
    jr .handleYPos
.handleLeftXPos
    ld a, [PLAYER_X]
    sub a, $03
    ld [TONGUE_X], a
.handleYPos
    ld a, [PLAYER_Y]
    sub a, $05
    ld [TONGUE_Y], a
    ret
    
updateTongueNodes:
    srl a ; Divide the length by 2
    srl a ; repeat div 2
    srl a ; repeat div 2 (ultimately dividng by 8)
    sla a
    sla a
    ld hl, NODES ; Load the root node address
    ld b, $00
    ld c, a
    add hl, bc
    ld a, [hl]
    cp $00
    jr nz, .return ; break early if this tile is already set
    ld a, [TONGUE_SPRITE_Y]
    ldi [hl], a
    ld a, [TONGUE_SPRITE_X]
    ldi [hl], a
    ld a, $6D
    ldi [hl], a
    ld a, [TONGUE_ATTRIBUTE] ; We can re-use the tongue attributes so that we don't need to recalculate the dir
    ld [hl], a
.return
    ret

clearTongueNodes:
    ld hl, NODES ; clear OAM
    ld bc, $40
    call memClear ; Copy tile data to VRAM
    ret


update_tongue:
    ld a, [TONGUE_Y]
    sub $08
    ld [TONGUE_SPRITE_Y], a
    ld a, [TONGUE_X]
    ld [TONGUE_SPRITE_X], a
    ld a, [TONGUE_EATING] ; If a bean has marked itself as eaten since the last frame
    cp $01
    jp z, .tongueReachedEnd ; Retract the tongue as if we collided with something
    call SampleInput ; Sample d-pad and buttons
.testA
    bit PADB_B, a ; Check if B button is pressed
    jp z, .restoreTongueFully ; If it isn't, retract the tongue
    ld a, [TONGUE_FIRED] ; Check if the tongue has been previously fired in this keypress
    cp $1
    jp z, .stop ; If it has, we don't want to fire it again until the key is repressed
    ld a, [TONGUE_LENGTH] ; Load the length of the tongue (in pixels)
    cp $80 ; If it is equal to $80, it has reached max length. Retract it
    jr z, .tongueReachedEnd ; Tongue has hit it
;call tonguenodes
    ld a, [TONGUE_Y]
    cp $00
    jr nz, .skip
    call jumpToPlayerPosOffset ; If the Y pos is zero, set to player pos
.skip
    ld a, [PLAYER_FACING] ; Check which way player is facing (originally this was direct sum but need to set sprite rot)
    cp $00 ; if it is zero, player is facing left
    jr z, .tongueLeft
.tongueRight
    ld a, [TONGUE_X]; if it is anything else, move the sprite right
    add a, $01
    cp $98 ; Check if the new position is outside the bounds of the rightmost wall
    jr nc, .tongueReachedEnd ; If it is, retract the tongue
    ld [TONGUE_X], a
    ld a, [TONGUE_ATTRIBUTE]
    and OMF_XFLIP_INV
    ld [TONGUE_ATTRIBUTE], a
    jp .tongueUp
.tongueLeft
    ld a, [TONGUE_X]
    sub a, $01
    cp $10 ; Check if the new position is outside the bounds of the leftmost wall
    jr c, .tongueReachedEnd ; If it is, retract the tongue
    ld [TONGUE_X], a
    ld a, [TONGUE_ATTRIBUTE]
    or OAMF_XFLIP
    ld [TONGUE_ATTRIBUTE], a

.tongueUp
    ld a, [TONGUE_Y]
    sub a, $01
    cp $18 ; Check if the new position is out of bounds above the topmost wall
    jr c, .tongueReachedEnd ; If it is, retract the tongue
    ld [TONGUE_Y], a
    ld a, [TONGUE_LENGTH]
    add a, $01
    ld [TONGUE_LENGTH], a
    ld a, [TONGUE_LENGTH]
    call updateTongueNodes
    jp .stop

.tongueReachedEnd ; Jump here if the tongue collided with a wall, or reached its max length
    ld a, $25 ; 3f
    ld [rNR10], a
    ld a, $84 ; a1
    ld [rNR11], a
    ld a, $45 ; 00
    ld [rNR12], a
    ld a, $9A
    ld [rNR13], a ; Play noise
    ld a, $86
    ld [rNR14], a
    ld a, $01
    ld [TONGUE_FIRED], a ; Set tongue fired to 1, so that it doesn't fire again until the key is released and repressed
    xor a
    ld [TONGUE_EATING], a
    jp .restoreTonguePartially

.restoreTongueFully ; Reset tongue state, including whether it was fired this key press
    xor a
    ld [TONGUE_FIRED], a
.restoreTonguePartially ; Reset tongue state, excluding whether it was fired this key press
    ld a, $05
    ld [TONGUE_LENGTH], a
    xor a
    ld [TONGUE_X], a
    ld [TONGUE_Y], a
    call clearTongueNodes


.stop
    ret


SECTION "Echo OAM TONGUE", WRAM0[$C108]
TONGUE_SPRITE_Y: DS 1
TONGUE_SPRITE_X: DS 1
TONGUE_SPRITE: DS 1
TONGUE_ATTRIBUTE : DS 1

SECTION "Echo OAM Tongue Nodes", WRAM0[$C10C]
NODES: DS 48 ; 64 bytes of memory, for OAM data of 16 nodes

SECTION "Tongue Values", WRAM0[$C00A]
TONGUE_Y : DS 1
TONGUE_X : DS 1
TONGUE_IS_ACTIVE : DS 1 ; Is the tongue currently in use?
TONGUE_LENGTH : DS 1 ; How long is the tongue currently?
TONGUE_FIRED : DS 1 ; Has the tongue been fired this key press?
TONGUE_EATING : DS 1 ; Has the tongue hit a bean? beans resolve collision, but I should probably call a function instead of setting this