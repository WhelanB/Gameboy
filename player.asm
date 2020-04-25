SECTION "Player", ROM0
init_player:
    xor a
    ld [PLAYER_DY], a
    ld [PLAYER_DX], a
    ld a, $01
    ld [PLAYER_CAN_JUMP], a

update_player:
    call SampleInput ; Sample d-pad and buttons
    ld c, a ; Store state of input in c - should probably move this to ram
    cp 0 ; If no keys pressed, try again!
    jr nz, .testLeft ; jump to wait for next frame
    xor a
    ld [PLAYER_DX], a
    jr .handleGravity

.testLeft
    bit PADB_LEFT, a ; check if d-pad left is pressed
    jr z, .testRight ; if it isn't, check if d-pad right is pressed
    ld a, $02
    call negateNumber
    ld [PLAYER_DX], a
    jr .testJump

.testRight:
    ld a, c
    bit PADB_RIGHT, a
    jr z, .testJump
    ld a, $02
    ld [PLAYER_DX], a

.testJump:
    ld a, c
    bit PADB_A, a
    jr z, .handleGravity
    ld a, [PLAYER_CAN_JUMP]
    cp $00
    jr z, .handleGravity
    ld a, $08
    call negateNumber
    ld [PLAYER_DY], a
    ld a, $00
    ld [PLAYER_CAN_JUMP], a

.handleGravity:
    ld a, [PLAYER_DX]
    ld b, a
    ld a, [PLAYER_X]
    add a, b
    ld [PLAYER_X], a

    ld a, [PLAYER_DY]
    ld b, a
    ld a, [PLAYER_Y]
    add a, b
    ld [PLAYER_Y], a

    ld a, [PLAYER_Y]
    cp $88 ; check floor pos
    jr nc, .resetDY ; end if on floor

    ld a, $01
    ld b, a
    ld a, [PLAYER_DY]
    add a, b
    ld [PLAYER_DY], a


    jr .stop

.resetDY
    ld a, $01
    ld [PLAYER_CAN_JUMP], a
    ld a, $88
    ld [PLAYER_Y], a
    xor a
    ld [PLAYER_DY], a
.stop
    ret

SECTION "Echo OAM", WRAM0[$C100]
PLAYER_Y: DS 1
PLAYER_X: DS 1
PLAYER_SPRITE: DS 1

SECTION "Player Values", WRAM0[$C000]
PLAYER_DY : DS 1
PLAYER_DX : DS 1
PLAYER_CAN_JUMP : DS 1
