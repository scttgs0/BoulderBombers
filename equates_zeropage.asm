;======================================
; ZERO-PAGE VARIABLES
;======================================

;--------------------------------------
;--------------------------------------
                * = $12
;--------------------------------------

CLOCK           .byte ?
DELYVAL         .byte ?
DIR             .byte ?
EXPLODE         .byte ?
HOLDIT          .byte ?
MASK            .byte ?
ONSCR           .byte ?
PLAY            .byte ?
PLAYERS         .byte ?
RKILL           .byte ?
TDIR            .byte ?
XCOUNT          .byte ?
YCOUNT          .byte ?

BMBDRP          .word ?
BRUN            .word ?
DRPFREQ         .word ?
DRPRATE         .word ?
FREMEN          .word ?
BOMBS           .word ?
PLYRX           .word ?
PLYRY           .word ?
RCKHIT          .word ?
ROCKS           .word ?
SCRPTR          .word ?


;--------------------------------------
;--------------------------------------
                * = $80
;--------------------------------------

JIFFYCLOCK      .byte ?
InputFlags      .byte ?
InputType       .byte ?
itJoystick  = 0
itKeyboard  = 1
KEYCHAR         .byte ?                   ; last key pressed
CONSOL          .byte ?                   ; state of OPTION,SELECT,START

SOURCE          .dword ?                ; Starting address for the source data (4 bytes)
DEST            .dword ?                ; Starting address for the destination block (4 bytes)
SIZE            .dword ?                ; Number of bytes to copy (4 bytes)
