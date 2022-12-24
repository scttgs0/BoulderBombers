
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


                .cpu "65816"

                .include "equates_system_c256.inc"
                .include "equates_zeropage.inc"
                .include "equates_game.inc"

                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"
                .include "macros_frs_random.asm"


;--------------------------------------
;--------------------------------------
                * = INIT-40
;--------------------------------------
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            clc
                xce
                .m8i8
                .setdp $0000
                .setbank $00
                cld

                jmp INIT


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

                .include "launch.asm"

                .include "newscreen.asm"
                .include "bombloop.asm"
                .include "score.asm"
                .include "bomb.asm"
                .include "player.asm"
                .include "render.asm"

                .include "endgame.asm"

                .include "data.asm"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "interrupt.asm"
                .include "platform_c256.asm"


;--------------------------------------
                .align $100
;--------------------------------------

GameFont        .include "FONT.asm"
GameFont_end

Palette         .include "PALETTE.asm"
Palette_end


;--------------------------------------
                .align $100
;--------------------------------------

StampSprites    .include "SPRITES.asm"
StampSprites_end
