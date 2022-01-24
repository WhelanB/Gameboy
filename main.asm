INCLUDE "hardware.inc"
INCLUDE "helpers.asm"
INCLUDE "player.asm"
INCLUDE "tongue.asm"
INCLUDE "beans.asm"

SECTION "Header", ROM0[$100]

EntryPoint: ; This is where execution begins
    di ; Disable interrupts.
    jp Start ; Leave this tiny space
REPT $150 - $104
    db 0
ENDR

SECTION "Game", ROM0
INCLUDE "Sprites/map.inc"
INCLUDE "Sprites/beanrandomtable.inc"
INCLUDE "Sprites/startscreen.inc"
INCLUDE "Sprites/mainmenu.inc"
INCLUDE "Sprites/controls.inc"

Start:



    ld	a, IEF_VBLANK | IEF_LCDC ; Enable v-blank interrupt only
    ld	[rIE], a 
    call CopyDMARoutine
    ei

LD SP,$E000
; GAME OVER PROCESS
.controlsScreen

    call TurnOffLCD ; turn off the LCD and load the game over screen
    ld hl, $C100 ; clear OAM
    ld bc, $FE9F - _OAMRAM
    call memClear ; Copy tile data to VRAM

    ld hl, $8000 ; go to zero in first VRAM tileset
    ld de, startscreen_tile_data ; Load tile data location
    ld bc, startscreen_tile_data_size ; Load tile data size
    call memCopy ; Copy tile data to VRAM

    ld hl, $9000 ; go to zero in first VRAM tileset
    ld de, startscreen_tile_data ; Load tile data location
    ld bc, startscreen_tile_data_size ; Load tile data size
    call memCopy ; Copy tile data to VRAM

    ld hl, $9800 ; Load background location
    ld de, startscreen_map_data ; Load tilemap location
    ld bc, startscreen_tile_map_size ; Load tilemap size
    call memCopy ; Copy tilemap to background buffer

    ld a, %11100100 ; Set palette
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a
    ld a, %10000011 ;
    ld [rLCDC], a ; Enable LCD, Sprites and Background
.loopk
    halt
    nop
    call SampleInput
    cp $00
    jr z, .loopk
; GAME OVER PROCESS
.startScreen

    call TurnOffLCD ; turn off the LCD and load the game over screen
    ld hl, $C100 ; clear OAM
    ld bc, $FE9F - _OAMRAM
    call memClear ; Copy tile data to VRAM

    ld hl, $8000 ; go to zero in first VRAM tileset
    ld de, startscreen_tile_data ; Load tile data location
    ld bc, startscreen_tile_data_size ; Load tile data size
    call memCopy ; Copy tile data to VRAM

    ld hl, $9000 ; go to zero in first VRAM tileset
    ld de, startscreen_tile_data ; Load tile data location
    ld bc, startscreen_tile_data_size ; Load tile data size
    call memCopy ; Copy tile data to VRAM

    ld hl, $9800 ; Load background location
    ld de, startscreen_map_data ; Load tilemap location
    ld bc, startscreen_tile_map_size ; Load tilemap size
    call memCopy ; Copy tilemap to background buffer

    ld a, %11100100 ; Set palette
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a
    ld a, %10000011 ;
    ld [rLCDC], a ; Enable LCD, Sprites and Background
.loopj
    halt
    nop
    call SampleInput
    cp $00
    jr z, .loopj

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

    xor a
    ld [GAME_SCORE], a ; Set score to 0
    ld a, $01
    ld [GAME_LEVEL], a ; Set first level to 1


;    ld [rNR52], a ; Disable sound
    ld a, %01110111
    ld [rAUDVOL], a
    ld a, %11111111
    ld [rAUDTERM], a
    ld a, %10000111 ;
    ld [rLCDC], a ; Enable LCD, Sprites and Background
    call init_player
    call init_tongue
    call init_beans
    ld a, $02
    ld [NEXT_BEAN], a
    xor a
    ld [FRAME], a

; MAIN GAME LOOP
.stop:
    ld a, [GAME_OVER]
    cp $01
    jr z, .gameOver
    halt
    nop
    ; Potentially move bean tilemap updating code into v-blank interrupt
    call update_beans
    call update_player
    call update_tongue
    call renderScore
    ld a, [FRAME]
    SRL a ; 
    jp c, .dontreset

    ld a, [NEXT_BEAN]
    cp $13
    jr z, .reset
    inc a
    ld [NEXT_BEAN], a
    jr .stop
.reset
    ld a, $02
    ld [NEXT_BEAN], a
.dontreset
jr .stop



; GAME OVER PROCESS
.gameOver

; FADE OUT THE SCREEN TO WHITE
    call fadeOut

    halt
    nop
    xor a
    ld [GAME_OVER], a ; reset game over flag


    call TurnOffLCD ; turn off the LCD and load the game over screen
    ld hl, $C100 ; clear OAM
    ld bc, $FE9F - _OAMRAM
    call memClear ; Copy tile data to VRAM

    ld hl, $8000 ; go to zero in first VRAM tileset
    ld de, mainmenu_tile_data ; Load tile data location
    ld bc, mainmenu_tile_data_size ; Load tile data size
    call memCopy ; Copy tile data to VRAM

    ld hl, $9000 ; go to zero in first VRAM tileset
    ld de, mainmenu_tile_data ; Load tile data location
    ld bc, mainmenu_tile_data_size ; Load tile data size
    call memCopy ; Copy tile data to VRAM

    ld hl, $9800 ; Load background location
    ld de, mainmenu_map_data ; Load tilemap location
    ld bc, mainmenu_tile_map_size ; Load tilemap size
    call memCopy ; Copy tilemap to background buffer

    ld a, %10000011 ;
    ld [rLCDC], a ; Enable LCD, Sprites and Background

    call fadeIn ; fade back in
.loopi
    halt
    nop
    call SampleInput
    cp $00
    jr z, .loopi
    jp Start


wait:
    ld a, %00000110
    ld [rTAC], a
    ld a, $00
    ld [rTMA], a
    di
    ld	a, IEF_TIMER
    ld	[rIE], a
    ei
    halt
    nop
    di
    ld	a, IEF_VBLANK | IEF_LCDC
    ld	[rIE], a
    ei
    ret


fadeIn:
    ld a, $10
    ld b, a
.fadein
    ld a, b
    call StepFadeInDefaultPallete
    halt
    nop
    ld a, b
    dec a
    ld b, a
    cp $01
    jr nz, .fadein
.doneFadeIn
    ret

fadeOut:
    ld a, $10
    ld b, a
.fadeout
    ld a, b
    call StepFadeOutDefaultPallete
    halt
    nop
    ld a, b
    dec a
    ld b, a
    cp $01
    jr nz, .fadeout
.doneFadeOut
    ret

renderScore:
    ld a, [GAME_LEVEL]
    ld b, a
    ld a, [GAME_SCORE]
    cp b
    jr z, .incrementLevel
    jp .display
.incrementLevel
    ld a, [GAME_LEVEL]
    jp .cont
.cont
    ld a, [GAME_LEVEL]
    add a, $01
    daa ; converts contents of a register into BCD
    ld [GAME_LEVEL], a
    xor a
    ld [GAME_SCORE], a
    ld a, $81
    ld [rNR21], a
    ld a, $84
    ld [rNR22], a
    ld a, $D7
    ld [rNR23], a
    ld a, $86
    ld [rNR24], a
.display
    ld a, [GAME_SCORE]
    and $0f
    ld [$9a27], a
    ld a, [GAME_SCORE]
    and $f0
    swap a
    ld [$9a26], a

    ld a, [GAME_LEVEL]
    and $0f
    ld [$9a31], a
    ld a, [GAME_LEVEL]
    and $f0
    swap a
    ld [$9a30], a
    ret

SECTION "Global Values", WRAM0[$C000]
GAME_PAUSED : DS 1
GAME_OVER : DS 1
GAME_SCORE : DS 1
GAME_LEVEL : DS 1
NEXT_BEAN : DS 1
ACTIVE_BEANS : DS 1
FRAME : DS 1
RandomPtr : DS 1

SECTION "Font", ROM0

FontTiles:
INCBIN "Sprites/font.chr"
FontTilesEnd:


SECTION "Vblank", ROM0[$0040]
    ld a, $C1
    call $FF80
	reti

SECTION "lcdc",ROM0[$0048]
    call ScrollBGRight
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