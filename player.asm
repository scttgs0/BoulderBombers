;======================================
; move player, check for leaving
; screen, end game check, switch
; ship types
;======================================
MovePlayer      .proc
                lda ONSCR               ; if not on screen, set sound
                bne _ADDCLOK

;   do the appropriate sound effect based on the ship type
                lda zpShipType          ; player is Balloon?
                cmp #stBalloon
                beq _STBLSND            ;   yes, do that

                lda #$96                ; set plane sound
                ;sta AUDF4
                lda #$24
                ;sta AUDC4
                bne _ADDCLOK            ; & goto clock add

_STBLSND        lda #0                  ; set wind sound
                ;sta AUDF4
                lda #2
                ;sta AUDC4

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

                .m16
                and #$FF
                asl A
                clc
                adc #32
                sta SP00_X_POS
                sta SP02_X_POS
                .m8

                lda #152                ; then player 2
                sec
                sbc PlayerPosX
                sta PlayerPosX+1

                .m16
                and #$FF
                asl A
                clc
                adc #32
                sta SP01_X_POS
                sta SP03_X_POS
                .m8

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
_next3          phx

                lda CLOCK               ; get image index from clock
                and #4
                asl A
                sta HOLDIT              ; and hold it

                lda tmpDIR              ; get direction index from dir
                and #$10
                clc
                adc HOLDIT              ; & add 'em to get index.
                stx HOLDIT
                tax                     ; save player #

;   calculate stamp address
                .m16
                and #$FF

                ldy #6
_nextMult       asl A                   ; *128
                dey
                bpl _nextMult

                clc
                adc #$400

                plx
                beq _plyr00

                sta SP01_ADDR
                bra _cont2

_plyr00         sta SP00_ADDR

_cont2          .m8
                lda tmpDIR              ; reverse tdir
                eor #$FE
                sta tmpDIR

                ldx HOLDIT              ; get player #
                dex                     ; & animate next
                bpl _next3

;   wait for a while to make game playable
_DODELAY        lda JIFFYCLOCK
                inc A
                ;inc A
_wait1          cmp JIFFYCLOCK
                bne _wait1

;   players are now on screen, but check to see if they aren't
                lda #1
                sta ONSCR

                lda PlayerPosX
                beq _OFFSCR

                cmp #152
                bne _XIT                ; if on, return

_OFFSCR         lda #0                  ; else, turn off explosions and bkg sound
                sta SID_CTRL3
                ;sta AUDC4
                sta EXPLODE
                sta ONSCR               ; set onscreen false
                ldx #1
_next5          lda zpBombDrop,X        ; if a bomb is in the air, and
                beq _CKBRN

                lda RCKHIT,X            ; it hasn't hit anything yet,
                bne _CKBRN

                jsr DecrementMissile    ; it's a miss

_CKBRN          lda BRUN,X              ; if no bombs dropped this pass,
                bne _CKNBR

                jsr DecrementMissile    ; it's a miss

_CKNBR          dex
                bpl _next5

                jsr ClearPlayer         ; clear out players

                ldx PlayerCount         ; if the actual players have no more bombs,
                lda BombCount
                clc
                adc BombCount,X
                adc zpWaitForPlay       ; and we're on a game, end it
                                        ; zpWaitForPlay = [0] means a game is in progress
                beq EndGame

                lda DIR                 ; reverse direction
                eor #$FE
                sta DIR

                ldx PlayerPosY          ; change player lanes
                ldy PlayerPosY+1
                stx PlayerPosY+1
                sty PlayerPosY

                .m16
                tya
                and #$FF
                sta SP00_Y_POS
                txa
                and #$FF
                sta SP01_Y_POS
                .m8

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
                sta RKILL

                ;.m16
                ;lda #$0C00
                ;sta SP00_ADDR
                ;lda #$0400
                ;sta SP01_ADDR
                ;.m8

_XIT            rts
                .endproc


;======================================
; clear players, bomb y positions,
; bombs dropped this pass, and
; turn off bomb sounds
;======================================
ClearPlayer     .proc
                lda #0
;                tay
;_next1          sta PL0,Y               ; clear all players
;                sta PL1,Y
;                sta PL2,Y
;                sta PL3,Y
;                dey
;                bne _next1

                sta zpBombDrop          ; clear bomb y position & bombs dropped this pass
                sta zpBombDrop+1
                sta BRUN
                sta BRUN+1

                sta SID_CTRL1           ; turn off bomb fall sounds
                sta SID_CTRL2
                rts
                .endproc
