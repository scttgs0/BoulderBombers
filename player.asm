
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

                stz zpTemp1
                asl A
                rol zpTemp1
                clc
                adc #32
                bcc _1

                inc zpTemp1

_1              sta SP00_X_POS
                sta SP02_X_POS
                lda zpTemp1
                sta SP00_X_POS+1
                sta SP02_X_POS+1

                lda #152                ; then player 2
                sec
                sbc PlayerPosX
                sta PlayerPosX+1

                stz zpTemp1
                asl A
                rol zpTemp1
                clc
                adc #32
                bcc _2

                inc zpTemp1

_2              sta SP01_X_POS
                sta SP03_X_POS
                lda zpTemp1
                sta SP01_X_POS+1
                sta SP03_X_POS+1

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
_next3          lda CLOCK               ; get image index from clock
                and #4
                asl A
                sta HOLDIT              ; and hold it

                lda tmpDIR              ; get direction index from dir
                and #$10
                clc
                adc HOLDIT              ; & add 'em to get index.

                stx HOLDIT              ; save player #

;   calculate stamp address
                sta zpTemp1
                stz zpTemp2

                ldy #6
_nextMult       asl zpTemp1             ; *128
                bcc _3

                inc zpTemp2

_3              dey
                bpl _nextMult

                lda zpTemp2
                clc
                adc #$4
                sta zpTemp2

                ldx HOLDIT
                cpx #0
                beq _plyr00

                lda zpTemp1
                sta SP01_ADDR
                lda zpTemp2
                sta SP01_ADDR+1
                bra _cont2

_plyr00         lda zpTemp1
                sta SP00_ADDR
                lda zpTemp2
                sta SP00_ADDR+1

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

;   players are now on screen, but check to see if they aren't
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
                stx SP01_Y_POS
                sty PlayerPosY
                sty SP00_Y_POS

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

                stz SID1_CTRL1          ; turn off bomb fall sounds
                stz SID1_CTRL2

                stz SP02_Y_POS          ; clear bombs
                stz SP02_Y_POS+1
                stz SP03_Y_POS
                stz SP03_Y_POS+1
                rts
                .endproc
