SECTION "Beans", ROM0
BEAN_POOL_SIZE EQU $03 ; The number of beans to initialise into the pool

; init_beans
; This iterates over the area of WRAM allocated for beans
; First, configure sound and frame counter
; Next, for the number of beans defined in BEAN_POOL_SIZE, we:
;       Set Bean start Y-pos to 0
;       Set Bean start X-pos to bean index * 8 + offset for walls
;       Set Bean sprite to $68 (see map.inc)
;       Zero out the sprite attribute field
init_beans:
    ld a, $3D ; 3f
    ld [rNR41], a
    ld a, $53 ; a1
    ld [rNR42], a
    ld a, $60 ; 00
    ld [rNR43], a
    ld a, $C0
    ld [rNR44], a ; Hard-coded values to configure the bean destroy sound-effect
    ld hl, $C14C

    xor a
    ld [FRAME], a ; zero out the frame counter, a temporary way of controlling bean speed

.repeat ; Initialise the falling beans in VRAM
    ld d, a ; cache the loop index in d so we can perform arithmetic on a
    xor a
    ldi [hl], a ; zero out the y-pos and increment
    ld a, d ; restore the index into a
    call GetNextBeanAisle
    sla a
    sla a
    sla a
    add a, $10; add $10, since x pos is -8 and there are walls at the side of the map
    ldi [hl], a
    ld a, $68
    ldi [hl], a ; Set sprite to tile 68
    xor a
    ldi [hl], a ; Set sprite attributes to 0
    ld a, d ; Restore index back into a
    inc a ; Increment index
    cp BEAN_POOL_SIZE ; If index != pool size, repeat 
    jr nz, .repeat
    ret ; Otherwise, return
    
; GetNextBeanAisle
; Read a random number from the BeanRandomTable and return it (next aisle for the bean to fall in)
GetNextBeanAisle:
        push    hl
        ld      a, [RandomPtr]
        inc     a
        ld      [RandomPtr], a
        ld      hl, BeanRandomTable
        add     a, l
        ld      l, a
        jr      nc, .skip
        inc     h
.skip:  ld      a, [hl]
        pop     hl
        ret


update_beans:
    xor a ; zero out a
    ld hl, $C14C ; Load the echo OAM address into hl
    ld a, [FRAME]
    inc a
    ld [FRAME], a ; Increment the frame counter, which controls bean speed
    SRL a ; 
    jp c, .stop
    xor a

.repeatstuff
    ld d, a ; load the index into d so we can perform other operations over a
    ld a, [TONGUE_LENGTH] ; Load tongue length
    cp $00 ; check if tongue length is zero
    jr z, .skipcoltest ; if it is, don't bother checking the beans for tongue collisions, since it isn't deployed
    ld a, [TONGUE_EATING] ; if the tongue is currently eating a bean
    cp $01
    jr z, .skipcoltest ; don't check other beans for collisions, since the tongue will retract



    ; CHECK OVERLAP WITH TONGUE
    push hl ; save hl, since it is used as a memory address
    ld a, [hl] ; load the current bean y-pos
    add a, $08
    ld c, a ; into c
    inc hl ; inc hl to get x-pos
    ld a, [hl] ; load the current bean x-pos
    ld b, a ; into b
    ld a, [TONGUE_X] ; load the tongue tip x-pos
    ld h, a ; into h
    ld a, [TONGUE_Y] ; load the tongue tip y-pos
    ld l, a ; into l
    call checkOverlap ; check if bc overlaps with hl (if the tongue overlaps with the current bean)
    ld [TONGUE_EATING], a ; if it is, set the tongue to eating so it knows to retract
    pop hl ; restore hl
    cp $00 ; if the result of checkOverlap was 0
    jr z, .skipcoltest ; skip the next section

; RESET BEAN
    xor a
    ld [hl], a ; load zero into location at hl (resets the y-pos of the current bean)
    inc hl ; REMOVE ME
    call GetNextBeanAisle
    sla a
    sla a
    sla a
    ld [hl], a
    dec hl
    ld a, [GAME_SCORE] ; load the current score into a
    inc a ; increment a
    daa ; convert to binary-coded decimal
    ld [GAME_SCORE], a ; set the current game score to a


.skipcoltest
    ; CHECK OVERLAP WITH PLAYER
    push hl ; save hl, since it is used as a memory address
    ld a, [hl] ; load the current bean y-pos
    add $10 ; Add 16 to offset to bottom of 8x16 sprite
    ld c, a ; into c
    inc hl ; inc hl to get x-pos
    ld a, [hl] ; load the current bean x-pos
    ld b, a ; into b
    ld h, b
    ld l, c
    ld a, [PLAYER_X] ; load the player x-pos
    ld b, a ; into h
    ld a, [PLAYER_Y] ; load the player y-pos
    add a, $08
    ld c, a ; into l
    call checkOverlapLarge ; check if bc overlaps with hl (if the PLAYER overlaps with the current bean)
    pop hl
    cp $01
    jr z, .hitPlayer ; handle collision logic
    jr .idekam

.hitPlayer
    ld a, [PLAYER_IS_GROUNDED]
    cp $01
    jr z, .isGrounded ; if the player is grounded, game over man, game over!

    xor a
    ld [hl], a ; load zero into location at hl (resets the y-pos of the current bean)
    inc hl ; REMOVE ME
    call GetNextBeanAisle
    sla a
    sla a
    sla a
    ld [hl], a
    dec hl
    ld a, [GAME_SCORE] ; load the current score into a
    inc a ; increment a
    daa ; convert to binary-coded decimal, so we can render it easily
    ld [GAME_SCORE], a ; set the current game score to a
    ld a, $25 ; 3f
    ld [rNR10], a
    ld a, $84 ; a1
    ld [rNR11], a
    ld a, $45 ; 00
    ld [rNR12], a
    ld a, $9A
    ld [rNR13], a ; Play noise
    ld a, $86
    ld [rNR14], a
    ld a, $01
    jr .idekam


.isGrounded
    ld a, $01
    ld [GAME_OVER], a
    cp $01
    jr z, .stop

    
.idekam
    ld a, [hl] ; Load the Y-Pos into a
    inc a ; Add one to the Y-Pos
    ld [hl], a ; Restore the Y-Pos
    cp $88 ; $87 is the floor pos
    jr nz, .dontDestroy ; if we are not at the floor pos, skip to dontDestroy
    ld a, [NEXT_BEAN]
    sla a
    ld c, a
    xor a ; otherwise, xor a
    sub a, c
    ld [hl], a ; set the y-pos back to 0
    push hl ; push hl on to the stack
    inc hl
    ld a, [hl] ; Load the X-Pos
    ld hl, $9A00
    srl a
    srl a
    srl a ; div by 8
    sub $01 ; subtract 1 to get correct block
    ld c, a
    xor a
    ld b, a
    add hl, bc
    ld a, [hl]
    cp $2C
    jr z, .dontReplace
    cp $65
    jr z, .replaceAir
.replaceBroken
    ld a, $65
    jr .doReplace
.replaceAir
    ld a, $2C
.doReplace
    ld [hl], a
    ld a, $C0
    ld [rNR44], a ; Play noise
.dontReplace
    pop hl
    inc hl
    call GetNextBeanAisle
    sla a
    sla a
    sla a
    ld [hl], a
    dec hl
.dontDestroy
    inc hl ; Skip over Y-Pos
    inc hl ; Skip over X-Pos
    inc hl ; Skip over sprite
    inc hl ; Skip over sprite attribute
    ld a, d ; Restore a
    inc a ; Go to next bean
    cp BEAN_POOL_SIZE ; If we've not updated all beans
    jp nz, .repeatstuff ; Go to the next bean
.stop
    ret


SECTION "Echo OAM BEANS", WRAM0[$C14C] ; Bean instances
BEAN_Y: DS 1 ; First bean instance Y-pos (useful for indexing)
BEAN_X: DS 1 ; First bean instance X-pos (useful for indexing)
BEAN_SPRITE: DS 1 ; First bean instance sprite
BEAN_ATTRIBUTE : DS 1 ; First bean instance sprite attributes
BEAN_POOL_MEM_CHUNK : DS BEAN_POOL_SIZE * 4 ; Block out enough memory for remaining bean instances (pool size is compile time)