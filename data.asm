
;
; player 2/computer messages
;

            .enc "atari-screen-inverse"
P2COMPT         .text "RETUPMOC2 REYALP"
            .enc "none"

;
; misc data
;
SCRNDX          .byte 3,13
MASKS           .byte 1,3

;
; title screen display list
;

DLIST1          .byte AEMPTY8,AEMPTY8,AEMPTY8

                .byte $06+ALMS
                    .addr GAME

                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8

                .byte $04+ALMS
                    .addr CANYON+40
                .byte $04,$04,$04
                .byte $04,$04,$04
                .byte $04,$04,$04

                .byte $07+ALMS
                    .addr TITLE

                .byte $06,$06

                .byte AVB+AJMP
                    .addr DLIST1

;
; game display list
;

DLIST2          .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8

                .byte $04+ALMS
                    .word CANYON+40
                .byte $04,$04,$04
                .byte $04,$04,$04
                .byte $04,$04,$04

                .byte $06+ALMS
                    .addr GAME

                .byte AEMPTY8

                .byte $06,$06

                .byte AVB+AJMP
                    .addr DLIST2

;
; titles
;

TITLE
            .enc "atari-screen-inverse"
                .text "  boulder "
                .text " bombers  "
            .enc "atari-screen"
                .text "   by  mark price   "
                .text "     PLAYERS: "
            .enc "none"

SCNOPLR         .byte $11,0,0,0,0,0

;
; bottom of game screen
;

            .enc "atari-screen"
GAME            .text "     HIGH: "
HISCOR          .text "   0      PLAYER 1   "
            .enc "none"

P2MSG           .byte 0,0,0,0,0,0,0,0,0,0
SCORE1          .byte 0,0,0,0,0
BOMB1           .byte 0,0,0,0,0
SCORE2          .byte 0,0,0,0,0
BOMB2           .byte 0,0,0,0

;
; data for canyon
;

ROCKIMG         .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte $85,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,$85
                .byte $84,$85,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,$84,$85
                .byte $84,$85,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,$84,$85
                .byte $84,$84,$85,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,$84,$84,$85
                .byte $84,$84,$85,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,$84,$84,$85
                .byte $84,$84,$84,$85,3
                .byte 3,3,3,3,3,3,3
                .byte $85,3,3,3,3,3,3,3,3,3,3,3
                .byte 3,3,3,$85,3,3,3,3,3,3,3,3
                .byte $84,$84,$84,$85,$84,$84
                .byte $84,$85,3,3,3,3
                .byte 3,3,3,$84,$84,$85
                .byte 3,$85,3,3,3,3
                .byte 3,3,3,3,$85,3
                .byte $84,$84,$85,3,3,3
                .byte 3,3,3,3,$84,$84
                .byte $84,$85,$84,$84,$84,$84
                .byte $85,3,3,3,3,3
                .byte $84,$84,$84,$84,$84,$84
                .byte $85,3,3,3,3,3
                .byte 3,$84,$84,$84,$84,$84
                .byte $84,$85,3,3,3,3
                .byte 3,$84,$84,$84,$84,$85
                .byte $84,$84,$84,$84,$84,$85
                .byte 3,3,3,$84,$84,$84
                .byte $84,$84,$84,$84,$84,$85
                .byte 3,3,3,3,$84,$84
                .byte $84,$84,$84,$84,$84,$84
                .byte $85,3,3,3,$84,$84
                .byte $84,$84,$84,$85

;
; character set data
;

MYCHARS         ;.byte $00,$00,$00,$00,$00,$00,$00,$00
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                ;.byte $54,$54,$54,$54,$54,$54,$54,$00
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %00000000         ; ....
                ;.byte $A8,$A8,$A8,$A8,$A8,$A8,$A8,$00
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %00000000         ; ....
                ;.byte $FC,$FC,$FC,$FC,$FC,$FC,$FC,$00
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %00000000         ; ....
                ;.byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                ;.byte $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                ;.byte $00,$00,$01,$03,$3F,$D3,$FE,$80
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000001         ; ...A
                .byte %00000011         ; ...C
                .byte %00111111         ; .CCC
                .byte %11010011         ; CA.C
                .byte %11111110         ; CCCB
                .byte %10000000         ; B...
                ;.byte $00,$00,$01,$83,$BF,$D3,$7E,$00
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000001         ; ...A
                .byte %10000011         ; B..C
                .byte %10111111         ; BCCC
                .byte %11010011         ; CA.C
                .byte %01111110         ; ACCB
                .byte %00000000         ; ....
                ;.byte $00,$00,$80,$C0,$FC,$CB,$7F,$01
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %10000000         ; B...
                .byte %11000000         ; C...
                .byte %11111100         ; CCC.
                .byte %11001011         ; C.BC
                .byte %01111111         ; ACCC
                .byte %00000001         ; ...A
                ;.byte $00,$00,$80,$C1,$FD,$CB,$7E,$00
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %10000000         ; B...
                .byte %11000001         ; C..A
                .byte %11111101         ; CCCA
                .byte %11001011         ; C.BC
                .byte %01111110         ; ACCB
                .byte %00000000         ; ....
                ;.byte $3C,$7E,$FF,$00,$FF,$FF,$7E,$3C
                .byte %00111100         ; .CC.
                .byte %01111110         ; ACCB
                .byte %11111111         ; CCCC
                .byte %00000000         ; ....
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %01111110         ; ACCB
                .byte %00111100         ; .CC.
                ;.byte $18,$24,$24,$18,$18,$00,$00,$00
                .byte %00011000         ; .AB.
                .byte %00100100         ; .BA.
                .byte %00100100         ; .BA.
                .byte %00011000         ; .AB.
                .byte %00011000         ; .AB.
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                ;.byte $A0,$40,$E0,$E0,$E0,$40,$00,$00
                .byte %10100000         ; BB..
                .byte %01000000         ; A...
                .byte %11100000         ; CB..
                .byte %11100000         ; CB..
                .byte %11100000         ; CB..
                .byte %01000000         ; A...
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                ;.byte $6C,$7C,$38,$7C,$7C,$7C,$38,$10
                .byte %01101100         ; ABC.
                .byte %01111100         ; ACC.
                .byte %00111000         ; .CB.
                .byte %01111100         ; ACC.
                .byte %01111100         ; ACC.
                .byte %01111100         ; ACC.
                .byte %00111000         ; .CB.
                .byte %00010000         ; .A..

                .fill 4,$00
                .fill $18C

;
; on-screen canyon
;

CANYON
