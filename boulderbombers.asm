
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


                .include "equates/system_f256.equ"
                .include "equates/zeropage.equ"
                .include "equates/game.equ"

                .include "macros/f256_graphic.mac"
                .include "macros/f256_mouse.mac"
                .include "macros/f256_random.mac"
                .include "macros/f256_sprite.mac"
                .include "macros/f256_text.mac"
                .include "macros/game.mac"


;--------------------------------------
;--------------------------------------
                * = $6000
;--------------------------------------

.if PGX=1
                .text "PGX"
                .byte $03
                .dword BOOT
;--------------------------------------
.else
                .byte $F2,$56           ; signature
                .byte $02               ; block count
                .byte $03               ; first block
                .addr BOOT              ; execute address
                .word $0001             ; version
                .word $0000             ; kernel
                .null 'Boulder Bombers' ; binary name
.endif

;--------------------------------------

BOOT            clc
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

                .include "platform_f256.asm"
                .include "facade.asm"
