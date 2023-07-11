SECTION "Beans", ROM0
BEAN_POOL_SIZE EQU $0A ; The number of beans to initialise into the pool

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
    ld a, $A1 ; a1
    ld [rNR42], a
    ld a, $90 ; 00
    ld [rNR43], a
    ld a, $80
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
; 16X16 BEANS TEST
    ld e, a ; put the position into e, so we can set it on the second sprite later
; end
    ldi [hl], a
    ld a, $68
    ldi [hl], a ; Set sprite to tile 68
    xor a
    ldi [hl], a ; Set sprite attributes to 0
; 16X16 BEANS TEST
    xor a
    ldi [hl], a
    ld a, e
    add a, $08
    ldi [hl], a
    ld a, $68
    ldi [hl], a
    ld a, %00100000 ; flip the other sprite
    ldi [hl], a
; END
    ld a, d ; Restore index back into a
    inc a ; Increment index
; 16X16 BEANS TEST
    inc a
;END
    cp BEAN_POOL_SIZE * 2 ; If index != pool size, repeat 
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
;16X16 BEANS TEST
; always odd
        cp $01
        jr nz, .cont
        add $02
.cont
        rr a
        jp Nc, .stop
        rl a
        sub $01
        
.stop
        pop     hl
        ret


update_beans:
    xor a ; zero out a
    ld hl, $C14C ; Load the echo OAM address into hl, so we can index sprites from here on out
    ld a, [FRAME]
    inc a
    ld [FRAME], a ; Increment the frame counter, which controls bean speed
    SRL a ; Check if it's even or odd, skip updating on odd ticks
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
    ld a, [TONGUE_COLL_X] ; load the tongue tip x-pos
    ld h, a ; into h
    ld a, [TONGUE_COLL_Y] ; load the tongue tip y-pos
    ld l, a ; into l
    call checkPointInSpriteLarge ; check if bc overlaps with hl (if the tongue overlaps with the current bean)
    ld [TONGUE_EATING], a ; if it is, set the tongue to eating so it knows to retract
    pop hl ; restore hl
    cp $00 ; if the result of checkOverlap was 0
    jr z, .skipcoltest ; skip the next section

; We've hit a bean, so reset it back to the top of the screen
    xor a
    ld [hl], a ; load zero into location at hl (resets the y-pos of the current bean)

    inc hl
    inc hl
    inc hl
    inc hl
    ld [hl], a
    dec hl
    dec hl
    dec hl
    dec hl

    inc hl ; REMOVE ME
    call GetNextBeanAisle
    sla a
    sla a
    sla a
    ld [hl], a

    inc hl
    inc hl
    inc hl
    inc hl
    add a, $08
    ld [hl], a
    dec hl
    dec hl
    dec hl
    dec hl

    dec hl
    ld a, [TONGUE_LENGTH]
    sra a
    sra a
    sra a
    ld b, a ; Add tongue length to score - the further the tongue reaches, the higher points awarded
    add a, $0
    daa
    ld [GAME_LAST_INCREMENT], a
    ld a, [GAME_SCORE] ; load the current score into a
    add a, b
    daa ; convert to binary-coded decimal
    ld [GAME_SCORE], a ; set the current game score to a
    ld a, [GAME_LEVEL]
    adc a, $0
    daa
    ld [GAME_LEVEL], a
    


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
    jr .moveBean

.hitPlayer
    ld a, [PLAYER_IS_GROUNDED]
    cp $01
    jr z, .isGrounded ; if the player is grounded, game over man, game over!

    xor a
    ld [hl], a ; load zero into location at hl (resets the y-pos of the current bean)

    inc hl
    inc hl
    inc hl
    inc hl
    ld [hl], a
    dec hl
    dec hl
    dec hl
    dec hl

    inc hl ; REMOVE ME
    call GetNextBeanAisle
    sla a
    sla a
    sla a
    ld [hl], a

    inc hl
    inc hl
    inc hl
    inc hl
    add a, $08
    ld [hl], a
    dec hl
    dec hl
    dec hl
    dec hl

    dec hl
    ld a, [GAME_SCORE] ; load the current score into a
    inc a ; increment a
    daa ; convert to binary-coded decimal, so we can render it easily
    ld [GAME_SCORE], a ; set the current game score to a
    ld a, [GAME_LEVEL]
    adc a, $0
    daa
    ld [GAME_LEVEL], a
    ld a, $01
    daa
    ld [GAME_LAST_INCREMENT], a
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
    jr .moveBean


.isGrounded
    ld a, $01
    ld [GAME_OVER], a
    cp $01
    jp z, .stop

    
.moveBean
    ld a, [PLAYER_STEP_COUNT]
    ld a, [hl] ; Load the Y-Pos into a
    inc a ; Add one to the Y-Pos
    ld [hl], a ; Restore the Y-Pos

    inc hl
    inc hl
    inc hl
    inc hl
    ld [hl], a ; Restore the Y-Pos
    dec hl
    dec hl
    dec hl
    dec hl

    cp $88 ; $87 is the floor pos
    jr nz, .dontDestroy ; if we are not at the floor pos, skip to dontDestroy
    ;ld a, [NEXT_BEAN] ;; TODO what are these lines doing?
    ;sla a
    ;ld c, a
    ld a, $90
    ;sub a, c
    ld [hl], a ; set the y-pos back to 0

    inc hl
    inc hl
    inc hl
    inc hl
    ld [hl], a ; Restore the Y-Pos
    dec hl
    dec hl
    dec hl
    dec hl

    push hl ; push hl on to the stack
    inc hl
    ld a, [hl] ; Load the X-Pos
    srl a
    srl a
    srl a ; div by 8
    sub a, $01
    call damage_tile

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

    inc hl
    inc hl
    inc hl
    inc hl
    add a, $08
    ld [hl], a
    dec hl
    dec hl
    dec hl
    dec hl

    dec hl
.dontDestroy
    inc hl ; Skip over Y-Pos
    inc hl ; Skip over X-Pos

    ;inc hl ; Skip over sprite
    push hl
    ld hl, FLY_ANIM
    xor a
    ld b, a
    ld a, [PLAYER_STEP_COUNT]
    ld c, a
    add hl, bc
    ld a, [hl]
    pop hl
    ldi [hl], a

    inc hl ; Skip over sprite attribute
    inc hl ; Skip over Y-Pos
    inc hl ; Skip over X-Pos

    ;inc hl ; Skip over sprite
    push hl
    ld hl, FLY_ANIM
    xor a
    ld b, a
    ld a, [PLAYER_STEP_COUNT]
    ld c, a
    add hl, bc
    ld a, [hl]
    pop hl
    ldi [hl], a

    inc hl ; Skip over sprite attribute
    ld a, [ACTIVE_BEANS]
    ld b, a
    ld a, d ; Restore a
    inc a ; Go to next bean
    cp b ; If we've not updated all beans
    jp nz, .repeatstuff ; Go to the next bean
.stop
    ret

SECTION "Beans WRAM", WRAM0[$C300] ; Bean scratchpad
SECTION "Echo OAM BEANS", WRAM0[$C14C] ; Bean instances
BEAN_Y: DS 1 ; First bean instance Y-pos (useful for indexing)
BEAN_X: DS 1 ; First bean instance X-pos (useful for indexing)
BEAN_SPRITE: DS 1 ; First bean instance sprite
BEAN_ATTRIBUTE : DS 1 ; First bean instance sprite attributes
BEAN_POOL_MEM_CHUNK : DS BEAN_POOL_SIZE * 4 ; Block out enough memory for remaining bean instances (pool size is compile time)