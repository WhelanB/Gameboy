SECTION "Player", ROM0
; These three values MUST be multiples
PLAYER_GRAVITY equ %00000110 ; 0.1875 (000.00110)
GRAVITY_LIM equ $84 ; (100.00100)
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
    ld a, [PLAYER_ATTRIBUTE]
    or OAMF_XFLIP
    ld [PLAYER_ATTRIBUTE], a
    jr .testJump

.testRight:
    ld a, c
    bit PADB_RIGHT, a
    jr z, .testJump
    ld a, $02
    ld [PLAYER_DX], a
    ld a, [PLAYER_ATTRIBUTE]
    and OMF_XFLIP_INV
    ld [PLAYER_ATTRIBUTE], a

.testJump:
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
    ;xor a ; set A reg to 0
    ;ld [PLAYER_DY], a ; reset delta Y to 0
    ;ld a, [FLOOR_Y] ; Load floor position
    ;ld [PLAYER_Y], a ; push back to top of floor
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

.applyYVelocity:
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
    ld a, [PLAYER_DY]
    bit OAMB_PRI, a
    jr nz, .resolveYPenetrationUp ; Only check for collisions if we're falling

.resolveYPenetrationDown ; Need to fix clipping at edge of tile on right side
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
    call GetTileAtPosition ; Get ID of Tile underneath player
    ld [PLAYER_TILE_ID], a
    cp $60 ; Compare to floor tile
    jr nz, .resetGrounded ; If not floor tile, set grounded flag to 0 again


    ld a, $01 
    ld [PLAYER_IS_GROUNDED], a ; Otherwise, we're grounded! go to your room
    xor a
    ld [PLAYER_DY], a ; reset velocity
    call GetTileTopLeftWorldPosition ; right now, we don't care about collisions in any direction but down!
    ld a, c
    sub a, $08
    ld [PLAYER_Y], a ; Reset player position
    jr .applyXVelocity

.resolveYPenetrationUp ; TODO there is a lot of duplicate code between here and resolveYPenetrationDown
    ld a, [PLAYER_X] ; Load Player X pos into H
    add a, $04 ; middle of player
    ld h, a
    ld a, [PLAYER_Y] ; Load Player Y pos into L - HL now contains position
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

    call GetTileAtPosition ; Get ID of Tile over player
    ld [PLAYER_TILE_ID], a
    cp $60 ; Compare to floor tile
    jr nz, .resetGrounded ; If not floor tile, set grounded flag to 0 again

    xor a
    ld [PLAYER_DY], a ; reset velocity
    call GetTileBottomRightWorldPosition ; right now, we don't care about collisions in any direction but down!
    ld a, c   
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

    ld a, [PLAYER_DX]
    bit OAMB_PRI, a
    jr nz, .resolveXPenetrationLeft ; Are we going left or right?

.resolveXPenetrationRight
    ld a, [PLAYER_X] ; Load Player X pos into H
    add a, $08
    ld h, a
    ld a, [PLAYER_Y] ; Load Player Y pos into L - HL now contains position
    add a, $04 ; middle of player
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
    call GetTileAtPosition ; Get ID of Tile underneath player
    ld [PLAYER_TILE_ID], a
    cp $60 ; Compare to floor tile
    jr nz, .stop ; If not floor tile, set grounded flag to 0 again


    xor a
    ld [PLAYER_DX], a ; reset velocity
    call GetTileTopLeftWorldPosition ; Get the left pos of the tile
    ld a, b
    sub a, $08  
    ld [PLAYER_X], a ; Reset player position
    jr .stop

.resolveXPenetrationLeft ; TODO there is a lot of duplicate code between here and resolveXPenetrationRight
    ld a, [PLAYER_X] ; Load Player X pos into H
    ld h, a
    ld a, [PLAYER_Y] ; Load Player Y pos into L - HL now contains position
    add a, $04 ; middle of player
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
    call GetTileAtPosition ; Get ID of Tile underneath player
    ld [PLAYER_TILE_ID], a
    cp $60 ; Compare to floor tile
    jr nz, .stop ; If not floor tile, set grounded flag to 0 again


    xor a
    ld [PLAYER_DX], a ; reset velocity
    call GetTileBottomRightWorldPosition ; Get the left pos of the tile
    ld a, b  
    ld [PLAYER_X], a ; Reset player position
    jr .stop


.stop
    ret

SECTION "Echo OAM", WRAM0[$C100]
PLAYER_Y: DS 1
PLAYER_X: DS 1
PLAYER_SPRITE: DS 1
PLAYER_ATTRIBUTE : DS 1
FLOOR_Y: DS 1 ; Debug sprite used to check tile positions
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