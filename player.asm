SECTION "Player", ROM0
PLAYER_GRAVITY equ %000000110
PLAYER_JUMP_VEL equ %01111111
init_player:
    xor a
    ld [PLAYER_DY], a
    ld [PLAYER_DX], a


update_player:
    call SampleInput ; Sample d-pad and buttons
    ld c, a ; Store state of input in c - should probably move this to ram
    ;cp 0 ; If no keys pressed, try again!
    ;jr nz, .testLeft ; jump to wait for next frame
    xor a
    ld [PLAYER_DX], a

.testLeft
    ld a, c
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
    ld a, [PLAYER_Y]
    cp $88 ; check floor pos
    jr c, .notGrounded ; first, check if we're grounded
    ; IF GROUNDED:
.grounded

    ld a, c
    bit PADB_A, a
    jr z, .notJumpPressed ; if A not pressed, skip to applying velocity
 .jumpPressed   
    ld a, $01
    ld [PLAYER_IS_GROUNDED], a
    ld a, PLAYER_JUMP_VEL
    ;call negateNumber
    ld b, a
    ld a, [PLAYER_DY]
    sub a, b
    jr nc, .jumpEnd
    ld [PLAYER_DY], a ; Apply jump velocity to player DY
    ;xor a
    ;ld [PLAYER_Y], a
    ;ld a, %11111111
    ;ld [PLAYER_DY], a
    jr .jumpEnd

.notJumpPressed
    xor a
    ld [PLAYER_DY], a ; reset velocity
    ld a, $88 
    ld [PLAYER_Y], a ; push back to top of floor
    jr .jumpEnd

.notGrounded:
    xor a
    ld [PLAYER_IS_GROUNDED], a
    ld a, PLAYER_GRAVITY
    ld b, a
    ld a, [PLAYER_DY]
    add a, b
    cp $83
    jr z, .jumpEnd
    ld [PLAYER_DY], a
    
.jumpEnd

.applyVelocity:

    ld a, [PLAYER_DY]
    ld b, a
    sra b
    sra b
    sra b
    sra b
    sra b
    ld a, b
    ld [PLAYER_WILL_BE_GROUNDED], a
    ld a, [PLAYER_Y]
    add a, b
    ld [PLAYER_Y], a


    cp $88 ; check floor pos
    jr c, .applyXVelocity ; first, check if we're grounded    
    xor a
    ld [PLAYER_DY], a ; reset velocity
    ld a, $88 
    ld [PLAYER_Y], a ; push back to top of floor

.applyXVelocity:
    ld a, [PLAYER_DX]
    ld b, a
    ld a, [PLAYER_X]
    add a, b
    ld [PLAYER_X], a


.stop
    ret

SECTION "Echo OAM", WRAM0[$C100]
PLAYER_Y: DS 1
PLAYER_X: DS 1
PLAYER_SPRITE: DS 1

SECTION "Player Values", WRAM0[$C000]
PLAYER_DY : DS 1
PLAYER_DX : DS 1

PLAYER_IS_GROUNDED : DS 1
PLAYER_WILL_BE_GROUNDED : DS 1
;PLAYER_CAN_JUMP : DS 1 