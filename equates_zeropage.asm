
;--------------------------------------
; ZERO-PAGE VARIABLES
;--------------------------------------

;--------------------------------------
;--------------------------------------
                * = $12
;--------------------------------------

CLOCK               .byte ?
DELYVAL             .byte ?

DIR                 .byte ?
dirLeft         = $FF                   ; =-1
dirRight        = 1
tmpDIR              .byte ?

EXPLODE             .byte ?
HOLDIT              .byte ?

zpShipType          .byte ?
stPlane         = 1
stBalloon       = 3

onScreen            .byte ?
zpWaitForPlay       .byte ?             ; 0 = game in play, 1 = not in play
PlayerCount         .byte ?             ; 0 = 1-player, 1 = 2-player
RocksPerBomb        .byte ?             ; max=8
XCOUNT              .byte ?
YCOUNT              .byte ?

zpBombDrop          .byte ?             ; 0 = not dropping bomb; !0 = bomb Y position
                    .byte ?
zpBombRunDrops      .byte ?             ; number of bombs dropped during this pass
                    .byte ?
zpDropFreq          .byte ?
                    .byte ?
zpDropRate          .byte ?
                    .byte ?
zpFreeManTarget     .byte ?
                    .byte ?
zpBombCount         .byte ?
                    .byte ?

PlayerPosX          .byte ?             ; low-byte= player 1
                    .byte ?             ; high-byte=player 2
PlayerPosY          .byte ?
                    .byte ?

zpRockHit           .byte ?
                    .byte ?
ROCKS               .word ?
SCRPTR              .word ?

P2PF                .byte ?
P3PF                .byte ?

P2PFaddr            .word ?
P3PFaddr            .word ?

;--------------------------------------
;--------------------------------------
                * = $80
;--------------------------------------

JIFFYCLOCK          .byte ?

InputFlags          .byte ?
                    .byte ?
InputType           .byte ?
                    .byte ?
itJoystick      = 0
itKeyboard      = 1
KEYCHAR             .byte ?             ; last key pressed
CONSOL              .byte ?             ; state of OPTION,SELECT,START

zpSource            .dword ?            ; Starting address for the source data (4 bytes)
zpDest              .dword ?            ; Starting address for the destination block (4 bytes)
zpSize              .dword ?            ; Number of bytes to copy (4 bytes)

zpTemp1             .byte ?
zpTemp2             .byte ?

RND_MIN             .byte ?
RND_SEC             .byte ?
RND_RESULT          .word ?

CharResX        = 40
CharResY        = 30
