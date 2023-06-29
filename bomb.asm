
;--------------------------------------
; Remove bomb from screen
;--------------------------------------
; on entry
;   X           player index [0,1]
;--------------------------------------
HideBomb        .proc
                cpx #1
                beq _player2

                .frsSpriteClearY 2
                bra _killbomb

_player2        .frsSpriteClearY 3

_killbomb       txa                     ; turn off sound for this bomb
                .mult7
                tay

                lda #0
                sta SID1_FREQ1,Y
                sta SID1_CTRL1,Y

                stz zpBombDrop,X        ; set flag off

                lda zpRockHit,X         ; if it didn't hit anything,
                bne _hop

                jsr DecrementMissile    ; lower # bombs

_hop            jmp DoNextBomb          ; & do next

                .endproc


;--------------------------------------
; decend the bombs
;--------------------------------------
; on entry
;   X           player index [0,1]
;--------------------------------------
LowerBomb       .proc
                inc zpDropRate,X        ; up drop speed
                lda zpDropRate,X
                lsr                     ; update position
                lsr
                lsr
                lsr                     ; /16
                sta HOLDIT

                clc
                adc zpBombDrop,X
                cmp #224                ; out of range?
                bcs HideBomb            ;   yes, kill it

                sta zpBombDrop,X        ;   no, set the bomb

                cpx #1
                beq _player2

                sta SPR(sprite_t.Y, 2)
                stz SPR(sprite_t.Y+1, 2)
                bra _cont

_player2        sta SPR(sprite_t.Y, 3)
                stz SPR(sprite_t.Y+1, 3)

_cont           txa                     ; set y to index the sound regs
                .mult7
                tay

                lda HOLDIT              ; update sound of dropping bomb
                clc
                adc zpDropFreq,X
                sta zpDropFreq,X

                sta SID1_FREQ1,Y

                lda #$A8
                sec
                sbc HOLDIT

                sta SID1_CTRL1,Y
                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
; on entry
;   X           player index [0,1]
;--------------------------------------
DoNextBomb      .proc
                dex                     ; reset index if both not done
                bmi CheckDrop._doPlyrMove

                jmp BombNextLoop        ; do next

                .endproc


;--------------------------------------
; check & drop bombs
;--------------------------------------
; on entry
;   X           player index [0,1]
;--------------------------------------
CheckDrop       .proc
                lda zpBombCount,X       ; if no bombs left then do next
                beq DoNextBomb

                txa                     ; if not the computer, check trigger
                clc
                sbc PlayerCount
                bne _chkTrigger         ; it's player!

;   computer only code -- note: computer direction is opposite of player
                lda DIR                 ; going left?
                bmi _going_right        ;   no!

                lda PlayerPosX,X        ; get ship x
                cmp #1                  ; too far left?
                bcc DoNextBomb          ;   yes!
                bra _tryDrop            ;   no, try drop!

_going_right    lda PlayerPosX,X        ; get computer x
                cmp #152                ; too far right?
                bcs DoNextBomb          ;   yes!

_tryDrop        .frsRandomByte          ; computer drops a bomb if random says to
                and #15
                beq _dropIt
                bne DoNextBomb          ; else do next
;--- END computer only code

_chkTrigger     lda InputFlags,X        ; trig pushed?
                and #$10
                bne DoNextBomb          ;   no, do next

_dropIt         lda PlayerPosY,X        ; drop: set bomb Y to player Y+8
                clc
                adc #8
                sta zpBombDrop,X

                lda #0                  ; clear drop rate
                sta zpDropRate,X
                sta zpRockHit,X         ; and rocks hit
                inc zpBombRunDrops,X    ; increment bombs dropped

                lda #50                 ; set the sound flag
                sta zpDropFreq,X
                bne DoNextBomb          ; and do next

_doPlyrMove     stz P2PF                ; clear collisions
                stz P3PF

                phx
                jsr MovePlayer          ; move players
                plx

                lda EXPLODE             ; explosion going?
                beq _chkRestart         ;   no, skip

                dec EXPLODE             ; update explosion sound
                dec EXPLODE
                eor #$F0
                sta SID1_FREQ3
                lsr                     ; /16
                lsr
                lsr
                lsr
                eor #$8F
                sta SID1_CTRL3

_chkRestart     lda CONSOL              ; any console buttons pushed?
                cmp #7
                beq _chkNewScrn         ;   no

                jmp RESTART             ;   yes, re-start

_chkNewScrn     lda ROCKS               ; # of rocks left
                bne _chkPause           ; = zero?

                lda ROCKS+1
                bne _chkPause           ;   no

                jmp NewScreen           ;   yes, set up a new screen

_chkPause       lda KEYCHAR             ; spacebar pressed?
                cmp #$39
                bne _chkRockDrop        ;   no, continue

                lda #0                  ;   yes, pause game
                sta SID1_CTRL1          ; turn off main sounds
                sta SID1_CTRL2
                sta SID1_CTRL3

_wait1          lda InputFlags          ; wait for stick movement
                and #$0F
                cmp #$0F
                beq _wait1

                lda #$FF                ; reset for another pause
                sta KEYCHAR

_chkRockDrop    lda CLOCK               ; time to drop
                and #15                 ; suspended
                beq _dropRock           ; rocks?

                jmp BombLoop            ;   no, do bombs

_dropRock       lda #39                 ; set column to 39
                sta XCOUNT

                phx
_next1          lda #8                  ; row to 8
                sta YCOUNT              ; and set pointer
                lda #<CANYON+360        ; to xcount
                clc                     ; plus canyon
                adc XCOUNT              ; start
                sta SCRPTR
                lda #>CANYON+360
                adc #0
                sta SCRPTR+1

_next2          ldy #0                  ; rock fall loop:
                lda (SCRPTR),Y          ; nothing there then try next up
                beq _doNextRock

                tax                     ; else hold it & look underneath
                ldy #$28
                lda (SCRPTR),Y
                bne _doNextRock         ; not blank-do next

                txa                     ; blank, move rock above down
                sta (SCRPTR),Y
                ldy #0
                tya
                sta (SCRPTR),Y
                lda SCRPTR              ; & go up one so whole column won't fall at once
                sec
                sbc #$28
                sta SCRPTR
                bcs _notOver

                dec SCRPTR+1
_notOver        dec YCOUNT              ; last row done?
                bmi _doNextColumn       ;   yes, do next col

_doNextRock     lda SCRPTR              ; go up one row
                sec
                sbc #$28
                sta SCRPTR
                bcs _notOver2

                dec SCRPTR+1
_notOver2       dec YCOUNT              ; last row done?
                bpl _next2              ;   yes, do next col

_doNextColumn   dec XCOUNT              ; last col done?
                bpl _next1              ;   no, do next

                plx
                jmp BombLoop            ; do bombs again

                .endproc


;======================================
; lower number of bombs remaining
;--------------------------------------
; on entry
;   X           player index [0,1]
;======================================
DecrementMissile .proc
                lda zpBombCount,X       ; if already zero, exit
                beq _XIT

                dec zpBombCount,X       ; lower bombs left
                lda zpBombCount,X       ; if at least 3 remain, return
                cmp #3
                bcs _XIT

                clc                     ; get index for screen to erase bomb
                adc ScoreIndex,X
                adc #2                  ; bomb icons are 2 chars from the score index
                tay
                lda #0
                sta SCORE1,Y

                jsr RenderScore

_XIT            rts
                .endproc
