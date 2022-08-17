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

_chkHits        lda P2PF,X              ; bomb hit anything?
                bne _chkRockOK

                jmp LowerBomb           ;   no, move bomb

_chkRockOK      and #7                  ; if hit only color 3, it gets erased
                bne _chkHitRock

                jmp HideBomb

;   set pointer into screen ram where the rock hit is
_chkHitRock     lda #0
                sta SCRPTR+1
                lda zpBombDrop,X

;   1st, get bomb's y-pos translated into row number and multiply it by 40
                sec
                sbc #103                ; A=(Y-103)&$F8
                and #$F8
                sta SCRPTR              ; SCRPTR=A
                asl SCRPTR              ; *4
                asl SCRPTR
                rol SCRPTR+1            ; roll into high-byte
                clc
                adc SCRPTR              ; *5
                sta SCRPTR
                bcc _gtp0

                inc SCRPTR+1            ; into high-byte
_gtp0           lda PlayerPosX,X        ; then, change x-pos into the column number
                ;sec
                ;sbc #47
                lsr A                   ; /4
                lsr A
                clc                     ; and add it on
                adc SCRPTR
                sta SCRPTR
                bcc _gtpA

                inc SCRPTR+1
_gtpA           clc                     ; add screen start address
                adc #<CANYON
                sta SCRPTR
                lda SCRPTR+1
                adc #>CANYON
                sta SCRPTR+1

                ldy #0                  ; clear index
                lda (SCRPTR),Y          ; & get char if it's blank
                beq _gtp1

                cmp #4                  ; or above 4 this isn't it.
                bcc _gotChr

_gtp1           iny                     ; try again, one right
                lda (SCRPTR),Y
                beq _gtp2

                cmp #4
                bcc _gotChr

_gtp2           ldy #$28                ; if we still don't get it, try 1 down
                lda (SCRPTR),Y
                beq _gtp3

                cmp #4
                bcc _gotChr

_gtp3           iny                     ; then, both at once
                lda (SCRPTR),Y
                bne _gckrck

                jmp LowerBomb           ; if by this time, we dont have it, then give up

_gckrck         cmp #4
                bcc _gotChr

                jmp LowerBomb

_gotChr         asl A                   ; hold score= char * 2
                sta HOLDIT

                lda #0                  ; erase rock on screen
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

                cmp #26                 ; digit >10?
                bcc _scundx             ;   no, go right

                sec                     ; sub 10 from this digit
                sbc #10
                sta SCORE1,Y
                dey                     ; point to next
                dec HOLDIT
                bmi CheckHiScore        ; rollover! leave

                lda SCORE1,Y            ; get digit
                bne _scbrk              ; if blank, set to zero

                lda #$10
_scbrk          clc                     ; add 1
                adc #1
                sta SCORE1,Y            ; and save it
                bne _next1              ; check this digit

_scundx         iny                     ; go right one digit
                inc HOLDIT
                bne _next1

                jmp CheckHiScore

                .endproc
