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





;memCopy
; Copies a range of values from one location to another
; Params:
; de - A pointer to the memory to be copied
; bc - The amount of data to copy
; hl - A pointer to the beginning of the destination buffer
memCopy:
    ld a, [de] ; Grab a byte
    ld [hli], a ; Place it into VRAM
    inc de ; get next byte
    dec bc ; decrement size counter
    ld a, b ; check if size counter is 0
    or c
    jr nz, memCopy ; keep going if not zero
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
