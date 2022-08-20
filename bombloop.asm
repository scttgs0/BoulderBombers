;--------------------------------------
; bomb movement, hit checks,
; score and highscore set
;--------------------------------------
BombLoop        ldx #1                  ; set player index

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
; on entry
;   X           player index [0,1]
;--------------------------------------
BombNextLoop    .proc
                .m8
                lda zpBombDrop,X        ; if bomb not dropped
                bne _chkHits

                jmp CheckDrop           ; check trigger

_chkHits        jsr CheckCollision

                lda P2PF,X              ; bomb hit anything?
                bne _chkRockOK

                jmp LowerBomb           ;   no, move bomb

_chkRockOK      bpl _chkHitRock

                jmp HideBomb

;   set pointer into screen ram where the rock hit is
_chkHitRock     pha
                cpx #1
                beq _player2

                lda P2PFaddr
                sta SCRPTR
                lda P2PFaddr+1
                sta SCRPTR+1
                bra _gotChr

_player2        lda P3PFaddr
                sta SCRPTR
                lda P3PFaddr+1
                sta SCRPTR+1

_gotChr         pla
                asl A                   ; hold score= char * 2
                sta HOLDIT

                lda #0                  ; erase rock on screen
                ldy #0
                sta (SCRPTR),Y

                lda ROCKS               ; decrement # of rocks remaining
                sec
                sbc #1
                sta ROCKS

                bcs _got1

                dec ROCKS+1

_got1           lda #$FE                ; start explosion sound
                sta EXPLODE

; add on to score
                ldy ScoreIndex,X        ; get base index to scores, and add to score
                lda HOLDIT
                clc
                adc SCORE1,Y
                sta SCORE1,Y

                lda #3                  ; set digit # for rollover prot.
                sta HOLDIT

_next1          lda SCORE1,Y            ; done?
                beq CheckHiScore        ;   yes, check high

                cmp #$3A                ; digit >10?
                bcc _scundx             ;   no, go right

                sec                     ; sub 10 from this digit
                sbc #10
                sta SCORE1,Y
                dey                     ; point to next
                dec HOLDIT
                bmi CheckHiScore        ; rollover! leave

                lda SCORE1,Y            ; get digit
                bne _scbrk              ; if blank, set to zero

                lda #$30
_scbrk          clc                     ; add 1
                adc #1
                sta SCORE1,Y            ; and save it
                bne _next1              ; check this digit

_scundx         ;iny                     ; go right one digit
                ;inc HOLDIT
                ;bne _next1

                jmp CheckHiScore

                .endproc
