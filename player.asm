
;======================================
; move player, check for leaving
; screen, end game check, switch
; ship types
;======================================
MovePlayer      .proc
                lda onScreen            ; if not on screen, set sound
                bne _ADDCLOK

;   do the appropriate sound effect based on the ship type
                lda zpShipType          ; player is Balloon?
                cmp #stBalloon
                beq _STBLSND            ;   yes, do that

                lda #$96                ; set plane sound
                sta SID2_FREQ1
                lda #$24
                sta SID2_CTRL1
                bra _ADDCLOK            ; & goto clock add

_STBLSND        lda #0                  ; set wind sound
                sta SID2_FREQ1
                lda #2
                sta SID2_CTRL1

_ADDCLOK        inc CLOCK               ; add to clock
                lda CLOCK               ; if clock and
                and zpShipType          ; mask<>0 then don't move
                beq _cont1

                jmp _DODELAY

;   move the players
_cont1          lda PlayerPosX          ; first player 1
                clc
                adc DIR
                sta PlayerPosX

                .mult2p32 zpTemp1       ; Accum*2+32, result in zpTemp1:Accum

                sta SPR(sprite_t.X, 0)  ; player 1 x-coordinate (aircraft & bomb)
                sta SPR(sprite_t.X, 2)
                lda zpTemp1
                sta SPR(sprite_t.X+1, 0)
                sta SPR(sprite_t.X+1, 2)

                lda #152                ; then player 2
                sec
                sbc PlayerPosX
                sta PlayerPosX+1

                .mult2p32 zpTemp1       ; Accum*2+32, result in zpTemp1:Accum

                sta SPR(sprite_t.X, 1)  ; player 2 x-coordinate (aircraft & bomb)
                sta SPR(sprite_t.X, 3)
                lda zpTemp1
                sta SPR(sprite_t.X+1, 1)
                sta SPR(sprite_t.X+1, 3)

;   player animation
                lda zpShipType          ; if on planes then check if time to animate
                cmp #stPlane
                bne _DODELAY

                lda CLOCK               ; props
                and #2
                beq _DODELAY            ;   no, skip this

                lda DIR                 ; set temp direction
                sta tmpDIR              ; (will be killed)

                ldx #1

_next3          stx HOLDIT              ; save player #

                stz zpTemp1
                stz zpTemp2

                lda tmpDIR              ; get direction index from dir
                and #$10                ; moving left?
                beq _1                  ;   yes

                lda #2                  ;   no, moving right
                sta zpTemp2             ; move ahead by 2 stamps

_1              lda CLOCK               ; get image index from clock
                and #4                  ; switch the propeller frame?
                beq _2                  ;   no

                inc zpTemp2             ;   yes

_2              lda zpTemp2
                clc
                adc #>SPR_PlaneLA
                sta zpTemp2

                ldx HOLDIT
                cpx #0
                beq _plyr00

                ; valid values: {7c00|7d00|7e00|7f00}

                lda zpTemp1
                sta SPR(sprite_t.ADDR, 1)
                lda zpTemp2
                sta SPR(sprite_t.ADDR+1, 1)
                bra _cont2

_plyr00         lda zpTemp1
                sta SPR(sprite_t.ADDR, 0)
                lda zpTemp2
                sta SPR(sprite_t.ADDR+1, 0)

_cont2          lda tmpDIR              ; reverse tdir
                eor #$FE
                sta tmpDIR

                ldx HOLDIT              ; get player #
                dex                     ; & animate next
                bpl _next3

;   wait for a while to make game playable
_DODELAY        lda JIFFYCLOCK
                inc A
_wait1          cmp JIFFYCLOCK
                bne _wait1

;   players should now be on screen, but check to see if they aren't
                lda #TRUE
                sta onScreen

                lda PlayerPosX
                beq _OFFSCR

                cmp #152
                beq _OFFSCR
                bra _XIT                ; if on, return

_OFFSCR         lda #0                  ; else, turn off explosions and bkg sound
                sta SID1_CTRL3
                sta SID2_CTRL1
                sta EXPLODE
                sta onScreen            ; set onscreen=false

                ldx #1
_next5          lda zpBombDrop,X        ; if a bomb is in the air, and
                beq _CKBRN

                lda zpRockHit,X         ; it hasn't hit anything yet,
                bne _CKBRN

                jsr DecrementMissile    ; it's a miss

_CKBRN          lda zpBombRunDrops,X    ; if no bombs dropped this pass,
                bne _CKNBR

                jsr DecrementMissile    ; it's a miss

_CKNBR          dex
                bpl _next5

                jsr ClearPlayer         ; clear out players

                ldx PlayerCount         ; if the actual players have no more bombs,
                lda zpBombCount
                clc
                adc zpBombCount,X
                adc zpWaitForPlay       ; and we're on a game, end it
                                        ; zpWaitForPlay = [0] means a game is in progress
                beq EndGame

                lda DIR                 ; reverse direction
                eor #$FE
                sta DIR

                ldx PlayerPosY          ; change player lanes
                ldy PlayerPosY+1
                stx PlayerPosY+1
                stx SPR(sprite_t.Y, 1)
                sty PlayerPosY
                sty SPR(sprite_t.Y, 0)

                lda #3                  ; reset clock
                sta CLOCK
                lda ROCKS+1             ; if half of the rocks are gone
                bne _XIT

                lda ROCKS               ; then switch to planes
                cmp #149
                bcs _XIT                ; else return

                lda #stPlane            ; set move rate mask
                sta zpShipType
                lda #4                  ; plane bombs get max of 4 rocks
                sta RocksPerBomb

_XIT            rts
                .endproc


;======================================
; clear players, bomb y positions,
; bombs dropped this pass, and
; turn off bomb sounds
;======================================
ClearPlayer     .proc
                stz zpBombDrop          ; clear bomb y position & bombs dropped this pass
                stz zpBombDrop+1
                stz zpBombRunDrops
                stz zpBombRunDrops+1

;   turn off bomb fall sounds
                stz SID1_CTRL1
                stz SID1_CTRL2

;   clear bombs
                stz SPR(sprite_t.Y, 2)
                stz SPR(sprite_t.Y+1, 2)
                stz SPR(sprite_t.Y, 3)
                stz SPR(sprite_t.Y+1, 3)

                rts
                .endproc
