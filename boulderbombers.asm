
;***********************
;*                     *
;*  'BOULDER BOMBERS'  *
;*         by          *
;*     Mark Price      *
;*                     *
;***********************

;   SP00                Player1
;   SP01                Player2
;   SP02                Player1 Bomb
;   SP03                Player2 Bomb

;   PlayerPosX[0,1]     byte [1,151]
;   PlayerPosY[0,1]     byte [70,90]
;   SP0[0,1]_X_POS      word PlayerPosX*2+32 [34,334]
;   SP0[0,1]_Y_POS      word [70,90]


                .cpu "65c02"

                .include "system_f256jr.equ"
                .include "zeropage.equ"
                .include "game.equ"

                .include "frs_jr_graphic.mac"
                .include "frs_jr_mouse.mac"
                .include "frs_jr_random.mac"
                .include "game.mac"


;--------------------------------------
;--------------------------------------
                * = $8000
;--------------------------------------

;   Boot from RAM data block

                .byte $F2,$56           ; signature
                .byte $02               ; block count
                .byte $04               ; start at block1
                .addr BOOT              ; execute address
                .word $0000             ; version
                .word $0000             ; kernel
                                        ; binary name
                .text 'Boulder Bombers',$00

;--------------------------------------

BOOT            cld                     ; clear decimal
                ldx #$FF                ; initialize the stack
                txs
                jmp INIT

;--------------------------------------
;--------------------------------------

                .include "launch.asm"

                .include "newscreen.asm"
                .include "bombloop.asm"
                .include "score.asm"
                .include "bomb.asm"
                .include "player.asm"
                .include "render.asm"

                .include "endgame.asm"

                .include "data.inc"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "interrupt.asm"


;--------------------------------------
                .align $100
;--------------------------------------

GameFont        .include "FONT.inc"
GameFont_end

Palette         .include "PALETTE.inc"
Palette_end


;--------------------------------------
                .align $100
;--------------------------------------

StampSprites    .include "SPRITES.inc"
StampSprites_end

                .include "platform_f256jr.asm"
