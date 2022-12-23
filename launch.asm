
;--------------------------------------
;
;--------------------------------------
INIT            .proc
;   set system vectors
                ;--jsr InitSystemVectors

                jsr Random_Seed

                .frsGraphics mcTextOn|mcOverlayOn|mcGraphicsOn|mcSpriteOn,mcVideoMode240
                .frsMouse_off
                .frsBorder_off

                stz BITMAP0_CTRL        ; disable all bitmaps
                stz BITMAP1_CTRL
                stz BITMAP2_CTRL
                stz LAYER_ORDER_CTRL_0
                stz LAYER_ORDER_CTRL_1

                jsr InitLUT
                jsr InitCharLUT

                jsr SetFont
                jsr ClearScreen
                jsr ClearGamePanel

                jsr InitSID             ; init sound

;   initialize sprites
                jsr InitSprites

;   zero out all variables (37 bytes)
                lda #0
                ldy #P3PF+1-CLOCK
_next1          sta CLOCK,Y
                dey
                bpl _next1

;   zero out the top line of CANYON
                ldy #39                 ; set screen display
_next2          sta CANYON,Y
                dey
                bpl _next2

                jsr ResetCanyon

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
RESTART         .proc
                lda #1                  ; set player start positions
                sta PlayerPosX
                lda #151
                sta PlayerPosX+1

                ldx #70                 ; set player lanes
                stx PlayerPosY
                ldy #90
                sty PlayerPosY+1

                stx SP00_Y_POS
                stz SP00_Y_POS+1
                sty SP01_Y_POS
                stz SP01_Y_POS+1

                lda #0                  ; turn off explosions, and bkg sound
                sta SID1_CTRL3
                sta EXPLODE
                sta SID2_CTRL1

                lda #dirRight           ; set start direction
                sta DIR
                sta zpWaitForPlay       ; waiting for play to start

                jsr ClearPlayer         ; clear players

                jsr RenderHiScore
                jsr RenderTitle
                jsr RenderAuthor
                jsr RenderSelect
                jsr RenderCanyon

                lda #$FF                ; set game speed for titles
                sta DELYVAL

                lda #0                  ; players not on screen
                sta onScreen

                jsr InitIRQs

                lda #3                  ; init clock
                sta CLOCK

_next1          lda CONSOL              ; check consol switches
                and #3
                cmp #1                  ; SELECT pressed?
                bne _chkSTART           ;   no, try START

_wait1          lda CONSOL              ;   yes, wait for key release
                and #2
                beq _wait1

                lda PlayerCount         ; change # of players
                eor #1
                sta PlayerCount
                clc
                adc #$31                ; & set on screen
                sta PlyrQtyMsg+14
                jsr RenderSelect

                bra _moveT              ; (move players)

_chkSTART       cmp #2                  ; if START then start game
                beq START

_moveT          lda onScreen            ; if on screen, then move
                bne _moveIt

                .randomByte             ; else, pick out new ship type
                and #1
                tax
                lda ShipTypeTbl,X
                sta zpShipType          ; & set it

                txa
                and #1
                asl A                   ; *2
                tax
                lda ShipSprOffset,X
                sta SP00_ADDR
                sta SP01_ADDR
                lda ShipSprOffset+1,X
                sta SP00_ADDR+1
                sta SP01_ADDR+1

_moveIt         phx
                jsr MovePlayer          ; move players
                plx

                jmp _next1              ; do check again

                .endproc


;--------------------------------------
;
;--------------------------------------
START           .proc
;   wait for key release
_wait1          lda CONSOL
                and #1
                beq _wait1

                lda #3                  ; set game speed to $ff+$04
                sta DELYVAL

                lda #0                  ; we're now in play, clear the wait flag
                sta zpWaitForPlay

;   warning: must use zero for space within score and hiscore
                lda #0
                ldx #2                  ; reset scores to zero
_next1          sta SCORE1,X
                sta SCORE2,X
                dex
                bpl _next1

                lda #$30
                sta SCORE1+3
                sta SCORE2+3

                ldx #2                  ; set bombs remaining to three
                lda #$9B
_next2          sta BOMB1,X
                sta BOMB2,X
                dex
                bpl _next2

                lda #3
                sta zpBombCount
                sta zpBombCount+1

                lda #$11                ; set next free bomb at 1000
                sta zpFreeManTarget
                sta zpFreeManTarget+1

;   set second player message to 'player 2' or 'computer'
                lda PlayerCount
                asl A
                asl A
                asl A

                ldx #7
                tay
_next3          lda P2COMPT,Y
                sta P2MSG,X
                iny
                dex
                bpl _next3

                jsr ClearScreen
                jsr ClearGamePanel
                jsr RenderHiScore2
                jsr RenderPlayers
                jsr RenderScore

                jmp NewScreen

                .endproc
