INCLUDE "hardware.inc"

INCLUDE "helpers.asm"

SECTION "Header", ROM0[$100]

EntryPoint: ; This is where execution begins
    di ; Disable interrupts.
    jp Start ; Leave this tiny space
REPT $150 - $104
    db 0
ENDR

SECTION "Game", ROM0

INCLUDE "Sprites/inigo.inc"
Start:
    ld	a, IEF_VBLANK ; Enable v-blank interrupt only
    ld	[rIE], a 
    
    ei

    halt
    nop

    call TurnOffLCD
    ld hl, $9000 ; go to zero in first VRAM tileset
    ld de, Untitled_tile_data ; Load tile data location
    ld bc, Untitled_tile_data_size ; Load tile data size
    call memCopy ; Copy tile data to VRAM

    ld hl, $9800 ; Load background location
    ld de, Untitled_map_data ; Load tilemap location
    ld bc, Untitled_tile_map_size ; Load tilemap size
    call memCopy ; Copy tilemap to background buffer

    ld a, %11100100 ; Set palette
    ld [rBGP], a


    ld [rNR52], a ; Disable sound
    ld a, %10000001
    ld [rLCDC], a ; Enable LCD and Background

.stop:

    call WaitVBlank
    
    call SampleInput ; Sample d-pad and buttons
    ld c, a ; Store state of input in c - should probably move this to ram
    cp 0 ; If no keys pressed, try again!
    jr z, .stop ; jump to wait for next frame

    bit PADB_LEFT, a ; check if d-pad left is pressed
    jr z, .testRight ; if it isn't, check if d-pad right is pressed
    call ScrollBGLeft ; otherwise, scroll BG to the left

.testRight:
    ld a, c ; Scrolling BG uses a register, so restore it from c
    bit PADB_RIGHT, a
    jr z, .testUp
    call ScrollBGRight

.testUp:
    ld a, c
    bit PADB_UP, a
    jr z, .testDown
    call ScrollBGUp

.testDown:
    ld a, c
    bit PADB_DOWN, a
    jr z, .stop
    call ScrollBGDown

jr .stop

SECTION "Font", ROM0

FontTiles:
INCBIN "Sprites/font.chr"
FontTilesEnd:

SECTION "OAM Vars", WRAM0[$C100]
scroll: DS 1

SECTION "Vblank", ROM0[$0040]
	reti