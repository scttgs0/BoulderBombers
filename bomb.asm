;--------------------------------------
; Remove bomb from screen
;--------------------------------------
HideBomb        .proc
                .m16
                lda #$00
                cpx #1
                beq _player2

                sta SP02_Y_POS
                bra _XIT

_player2        sta SP03_Y_POS

_XIT           .m8
                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
KillBomb        .proc
                txa                     ; turn off sound for this bomb
                .mult7
                tay

                .setbank $AF
                lda #0
                sta SID_FREQ1,Y
                sta SID_CTRL1,Y
                .setbank $00

                sta zpBombDrop,X        ; set flag off

                lda RCKHIT,X            ; if it didn't hit anything,
                bne _hop

                jsr DecrementMissile    ; lower # bombs

_hop            jmp DoNextBomb          ; & do next

                .endproc


;--------------------------------------
; decend the bombs
;--------------------------------------
LowerBomb       .proc
                lda zpBombDrop,X

                inc DRPRATE,X           ; up drop speed
                lda DRPRATE,X
                lsr A                   ; update position
                lsr A
                lsr A
                lsr A
                sta HOLDIT

                clc
                adc zpBombDrop,X
                cmp #212                ; out of range?
                bcs KillBomb            ;   yes, kill it

                sta zpBombDrop,X        ;   no, set the bomb

                .m16
                and #$FF

                cpx #1
                beq _player2

                sta SP02_Y_POS
                bra _cont

_player2        sta SP03_Y_POS

_cont           .m8
                txa                     ; set y to index the sound regs
                .mult7
                tay

                lda HOLDIT              ; update sound of dropping bomb
                clc
                adc DRPFREQ,X
                sta DRPFREQ,X
                .setbank $AF
                sta SID_FREQ1,Y
                .setbank $00

                lda #$A8
                sec
                sbc HOLDIT
                .setbank $AF
                sta SID_CTRL1,Y
                .setbank $00
                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
DoNextBomb      .proc
                dex                     ; reset index if both not done
                bmi CheckDrop._DOPLMV

                jmp BombNextLoop        ; do next

                .endproc


;--------------------------------------
; check & drop bombs
;--------------------------------------
CheckDrop       .proc
                lda BombCount,X         ; if no bombs left then do next
                beq DoNextBomb

                txa                     ; if not the computer, check trigger
                clc
                sbc PlayerCount
                bne _chkTrigger         ; it's player!

                lda DIR                 ; going left?
                bmi _GOING_R            ;   no!

                lda PlayerPosX,X        ; get ship x
                cmp #1                  ; too far left?
                bcc DoNextBomb          ;   yes!
                bcs _TRYDRP             ;   no, try drop!

_GOING_R        lda PlayerPosX,X        ; get computer x
                cmp #151                ; too far right?
                bcs DoNextBomb          ;   yes!

_TRYDRP         .randomByte             ; computer drops a bomb if random says to
                and #15
                beq _DROPIT
                bne DoNextBomb          ; else do next

_chkTrigger     lda JOYSTICK0,X         ; trig pushed?
                and #$10
                bne DoNextBomb          ;   no, do next

_DROPIT         lda PlayerPosY,X        ; drop: set bomb Y to player Y+8
                clc
                adc #8
                sta zpBombDrop,X

                lda #0                  ; clear drop rate
                sta DRPRATE,X
                sta RCKHIT,X            ; and rocks hit
                inc BRUN,X              ; increment bombs dropped
                lda #50                 ; set the sound flag
                sta DRPFREQ,X
                bne DoNextBomb          ; and do next

_DOPLMV         ;sta HITCLR             ; clear collisions

                jsr MovePlayer          ; move players

                lda EXPLODE             ; explosion going?
                beq _CKRSTRT            ;   no, skip

                dec EXPLODE             ; update explosion sound
                dec EXPLODE
                eor #$F0
                sta SID_FREQ3
                lsr A
                lsr A
                lsr A
                lsr A
                eor #$8F
                sta SID_CTRL3
_CKRSTRT        lda CONSOL              ; any console buttons pushed?
                cmp #7
                beq _CKNSCR             ;   no

                jmp RESTART             ;   yes, re-start

_CKNSCR         lda ROCKS               ; # of rocks left
                bne _CHKPAUS            ; = zero?

                lda ROCKS+1
                bne _CHKPAUS            ;   no

                jmp NewScreen           ;   yes, set up a new screen

_CHKPAUS        lda KEYCHAR             ; spacebar pressed?
                cmp #33
                bne _CKDRRCK            ;   no, continue

                lda #0                  ;   yes, pause game
                sta SID_CTRL1           ; turn off main sounds
                sta SID_CTRL2
                sta SID_CTRL3

_wait1          lda JOYSTICK0           ; wait for stick movement
                and #$0F
                cmp #$0F
                beq _wait1

                lda #$FF                ; reset for another pause
                sta KEYCHAR

_CKDRRCK        lda CLOCK               ; time to drop
                and #15                 ; suspended
                beq _DRPROCK            ; rocks?

                jmp BombLoop            ;   no, do bombs

_DRPROCK        lda #39                 ; set column to 39
                sta XCOUNT

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
                beq _DONXRCK

                tax                     ; else hold it & look underneath
                ldy #$28
                lda (SCRPTR),Y
                bne _DONXRCK            ; not blank-do next

                txa                     ; blank, move rock above down
                sta (SCRPTR),Y
                ldy #0
                tya
                sta (SCRPTR),Y
                lda SCRPTR              ; & go up one so whole column won't fall at once
                sec
                sbc #$28
                sta SCRPTR
                bcs _NOVER

                dec SCRPTR+1
_NOVER          dec YCOUNT              ; last row done?
                bmi _DONXCOL            ;   yes, do next col

_DONXRCK        lda SCRPTR              ; go up one row
                sec
                sbc #$28
                sta SCRPTR
                bcs _NOVER2

                dec SCRPTR+1
_NOVER2         dec YCOUNT              ; last row done?
                bpl _next2              ;   yes, do next col

_DONXCOL        dec XCOUNT              ; last col done?
                bpl _next1              ;   no, do next

                jmp BombLoop            ; do bombs again

                .endproc


;======================================
; lower number of bombs remaining
;--------------------------------------
; on entry
;   X           Player owning bomb [0,1]
;======================================
DecrementMissile .proc
                lda BombCount,X         ; if already zero, exit
                beq _XIT

                dec BombCount,X         ; lower bombs left
                lda BombCount,X         ; if at least 3 remain, return
                cmp #3
                bcs _XIT

                clc                     ; get index for screen to erase bomb
                adc ScoreIndex,X
                tay
                lda #0
                sta BOMB1-3,Y

                jsr RenderScore

_XIT            rts
                .endproc
