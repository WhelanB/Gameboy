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

INCLUDE "Sprites/map.inc"
Start:
    ld	a, IEF_VBLANK ; Enable v-blank interrupt only
    ld	[rIE], a 
    call CopyDMARoutine
    ei

    halt ; Halt stops CPU until interrupt (v-blank) occurs
    nop ; nop, because of Halt bug

    call TurnOffLCD

    ld hl, $C100 ; clear OAM
    ld bc, $FE9F - _OAMRAM
    call memClear ; Copy tile data to VRAM

    ld hl, $8000 ; go to zero in first VRAM tileset
    ld de, map_tile_data ; Load tile data location
    ld bc, map_tile_data_size ; Load tile data size
    call memCopy ; Copy tile data to VRAM


    ld hl, $9000 ; go to zero in first VRAM tileset
    ld de, map_tile_data ; Load tile data location
    ld bc, map_tile_data_size ; Load tile data size
    call memCopy ; Copy tile data to VRAM

    ld hl, $9800 ; Load background location
    ld de, map_map_data ; Load tilemap location
    ld bc, map_tile_map_size ; Load tilemap size
    call memCopy ; Copy tilemap to background buffer

    ld a, %11100100 ; Set palette
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

    ld a, $88
    ld [$C100], a
    ld a, $22
    ld [$C101], a
    ld a, $0B
    ld [$C102], a
    ld a, $00
    ld [$C103], a

    ld a, $88
    ld [$C104], a
    ld a, $2A
    ld [$C105], a
    ld a, $1B
    ld [$C106], a
    ld a, $00
    ld [$C107], a

    ld a, $88
    ld [$C108], a
    ld a, $32
    ld [$C109], a
    ld a, $12
    ld [$C10A], a
    ld a, $00
    ld [$C10B], a

    ld a, $88
    ld [$C10C], a
    ld a, $3A
    ld [$C10D], a
    ld a, $0A
    ld [$C10E], a
    ld a, $00
    ld [$C10F], a

    ld a, $88
    ld [$C110], a
    ld a, $42
    ld [$C111], a
    ld a, $17
    ld [$C112], a
    ld a, $00
    ld [$C113], a

    ld [rNR52], a ; Disable sound
    ld a, %10000011 ;
    ld [rLCDC], a ; Enable LCD, Sprites and Background

.stop:
    call LoadBGLoc
    ld l, $88
    ld h, $22
    call WorldToScreenCoord
    ld [$C100], a
    ld a, h
    ld [$C101], a
    ld a, $0B
    ld [$C102], a
    ld a, $00
    ld [$C103], a
    halt
    nop


    ;call ScrollBGLeft
    call SampleInput ; Sample d-pad and buttons
    ld d, a ; Store state of input in c - should probably move this to ram
    cp 0 ; If no keys pressed, try again!
    jr z, .updatePos ; jump to wait for next frame

    bit PADB_LEFT, a ; check if d-pad left is pressed
    jr z, .testRight ; if it isn't, check if d-pad right is pressed
    call ScrollBGRightLim ; otherwise, scroll BG to the left
    ld b, a
    jr .testUp

.testRight:
    ld a, d ; Scrolling BG uses a register, so restore it from c
    bit PADB_RIGHT, a
    jr z, .testUp
    call ScrollBGLeft
    ld b, a

.testUp:
    ld a, d
    bit PADB_UP, a
    jr z, .testDown
    call ScrollBGDownLim
    ld c, a
    jr .updatePos

.testDown:
    ld a, d
    bit PADB_DOWN, a
    jr z, .updatePos
    call ScrollBGUpLim
    ld c, a
    

.updatePos

jr .stop

SECTION "Font", ROM0

FontTiles:
INCBIN "Sprites/font.chr"
FontTilesEnd:


SECTION "Echo OAM", WRAM0[$C100]

SECTION "Vblank", ROM0[$0040]
    ld a, $C1
    call $FF80
	reti

SECTION "OAM DMA routine", ROM0
CopyDMARoutine:
  ld  hl, DMARoutine
  ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
  ld  c, LOW($FF80) ; Low byte of the destination address
.copy
  ld  a, [hli]
  ldh [c], a
  inc c
  dec b
  jr  nz, .copy
  ret

DMARoutine:
  ldh [rDMA], a
  ld  a, 40
.wait
  dec a
  jr  nz, .wait
  ret
DMARoutineEnd:

SECTION "OAM DMA", HRAM

hOAMDMA::
  DS DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to