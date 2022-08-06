;***********************
;*                     *
;*  'BOULDER BOMBERS'  *
;*         by          *
;*     Mark Price      *
;*                     *
;***********************

;   SP00        Player1
;   SP01        Player2
;   SP02        Player1 Bomb
;   SP03        Player2 Bomb

                .cpu "65816"

                .include "equates_system_c256.asm"
                .include "equates_zeropage.asm"
                .include "equates_game.asm"

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

                jmp INIT


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

                .include "main.asm"
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
