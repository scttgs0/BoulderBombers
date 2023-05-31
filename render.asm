
;======================================
; set canyon screen image
;======================================
ResetCanyon     .proc
                ldy #0                  ; copy rocks & canyon to screen
_next1          lda ROCKIMG,Y
                sta CANYON+40,Y

                iny
                bne _next1

                ldy #144
_next2          lda ROCKIMG+255,Y
                sta CANYON+295,Y

                dey
                bne _next2

                rts
                .endproc
