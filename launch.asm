;--------------------------------------
;
;--------------------------------------
INIT            .proc
                .m8i8
                jsr Random_Seed

                .frsGraphics mcTextOn|mcOverlayOn|mcGraphicsOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

                lda #<CharResX
                sta COLS_PER_LINE
                lda #>CharResX
                sta COLS_PER_LINE+1
                lda #CharResX
                sta COLS_VISIBLE

                lda #<CharResY
                sta LINES_MAX
                lda #>CharResY
                sta LINES_MAX+1
                lda #CharResY
                sta LINES_VISIBLE

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
                .m8i8
                lda #1                  ; set player start positions
                sta PlayerPosX
                lda #151
                sta PlayerPosX+1

                ldx #70                 ; set player lanes
                stx PlayerPosY
                ldy #90
                sty PlayerPosY+1

                .m16
                txa
                and #$FF
                sta SP00_Y_POS
                tya
                and #$FF
                sta SP01_Y_POS
                .m8

                lda #0                  ; turn off explosions, and bkg sound
                sta SID_CTRL3
                sta EXPLODE
                ;sta AUDC4

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

                .m16i8
                txa
                and #1
                asl A
                tax
                lda ShipSprOffset,X
                sta SP00_ADDR
                sta SP01_ADDR
                .m8

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

                jsr ClearGamePanel
                jsr RenderHiScore2
                jsr RenderPlayers
                jsr RenderScore

                jmp NewScreen

                .endproc
