;======================================
; ZERO-PAGE VARIABLES
;======================================

;--------------------------------------
;--------------------------------------
                * = $12
;--------------------------------------

CLOCK               .byte ?
DELYVAL             .byte ?

DIR                 .byte ?
dirLeft         = $FF                   ; =-1
dirRight        = 1

EXPLODE             .byte ?
HOLDIT              .byte ?

zpShipType          .byte ?
stPlane         = 1
stBalloon       = 3

ONSCR               .byte ?
zpWaitForPlay       .byte ?             ; 0 = game in play, 1 = not in play
PLAYERS             .byte ?             ; 0 = 1-player, 1 = 2-player
RKILL               .byte ?
tmpDIR              .byte ?
XCOUNT              .byte ?
YCOUNT              .byte ?

BMBDRP              .word ?
BRUN                .word ?
DRPFREQ             .word ?
DRPRATE             .word ?
FREMEN              .word ?
BOMBS               .word ?
PlayerPosX          .byte ?
                    .byte ?
PlayerPosY          .byte ?
                    .byte ?
RCKHIT              .word ?
ROCKS               .word ?
SCRPTR              .word ?


;--------------------------------------
;--------------------------------------
                * = $80
;--------------------------------------

JIFFYCLOCK          .byte ?
InputFlags          .byte ?
InputType           .byte ?
itJoystick      = 0
itKeyboard      = 1
KEYCHAR             .byte ?             ; last key pressed
CONSOL              .byte ?             ; state of OPTION,SELECT,START

SOURCE              .dword ?            ; Starting address for the source data (4 bytes)
DEST                .dword ?            ; Starting address for the destination block (4 bytes)
SIZE                .dword ?            ; Number of bytes to copy (4 bytes)

zpTemp1             .byte ?
zpTemp2             .byte ?

zpSource            .addr ?
zpDest              .addr ?

RND_MIN             .byte ?
RND_SEC             .byte ?
RND_RESULT          .word ?

CharResX        = 40
CharResY        = 30
