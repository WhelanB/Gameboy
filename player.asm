SECTION "Player", ROM0
PLAYER_GRAVITY equ %00000110 ; 0.1875 (000.00110)
PLAYER_JUMP_VEL equ %01100000 ; 3.0 (011.00000)
FLOOR_POS equ $88
init_player:
    xor a
    ld [PLAYER_DY], a
    ld [PLAYER_DX], a
    ld a, $88
    ld [FLOOR_Y], a
    ld [FLOOR_X], a


update_player:
    call SampleInput ; Sample d-pad and buttons
    ld c, a ; Store state of input in c - should probably move this to ram
    ;cp 0 ; If no keys pressed, try again!
    ;jr nz, .testLeft ; jump to wait for next frame
    xor a
    ld [PLAYER_DX], a
    ;ld a, [PLAYER_X]
 ;   cp $5A
;    jr c, .testLeft
    ;call ScrollBGLeft
    ;call ScrollBGLeft
    ;jr .testJump

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
    
    ;ld a, [PLAYER_Y]
    ;cp FLOOR_POS ; check floor pos
    ;jr c, .notGrounded ; first, check if we're grounded

    ld a, [PLAYER_IS_GROUNDED]
    cp $00
    jr z, .notGrounded ; If the grounded flag is not set, jump to handle gravity etc.


    ; If the grounded flag is set:
.grounded

    ld a, c ; Restore key state
    bit PADB_A, a ; Check for button A down
    jr z, .notJumpPressed ; If A not pressed, skip

    ; If A is pressed, and we're grounded:
 .jumpPressed   
    ld a, $01
    ld [PLAYER_IS_GROUNDED], a ; Set the grounded flag?
    ld a, PLAYER_JUMP_VEL ; Load the jump velocity
    ld b, a ; move to B reg
    ld a, [PLAYER_DY] ; Load Player delta Y
    sub a, b ; Subtract jump velocity from delta Y (negative velocity goes up)
    jr nc, .jumpEnd ; If this causes a carry, skip writing it back
    ld [PLAYER_DY], a ; Apply jump velocity to player DY
    jr .jumpEnd

    ; If A not pressed, and we're grounded
.notJumpPressed
    xor a ; set A reg to 0
    ld [PLAYER_DY], a ; reset delta Y to 0
    ld a, [FLOOR_Y] ; Load floor position
    ld [PLAYER_Y], a ; push back to top of floor
    jr .jumpEnd

    ; If we're not grounded:
.notGrounded:
    xor a ; set A reg to 0
    ld [PLAYER_IS_GROUNDED], a ; set grounded flag to false
    ld a, PLAYER_GRAVITY ; Load gravity velocity
    ld b, a ; move to B reg
    ld a, [PLAYER_DY] ; Load Player delta Y
    add a, b ; Add gravity to delta Y (positive velocity goes down)
    cp $84 ; If current velocity is 83, don't apply back (limit gravity) (TODO)
    jr z, .jumpEnd 
    ld [PLAYER_DY], a ; Write back
    
.jumpEnd

.applyVelocity:

    ld a, [PLAYER_DY] ; Load Player delta Y into a
    ld b, a ; move to B reg
    sra b
    sra b
    sra b
    sra b
    sra b ; Round delta Y down to int
    ld a, [PLAYER_Y] ; Load Player Y pos
    add a, b ; Add velocity to Y pos
    ld [PLAYER_Y], a ; Store


    ;cp FLOOR_POS ; check floor pos
    ;jr c, .applyXVelocity ; first, check if we're grounded   

.resolveYPenetration
    ld a, [PLAYER_X] ; Load Player X pos into H
    add a, $04 ; middle of player
    ld h, a
    ld a, [PLAYER_Y] ; Load Player Y pos into L - HL now contains position
    add a, $08 ; bottom of player
    ld l, a
    call WorldToTileMap ; Convert Player position to Tilemap position
    ld a, h
    ld [PLAYER_TILE_X], a ; Store Tilemap position into memory
    ld a, l
    ld [PLAYER_TILE_Y], a ; Store Tilemap position into memory
    ld b, h ; Load tilemap position X into B
    ld c, l ; Load tilemap position Y into C - BC now contains tile player is contained in
    ld d, $98 ; Set DE to $9800 - tilemap address
    ld e, $00 ; Set DE to $9800 - tilemap address
    ld a, c 
    ;add a, $01 ; Add 1 to Tilemap Y pos to get tile underneath player (TODO)
    ld c, a
    call GetTileAtPosition ; Get ID of Tile underneath player
    ld [PLAYER_TILE_ID], a
    cp $60 ; Compare to floor tile
    jr nz, .resetGrounded ; If not floor tile, set grounded flag to 0 again


    ld a, $01 
    ld [PLAYER_IS_GROUNDED], a ; Otherwise, we're grounded! go to your room
    xor a
    ld [PLAYER_DY], a ; reset velocity
    call GetTileTopLeftWorldPosition ; right now, we don't care about collisions in any direction but down!
    ld a, b
    ld [FLOOR_X], a
    ld a, c
    ld [FLOOR_Y], a
    sub a, $08
    ld [PLAYER_Y], a ; Reset player position
    jr .applyXVelocity

.resetGrounded
    xor a
    ld [PLAYER_IS_GROUNDED], a

.applyXVelocity:
    ld a, [PLAYER_DX]
    ld b, a
    ld a, [PLAYER_X]
    add a, b
    ld [PLAYER_X], a

    ld a, [PLAYER_X]
    ld h, a
    ld a, [PLAYER_Y]
    ld l, a
    call WorldToTileMap ; translate player position to tile position
    ld a, h
    ld [PLAYER_TILE_X], a
    ld a, l
    ld [PLAYER_TILE_Y], a
    ld b, h
    ld c, l
    ld d, $98
    ld e, $00 ; BG tilemap starts at $9800, so set this as offset
    ld a, c
    ;add a, $01 ; increment tile Y by 1 to get tile under player
    ld c, a
    call GetTileAtPosition ; Get TileID
    ld [PLAYER_TILE_ID], a
    call GetTileTopLeftWorldPosition ; Get Top-left pixel of tile under player
    ld a, b
    ld [PLAYER_TILE_TOP_X], a
    ld [FLOOR_X], a
    ld a, c
    ld [PLAYER_TILE_TOP_Y], a
    ld [FLOOR_Y], a
    ld a, $0F
    ld [FLOOR_SPRITE], a


.stop
    ret

SECTION "Echo OAM", WRAM0[$C100]
PLAYER_Y: DS 1
PLAYER_X: DS 1
PLAYER_SPRITE: DS 1
PLAYER_ATTRIBUTE : DS 1
FLOOR_Y: DS 1
FLOOR_X: DS 1
FLOOR_SPRITE: DS 1

SECTION "Player Values", WRAM0[$C000]
PLAYER_DY : DS 1
PLAYER_DX : DS 1

PLAYER_IS_GROUNDED : DS 1
PLAYER_TILE_X : DS 1
PLAYER_TILE_Y : DS 1
PLAYER_TILE_ID : DS 1
PLAYER_TILE_TOP_X : DS 1
PLAYER_TILE_TOP_Y : DS 1
;PLAYER_CAN_JUMP : DS 1 