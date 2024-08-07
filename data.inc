
;--------------------------------------
; player 2/computer messages
;--------------------------------------

P2COMPT         .text "RETUPMOC"        ; "COMPUTER" spelled backwards
                .text "2 REYALP"        ; "PLAYER 2" spelled backwards


;--------------------------------------
; misc data
;--------------------------------------

ScoreIndex      .byte 3,13              ; char positions within the screen score line
ShipTypeTbl     .byte stPlane
                .byte stBalloon
ShipSprOffset   .word SPR_PlaneLA
                .word SPR_Balloon

;--------------------------------------
; titles
;--------------------------------------

TitleMsg        ;.text "  BOULDER  BOMBERS  "       ; double-wide, double-height
;   top
                .byte $00,$00,$00,$00
                .byte $B6,$B7,$CA,$CB,$D6,$D7,$C2,$C3,$BA,$BB,$BE,$BF,$CE,$CF
                .byte $00,$00,$00,$00
                .byte $B6,$B7,$CA,$CB,$C6,$C7,$B6,$B7,$BE,$BF,$CE,$CF,$D2,$D3
                .byte $00,$00,$00,$00
;   bottom
                .byte $00,$00,$00,$00
                .byte $B8,$B9,$CC,$CD,$D8,$D9,$C4,$C5,$BC,$BD,$C0,$C1,$D0,$D1
                .byte $00,$00,$00,$00
                .byte $B8,$B9,$CC,$CD,$C8,$C9,$B8,$B9,$C0,$C1,$D0,$D1,$D4,$D5
                .byte $00,$00,$00,$00

AuthorMsg       .text "   BY  MARK PRICE   "
PlyrQtyMsg      .text "     PLAYERS: 1     "

TitleMsgColor
;   top
                .byte $00,$00,$00,$00
                .byte $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
                .byte $00,$00,$00,$00
                .byte $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
                .byte $00,$00,$00,$00
;   bottom
                .byte $00,$00,$00,$00
                .byte $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
                .byte $00,$00,$00,$00
                .byte $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
                .byte $00,$00,$00,$00

AuthorColor     .byte $00,$00,$00
                .byte $90,$90
                .byte $00,$00
                .byte $90,$90,$90,$90
                .byte $00
                .byte $90,$90,$90,$90,$90
                .byte $00,$00,$00

PlyrQtyColor    .byte $00,$00,$00,$00,$00
                .byte $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
                .byte $00
                .byte $C0
                .byte $00,$00,$00,$00,$00

;--------------------------------------
; bottom of game screen
;--------------------------------------

HighScoreMsg    .text "     HIGH: ",0,0,0,"0     "  ; warning: must use zero for space within score and hiscore

HighScoreColor  .byte $00,$00,$00,$00,$00
                .byte $C0,$C0,$C0,$C0,$C0
                .byte $00,$C0,$C0,$C0
                .byte $C0,$00,$00,$00,$00
                .byte $00

;   titles above score line
PlayersMsg      .text " PLAYER 1  "

P2MSG           .text "         "

PlayersMsgColor .byte $00,$90,$90,$90,$90
                .byte $90,$90,$00,$90,$00
                .byte $00,$60,$60,$60,$60
                .byte $60,$60,$60,$60,$00

ScoreMsg        .text " "
SCORE1          .text "    "
                .text " "
BOMB1           .text "   "
                .text "  "
SCORE2          .text "    "
                .text " "
BOMB2           .text "   "
                .text " "

ScoreMsgColor   .byte $00
                .byte $A0,$A0,$A0,$A0
                .byte $00
                .byte $E0,$E0,$E0
                .byte $00,$00
                .byte $A0,$A0,$A0,$A0
                .byte $00
                .byte $E0,$E0,$E0
                .byte $00

DebugMsg        .text "TEST"
                .fill 40," "
DebugMsgColor   .fill 40,$90


;--------------------------------------
; canyon data
;--------------------------------------

ROCKIMG         .byte       $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
                .byte $85,      $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,      $85
                .byte $84,$85,      $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,      $84,$85

                .byte $84,$85,      $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,      $84,$85
                .byte $84,$84,$85,      $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,      $84,$84,$85
                .byte $84,$84,$85,      $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,      $84,$84,$85

                .byte $84,$84,$84,$85,  $03,$03,$03,$03,$03,$03,$03,$03,  $85,  $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03, $85,   $03,$03,$03,$03,$03,$03,$03,$03,  $84,$84,$84,$85
                .byte $84,$84,$84,$85,  $03,$03,$03,$03,$03,$03,$03,  $84,$84,$85,  $03,$85,$03,$03,$03,$03,$03,$03,$03,$03,$85,$03,$84,$84,$85,    $03,$03,$03,$03,$03,$03,$03,  $84,$84,$84,$85
                .byte $84,$84,$84,$84,$85,  $03,$03,$03,$03,$03,  $84,$84,$84,$84,$84,$84,$85,  $03,$03,$03,$03,$03,$03,  $84,$84,$84,$84,$84,$84,$85,  $03,$03,$03,$03,$03,  $84,$84,$84,$84,$85
                .byte $84,$84,$84,$84,$84,$85,  $03,$03,$03,  $84,$84,$84,$84,$84,$84,$84,$84,$85,  $03,$03,$03,$03,  $84,$84,$84,$84,$84,$84,$84,$84,$85,  $03,$03,$03,  $84,$84,$84,$84,$84,$85


;--------------------------------------
; character set data
;--------------------------------------
; copied into the first 14 chars of
; CharsetCustom [$2C00]
;--------------------------------------

GameStamps_z    ;.byte $00,$00,$00,$00,$00,$00,$00,$00      [00]
                .byte %00000000         ; ........
                .byte %00000000         ; ........
                .byte %00000000         ; ........
                .byte %00000000         ; ........
                .byte %00000000         ; ........
                .byte %00000000         ; ........
                .byte %00000000         ; ........
                .byte %00000000         ; ........

                ;.byte $54,$54,$54,$54,$54,$54,$54,$00      [01]    block top rows
                .byte %01010100         ; AAAAAA..
                .byte %01010100         ; AAAAAA..
                .byte %01010100         ; AAAAAA..
                .byte %01010100         ; AAAAAA..
                .byte %01010100         ; AAAAAA..
                .byte %01010100         ; AAAAAA..
                .byte %01010100         ; AAAAAA..
                .byte %00000000         ; ........

                ;.byte $A8,$A8,$A8,$A8,$A8,$A8,$A8,$00      [02]    block mid rows
                .byte %10101000         ; BBBBBB..
                .byte %10101000         ; BBBBBB..
                .byte %10101000         ; BBBBBB..
                .byte %10101000         ; BBBBBB..
                .byte %10101000         ; BBBBBB..
                .byte %10101000         ; BBBBBB..
                .byte %10101000         ; BBBBBB..
                .byte %00000000         ; ........

                ;.byte $FC,$FC,$FC,$FC,$FC,$FC,$FC,$00      [03]    block bottom rows
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %00000000         ; ........

                ;.byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF      [04]    solid earth
                .byte %11111111         ; CCCCCCCC
                .byte %11111111         ; CCCCCCCC
                .byte %11111111         ; CCCCCCCC
                .byte %11111111         ; CCCCCCCC
                .byte %11111111         ; CCCCCCCC
                .byte %11111111         ; CCCCCCCC
                .byte %11111111         ; CCCCCCCC
                .byte %11111111         ; CCCCCCCC

                ;.byte $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC      [05]    solid right-edge
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..
                .byte %11111100         ; CCCCCC..

                ;.byte $00,$00,$01,$03,$3F,$D3,$FE,$80      [06]    plane left-A
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........
                .byte %00000000,%00000000,%00000000,%00001111         ; ........ ........ ........ ....####
                .byte %00000000,%00000000,%00000000,%11111111         ; ........ ........ ........ ########
                .byte %00000000,%11111111,%11111111,%11111111         ; ........ ######## ######## ########
                .byte %11111111,%00001111,%00000000,%11111111         ; ######## ....#### ........ ########
                .byte %11111111,%11111111,%11111111,%11110000         ; ######## ######## ######## ####....
                .byte %11110000,%00000000,%00000000,%00000000         ; ####.... ........ ........ ........

                ;.byte $00,$00,$01,$83,$BF,$D3,$7E,$00      [0A]   plane left-B
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........
                .byte %00000000,%00000000,%00000000,%00001111         ; ........ ........ ........ ....####
                .byte %11110000,%00000000,%00000000,%11111111         ; ####.... ........ ........ ########
                .byte %11110000,%11111111,%11111111,%11111111         ; ####.... ######## ######## ########
                .byte %11111111,%00001111,%00000000,%11111111         ; ######## ....#### ........ ########
                .byte %00001111,%11111111,%11111111,%11110000         ; ....#### ######## ######## ####....
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........

                ;.byte $00,$00,$80,$C0,$FC,$CB,$7F,$01      [0E]    plane right-A
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........
                .byte %11110000,%00000000,%00000000,%00000000         ; ####.... ........ ........ ........
                .byte %11111111,%00000000,%00000000,%00000000         ; ######## ........ ........ ........
                .byte %11111111,%11111111,%11111111,%00000000         ; ######## ######## ######## ........
                .byte %11111111,%00000000,%11110000,%11111111         ; ######## ........ ####.... ########
                .byte %00001111,%11111111,%11111111,%11111111         ; ....#### ######## ######## ########
                .byte %00000000,%00000000,%00000000,%00001111         ; ........ ........ ........ ....####

                ;.byte $00,$00,$80,$C1,$FD,$CB,$7E,$00      [12]    plane right-B
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........
                .byte %11110000,%00000000,%00000000,%00000000         ; ####.... ........ ........ ........
                .byte %11111111,%00000000,%00000000,%00001111         ; ######## ........ ........ ....####
                .byte %11111111,%11111111,%11111111,%00001111         ; ######## ######## ######## ....####
                .byte %11111111,%00000000,%11110000,%11111111         ; ######## ........ ####.... ########
                .byte %00001111,%11111111,%11111111,%11110000         ; ....#### ######## ######## ####....
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........

                ;.byte $3C,$7E,$FF,$00,$FF,$FF,$7E,$3C      [16]   balloon
                .byte %00000000,%11111111,%11111111,%00000000         ; ........ ######## ######## ........
                .byte %00001111,%11111111,%11111111,%11110000         ; ....#### ######## ######## ####....
                .byte %11111111,%11111111,%11111111,%11111111         ; ######## ######## ######## ########
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........
                .byte %11111111,%11111111,%11111111,%11111111         ; ######## ######## ######## ########
                .byte %11111111,%11111111,%11111111,%11111111         ; ######## ######## ######## ########
                .byte %00001111,%11111111,%11111111,%11110000         ; ....#### ######## ######## ####....
                .byte %00000000,%11111111,%11111111,%00000000         ; ........ ######## ######## ........

                ;.byte $18,$24,$24,$18,$18,$00,$00,$00      [1A]    balloon basket
                .byte %00000000,%00001111,%11110000,%00000000         ; ........ ....#### ####.... ........
                .byte %00000000,%11110000,%00001111,%00000000         ; ........ ####.... ....#### ........
                .byte %00000000,%11110000,%00001111,%00000000         ; ........ ####.... ....#### ........
                .byte %00000000,%00001111,%11110000,%00000000         ; ........ ....#### ####.... ........
                .byte %00000000,%00001111,%11110000,%00000000         ; ........ ....#### ####.... ........
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........
                .byte %00000000,%00000000,%00000000,%00000000         ; ........ ........ ........ ........

                ;.byte $A0,$40,$E0,$E0,$E0,$40,$00,$00      [1E]    bomb small
                .byte %10100000         ; #.#.....
                .byte %01000000         ; .#......
                .byte %11100000         ; ###.....
                .byte %11100000         ; ###.....
                .byte %11100000         ; ###.....
                .byte %01000000         ; .#......
                .byte %00000000         ; ........
                .byte %00000000         ; ........

                ;.byte $6C,$7C,$38,$7C,$7C,$7C,$38,$10      [1F]    bomb
                .byte %01101100         ; .##.##..
                .byte %01111100         ; .#####..
                .byte %00111000         ; ..###...
                .byte %01111100         ; .#####..
                .byte %01111100         ; .#####..
                .byte %01111100         ; .#####..
                .byte %00111000         ; ..###...
                .byte %00010000         ; ...#....

                .fill $100,$00


;--------------------------------------
; off-screen canyon
;--------------------------------------

CanyonColors    .byte $00,$40,$90,$60,$E0,$E0
CANYON          .fill 440,$00
