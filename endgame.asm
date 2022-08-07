;--------------------------------------
; do delay so the players can see the
; final score
;--------------------------------------
EndGame         .proc
                pla                     ; get rid of return address
                pla

                lda #8
                sta HOLDIT
_wait1          ldx #$FF
_wait2          ldy #$FF
_wait3          lda CONSOL              ; end delay early with consol key
                cmp #7
                bne _XIT

                dey
                bne _wait3

                dex
                bne _wait2

                dec HOLDIT
                bpl _wait1

_XIT            jmp RESTART             ; go title screen
                .endproc
