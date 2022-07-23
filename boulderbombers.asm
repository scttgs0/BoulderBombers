;***********************
;*                     *
;*  'BOULDER BOMBERS'  *
;*         by          *
;*     Mark Price      *
;*                     *
;***********************

                .include "equates_system_atari8.asm"
                .include "equates_zeropage.asm"
                .include "equates_game.asm"


            .enc "atari-screen"
                .cdef " Z",$00
                .cdef "az",$61
            .enc "atari-screen-inverse"
                .cdef " Z",$80
                .cdef "az",$E1
            .enc "none"


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

INIT            ldx #111                ; copy my chars
MYCHRS          lda MYCHARS,X
                sta CharsetCustom,X
                dex
                bpl MYCHRS
                lda #0                  ; disable vbi
                sta NMIEN
                lda #$34                ; set colors
                sta COLPF0
                lda #$28
                sta COLPF1
                lda #$84
                sta COLPF2
                lda #$C4
                sta COLPF3
                lda #0
                sta COLBAK
                ldx #3                  ; init players
STWIDTH         sta SIZEP0,X
                dex
                bpl STWIDTH
                lda #$28
                sta COLPM0
                lda #$84
                sta COLPM1
                lda #$C8
                sta COLPM2
                lda #$C8
                sta COLPM3
                lda #>PMAREA
                sta PMBASE
                lda #$3E
                sta DMACTL
                lda #3
                sta GRACTL
                ldy #112                ; init chr set
SETCH1          lda CharsetNorm,Y
                sta CharsetCustom,Y
                iny
                bne SETCH1
SETCH2          lda CharsetNorm+256,Y
                sta CharsetCustom+256,Y
                iny
                bne SETCH2
                lda #>CharsetCustom
                sta CHBASE

                lda #0                  ; init vars
                ldy #SCRPTR+1-CLOCK
ZEROVAR         sta CLOCK,Y
                dey
                bpl ZEROVAR
                ldy #$27                ; set screen disp
CLRTOP          sta CANYON,Y
                dey
                bpl CLRTOP
                jsr SETSCRN
                lda #0                  ; init sound
                sta AUDCTL
                lda #3
                sta SKCTL
                lda #56                 ; set player
                sta PLYRY               ;  lanes
                lda #72
                sta PLYRY+1

RESTART         lda #44                 ; set player
                sta PLYRX               ; start
                lda #204                ; positions
                sta PLYRX+1
                lda #0                  ; turn off screen
                sta DMACTL
                sta AUDC3               ; explosions,
                sta EXPLODE
                sta AUDC4               ; and bkg sound
                jsr PMCLR               ; clear players
                lda #<dlist1            ;set title
                sta DLIST               ; screen
                lda #>dlist1
                sta DLIST+1
                lda #$FF                ; set game speed
                sta DELYVAL             ; for titles
                lda #1                  ; set start dir
                sta DIR
                sta PLAY                ; set play false
                lda #0                  ; players not
                sta ONSCR               ; on screen
                lda #$3E                ; turn screen
                sta DMACTL              ; back on
                lda #3                  ; init clock
                sta CLOCK
GTCNSL          lda CONSOL              ; check consol
                and #3                  ; switches
                cmp #1                  ; select pressed?
                bne CHKSTRT             ; no, try start
SELECT          lda CONSOL              ; yes, wait for
                and #2                  ; key release
                beq SELECT
                lda PLAYERS             ; change # of
                eor #1                  ; players
                sta PLAYERS
                clc
                adc #$11                ; & set on screen
                sta SCNOPLR
                bne MOVET               ; (move players)
CHKSTRT         cmp #2                  ; if start then
                beq START               ; start game
MOVET           lda ONSCR               ; if on screen,
                bne MOVIT               ; then move
                lda RANDOM              ; else, pick out
                and #1                  ; new ship type
                tax
                lda MASKS,X
                sta MASK                ; & set it
MOVIT           jsr MOVEPLR             ; move players
                jmp GTCNSL              ; do check again

START           lda CONSOL              ; wait for key
                and #1                  ; release
                beq START
                lda #3                  ; set game speed
                sta DELYVAL             ; to $ff+$04
                lda #0                  ; set play true
                sta PLAY
                sta DMACTL              ; turn off screen
                ldx #2                  ; set scores to
ZEROSCR         sta SCORE1,X            ; zero
                sta SCORE2,X
                dex
                bpl ZEROSCR
                lda #$10
                sta SCORE1+3
                sta SCORE2+3
                ldx #2                  ; set bombs left
                lda #$CD                ; to three
STBMBC          sta BOMB1,X
                sta BOMB2,X
                dex
                bpl STBMBC
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
STP2MS          lda P2COMPT,Y
                sta P2MSG,X
                iny
                dex
                bpl STP2MS
                lda #<DLIST2            ; set dlist
                sta DLIST               ; to game
                lda #>DLIST2            ; screen
                sta DLIST+1
                lda #$3E                ; turn on screen
                sta DMACTL

NEWSCRN         jsr SETSCRN             ; set canyon
                lda #3                  ; set type to
                sta MASK                ; balloon
                sta CLOCK               ; and begin clock
                lda #1
                sta DIR                 ; dir = right
                sta ROCKS+1             ; rocks in
                lda #42                 ; canyon=298
                sta ROCKS
                jsr PMCLR               ; clear players
                lda #0                  ; set players on
                sta ONSCR               ; screen=false
                sta AUDF4
                lda #44                 ; set start
                sta PLYRX               ; positions
                lda #204                ; of players
                sta PLYRX+1
                sta HITCLR              ; clear hits
                lda #8                  ; #rocks per bomb
                sta RKILL               ; (max) =8
                lda DELYVAL             ; speed up the
                cmp #$AF                ; game just a bit
                beq BMBLOOP             ; (unless already
                sec                     ; at max speed)
                sbc #4
                sta DELYVAL

;
; bomb movement, hit checks,
; score and highscore set
;

BMBLOOP         ldx #1                  ; get player index
BMBNLOP         lda BMBDRP,X            ; if bomb not
                bne CHKHITS             ; dropped
                jmp CHKDRP              ; check trig
CHKHITS         lda PL2PF,X             ; bomb hit
                bne CKHROK              ; anything?
                jmp LWRBMB              ; no,move bomb
CKHROK          and #7                  ; if hit only
                bne BHITRK              ; color 3, it
                jmp KILLBMB             ; gets erased
BHITRK          lda #0                  ; set pointer
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
                bcc GTP0
                inc SCRPTR+1
GTP0            lda PLYRX,X             ; then, change
                sec                     ; x-pos into the
                sbc #47                 ; column number
                lsr A
                lsr A
                clc                     ; and add it on
                adc SCRPTR
                sta SCRPTR
                bcc GTPA
                inc SCRPTR+1
GTPA            clc                     ; add screen
                adc #<CANYON            ; start
                sta SCRPTR              ; address
                lda SCRPTR+1
                adc #>CANYON
                sta SCRPTR+1
                ldy #0                  ; clear index
                lda (SCRPTR),Y          ; & get char
                beq GTP1                ; if it's blank
                cmp #4                  ; or above 4
                bcc GOTCHR              ; this isn't it.
GTP1            iny                     ; try again,one
                lda (SCRPTR),Y          ; right
                beq GTP2
                cmp #4
                bcc GOTCHR
GTP2            ldy #$28                ; if we still
                lda (SCRPTR),Y          ; don't get it
                beq GTP3                ; try 1 down
                cmp #4
                bcc GOTCHR
GTP3            iny                     ; then, both at
                lda (SCRPTR),Y          ; once
                bne GCKRCK
                jmp LWRBMB              ; if by this
GCKRCK          cmp #4                  ; time, we dont
                bcc GOTCHR              ; have it, then
                jmp LWRBMB              ; give up
GOTCHR          asl A                   ; hold score=
                sta HOLDIT              ; char * 2
                lda #0                  ; erase rock on
                sta (SCRPTR),Y          ; screen
                lda ROCKS               ; lower # of
                sec                     ; rocks left
                sbc #1
                sta ROCKS
                bcs GOT1
                dec ROCKS+1
GOT1            lda #$FE                ; start explosion
                sta EXPLODE             ; sound

;
; add on to score
;

                ldy SCRNDX,X            ; get base index
                lda HOLDIT              ; to scores,and
                clc                     ; add to score
                adc SCORE1,Y
                sta SCORE1,Y
                lda #3                  ; set digit # for
                sta HOLDIT              ; rollover prot.
ADDSCR          lda SCORE1,Y            ; done?
                beq CHKHI               ; yes, check high
                cmp #26                 ; digit >10?
                bcc SCUNDX              ; no, go right
                sec                     ; sub 10 from
                sbc #10                 ; this digit
                sta SCORE1,Y
                dey                     ; point to next
                dec HOLDIT
                bmi CHKHI               ; rollover! leave
                lda SCORE1,Y            ; get digit
                bne SCBRK               ; if blank, set
                lda #$10                ; to zero
SCBRK           clc                     ; add 1
                adc #1
                sta SCORE1,Y            ; and save it
                bne ADDSCR              ; check this digit
SCUNDX          iny                     ; go right one
                inc HOLDIT              ; digit
                bne ADDSCR

;
; check for high score
;

CHKHI           lda #<SCORE1
                sta SCRPTR              ; set pointer
                lda #>SCORE1            ; to score for
                sta SCRPTR+1            ; player 1
                txa                     ; if it isn't
                beq CHKSCR              ; player 1, then
                lda #10                 ; add to get
                clc                     ; pointer for
                adc SCRPTR              ; player 2
                sta SCRPTR
                bcc CHKSCR
                inc SCRPTR+1
CHKSCR          ldy #0                  ; begin at hi end
CHECKSC         lda (SCRPTR),Y
                cmp HISCOR,Y            ; compare 'em
                beq CKNXDG              ; if same,do next
                bcs STHISC              ; if player > set
                bcc CHKFRM              ; if high > skip
CKNXDG          iny                     ; do next digit
                cpy #4                  ; if all done,
                bne CHECKSC             ; then it's the
                beq CHKFRM              ; same, skip

;
; set high score
;

STHISC          ldy #3                  ; copy the
SETDIGT         lda (SCRPTR),Y          ; new high
                sta HISCOR,Y            ; score into
                dey                     ; hiscor
                bpl SETDIGT

;
; check for getting extra bombs
;

CHKFRM          ldy SCRNDX,X            ; get score
                lda SCORE1-3,Y          ; in thousands
                cmp FREMEN,X            ; if not free
                bne STRKHT              ; bomb yet,skip.
                inc BOMBS,X             ; else, up bombs
                lda BOMBS,X             ; by 1
                cmp #4                  ; if bombs>=4,
                bcs UPDTFM              ; keep in reserve
                clc                     ; if bombs less
                adc SCRNDX,X            ; than 4, then
                tay                     ; set extra
                lda #$CD                ; on screen
                sta BOMB1-4,Y
UPDTFM          inc FREMEN,X            ; set for next
;
STRKHT          inc RCKHIT,X            ; if new # of
                lda RCKHIT,X            ; rocks hit =
                cmp RKILL               ; max,kill bomb
                bne LWRBMB              ; else, lower it
KILLBMB         txa                     ; set pointer
                clc                     ; to bomb
                adc #>PL2
                sta SCRPTR+1
                lda BMBDRP,X
                sta SCRPTR
                ldy #5                  ; and erase it
                lda #0
ERABOMB         sta (SCRPTR),Y
                dey
                bpl ERABOMB
KILBOMB         txa                     ; turn off sound
                asl A                   ; for this bomb
                tay
                lda #0
                sta AUDF1,Y
                sta AUDC1,Y
                sta BMBDRP,X            ; set flag off
                lda RCKHIT,X            ; if it didn't
                bne DONXBMB             ; hit anything,
                jsr LWRMISS             ; lower # bombs
                jmp DONXBMB             ; & do next

;
; lower the bombs
;

LWRBMB          txa
                clc
                adc #>PL2               ; set pointer to
                sta SCRPTR+1            ; bomb
                lda BMBDRP,X
                sta SCRPTR
                lda #0                  ; erase the bomb
                ldy #5
ERBMB           sta (SCRPTR),Y
                dey
                bpl ERBMB
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
SETBOMB         lda CharsetCustom+96,Y
                sta (SCRPTR),Y
                dey
                bpl SETBOMB
                txa                     ; set y to index
                asl A                   ; the sound regs
                tay
                lda HOLDIT              ; update sound
                clc                     ; of dropping
                adc DRPFREQ,X           ; bomb
                sta DRPFREQ,X
                sta AUDF1,Y
                lda #$A8
                sec
                sbc HOLDIT
                sta AUDC1,Y
DONXBMB         dex                     ; reset index
                bmi DOPLMV              ; if both not
                jmp BMBNLOP             ; done, do next

;
; check & drop bombs
;

CHKDRP          lda BOMBS,X             ; if no bombs left
                beq DONXBMB             ; then do next
                txa                     ; if not the
                clc                     ; computer,check
                sbc PLAYERS             ; trigger
                bne CHKTRG              ; it's player!
                lda DIR                 ; going left?
                bmi GOINGR              ; no!
                lda PLYRX,X             ; get computer x
                cmp #$44                ; too far left?
                bcc DONXBMB             ; yes!
                bcs TRYDRP              ; no, try drop!
GOINGR          lda PLYRX,X             ; get comp. x
                cmp #$B8                ; too far right?
                bcs DONXBMB             ; yes!
TRYDRP          lda RANDOM              ; computer drops
                and #15                 ; a bomb if
                beq DROPIT              ; random says to
                bne DONXBMB             ; else do next
CHKTRG          lda TRIG0,X             ; trig pushed?
                bne DONXBMB             ; no, do next
DROPIT          lda PLYRY,X             ; drop: set
                clc                     ; bomb y to
                adc #8                  ; player y+8
                sta BMBDRP,X
                lda #0                  ; clear drop rate
                sta DRPRATE,X
                sta RCKHIT,X            ; and rocks hit
                inc BRUN,X              ; up bombs dropped
                lda #50                 ; set the sound
                sta DRPFREQ,X           ; flag
                bne DONXBMB             ; and do next

DOPLMV          sta HITCLR              ; clear hits
                jsr MOVEPLR             ; move players
                lda EXPLODE             ; explosion going?
                beq CKRSTRT             ; no,skip
                dec EXPLODE             ; update explosion
                dec EXPLODE             ; sound
                eor #$F0
                sta AUDF3
                lsr A
                lsr A
                lsr A
                lsr A
                eor #$8F
                sta AUDC3
CKRSTRT         lda CONSOL              ; any console
                cmp #7                  ; buttons pushed?
                beq CKNSCR              ; if yes, then
                jmp RESTART             ; re-start
CKNSCR          lda ROCKS               ; # of rocks left
                bne CHKPAUS             ; = zero?
                lda ROCKS+1             ; if yes, then
                bne CHKPAUS             ; set up a
                jmp NEWSCRN             ; new screen
CHKPAUS         lda CH                  ; spacebar pressed?
                cmp #33
                bne CKDRRCK             ; no, continue
                lda #0                  ; yes, pause game
                sta AUDC1               ; turn off main
                sta AUDC2               ; sounds
                sta AUDC3
HLDPTRN         lda PORTA               ; wait for stick
                cmp #$FF                ; movement
                beq HLDPTRN
                lda #$FF                ; reset ch for
                sta CH                  ; another pause
                sta CH1
CKDRRCK         lda CLOCK               ; time to drop
                and #15                 ; suspended
                beq DRPROCK             ; rocks?
                jmp BMBLOOP             ; no, do bombs
DRPROCK         lda #39                 ; set column to 39
                sta XCOUNT
DSTYCNT         lda #8                  ; row to 8
                sta YCOUNT              ; and set pointer
                lda #<CANYON+360        ; to xcount
                clc                     ; plus canyon
                adc XCOUNT              ; start
                sta SCRPTR
                lda #>CANYON+360
                adc #0
                sta SCRPTR+1
RK2DRP          ldy #0                  ; rock fall loop:
                lda (SCRPTR),Y          ; nothing there
                beq DONXRCK             ; then try next up
                tax                     ; else hold it
                ldy #$28                ; & look underneath
                lda (SCRPTR),Y
                bne DONXRCK             ; not blank-do next
                txa                     ; blank, move rock
                sta (SCRPTR),Y          ; above down
                ldy #0
                tya
                sta (SCRPTR),Y
                lda SCRPTR              ; & go up one
                sec                     ; so whole column
                sbc #$28                ; won't fall at
                sta SCRPTR              ; once
                bcs NOVER
                dec SCRPTR+1
NOVER           dec YCOUNT              ; last row done?
                bmi DONXCOL             ; yes, do next col
DONXRCK         lda SCRPTR              ; go up one
                sec                     ; row
                sbc #$28
                sta SCRPTR
                bcs NOVER2
                dec SCRPTR+1
NOVER2          dec YCOUNT              ; last row done?
                bpl RK2DRP              ; yes, do next col
DONXCOL         dec XCOUNT              ; last col done?
                bpl DSTYCNT             ; no, do next
                jmp BMBLOOP             ; do bombs again

;
; move player,check for leaving
; screen, end game check, switch
; ship types
;

MOVEPLR         lda ONSCR               ; if not on
                bne ADDCLOK             ; screen, set sound
                lda MASK                ; and players
                cmp #3                  ; balloon?
                beq STBLSND             ; yes, do that
                lda #$96                ; set plane sound
                sta AUDF4
                lda #$24
                sta AUDC4
                bne ADDCLOK             ; & goto clock add
STBLSND         lda #0                  ; set wind sound
                sta AUDF4
                lda #2
                sta AUDC4
                ldx #1                  ; set balloon
STBLNS          lda PLYRY,X
                sta SCRPTR
                txa
                clc
                adc #>PL0
                sta SCRPTR+1
                ldy #15
SETBALN         lda CharsetCustom+80,Y
                sta (SCRPTR),Y
                dey
                bpl SETBALN
                dex
                bpl STBLNS
ADDCLOK         inc CLOCK               ; add to clock
                lda CLOCK               ; if clock and
                and MASK                ; mask<>0 then
                bne DODELAY             ; don't move
                lda PLYRX               ; move the players
                clc                     ; first player 1
                adc DIR
                sta PLYRX
                sta HPOSP0
                sta HPOSP2
                lda DIR                 ; then player 2
                eor #$FE
                clc
                adc PLYRX+1
                sta PLYRX+1
                sta HPOSP1
                sta HPOSP3
                lda MASK                ; if on planes
                cmp #1                  ; then check if
                bne DODELAY             ; time to animate
                lda CLOCK               ; props
                and #2
                beq DODELAY             ; no, skip this
                lda DIR                 ; set temp dir
                sta TDIR                ; (will be killed)
                ldx #1
ANILOOP         lda PLYRY,X             ; set pointer
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
ANISET          lda CharsetCustom+48,X
                sta (SCRPTR),Y
                inx
                iny
                cpy #8
                bne ANISET
                lda TDIR                ; reverse tdir
                eor #$FE
                sta TDIR
                ldx HOLDIT              ; get player #
                dex                     ; & animate next
                bpl ANILOOP
DODELAY         ldx #15                 ; wait for a
DELAY1          ldy DELYVAL             ; while to make
DELAY2          dey                     ; game playable
                bne DELAY2
                dex
                bne DELAY1
                lda #1                  ; players are now
                sta ONSCR               ; on screen
                lda PLYRX               ; but check to
                cmp #44                 ; see if they
                beq OFFSCR              ; aren't
                cmp #204
                bne MPGOBAK             ; if on, return
OFFSCR          lda #0                  ; else, turn off
                sta AUDC3               ; explosions and
                sta AUDC4               ; bkg sound
                sta EXPLODE
                sta ONSCR               ; set onscr false
                ldx #1
CHKBR           lda BMBDRP,X            ; if a bomb is
                beq CKBRN               ; in the air, and
                lda RCKHIT,X            ; it hasn't hit
                bne CKBRN               ; anything yet,
                jsr LWRMISS             ; it's a miss
CKBRN           lda BRUN,X              ; if no bombs
                bne CKNBR               ; dropped this
                jsr LWRMISS             ; pass,it's a miss
CKNBR           dex
                bpl CHKBR
                jsr PMCLR               ; clear out players
                ldx PLAYERS             ; if the actual
                lda BOMBS               ; players have
                clc                     ; no more bombs,
                adc BOMBS,X             ; and we're on a
                adc PLAY                ; game, end it
                beq ENDGAME
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
                bne MPGOBAK             ; rocks are gone
                lda ROCKS               ; then switch
                cmp #149                ; to planes
                bcs MPGOBAK             ; else return
                lda #1                  ; set move rate
                sta MASK                ; mask
                lda #4                  ; plane bombs get
                sta RKILL               ; max of 4 rocks
MPGOBAK         rts                     ; return
;
ENDGAME         pla                     ; get rid of
                pla                     ; return address
                lda #8                  ; do delay so
                sta HOLDIT              ; the players
WAIT0           ldx #$FF                ; can see the
WAIT1           ldy #$FF                ; final score
WAIT2           lda CONSOL              ; (end delay
                cmp #7                  ; early with
                bne ENDGOBK             ; consol key)
                dey
                bne WAIT2
                dex
                bne WAIT1
                dec HOLDIT
                bpl WAIT0
ENDGOBK         jmp RESTART             ; go title screen

;
; set canyon screen image
;

SETSCRN         ldy #0                  ; copy rocks &
SETSC1          lda ROCKIMG,Y           ; canyon to
                sta CANYON+40,Y         ; screen
                iny
                bne SETSC1
                ldy #145
SETSC2          lda ROCKIMG+255,Y
                sta CANYON+295,Y
                dey
                bne SETSC2
                rts                     ; return

;
; lower number of bombs left
;

LWRMISS         lda BOMBS,X             ; if already
                beq LWMGOBK             ; zero, exit
                dec BOMBS,X             ; lower bombs left
                lda BOMBS,X             ; if at least 3
                cmp #3                  ; left, return
                bcs LWMGOBK
                clc                     ; get index for
                adc SCRNDX,X            ; screen to
                tay                     ; erase bomb
                lda #0
                sta BOMB1-3,Y
LWMGOBK         rts                     ; return

;
; clear players,bomb y positions,
; bombs dropped this pass, and
; turn off bomb sounds
;

PMCLR           lda #0
                tay
PMCLOOP         sta PL0,Y               ; clear all
                sta PL1,Y               ; players
                sta PL2,Y
                sta PL3,Y
                dey
                bne PMCLOOP
                sta BMBDRP              ; clear bomb y
                sta BMBDRP+1            ; position
                sta BRUN                ; & bombs dropped
                sta BRUN+1              ; this pass
                sta AUDC1               ; turn off bomb
                sta AUDC2               ; fall sounds
                rts

;
; player 2/computer messages
;

            .enc "atari-screen-inverse"
P2COMPT         .text "RETUPMOC2 REYALP"
            .enc "none"

;
; misc data
;
SCRNDX          .byte 3,13
MASKS           .byte 1,3

;
; title screen display list
;

DLIST1          .byte AEMPTY8,AEMPTY8,AEMPTY8

                .byte $06+ALMS
                    .addr GAME

                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8

                .byte $04+ALMS
                    .addr CANYON+40
                .byte $04,$04,$04
                .byte $04,$04,$04
                .byte $04,$04,$04

                .byte $07+ALMS
                    .addr TITLE

                .byte $06,$06

                .byte AVB+AJMP
                    .addr DLIST1

;
; game display list
;

DLIST2          .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8,AEMPTY8,AEMPTY8
                .byte AEMPTY8

                .byte $04+ALMS
                    .word CANYON+40
                .byte $04,$04,$04
                .byte $04,$04,$04
                .byte $04,$04,$04

                .byte $06+ALMS
                    .addr GAME

                .byte AEMPTY8

                .byte $06,$06

                .byte AVB+AJMP
                    .addr DLIST2

;
; titles
;

TITLE
            .enc "atari-screen-inverse"
                .text "  boulder "
                .text " bombers  "
            .enc "atari-screen"
                .text "   by  mark price   "
                .text "     PLAYERS: "
            .enc "none"

SCNOPLR         .byte $11,0,0,0,0,0

;
; bottom of game screen
;

            .enc "atari-screen"
GAME            .text "     HIGH: "
HISCOR          .text "   0      PLAYER 1   "
            .enc "none"

P2MSG           .byte 0,0,0,0,0,0,0,0,0,0
SCORE1          .byte 0,0,0,0,0
BOMB1           .byte 0,0,0,0,0
SCORE2          .byte 0,0,0,0,0
BOMB2           .byte 0,0,0,0

;
; data for canyon
;

ROCKIMG         .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte $85,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,$85
                .byte $84,$85,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1,$84,$85
                .byte $84,$85,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,$84,$85
                .byte $84,$84,$85,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,$84,$84,$85
                .byte $84,$84,$85,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,$84,$84,$85
                .byte $84,$84,$84,$85,3
                .byte 3,3,3,3,3,3,3
                .byte $85,3,3,3,3,3,3,3,3,3,3,3
                .byte 3,3,3,$85,3,3,3,3,3,3,3,3
                .byte $84,$84,$84,$85,$84,$84
                .byte $84,$85,3,3,3,3
                .byte 3,3,3,$84,$84,$85
                .byte 3,$85,3,3,3,3
                .byte 3,3,3,3,$85,3
                .byte $84,$84,$85,3,3,3
                .byte 3,3,3,3,$84,$84
                .byte $84,$85,$84,$84,$84,$84
                .byte $85,3,3,3,3,3
                .byte $84,$84,$84,$84,$84,$84
                .byte $85,3,3,3,3,3
                .byte 3,$84,$84,$84,$84,$84
                .byte $84,$85,3,3,3,3
                .byte 3,$84,$84,$84,$84,$85
                .byte $84,$84,$84,$84,$84,$85
                .byte 3,3,3,$84,$84,$84
                .byte $84,$84,$84,$84,$84,$85
                .byte 3,3,3,3,$84,$84
                .byte $84,$84,$84,$84,$84,$84
                .byte $85,3,3,3,$84,$84
                .byte $84,$84,$84,$85

;
; character set data
;

MYCHARS         ;.byte $00,$00,$00,$00,$00,$00,$00,$00
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                ;.byte $54,$54,$54,$54,$54,$54,$54,$00
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %01010100         ; AAA.
                .byte %00000000         ; ....
                ;.byte $A8,$A8,$A8,$A8,$A8,$A8,$A8,$00
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %10101000         ; BBB.
                .byte %00000000         ; ....
                ;.byte $FC,$FC,$FC,$FC,$FC,$FC,$FC,$00
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %00000000         ; ....
                ;.byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                ;.byte $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                .byte %11111100         ; CCC.
                ;.byte $00,$00,$01,$03,$3F,$D3,$FE,$80
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000001         ; ...A
                .byte %00000011         ; ...C
                .byte %00111111         ; .CCC
                .byte %11010011         ; CA.C
                .byte %11111110         ; CCCB
                .byte %10000000         ; B...
                ;.byte $00,$00,$01,$83,$BF,$D3,$7E,$00
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000001         ; ...A
                .byte %10000011         ; B..C
                .byte %10111111         ; BCCC
                .byte %11010011         ; CA.C
                .byte %01111110         ; ACCB
                .byte %00000000         ; ....
                ;.byte $00,$00,$80,$C0,$FC,$CB,$7F,$01
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %10000000         ; B...
                .byte %11000000         ; C...
                .byte %11111100         ; CCC.
                .byte %11001011         ; C.BC
                .byte %01111111         ; ACCC
                .byte %00000001         ; ...A
                ;.byte $00,$00,$80,$C1,$FD,$CB,$7E,$00
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %10000000         ; B...
                .byte %11000001         ; C..A
                .byte %11111101         ; CCCA
                .byte %11001011         ; C.BC
                .byte %01111110         ; ACCB
                .byte %00000000         ; ....
                ;.byte $3C,$7E,$FF,$00,$FF,$FF,$7E,$3C
                .byte %00111100         ; .CC.
                .byte %01111110         ; ACCB
                .byte %11111111         ; CCCC
                .byte %00000000         ; ....
                .byte %11111111         ; CCCC
                .byte %11111111         ; CCCC
                .byte %01111110         ; ACCB
                .byte %00111100         ; .CC.
                ;.byte $18,$24,$24,$18,$18,$00,$00,$00
                .byte %00011000         ; .AB.
                .byte %00100100         ; .BA.
                .byte %00100100         ; .BA.
                .byte %00011000         ; .AB.
                .byte %00011000         ; .AB.
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                ;.byte $A0,$40,$E0,$E0,$E0,$40,$00,$00
                .byte %10100000         ; BB..
                .byte %01000000         ; A...
                .byte %11100000         ; CB..
                .byte %11100000         ; CB..
                .byte %11100000         ; CB..
                .byte %01000000         ; A...
                .byte %00000000         ; ....
                .byte %00000000         ; ....
                ;.byte $6C,$7C,$38,$7C,$7C,$7C,$38,$10
                .byte %01101100         ; ABC.
                .byte %01111100         ; ACC.
                .byte %00111000         ; .CB.
                .byte %01111100         ; ACC.
                .byte %01111100         ; ACC.
                .byte %01111100         ; ACC.
                .byte %00111000         ; .CB.
                .byte %00010000         ; .A..

                .fill 4,$00
                .fill $18C

;
; on-screen canyon
;

CANYON

;--------------------------------------
;--------------------------------------
                *=  $02E0
;--------------------------------------

                .addr INIT              ; run address
