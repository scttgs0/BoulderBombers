;--------------------------------------
; check for high score
;--------------------------------------
; on entry
;   X           player index [0,1]
;--------------------------------------
CheckHiScore    .proc
                lda #<SCORE1
                sta SCRPTR              ; set pointer to score for player 1
                lda #>SCORE1
                sta SCRPTR+1

                txa                     ; if it isn't player 1, then
                beq _chkScore

                lda #10                 ; add to get pointer for player 2
                clc
                adc SCRPTR
                sta SCRPTR
                bcc _chkScore

                inc SCRPTR+1
_chkScore       ldy #0                  ; begin at hi end
_next1          lda (SCRPTR),Y
                cmp HighScoreMsg+11,Y   ; compare 'em
                beq _chkNxtDgt          ; if same, do next

                bcs SetHiScore          ; if player > set
                bcc CheckFreeMan        ; if high > skip

_chkNxtDgt      iny                     ; do next digit
                cpy #4                  ; if all done, then it's the same, skip
                bne _next1

                beq CheckFreeMan

                .endproc

                ;[fall-through]


;--------------------------------------
; set high score
;--------------------------------------
SetHiScore      .proc
                ldy #3                  ; copy the new high score into HISCOR
_next1          lda (SCRPTR),Y
                sta HighScoreMsg+11,Y
                dey
                bpl _next1

                jsr RenderHiScore2

                .endproc

                ;[fall-through]


;======================================
; check for getting extra bombs
;--------------------------------------
; on entry
;   X           player index [0,1]
;======================================
CheckFreeMan    .proc
                ldy ScoreIndex,X        ; get score in thousands
                lda SCORE1-3,Y
                cmp zpFreeManTarget,X   ; if not free bomb yet, skip.
                bne _strikeHit

                inc zpBombCount,X       ; else, up bombs by 1
                lda zpBombCount,X
                cmp #4                  ; if bombs>=4, keep in reserve
                bcs _updateTarget

                clc                     ; if bombs less than 4, then set extra on screen
                adc ScoreIndex,X
                tay
                lda #$CD
                sta BOMB1-4,Y
_updateTarget   inc zpFreeManTarget,X   ; set for next

_strikeHit      inc zpRockHit,X         ; if new # of rocks hit = max, kill bomb else, lower it
                lda zpRockHit,X
                cmp RocksPerBomb
                bne LowerBomb

                jmp HideBomb

                .endproc
