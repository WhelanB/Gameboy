SECTION "Beans", ROM0


init_beans:
    xor a
    ld hl, $C14C
    ld [FRAME], a

.repeat ; Initialise the falling beans in VRAM
    ld d, a
    sla a
    sla a
    sla a
    ldi [hl], a
    ld a, d
    sla a
    sla a
    sla a
    add a, $0F
    ldi [hl], a
    ld a, $69
    ldi [hl], a
    xor a
    ldi [hl], a
    ld a, d
    inc a
    cp $10
    jr nz, .repeat
    ret
    
RandomNumber:

        push    hl
        ld      a,[RandomPtr]
        inc     a
        ld      [RandomPtr],a
        ld      hl,RandTable
        add     a,l
        ld      l,a
        jr      nc,.skip
        inc     h
.skip:  ld      a,[hl]
        pop     hl
        ret


update_beans:
    ld a, $10 ; load current level
    ld e, a
    xor a
    ld hl, $C14C
    ld a, [FRAME]
    inc a
    ld [FRAME], a
    SRL a
    jr c, .stop
    ld [FRAME], a

.repeatstuff
    ld d, a

    ld a, [TONGUE_LENGTH]
    cp $00
    jr z, .skipcoltest
    ld a, [TONGUE_EATING]
    cp $01
    jr z, .skipcoltest
    push hl
    ld a, [hl]
    ld c, a
    inc hl
    ld a, [hl]
    ld b, a
    ld a, [TONGUE_X]
    ld h, a
    ld a, [TONGUE_Y]
    ld l, a
    call checkOverlap
    ld [TONGUE_EATING], a
    pop hl
    cp $00
    jr z, .skipcoltest
    xor a
    ld [hl], a
    ld a, [GAME_SCORE]
    inc a
    ld [GAME_SCORE], a
.skipcoltest
    ld a, [hl] ; Load the Y-Pos into a
    inc a ; Add one to the Y-Pos
    ld [hl], a ; Restore the Y-Pos
    cp $87
    jr nz, .dontDestroy
    xor a
    ld [hl], a
    ld a, $C0
    ld [rNR44], a ; Play noise
    push hl
    inc hl
    ld a, [hl] ; Load the X-Pos
    ld hl, $9A00
    srl a
    srl a
    srl a ; Div by 8
    ld c, a
    xor a
    ld b, a
    add hl, bc
    ld a, $2C
    ld [hl], a
    pop hl
.dontDestroy
    inc hl ; Skip over Y-Pos
    inc hl ; Skip over X-Pos
    inc hl ; Skip over sprite
    inc hl ; Skip over sprite attribute
    ld a, d ; Restore a
    inc a ; Go to next bean
    cp e ; If we've not updated all beans
    jr nz, .repeatstuff ; Go to the next bean
.stop
    ret


SECTION "Echo OAM BEANS", WRAM0[$C14C]
BEAN_Y: DS 1
BEAN_X: DS 1
BEAN_SPRITE: DS 1
BEAN_ATTRIBUTE : DS 1
RandomPtr : DS 1
FRAME  : DS 1