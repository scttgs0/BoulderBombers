
;--------------------------------------
; Initialize the hardware
;--------------------------------------
INIT            .proc
                jsr InitSystemVectors
                ; jsr InitMMU

                jsr RandomSeedQuick

                .frsGraphics mcTextOn|mcOverlayOn|mcGraphicsOn|mcSpriteOn,mcVideoMode240|mcTextDoubleX|mcTextDoubleY
                .frsMouse_off
                .frsBorder_off

                stz BITMAP0_CTRL        ; disable all bitmaps
                stz BITMAP1_CTRL
                stz BITMAP2_CTRL
                stz LAYER_ORDER_CTRL_0
                stz LAYER_ORDER_CTRL_1

                jsr InitGfxPalette
                jsr InitTextPalette

                jsr SetFont
                jsr ClearScreen
                jsr ClearGamePanel

                ; jsr InitSID             ; initialize SID sound
                ; jsr InitPSG             ; initialize PSG sound

;   initialize sprites
                jsr InitSprites

;   DEBUG:
                .frsSpriteSetX 40, 0
                .frsSpriteSetX 80, 1
                .frsSpriteSetX 120, 2
                .frsSpriteSetX 160, 3

;   DEBUG:
                .frsSpriteSetY 40, 0
                .frsSpriteSetY 40, 1
                .frsSpriteSetY 40, 2
                .frsSpriteSetY 40, 3

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
                ldx #1                  ; set player start positions
                stx PlayerPosX
                txa
                .mult2p32 zpTemp1       ; Accum*2+32, result in zpTemp1:Accum
                tax

                ldy #151
                sty PlayerPosX+1
                tya
                .mult2p32 zpTemp2       ; Accum*2+32, result in zpTemp2:Accum
                tay

                stx SPRITE(sprite_t.X, 0)
                lda zpTemp1
                sta SPRITE(sprite_t.X+1, 0)
                sty SPRITE(sprite_t.X, 1)
                lda zpTemp2
                sta SPRITE(sprite_t.X+1, 1)

                ldx #70                 ; set player lanes
                stx PlayerPosY
                ldy #90
                sty PlayerPosY+1

                stx SPRITE(sprite_t.Y, 0)
                stz SPRITE(sprite_t.Y+1, 0)
                sty SPRITE(sprite_t.Y, 1)
                stz SPRITE(sprite_t.Y+1, 1)

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
                cmp #1                  ; SELECT <F3> pressed?
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

_chkSTART       ;--cmp #2                  ; if START <F4> then start game
                ;--lda #0
                ;--beq START

_moveT          lda onScreen            ; if on screen, then move
                bne _moveIt

                .frsRandomByte          ; else, pick out new ship type
                and #1
                tax
                lda ShipTypeTbl,X
                sta zpShipType          ; & set it

                txa
                and #1
                asl                     ; *2
                tax
                lda ShipSprOffset,X
                sta SPRITE(sprite_t.ADDR, 0)
                sta SPRITE(sprite_t.ADDR, 1)
                lda ShipSprOffset+1,X
                sta SPRITE(sprite_t.ADDR+1, 0)
                sta SPRITE(sprite_t.ADDR+1, 1)

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
                ; beq _wait1

                lda #3                  ; set game speed to $ff+$04
                sta DELYVAL

                lda #0                  ; we're now in play, clear the wait flag
                sta zpWaitForPlay

;   warning: must use zero for a space character within score and hiscore
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

                lda #$11                ; set next free bomb at score=1000
                sta zpFreeManTarget
                sta zpFreeManTarget+1

;   set second player message to 'player 2' or 'computer'
                lda PlayerCount
                asl                     ; *8
                asl
                asl

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
