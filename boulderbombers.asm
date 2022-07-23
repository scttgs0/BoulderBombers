;***********************
;*                     *
;*  'BOULDER BOMBERS'  *
;*         by          *
;*     Mark Price      *
;*                     *
;***********************

                .include "equates_system_c256.asm"
                .include "equates_zeropage.asm"
                .include "equates_game.asm"

                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"


            .enc "atari-screen"
                .cdef " Z",$00
                .cdef "az",$61
            .enc "atari-screen-inverse"
                .cdef " Z",$80
                .cdef "az",$E1
            .enc "none"


;--------------------------------------
;--------------------------------------
                * = INIT-40
;--------------------------------------
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            clc
                xce
                .m8i8
                .setdp $0000
                .setbank $00

                jmp INIT


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------


;--------------------------------------
;
;--------------------------------------
INIT            .proc
                ldx #111                ; copy my chars
_next1          lda MYCHARS,X
                sta CharsetCustom,X
                dex
                bpl _next1

                ;lda #0                  ; disable vbi
                ;sta NMIEN

                ;lda #$34                ; set colors
                ;sta COLPF0
                ;lda #$28
                ;sta COLPF1
                ;lda #$84
                ;sta COLPF2
                ;lda #$C4
                ;sta COLPF3
                ;lda #0
                ;sta COLBAK

;   quad-wide sprites
                ;ldx #3                  ; init players
_next2          ;sta SIZEP0,X
                ;dex
                ;bpl _next2

                ;lda #$28
                ;sta COLPM0
                ;lda #$84
                ;sta COLPM1
                ;lda #$C8
                ;sta COLPM2
                ;lda #$C8
                ;sta COLPM3

                ;lda #>PMAREA
                ;sta PMBASE

;   enabled instruction fetch, single-line sprite, sprite DMA, normal playfield
                ;lda #$3E
                ;sta DMACTL

;   enable players and missiles
                ;lda #3
                ;sta GRACTL

                ldy #112                ; init chr set
_next3          lda CharsetNorm,Y
                sta CharsetCustom,Y
                iny
                bne _next3

_next4          lda CharsetNorm+256,Y
                sta CharsetCustom+256,Y
                iny
                bne _next4

                ;lda #>CharsetCustom
                ;sta CHBASE

                lda #0                  ; init vars
                ldy #SCRPTR+1-CLOCK
_next5          sta CLOCK,Y
                dey
                bpl _next5

                ldy #$27                ; set screen disp
_next6          sta CANYON,Y
                dey
                bpl _next6

                jsr DrawScreen

                ;lda #0                  ; init sound
                ;sta AUDCTL

;   bring POKEY out of the two-tone mode (prevent noise)
                ;lda #3
                ;sta SKCTL

                lda #56                 ; set player
                sta PLYRY               ;  lanes
                lda #72
                sta PLYRY+1

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
RESTART         .proc
                lda #44                 ; set player
                sta PLYRX               ; start
                lda #204                ; positions
                sta PLYRX+1

                lda #0                  ; turn off screen
                ;sta DMACTL
                ;sta AUDC3               ; explosions,
                sta EXPLODE
                ;sta AUDC4               ; and bkg sound

                jsr ClearPlayer         ; clear players

                ;lda #<DLIST1            ;set title
                ;sta DLIST               ; screen
                ;lda #>DLIST1
                ;sta DLIST+1

                lda #$FF                ; set game speed
                sta DELYVAL             ; for titles

                lda #1                  ; set start dir
                sta DIR
                sta PLAY                ; set play false

                lda #0                  ; players not
                sta ONSCR               ; on screen

;   enabled instruction fetch, single-line sprite, sprite DMA, normal playfield
                ;lda #$3E                ; turn screen back on
                ;sta DMACTL

                lda #3                  ; init clock
                sta CLOCK

_next1          lda CONSOL              ; check consol
                and #3                  ; switches
                cmp #1                  ; select pressed?
                bne _chkSTART           ;   no, try start

_wait1          lda CONSOL              ; yes, wait for
                and #2                  ; key release
                beq _wait1

                lda PLAYERS             ; change # of
                eor #1                  ; players
                sta PLAYERS
                clc
                adc #$11                ; & set on screen
                sta SCNOPLR
                bne _moveT               ; (move players)

_chkSTART       cmp #2                  ; if start then
                beq START               ; start game

_moveT          lda ONSCR               ; if on screen,
                bne _moveIt             ; then move

                lda SID_RANDOM          ; else, pick out
                and #1                  ; new ship type
                tax
                lda MASKS,X
                sta MASK                ; & set it
_moveIt         jsr MovePlayer          ; move players

                jmp _next1              ; do check again

                .endproc


;--------------------------------------
;
;--------------------------------------
START           .proc
                lda CONSOL              ; wait for key
                and #1                  ; release
                beq START

                lda #3                  ; set game speed
                sta DELYVAL             ; to $ff+$04

                lda #0                  ; set play true
                sta PLAY
                ;sta DMACTL             ; turn off screen

                ldx #2                  ; set scores to
_next1          sta SCORE1,X            ; zero
                sta SCORE2,X
                dex
                bpl _next1

                lda #$10
                sta SCORE1+3
                sta SCORE2+3

                ldx #2                  ; set bombs left
                lda #$CD                ; to three
_next2          sta BOMB1,X
                sta BOMB2,X
                dex
                bpl _next2

                lda #3
                sta BOMBS
                sta BOMBS+1

                lda #$11                ; set next free
                sta FREMEN              ; bomb at 1000
                sta FREMEN+1

                lda PLAYERS             ; set second
                asl A                   ; player message
                asl A                   ; to 'player 2'
                asl A                   ; or 'computer'

                ldx #7
                tay
_next3          lda P2COMPT,Y
                sta P2MSG,X
                iny
                dex
                bpl _next3

                ;lda #<DLIST2            ; set dlist
                ;sta DLIST               ; to game
                ;lda #>DLIST2            ; screen
                ;sta DLIST+1

;   enabled instruction fetch, single-line sprite, sprite DMA, normal playfield
                ;lda #$3E                ; turn on screen
                ;sta DMACTL

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
NewScreen       .proc
                jsr DrawScreen          ; set canyon

                lda #3                  ; set type to
                sta MASK                ; balloon
                sta CLOCK               ; and begin clock

                lda #1
                sta DIR                 ; dir = right

                sta ROCKS+1             ; rocks in
                lda #42                 ; canyon=298
                sta ROCKS
                jsr ClearPlayer         ; clear players

                lda #0                  ; set players on
                sta ONSCR               ; screen=false
                ;sta AUDF4

                lda #44                 ; set start
                sta PLYRX               ; positions
                lda #204                ; of players
                sta PLYRX+1

                ;sta HITCLR              ; clear collisions

                lda #8                  ; #rocks per bomb
                sta RKILL               ; (max) =8

                lda DELYVAL             ; speed up the
                cmp #$AF                ; game just a bit
                beq BMBLOOP             ; (unless already

                sec                     ; at max speed)
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
                lda BMBDRP,X            ; if bomb not
                bne _chkHits            ; dropped

                jmp CheckDrop           ; check trig

_chkHits        ;lda P2PF,X              ; bomb hit anything?
                ;bne _chkRockOK
                bra _chkRockOK  ; HACK:

                jmp LowerBomb           ;   no, move bomb

_chkRockOK      and #7                  ; if hit only
                bne _chkHitRock         ; color 3, it

                jmp KILLBMB             ; gets erased

_chkHitRock     lda #0                  ; set pointer
                sta SCRPTR+1            ; into screen
                lda BMBDRP,X            ; ram where the
                sec                     ; rock hit is.
                sbc #103                ; 1st, get bomb's
                and #$F8                ; y-pos trans-
                sta SCRPTR              ; lated into
                asl SCRPTR              ; row number
                asl SCRPTR              ; and multiply it
                rol SCRPTR+1            ; by 40
                clc
                adc SCRPTR
                sta SCRPTR
                bcc _gtp0

                inc SCRPTR+1
_gtp0           lda PLYRX,X             ; then, change
                sec                     ; x-pos into the
                sbc #47                 ; column number
                lsr A
                lsr A
                clc                     ; and add it on
                adc SCRPTR
                sta SCRPTR
                bcc _gtpA

                inc SCRPTR+1
_gtpA           clc                     ; add screen
                adc #<CANYON            ; start
                sta SCRPTR              ; address
                lda SCRPTR+1
                adc #>CANYON
                sta SCRPTR+1
                ldy #0                  ; clear index
                lda (SCRPTR),Y          ; & get char
                beq _gtp1               ; if it's blank

                cmp #4                  ; or above 4
                bcc _gotChr             ; this isn't it.

_gtp1           iny                     ; try again,one
                lda (SCRPTR),Y          ; right
                beq _gtp2

                cmp #4
                bcc _gotChr

_gtp2           ldy #$28                ; if we still
                lda (SCRPTR),Y          ; don't get it
                beq _gtp3               ; try 1 down

                cmp #4
                bcc _gotChr

_gtp3           iny                     ; then, both at
                lda (SCRPTR),Y          ; once
                bne _gckrck

                jmp LowerBomb           ; if by this

_gckrck         cmp #4                  ; time, we dont
                bcc _gotChr             ; have it, then

                jmp LowerBomb           ; give up

_gotChr         asl A                   ; hold score=
                sta HOLDIT              ; char * 2
                lda #0                  ; erase rock on
                sta (SCRPTR),Y          ; screen
                lda ROCKS               ; lower # of
                sec                     ; rocks left
                sbc #1
                sta ROCKS
                bcs _got1

                dec ROCKS+1
_got1           lda #$FE                ; start explosion
                sta EXPLODE             ; sound

; add on to score

                ldy SCRNDX,X            ; get base index
                lda HOLDIT              ; to scores,and
                clc                     ; add to score
                adc SCORE1,Y
                sta SCORE1,Y
                lda #3                  ; set digit # for
                sta HOLDIT              ; rollover prot.
_next1          lda SCORE1,Y            ; done?
                beq CheckHiScore        ;   yes, check high

                cmp #26                 ; digit >10?
                bcc _scundx             ; no, go right

                sec                     ; sub 10 from
                sbc #10                 ; this digit
                sta SCORE1,Y
                dey                     ; point to next
                dec HOLDIT
                bmi CheckHiScore        ; rollover! leave

                lda SCORE1,Y            ; get digit
                bne _scbrk               ; if blank, set

                lda #$10                ; to zero
_scbrk          clc                     ; add 1
                adc #1
                sta SCORE1,Y            ; and save it
                bne _next1              ; check this digit

_scundx         iny                     ; go right one
                inc HOLDIT              ; digit
                bne _next1

                .endproc

                ;[fall-through]


;--------------------------------------
; check for high score
;--------------------------------------
CheckHiScore    .proc
                lda #<SCORE1
                sta SCRPTR              ; set pointer
                lda #>SCORE1            ; to score for
                sta SCRPTR+1            ; player 1

                txa                     ; if it isn't
                beq _chkScore           ; player 1, then

                lda #10                 ; add to get
                clc                     ; pointer for
                adc SCRPTR              ; player 2
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
                cpy #4                  ; if all done,
                bne _next1              ; then it's the

                beq CHKFRM              ; same, skip

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

                .endproc

                ;[fall-through]


;======================================
; check for getting extra bombs
;======================================
CHKFRM          .proc
                ldy SCRNDX,X            ; get score
                lda SCORE1-3,Y          ; in thousands
                cmp FREMEN,X            ; if not free
                bne _STRKHT             ; bomb yet,skip.

                inc BOMBS,X             ; else, up bombs
                lda BOMBS,X             ; by 1
                cmp #4                  ; if bombs>=4,
                bcs _UPDTFM             ; keep in reserve

                clc                     ; if bombs less
                adc SCRNDX,X            ; than 4, then
                tay                     ; set extra
                lda #$CD                ; on screen
                sta BOMB1-4,Y
_UPDTFM         inc FREMEN,X            ; set for next

_STRKHT         inc RCKHIT,X            ; if new # of
                lda RCKHIT,X            ; rocks hit =
                cmp RKILL               ; max,kill bomb
                bne LowerBomb           ; else, lower it

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
KILLBMB         .proc
                txa                     ; set pointer
                clc                     ; to bomb
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
                txa                     ; turn off sound
                asl A                   ; for this bomb
                tay
                lda #0
                ;sta AUDF1,Y
                ;sta AUDC1,Y
                sta BMBDRP,X            ; set flag off
                lda RCKHIT,X            ; if it didn't
                bne DoNextBomb          ; hit anything,

                jsr DecrementMissile    ; lower # bombs

                jmp DoNextBomb          ; & do next

                .endproc


;--------------------------------------
; lower the bombs
;--------------------------------------
LowerBomb       .proc
                txa
                clc
                adc #>PL2               ; set pointer to
                sta SCRPTR+1            ; bomb
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
                bcs KILBOMB             ; yes, kill it

                sta BMBDRP,X            ; else, set
                sta SCRPTR              ; the bomb

                ldy #5
_next2          lda CharsetCustom+96,Y
                sta (SCRPTR),Y
                dey
                bpl _next2

                txa                     ; set y to index
                asl A                   ; the sound regs
                tay
                lda HOLDIT              ; update sound
                clc                     ; of dropping
                adc DRPFREQ,X           ; bomb
                sta DRPFREQ,X
                ;sta AUDF1,Y
                lda #$A8
                sec
                sbc HOLDIT
                ;sta AUDC1,Y
                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
DoNextBomb      .proc
                dex                     ; reset index
                bmi CheckDrop._DOPLMV   ; if both not

                jmp BMBNLOP             ; done, do next

                .endproc


;--------------------------------------
; check & drop bombs
;--------------------------------------
CheckDrop       .proc
                lda BOMBS,X             ; if no bombs left
                beq DoNextBomb          ; then do next

                txa                     ; if not the
                clc                     ; computer,check
                sbc PLAYERS             ; trigger
                bne _CHKTRG             ; it's player!

                lda DIR                 ; going left?
                bmi _GOINGR             ;   no!

                lda PLYRX,X             ; get computer x
                cmp #$44                ; too far left?
                bcc DoNextBomb          ;   yes!
                bcs _TRYDRP             ;   no, try drop!

_GOINGR         lda PLYRX,X             ; get comp. x
                cmp #$B8                ; too far right?
                bcs DoNextBomb          ;   yes!

_TRYDRP         lda SID_RANDOM          ; computer drops
                and #15                 ; a bomb if
                beq _DROPIT             ; random says to
                bne DoNextBomb          ; else do next

_CHKTRG         lda JOYSTICK0,X         ; trig pushed?
                and #$10
                bne DoNextBomb          ;   no, do next

_DROPIT         lda PLYRY,X             ; drop: set
                clc                     ; bomb y to
                adc #8                  ; player y+8
                sta BMBDRP,X
                lda #0                  ; clear drop rate
                sta DRPRATE,X
                sta RCKHIT,X            ; and rocks hit
                inc BRUN,X              ; up bombs dropped
                lda #50                 ; set the sound
                sta DRPFREQ,X           ; flag
                bne DoNextBomb          ; and do next

_DOPLMV         ;sta HITCLR              ; clear collisions
                jsr MovePlayer          ; move players

                lda EXPLODE             ; explosion going?
                beq _CKRSTRT            ;   no,skip

                dec EXPLODE             ; update explosion
                dec EXPLODE             ; sound
                eor #$F0
                ;sta AUDF3
                lsr A
                lsr A
                lsr A
                lsr A
                eor #$8F
                ;sta AUDC3
_CKRSTRT        lda CONSOL              ; any console
                cmp #7                  ; buttons pushed?
                beq _CKNSCR             ; if yes, then

                jmp RESTART             ; re-start

_CKNSCR         lda ROCKS               ; # of rocks left
                bne _CHKPAUS            ; = zero?

                lda ROCKS+1             ; if yes, then
                bne _CHKPAUS            ; set up a

                jmp NewScreen           ; new screen

_CHKPAUS        lda KEYCHAR             ; spacebar pressed?
                cmp #33
                bne _CKDRRCK            ;   no, continue

                ;lda #0                  ; yes, pause game
                ;sta AUDC1               ; turn off main
                ;sta AUDC2               ; sounds
                ;sta AUDC3
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
                lda (SCRPTR),Y          ; nothing there
                beq _DONXRCK            ; then try next up

                tax                     ; else hold it
                ldy #$28                ; & look underneath
                lda (SCRPTR),Y
                bne _DONXRCK            ; not blank-do next

                txa                     ; blank, move rock
                sta (SCRPTR),Y          ; above down
                ldy #0
                tya
                sta (SCRPTR),Y
                lda SCRPTR              ; & go up one
                sec                     ; so whole column
                sbc #$28                ; won't fall at
                sta SCRPTR              ; once
                bcs _NOVER

                dec SCRPTR+1
_NOVER          dec YCOUNT              ; last row done?
                bmi _DONXCOL            ;   yes, do next col

_DONXRCK        lda SCRPTR              ; go up one
                sec                     ; row
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
                lda ONSCR               ; if not on
                bne _ADDCLOK            ; screen, set sound

                lda MASK                ; and players
                cmp #3                  ; balloon?
                beq _STBLSND            ; yes, do that

                ;lda #$96                ; set plane sound
                ;sta AUDF4
                lda #$24
                ;sta AUDC4
                bne _ADDCLOK            ; & goto clock add

_STBLSND        ;lda #0                  ; set wind sound
                ;sta AUDF4
                lda #2
                ;sta AUDC4
                ldx #1                  ; set balloon
_next1          lda PLYRY,X
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
                and MASK                ; mask<>0 then
                bne _DODELAY            ; don't move

                lda PLYRX               ; move the players
                clc                     ; first player 1
                adc DIR
                sta PLYRX
                sta SP00_X_POS
                sta SP02_X_POS
                lda DIR                 ; then player 2
                eor #$FE
                clc
                adc PLYRX+1
                sta PLYRX+1
                sta SP01_X_POS
                sta SP03_X_POS
                lda MASK                ; if on planes
                cmp #1                  ; then check if
                bne _DODELAY            ; time to animate

                lda CLOCK               ; props
                and #2
                beq _DODELAY            ; no, skip this

                lda DIR                 ; set temp dir
                sta TDIR                ; (will be killed)
                ldx #1
_next3          lda PLYRY,X             ; set pointer
                sta SCRPTR              ; to player
                txa
                clc
                adc #>PL0
                sta SCRPTR+1
                lda CLOCK               ; get image index
                and #4                  ; from clock
                asl A
                sta HOLDIT              ; and hold it
                lda TDIR                ; get direction
                and #$10                ; index from
                clc                     ; dir
                adc HOLDIT              ; & add 'em to get
                stx HOLDIT              ; index.
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

_DODELAY        ldx #15                 ; wait for a
_wait1          ldy DELYVAL             ; while to make
_wait2          dey                     ; game playable
                bne _wait2

                dex
                bne _wait1

                lda #1                  ; players are now
                sta ONSCR               ; on screen
                lda PLYRX               ; but check to
                cmp #44                 ; see if they
                beq _OFFSCR             ; aren't

                cmp #204
                bne _XIT                ; if on, return

_OFFSCR         lda #0                  ; else, turn off
                ;sta AUDC3               ; explosions and
                ;sta AUDC4               ; bkg sound
                sta EXPLODE
                sta ONSCR               ; set onscr false
                ldx #1
_next5          lda BMBDRP,X            ; if a bomb is
                beq _CKBRN              ; in the air, and

                lda RCKHIT,X            ; it hasn't hit
                bne _CKBRN              ; anything yet,

                jsr DecrementMissile    ; it's a miss

_CKBRN          lda BRUN,X              ; if no bombs
                bne _CKNBR              ; dropped this

                jsr DecrementMissile    ; pass, it's a miss

_CKNBR          dex
                bpl _next5

                jsr ClearPlayer         ; clear out players

                ldx PLAYERS             ; if the actual
                lda BOMBS               ; players have
                clc                     ; no more bombs,
                adc BOMBS,X             ; and we're on a
                adc PLAY                ; game, end it
                beq EndGame

                lda DIR                 ; reverse direction
                eor #$FE
                sta DIR
                ldx PLYRY               ; change player
                ldy PLYRY+1             ; lanes
                stx PLYRY+1
                sty PLYRY
                lda #3                  ; reset clock
                sta CLOCK
                lda ROCKS+1             ; if half of the
                bne _XIT                ; rocks are gone

                lda ROCKS               ; then switch
                cmp #149                ; to planes
                bcs _XIT                ; else return

                lda #1                  ; set move rate
                sta MASK                ; mask
                lda #4                  ; plane bombs get
                sta RKILL               ; max of 4 rocks
_XIT            rts
                .endproc


;--------------------------------------
; do delay so the players can see the
; final score
;--------------------------------------
EndGame         .proc
                pla                     ; get rid of
                pla                     ; return address

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

                ;sta AUDC1               ; turn off bomb fall sounds
                ;sta AUDC2
                rts
                .endproc


;--------------------------------------

                .include "data.asm"
