INCLUDE "hardware.inc"

INCLUDE "helpers.asm"
INCLUDE "player.asm"

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

    ld [rNR52], a ; Disable sound
    ld a, %10000011 ;
    ld [rLCDC], a ; Enable LCD, Sprites and Background
    call init_player

.stop:
    halt
    nop

    call update_player

jr .stop

SECTION "Font", ROM0

FontTiles:
INCBIN "Sprites/font.chr"
FontTilesEnd:


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