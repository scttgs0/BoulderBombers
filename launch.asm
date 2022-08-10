;--------------------------------------
;
;--------------------------------------
INIT            .proc
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

                lda #0                  ; init vars
                ldy #SCRPTR+1-CLOCK
_next5          sta CLOCK,Y
                dey
                bpl _next5

                ldy #$27                ; set screen display
_next6          sta CANYON,Y
                dey
                bpl _next6

                jsr DrawScreen

                .m16
                lda #70                 ; set player lanes
                sta SP00_Y_POS
                .m8
                sta PlayerPosY

                .m16
                lda #90
                sta SP01_Y_POS
                .m8
                sta PlayerPosY+1
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

                lda #0                  ; turn off explosions, and bkg sound
                sta SID_CTRL3
                sta EXPLODE
                ;sta AUDC4

                jsr ClearPlayer         ; clear players

                jsr RenderHiScore
                jsr RenderTitle
                jsr RenderAuthor
                jsr RenderSelect
                jsr RenderCanyon

                lda #$FF                ; set game speed for titles
                sta DELYVAL

                lda #dirRight           ; set start direction
                sta DIR
                sta zpWaitForPlay       ; waiting for play to start

                lda #0                  ; players not on screen
                sta ONSCR

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

_moveT          lda ONSCR               ; if on screen, then move
                bne _moveIt

                .randomByte             ; else, pick out new ship type
                and #1
                tax
                phx
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

_moveIt         jsr MovePlayer          ; move players

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

                lda #$20
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
                sta BombCount
                sta BombCount+1

                lda #$11                ; set next free bomb at 1000
                sta FREMEN
                sta FREMEN+1

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
