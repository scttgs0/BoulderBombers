
; SPDX-FileName: facade.asm
; SPDX-FileCopyrightText: Copyright 2023, Scott Giese
; SPDX-License-Identifier: GPL-3.0-or-later


;======================================
; Clear the bottom of the screen
;--------------------------------------
; preserve      A, Y
;======================================
ClearGamePanel  .proc
v_EmptyText     .var $00
v_TextColor     .var $40
v_RenderLine    .var 24*CharResX
;---

                pha
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   text color
                lda #<CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest+1
                stz zpDest+2

                lda #v_TextColor
                ldy #$00
_next1          sta (zpDest),Y

                iny
                cpy #$F0                ; 6 lines
                bne _next1

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                lda #<CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest+1
                stz zpDest+2

                lda #v_EmptyText
                ldy #$00
_next2          sta (zpDest),Y

                iny
                cpy #$F0                ; 6 lines
                bne _next2

;   switch to system map
                stz IOPAGE_CTRL

                ply
                pla
                rts
                .endproc


;======================================
; Render High Score
;--------------------------------------
; preserve      A, X, Y
;======================================
RenderHiScore   .proc
v_RenderLine    .var 2*CharResX
;---

                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda HighScoreColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda HighScoreMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Render High Score
;--------------------------------------
; preserve      A, X, Y
;======================================
RenderHiScore2  .proc
v_RenderLine    .var 24*CharResX
;---

                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda HighScoreColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda HighScoreMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Render Title
;--------------------------------------
; preserve      A, X, Y
;======================================
RenderTitle     .proc
v_RenderLine    .var 24*CharResX
;---

                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for two 40-char lines
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$50
                beq _processText

                lda TitleMsgColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X

                bra _nextColor

;   process the text
_processText
;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$50
                beq _XIT

                lda TitleMsg,Y
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Render Author
;--------------------------------------
; preserve      A, X, Y
;======================================
RenderAuthor    .proc
v_RenderLine    .var 26*CharResX
;---

                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda AuthorColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda AuthorMsg,Y
                beq _space
                cmp #$20
                beq _space

                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Render SELECT (Qty of Players)
;--------------------------------------
; preserve      A, X, Y
;======================================
RenderSelect    .proc
v_RenderLine    .var 27*CharResX
;---

                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda PlyrQtyColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda PlyrQtyMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT            stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Render Title
;--------------------------------------
; preserve      A, X, Y
;======================================
RenderPlayers   .proc
v_RenderLine    .var 26*CharResX
;---

                pha
                phx
                phy

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda PlayersMsgColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda PlayersMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Render Player Scores & Bombs
;--------------------------------------
; preserve      A, X, Y
;======================================
RenderScore     .proc
v_RenderLine    .var 27*CharResX
;---

                pha
                phx
                phy

;   if game is not in progress then exit
                lda zpWaitForPlay
                bne _XIT

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda ScoreMsgColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda ScoreMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$9B
                beq _bomb

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_bomb           sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Render Canyon
;--------------------------------------
; codes $01-$03 are boulders (destructible)
; codes $84-$85 are canyon (not destructible)
;--------------------------------------
; preserve      A, Y
;======================================
RenderCanyon    .proc
v_RenderLine    .var 13*CharResX    ; skip 13 lines
v_QtyLines      = zpTemp1
;---

                pha
                phy

                lda #11             ; 11 lines
                sta v_QtyLines

                lda #<CANYON
                sta zpSource
                lda #>CANYON
                sta zpSource+1

;   pointer to text-color memory
                lda #<CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest+1

;   pointer to text-character memory
                lda #<CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest+2
                lda #>CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest+3

                ldy #40             ; 40 characters per line
_nextChar       dey
                bpl _1

                dec v_QtyLines
                beq _XIT

                ldy #40             ; reset index

                lda zpSource
                clc
                adc #40
                sta zpSource
                lda zpSource+1
                adc #0
                sta zpSource+1

                lda zpDest
                clc
                adc #40
                sta zpDest
                lda zpDest+1
                adc #0
                sta zpDest+1

                lda zpDest+2
                clc
                adc #40
                sta zpDest+2
                lda zpDest+3
                adc #0
                sta zpDest+3

_1              lda (zpSource),Y
                beq _space          ; 0 or ' ' are processed as a space
                cmp #$20
                beq _space

                cmp #$84            ; is code < $84?
                bcc _boulder

_earth          eor #$80            ; clear the high-bit (to convert the data into the ascii code)
                pha

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

                lda #$E0
                sta (zpDest),Y

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                pla
                sta (zpDest+2),Y

                bra _nextChar

_space          pha

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

                lda #$00
                sta (zpDest),Y

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                pla
                sta (zpDest+2),Y

                bra _nextChar

_boulder        pha

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

                pla
                phy
                tay
                lda CanyonColors,Y
                ply
                sta (zpDest),Y

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                lda #$01
                sta (zpDest+2),Y

                bra _nextChar

_XIT
;   switch to system map
                stz IOPAGE_CTRL

                ply
                pla
                rts
                .endproc
