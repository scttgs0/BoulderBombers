;--------------------------------------
;
;--------------------------------------
INIT            .proc
                .frsGraphics mcTextOn|mcOverlayOn|mcGraphicsOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

                lda #<CharResX
                sta COLS_PER_LINE
                lda #>CharResX
                sta COLS_PER_LINE+1
                lda #CharResX
                sta COLS_VISIBLE

                lda #<CharResY
                sta LINES_MAX
                lda #>CharResY
                sta LINES_MAX+1
                lda #CharResY
                sta LINES_VISIBLE

                jsr InitLUT
                jsr InitCharLUT

                jsr SetFont
                jsr ClearScreen

                jsr InitSID             ; init sound

;   set playfield colors
                ;lda #$34               ; dark-orange, lum=4
                ;sta COLPF0
                ;lda #$28               ; red-orange, lum=8
                ;sta COLPF1
                ;lda #$84               ; medium-blue, lum=4
                ;sta COLPF2
                ;lda #$C4               ; medium-green, lum=4
                ;sta COLPF3
                ;lda #0                 ; black, lum=0
                ;sta COLBAK

;   set sprite colors
                ;lda #$28               ; red-orange, lum=8
                ;sta COLPM0
                ;lda #$84               ; medium-blue, lum=4
                ;sta COLPM1
                ;lda #$C8               ; medium-green, lum=8
                ;sta COLPM2
                ;lda #$C8               ; medium-green, lum=8
                ;sta COLPM3

;   initialize sprites
                jsr InitSprites

;_endless        bra _endless

                lda #0                  ; init vars
                ldy #SCRPTR+1-CLOCK
_next5          sta CLOCK,Y
                dey
                bpl _next5

                ldy #$27                ; set screen display
_next6          sta CANYON,Y
                dey
                bpl _next6

                jsr DrawScreen

                .m16
                lda #70                 ; set player lanes
                sta SP00_Y_POS
                .m8
                sta PlayerPosY

                .m16
                lda #90
                sta SP01_Y_POS
                .m8
                sta PlayerPosY+1
                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
RESTART         .proc
                lda #1                  ; set player start positions
                sta PlayerPosX
                lda #152
                sta PlayerPosX+1

                lda #0                  ; turn off explosions, and bkg sound
                sta SID_CTRL3
                sta EXPLODE
                ;sta AUDC4

                jsr ClearPlayer         ; clear players

                jsr RenderHiScore
                jsr RenderTitle
                jsr RenderAuthor
                jsr RenderSelect
                jsr RenderCanyon

                lda #$FF                ; set game speed for titles
                sta DELYVAL

                lda #dirRight           ; set start direction
                sta DIR
                sta PLAY                ; set play false

                lda #0                  ; players not on screen
                sta ONSCR

                jsr InitIRQs

                lda #3                  ; init clock
                sta CLOCK

_next1          lda CONSOL              ; check consol switches
                and #3
                cmp #1                  ; SELECT pressed?
                bne _chkSTART           ;   no, try START

_wait1          lda CONSOL              ;   yes, wait for key release
                and #2
                beq _wait1

                lda PLAYERS             ; change # of players
                eor #1
                sta PLAYERS
                clc
                adc #$31                ; & set on screen
                sta SCNOPLR
                jsr RenderSelect

                bra _moveT              ; (move players)

_chkSTART       cmp #2                  ; if START then start game
                beq START

_moveT          lda ONSCR               ; if on screen, then move
                bne _moveIt

                lda SID_RANDOM          ; else, pick out new ship type
                and #1
                tax
                lda MASKS,X
                sta MASK                ; & set it

                .m16
                ;lda MasksSprOffset,X
                ;sta SP00_ADDR
                ;sta SP01_ADDR

                cpx #maskBalloon
                beq _moveIt

                ;clc    ; HACK:
                ;adc $800
                ;sta SP00_ADDR

_moveIt         .m8
                jsr MovePlayer          ; move players

                jmp _next1              ; do check again

                .endproc


;--------------------------------------
;
;--------------------------------------
START           .proc
                lda CONSOL              ; wait for key release
                and #1
                beq START

                lda #3                  ; set game speed to $ff+$04
                sta DELYVAL

                lda #0                  ; set play true
                sta PLAY

                ldx #2                  ; reset scores to zero
_next1          sta SCORE1,X
                sta SCORE2,X
                dex
                bpl _next1

                lda #$10
                sta SCORE1+3
                sta SCORE2+3

                ldx #2                  ; set bombs remaining to three
                lda #$CD
_next2          sta BOMB1,X
                sta BOMB2,X
                dex
                bpl _next2

                lda #3
                sta BOMBS
                sta BOMBS+1

                lda #$11                ; set next free bomb at 1000
                sta FREMEN
                sta FREMEN+1

;   set second player message to 'player 2' or 'computer'
                lda PLAYERS
                asl A
                asl A
                asl A

                ldx #7
                tay
_next3          lda P2COMPT,Y
                sta P2MSG,X
                iny
                dex
                bpl _next3

                ;lda #<DLIST2           ; set dlist to game screen
                ;sta DLIST
                ;lda #>DLIST2
                ;sta DLIST+1

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
NewScreen       .proc
                jsr DrawScreen          ; set canyon

                lda #maskBalloon        ; set type to Balloon
                sta MASK
                sta CLOCK               ; and begin clock

                .m16
                lda #$0000
                sta SP00_ADDR
                sta SP01_ADDR
                .m8

                lda #dirRight
                sta DIR

                sta ROCKS+1             ; rocks in canyon=298
                lda #42
                sta ROCKS
                jsr ClearPlayer         ; clear players

                lda #0                  ; set players on screen=false
                sta ONSCR
                ;sta AUDF4

                lda #1                  ; set start positions of players
                sta PlayerPosX
                lda #152
                sta PlayerPosX+1

                ;sta HITCLR             ; clear collisions

                lda #8                  ; # of rocks per bomb
                sta RKILL               ; (max) = 8

                lda DELYVAL             ; speed up the game just a bit
                cmp #$AF
                beq BMBLOOP             ; (unless already at max speed)

                sec
                sbc #4
                sta DELYVAL

                .endproc

                ;[fall-through]


;--------------------------------------
; bomb movement, hit checks,
; score and highscore set
;--------------------------------------
BMBLOOP         .proc
                ldx #1                  ; get player index
                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
BMBNLOP         .proc
                lda BMBDRP,X            ; if bomb not dropped
                bne _chkHits

                jmp CheckDrop           ; check trigger

_chkHits        ;lda P2PF,X             ; bomb hit anything?
                ;bne _chkRockOK
                bra _chkRockOK  ; HACK:

                jmp LowerBomb           ;   no, move bomb

_chkRockOK      and #7                  ; if hit only color 3, it gets erased
                bne _chkHitRock

                jmp KILLBMB

_chkHitRock
;   set pointer into screen ram where the rock hit is
                lda #0
                sta SCRPTR+1
                lda BMBDRP,X

;   1st, get bomb's y-pos translated into row number and multiply it by 40
                sec
                sbc #103
                and #$F8
                sta SCRPTR
                asl SCRPTR
                asl SCRPTR
                rol SCRPTR+1
                clc
                adc SCRPTR
                sta SCRPTR
                bcc _gtp0

                inc SCRPTR+1
_gtp0           lda PlayerPosX,X        ; then, change x-pos into the column number
                sec
                sbc #47
                lsr A
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

                ldy SCRNDX,X            ; get base index to scores, and add to score
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

                .endproc

                ;[fall-through]


;--------------------------------------
; check for high score
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
                cmp HISCOR,Y            ; compare 'em
                beq _chkNxtDgt          ; if same, do next

                bcs SetHiScore          ; if player > set

                bcc CHKFRM              ; if high > skip

_chkNxtDgt      iny                     ; do next digit
                cpy #4                  ; if all done, then it's the same, skip
                bne _next1

                beq CHKFRM

                .endproc

                ;[fall-through]


;--------------------------------------
; set high score
;--------------------------------------
SetHiScore      .proc
                ldy #3                  ; copy the new high score into HISCOR
_next1          lda (SCRPTR),Y
                sta HISCOR,Y
                dey
                bpl _next1

                jsr RenderHiScore

                .endproc

                ;[fall-through]


;======================================
; check for getting extra bombs
;======================================
CHKFRM          .proc
                ldy SCRNDX,X            ; get score in thousands
                lda SCORE1-3,Y
                cmp FREMEN,X            ; if not free bomb yet,skip.
                bne _STRKHT

                inc BOMBS,X             ; else, up bombs by 1
                lda BOMBS,X
                cmp #4                  ; if bombs>=4, keep in reserve
                bcs _UPDTFM

                clc                     ; if bombs less than 4, then set extra on screen
                adc SCRNDX,X
                tay
                lda #$CD
                sta BOMB1-4,Y
_UPDTFM         inc FREMEN,X            ; set for next

_STRKHT         inc RCKHIT,X            ; if new # of rocks hit = max, kill bomb else, lower it
                lda RCKHIT,X
                cmp RKILL
                bne LowerBomb

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
KILLBMB         .proc
                txa                     ; set pointer to bomb
                clc
                adc #>PL2
                sta SCRPTR+1
                lda BMBDRP,X
                sta SCRPTR

                ldy #5                  ; and erase it
                lda #0
_next1          sta (SCRPTR),Y
                dey
                bpl _next1

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
KILBOMB         .proc
                txa                     ; turn off sound for this bomb
                .mult7
                tay

                .setbank $AF
                lda #0
                sta SID_FREQ1,Y
                sta SID_CTRL1,Y
                .setbank $00
                sta BMBDRP,X            ; set flag off

                lda RCKHIT,X            ; if it didn't hit anything,
                bne _hop

                jsr DecrementMissile    ; lower # bombs

_hop            jmp DoNextBomb          ; & do next

                .endproc


;--------------------------------------
; lower the bombs
;--------------------------------------
LowerBomb       .proc
                txa
                clc
                adc #>PL2               ; set pointer to bomb
                sta SCRPTR+1
                lda BMBDRP,X
                sta SCRPTR

                lda #0                  ; erase the bomb
                ldy #5
_next1          sta (SCRPTR),Y
                dey
                bpl _next1

                inc DRPRATE,X           ; up drop speed
                lda DRPRATE,X
                lsr A                   ; update position
                lsr A
                lsr A
                lsr A
                sta HOLDIT
                clc
                adc BMBDRP,X
                cmp #196                ; out of range?
                bcs KILBOMB             ;   yes, kill it

                sta BMBDRP,X            ;   no, set the bomb
                sta SCRPTR

                ldy #5
_next2          lda CharsetCustom+96,Y
                sta (SCRPTR),Y
                dey
                bpl _next2

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

                jmp BMBNLOP             ; do next

                .endproc


;--------------------------------------
; check & drop bombs
;--------------------------------------
CheckDrop       .proc
                lda BOMBS,X             ; if no bombs left then do next
                beq DoNextBomb

                txa                     ; if not the computer, check trigger
                clc
                sbc PLAYERS
                bne _CHKTRG             ; it's player!

                lda DIR                 ; going left?
                bmi _GOINGR             ;   no!

                lda PlayerPosX,X        ; get computer x
                cmp #1                  ; too far left?
                bcc DoNextBomb          ;   yes!
                bcs _TRYDRP             ;   no, try drop!

_GOINGR         lda PlayerPosX,X        ; get computer x
                cmp #152                ; too far right?
                bcs DoNextBomb          ;   yes!

_TRYDRP         lda SID_RANDOM          ; computer drops a bomb if random says to
                and #15
                beq _DROPIT
                bne DoNextBomb          ; else do next

_CHKTRG         lda JOYSTICK0,X         ; trig pushed?
                and #$10
                bne DoNextBomb          ;   no, do next

_DROPIT         lda PlayerPosY,X        ; drop: set bomb Y to player Y+8
                clc
                adc #8
                sta BMBDRP,X
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

                jmp BMBLOOP             ;   no, do bombs

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

                jmp BMBLOOP             ; do bombs again

                .endproc


;======================================
; move player, check for leaving
; screen, end game check, switch
; ship types
;======================================
MovePlayer      .proc
                lda ONSCR               ; if not on screen, set sound
                bne _ADDCLOK

                lda MASK                ; player is Balloon?
                cmp #maskBalloon
                beq _STBLSND            ;   yes, do that

                lda #$96                ; set plane sound
                ;sta AUDF4
                lda #$24
                ;sta AUDC4
                bne _ADDCLOK            ; & goto clock add

_STBLSND        lda #0                  ; set wind sound
                ;sta AUDF4
                lda #2
                ;sta AUDC4
                ldx #1                  ; set Balloon
_next1          lda PlayerPosY,X
                sta SCRPTR
                txa
                clc
                adc #>PL0
                sta SCRPTR+1
                ldy #15
_next2          lda CharsetCustom+80,Y
                sta (SCRPTR),Y
                dey
                bpl _next2

                dex
                bpl _next1

_ADDCLOK        inc CLOCK               ; add to clock
                lda CLOCK               ; if clock and
                and MASK                ; mask<>0 then don't move
                bne _DODELAY

                lda PlayerPosX          ; move the players; first player 1
                clc
                adc DIR
                sta PlayerPosX

                .m16
                and #$FF
                asl A
                clc
                adc #32
                sta SP00_X_POS
                sta SP02_X_POS
                .m8

                lda DIR                 ; then player 2
                eor #$FE
                clc
                adc PlayerPosX+1
                sta PlayerPosX+1

                .m16
                and #$FF
                asl A
                clc
                adc #32
                sta SP01_X_POS
                sta SP03_X_POS
                .m8

                lda MASK                ; if on planes then check if time to animate
                cmp #maskPlane
                bne _DODELAY

                lda CLOCK               ; props
                and #2
                beq _DODELAY            ;   no, skip this

                lda DIR                 ; set temp dir
                sta TDIR                ; (will be killed)
                ldx #1
_next3          lda PlayerPosY,X        ; set pointer to player
                sta SCRPTR
                txa
                clc
                adc #>PL0
                sta SCRPTR+1
                lda CLOCK               ; get image index from clock
                and #4
                asl A
                sta HOLDIT              ; and hold it
                lda TDIR                ; get direction index from dir
                and #$10
                clc
                adc HOLDIT              ; & add 'em to get index.
                stx HOLDIT
                tax                     ; save player #
                ldy #0                  ; set player
_next4          lda CharsetCustom+48,X
                sta (SCRPTR),Y
                inx
                iny
                cpy #8
                bne _next4

                lda TDIR                ; reverse tdir
                eor #$FE
                sta TDIR
                ldx HOLDIT              ; get player #
                dex                     ; & animate next
                bpl _next3

; _DODELAY        ldx #15                 ; wait for a while to make game playable
; _wait1          ldy DELYVAL
; _wait2          dey
;                 bne _wait2

;                 dex
;                 bne _wait1

_DODELAY        lda JIFFYCLOCK
                inc A
                inc A
_wait1          cmp JIFFYCLOCK
                bne _wait1

;   players are now on screen, but check to see if they aren't
                lda #1
                sta ONSCR

                lda PlayerPosX
                beq _OFFSCR

                cmp #152
                bne _XIT                ; if on, return

_OFFSCR         lda #0                  ; else, turn off explosions and bkg sound
                sta SID_CTRL3
                ;sta AUDC4
                sta EXPLODE
                sta ONSCR               ; set onscreen false
                ldx #1
_next5          lda BMBDRP,X            ; if a bomb is in the air, and
                beq _CKBRN

                lda RCKHIT,X            ; it hasn't hit anything yet,
                bne _CKBRN

                jsr DecrementMissile    ; it's a miss

_CKBRN          lda BRUN,X              ; if no bombs dropped this pass,
                bne _CKNBR

                jsr DecrementMissile    ; it's a miss

_CKNBR          dex
                bpl _next5

                jsr ClearPlayer         ; clear out players

                ldx PLAYERS             ; if the actual players have no more bombs,
                lda BOMBS
                clc
                adc BOMBS,X             ; and we're on a game, end it
                adc PLAY
                beq EndGame

                lda DIR                 ; reverse direction
                eor #$FE
                sta DIR

                ldx PlayerPosY          ; change player lanes
                ldy PlayerPosY+1
                stx PlayerPosY+1
                sty PlayerPosY

                .m16
                tya
                and #$FF
                sta SP00_Y_POS
                txa
                and #$FF
                sta SP01_Y_POS
                .m8

                lda #3                  ; reset clock
                sta CLOCK
                lda ROCKS+1             ; if half of the rocks are gone
                bne _XIT

                lda ROCKS               ; then switch to planes
                cmp #149
                bcs _XIT                ; else return

                lda #maskPlane          ; set move rate mask
                sta MASK
                lda #4                  ; plane bombs get max of 4 rocks
                sta RKILL

                ;.m16
                ;lda #$0C00
                ;sta SP00_ADDR
                ;lda #$0400
                ;sta SP01_ADDR
                ;.m8

_XIT            rts
                .endproc


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


;======================================
; set canyon screen image
;======================================
DrawScreen      .proc
                ldy #0                  ; copy rocks & canyon to screen
_next1          lda ROCKIMG,Y
                sta CANYON+40,Y
                iny
                bne _next1

                ldy #145
_next2          lda ROCKIMG+255,Y
                sta CANYON+295,Y
                dey
                bne _next2

                rts
                .endproc


;======================================
; lower number of bombs remaining
;======================================
DecrementMissile .proc
                lda BOMBS,X             ; if already zero, exit
                beq _XIT

                dec BOMBS,X             ; lower bombs left
                lda BOMBS,X             ; if at least 3 remain, return
                cmp #3
                bcs _XIT

                clc                     ; get index for screen to erase bomb
                adc SCRNDX,X
                tay
                lda #0
                sta BOMB1-3,Y
_XIT            rts
                .endproc


;======================================
; clear players, bomb y positions,
; bombs dropped this pass, and
; turn off bomb sounds
;======================================
ClearPlayer     .proc
                lda #0
                tay
_next1          sta PL0,Y               ; clear all players
                sta PL1,Y
                sta PL2,Y
                sta PL3,Y
                dey
                bne _next1

                sta BMBDRP              ; clear bomb y position & bombs dropped this pass
                sta BMBDRP+1
                sta BRUN
                sta BRUN+1

                sta SID_CTRL1           ; turn off bomb fall sounds
                sta SID_CTRL2
                rts
                .endproc
