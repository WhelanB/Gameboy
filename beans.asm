SECTION "Beans", ROM0
BEAN_POOL_SIZE EQU $08 ; The number of beans to initialise into the pool

init_beans:
    ld hl, $C14C
    xor a
    ;ld [FRAME], a

.repeat ; Initialise the falling beans in VRAM
    ld d, a ; cache the loop index in d so we can perform arithmetic on a
    sla a
    sla a
    sla a ; multiply the index by 8
    sla a
    ldi [hl], a ; zero out the y-pos and increment
    ld a, d ; restore the index into a
    sla a
    sla a
    sla a ; multiply the index by 8
    add a, $0F ; add $0F, since x pos is -8 and there are walls at the side of the map
    ldi [hl], a
    ld a, $69
    ldi [hl], a ; Set sprite to tile 69
    xor a
    ldi [hl], a ; Set sprite attributes to 0
    ld a, d ; Restore index back into a
    inc a ; Increment index
    cp BEAN_POOL_SIZE ; If index != pool size, repeat 
    jr nz, .repeat
    ret ; Otherwise, return
    
;RandomNumber: ; Fetch a random number from the RandTable;

;        push    hl
;        ld      a,[RandomPtr]
;        inc     a
;        ld      [RandomPtr],a
;        ld      hl,RandTable
;        add     a,l
;        ld      l,a
;        jr      nc,.skip
;        inc     h
;.skip:  ld      a,[hl]
;        pop     hl
;        ret


update_beans:
    xor a ; zero out a
    ld hl, $C14C ; Load the echo OAM address into hl
    ; temporarily remove FRAME counter as it shared a memory address with the x-pos of the second bean (oops!)
    ;ld a, [FRAME]
    ;inc a
    ;ld [FRAME], a ; Increment the frame counter
    ;SRL a ; 
    ;jr c, .stop
    ;ld [FRAME], a
    xor a

.repeatstuff
    ld d, a ; load the index into d
    ld a, [TONGUE_LENGTH] ; Load tongue length
    cp $00 ; check if tongue length is zero
    jr z, .skipcoltest ; if it is, don't bother checking the beans for tongue collisions
    ld a, [TONGUE_EATING] ; if the tongue is currently eating a bean
    cp $01
    jr z, .skipcoltest ; don't check other beans for collisions, since the tongue will retract
    push hl ; save hl
    ld a, [hl] ; load the current bean y-pos
    ld c, a ; into c
    inc hl ; inc hl to get x pos
    ld a, [hl] ; load the current bean x-pos
    ld b, a ; into b
    ld a, [TONGUE_X] ; load the tongue tip x into h
    ld h, a
    ld a, [TONGUE_Y] ; load the tongue tip y into l
    ld l, a
    call checkOverlap ; check if bc overlaps with hl
    ld [TONGUE_EATING], a ; if it is, set the tongue to eating
    pop hl ; restore hl
    cp $00 ; if the result of checkOverlap was 0
    jr z, .skipcoltest ; skip the next section
    xor a ; zero out a
    ld [hl], a ; load zero into hl
    ld a, [GAME_SCORE] ; load the current score into a
    inc a ; increment a
    daa
    ld [GAME_SCORE], a ; set the current game score to a
.skipcoltest
    ld a, [hl] ; Load the Y-Pos into a
    inc a ; Add one to the Y-Pos
    ld [hl], a ; Restore the Y-Pos
    cp $87 ; $87 is the floor pos
    jr nz, .dontDestroy
    xor a
    ld [hl], a
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
    ld a, [hl]
    cp $2C
    jr z, .dontReplace
    ld a, $2C
    ld [hl], a
    ld a, $C0
    ld [rNR44], a ; Play noise
.dontReplace
    pop hl
.dontDestroy
    inc hl ; Skip over Y-Pos
    inc hl ; Skip over X-Pos
    inc hl ; Skip over sprite
    inc hl ; Skip over sprite attribute
    ld a, d ; Restore a
    inc a ; Go to next bean
    cp BEAN_POOL_SIZE ; If we've not updated all beans
    jr nz, .repeatstuff ; Go to the next bean
.stop
    ret


SECTION "Echo OAM BEANS", WRAM0[$C14C]
BEAN_Y: DS 1
BEAN_X: DS 1
BEAN_SPRITE: DS 1
BEAN_ATTRIBUTE : DS 1