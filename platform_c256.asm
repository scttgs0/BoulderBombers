
VRAM            = $B00000               ; First byte of video RAM

SPRITES         = VRAM
BITMAP          = $B30000
BITMAPTXT0      = $B6F200
BITMAPTXT1      = $B71A00
BITMAPTXT2      = $B74C00
BITMAPTXT3      = $B31400


;======================================
; seed = elapsed seconds this hour
;======================================
Random_Seed     .proc
                .m8
                lda RTC_MIN
                sta RND_MIN
                lda RTC_SEC
                sta RND_SEC

                .m16
;   elapsed minutes * 60
                lda RND_MIN
                asl A
                asl A
                pha
                asl A
                pha
                asl A
                pha
                asl A
                sta RND_RESULT      ; *32
                pla
                clc
                adc RND_RESULT      ; *16
                sta RND_RESULT
                pla
                clc
                adc RND_RESULT      ; *8
                sta RND_RESULT
                pla
                clc
                adc RND_RESULT      ; *4
                sta RND_RESULT

;   + elapsed seconds
                lda RND_SEC
                adc RND_RESULT

                sta GABE_RNG_SEED_LO

                .m8
                lda #grcEnable|grcDV
                sta GABE_RNG_CTRL
                lda #grcEnable
                sta GABE_RNG_CTRL
                .endproc


;======================================
; Initialize SID
;======================================
InitSID         .proc
                pha
                phx
                .m8i8

;   reset the SID
                lda #$00
                ldx #$18
_next1          sta $AF_E400,X
                dex
                bpl _next1

                lda #$09                ; Attack/Decay = 9
                sta SID_ATDCY1
                sta SID_ATDCY2
                sta SID_ATDCY3

                lda #$00                ; Susatain/Release = 0
                sta SID_SUREL1
                sta SID_SUREL2
                sta SID_SUREL3

                ;lda #$21
                ;sta SID_CTRL1
                ;sta SID_CTRL2
                ;sta SID_CTRL3

                lda #$0F                ; Volume = 15 (max)
                sta SID_SIGVOL

                plx
                pla
                rts
                .endproc


;======================================
; Create the lookup table (LUT)
;======================================
InitLUT         .proc
                php
                phb

                .m16i16
                lda #Palette_end-Palette        ; Copy the palette to LUT0
                ldx #<>Palette
                ldy #<>GRPH_LUT0_PTR
                mvn `Palette,`GRPH_LUT0_PTR

                lda #Palette_end-Palette-64     ; ... LUT1
                ldx #<>Palette+64
                ldy #<>GRPH_LUT1_PTR
                mvn `Palette,`GRPH_LUT1_PTR

                .m8i8
                plb
                plp
                rts
                .endproc


;======================================
; Initialize the CHAR_LUT tables
;======================================
InitCharLUT     .proc
v_LUTSize       .var 64                 ; 4-byte color * 16 colors
;---

                pha
                phx
                .m8i8

                ldx #$00
_next1          lda Custom_LUT,x
                sta FG_CHAR_LUT_PTR,x
                sta BG_CHAR_LUT_PTR,x

                inx
                cpx #v_LUTSize
                bne _next1

                plx
                pla
                rts

;--------------------------------------

Custom_LUT      .dword $00282828        ; 0: Dark Jungle Green  [Editor Text bg]
                .dword $00DDDDDD        ; 1: Gainsboro          [Editor Text fg]
                .dword $00143382        ; 2: Saint Patrick Blue [Editor Info bg][Dialog bg]
                .dword $006B89D7        ; 3: Blue Gray          [Editor Info fg][Dialog fg]
                .dword $00693972        ; 4: Indigo             [Monitor Info bg]
                .dword $00B561C2        ; 5: Deep Fuchsia       [Monitor Info fg][Window Split]
                .dword $00352BB0        ; 6: Blue Pigment       [Reserved Word]
                .dword $007A7990        ; 7: Fern Green         [Comment]
                .dword $0074D169        ; 8: Moss Green         [Constant]
                .dword $00E6E600        ; 9: Peridot            [String]
                .dword $00C563BD        ; A: Pastel Violet      [Loop Control]
                .dword $005B8B46        ; B: Han Blue           [ProcFunc Name]
                .dword $00BC605E        ; C: Medium Carmine     [Define]
                .dword $00C9A765        ; D: Satin Sheen Gold   [Type]
                .dword $0004750E        ; E: Hookers Green      [Highlight]
                .dword $00BC605E        ; F: Medium Carmine     [Warning]

                .endproc


;======================================
; Initialize the Sprite layer
;--------------------------------------
; sprites dimensions are 32x32 (1024)
;======================================
InitSprites     .proc
                php
                phb

                .m16i16
                lda #StampSprites_end-StampSprites
                sta zpSize
                lda #$00
                sta zpSize+2

                lda #<>SPR_Ballon       ; Set the source address
                sta zpSource
                lda #`SPR_Ballon
                sta zpSource+2

                lda #<>(SPRITES-VRAM)   ; Set the destination address
                sta zpDest
                sta SP00_ADDR           ; And set the Vicky register
                sta SP01_ADDR

                clc
                adc #$1400              ; 5*1024
                sta SP02_ADDR
                sta SP03_ADDR

                lda #`(SPRITES-VRAM)
                sta zpDest+2

                .m8
                sta SP00_ADDR+2
                sta SP01_ADDR+2
                sta SP02_ADDR+2
                sta SP03_ADDR+2

                jsr Copy2VRAM

                .m16
                lda #00
                sta SP00_X_POS
                sta SP00_Y_POS
                sta SP01_X_POS
                sta SP01_Y_POS
                sta SP02_X_POS
                sta SP02_Y_POS
                sta SP03_X_POS
                sta SP03_Y_POS

                .m8
                lda #scEnable
                sta SP00_CTRL
                sta SP02_CTRL
                sta SP03_CTRL

                lda #scEnable|scLUT1
                sta SP01_CTRL

                plb
                plp
                rts
                .endproc


;======================================
;
;======================================
CheckCollision  .proc
                .m8i8
                pha
                phx
                phy

                ldx #1                  ; Given: SP02_Y_POS=112
_nextBomb       lda zpBombDrop,X        ; A=112
                beq _nextPlayer

                cmp #132
                bcs _withinRange

                bra _nextPlayer

_withinRange    sec
                sbc #132                ; A=8
                lsr A           ; /2    ; A=4
                lsr A           ; /4    ; A=2
                lsr A           ; /8    ; A=1
                sta zpTemp1             ; zpTemp1=1 (row)

                lda PlayerPosX,X
                lsr A           ; /2
                lsr A           ; /4
                sta zpTemp2             ; (column)

                lda #<CANYON
                sta zpSource
                lda #>CANYON
                sta zpSource+1

                ldy zpTemp1
_nextRow        beq _checkRock
                lda zpSource
                clc
                adc #40
                sta zpSource
                bcc _1

                inc zpSource+1
_1              dey
                bra _nextRow

_checkRock      ldy zpTemp2
                lda (zpSource),Y
                beq _nextPlayer

                ;cmp #4
                ;bcs _nextPlayer

                sta P2PF,X

                .m16
                txa
                and #$FF
                asl A
                tay
                lda zpSource
                stz zpTemp2+1
                clc
                adc zpTemp2
                sta P2PFaddr,Y
                .m8

_nextPlayer     dex
                bpl _nextBomb

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Clear the play area of the screen
;======================================
ClearScreen     .proc
v_QtyPages      .var $04                ; 40x30 = $4B0... 4 pages + 176 bytes
                                        ; remaining 176 bytes cleared via ClearGamePanel

v_EmptyText     .var $00
v_TextColor     .var $40
;---

                php
                pha
                phx
                phy
                .m8i8

;   clear color
                lda #<CS_COLOR_MEM_PTR
                sta zpDest
                lda #>CS_COLOR_MEM_PTR
                sta zpDest+1
                lda #`CS_COLOR_MEM_PTR
                sta zpDest+2

                ldx #v_QtyPages
                lda #v_TextColor
_nextPageC      ldy #$00
_next1C         sta [zpDest],Y

                iny
                bne _next1C

                inc zpDest+1            ; advance to next memory page
                dex
                bne _nextPageC

;   clear text
                lda #<CS_TEXT_MEM_PTR
                sta zpDest
                lda #>CS_TEXT_MEM_PTR
                sta zpDest+1
                lda #`CS_TEXT_MEM_PTR
                sta zpDest+2

                ldx #v_QtyPages
                lda #v_EmptyText
_nextPageT      ldy #$00
_next1T         sta [zpDest],Y

                iny
                bne _next1T

                inc zpDest+1            ; advance to next memory page
                dex
                bne _nextPageT

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Clear the bottom of the screen
;======================================
ClearGamePanel  .proc
v_EmptyText     .var $00
v_TextColor     .var $40
v_RenderLine    .var 24*CharResX
;---

                php
                pha
                phx
                phy
                .m8i8

                lda #<CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest+1
                lda #`CS_COLOR_MEM_PTR+v_RenderLine
                sta zpDest+2

                lda #v_TextColor
                ldy #$00
_next1          sta [zpDest],Y

                iny
                cpy #$F0                ; 6 lines
                bne _next1

                lda #<CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest
                lda #>CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest+1
                lda #`CS_TEXT_MEM_PTR+v_RenderLine
                sta zpDest+2

                lda #v_EmptyText
                ldy #$00
_next2          sta [zpDest],Y

                iny
                cpy #$F0                ; 6 lines
                bne _next2

                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render High Score
;======================================
RenderHiScore   .proc
v_RenderLine    .var 2*CharResX
;---

                php
                pha
                phx
                phy
                .m8i8

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
_processText    ldx #$FF
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
                asl A

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

_XIT            ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render High Score
;======================================
RenderHiScore2  .proc
v_RenderLine    .var 24*CharResX
;---

                php
                pha
                phx
                phy
                .m8i8

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
_processText    ldx #$FF
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
                asl A

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

_XIT            ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Title
;======================================
RenderTitle     .proc
v_RenderLine    .var 24*CharResX
;---

                php
                pha
                phx
                phy
                .m8i8

;   reset color for twp 40-char lines
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
_processText    ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$50
                beq _XIT

                lda TitleMsg,Y
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT            ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Author
;======================================
RenderAuthor    .proc
v_RenderLine    .var 26*CharResX
;---

                php
                .m8i8

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
_processText    ldx #$FF
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

_XIT            plp
                rts
                .endproc


;======================================
; Render SELECT (Qty of Players)
;======================================
RenderSelect    .proc
v_RenderLine    .var 27*CharResX
;---

                php
                pha
                phx
                phy
                .m8i8

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
_processText    ldx #$FF
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
                asl A

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

_XIT            ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Title
;======================================
RenderPlayers   .proc
v_RenderLine    .var 26*CharResX
;---

                php
                pha
                phx
                phy
                .m8i8

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
_processText    ldx #$FF
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
                asl A

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

_XIT            ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Player Scores & Bombs
;--------------------------------------
; preserves:
;   X Y
;======================================
RenderScore     .proc
v_RenderLine    .var 27*CharResX
;---

                php
                pha
                phx
                phy
                .m8i8

;   if game is not in progress then exit
                lda zpWaitForPlay
                bne _XIT

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
_processText    ldx #$FF
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
                asl A

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

_XIT            ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Render Canyon
;======================================
RenderCanyon    .proc
v_RenderLine    .var 13*CharResX
;---

                php
                pha
                phx
                phy
                .m8i16

                ldx #$FFFF
                ldy #$FFFF
_nextChar       inx
                iny
                cpy #440
                beq _XIT

                lda CANYON,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$84
                bcc _boulder

_earth          eor #$80
                pha

                lda #$E0
                sta CS_COLOR_MEM_PTR+v_RenderLine,X

                pla
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_space          lda #$00
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_boulder        phy
                xba
                lda #$00
                xba
                tay
                lda CanyonColors,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                ply

                lda #$01
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT            .m8i8
                ply
                plx
                pla
                plp
                rts
                .endproc


;======================================
; Copye data from system RAM to VRAM
;--------------------------------------
;   zpSource    address of source data
;               (system RAM)
;   zpDest      address of destination
;               (video RAM)
;   zpSize      number of bytes
;======================================
Copy2VRAM       .proc
                php
                .setbank `SDMA_SRC_ADDR
                .setdp zpSource
                .m8

    ; Set SDMA to go from system to video RAM, 1D copy
                lda #sdcSysRAM_Src|sdcEnable
                sta SDMA0_CTRL

    ; Set VDMA to go from system to video RAM, 1D copy
                lda #vdcSysRAM_Src|vdcEnable
                sta VDMA_CTRL

                .m16i8
                lda zpSource            ; Set the source address
                sta SDMA_SRC_ADDR
                ldx zpSource+2
                stx SDMA_SRC_ADDR+2

                lda zpDest              ; Set the destination address
                sta VDMA_DST_ADDR
                ldx zpDest+2
                stx VDMA_DST_ADDR+2

                .m16
                lda zpSize              ; Set the size of the block
                sta SDMA_SIZE
                sta VDMA_SIZE
                lda zpSize+2
                sta SDMA_SIZE+2
                sta VDMA_SIZE+2

                .m8
                lda VDMA_CTRL           ; Start the VDMA
                ora #vdcStart_TRF
                sta VDMA_CTRL

                lda SDMA0_CTRL          ; Start the SDMA
                ora #sdcStart_TRF
                sta SDMA0_CTRL

                nop                     ; VDMA involving system RAM will stop the processor
                nop                     ; These NOPs give Vicky time to initiate the transfer and pause the processor
                nop                     ; Note: even interrupt handling will be stopped during the DMA
                nop

wait_vdma       lda VDMA_STATUS         ; Get the VDMA status
                bit #vdsSize_Err|vdsDst_Add_Err|vdsSrc_Add_Err
                bne vdma_err            ; Go to monitor if there is a VDMA error
                bit #vdsVDMA_IPS        ; Is it still in process?
                bne wait_vdma           ; Yes: keep waiting

                lda #0                  ; Make sure DMA registers are cleared
                sta SDMA0_CTRL
                sta VDMA_CTRL

                .setdp $0000
                .setbank $00
                .m8i8
                plp
                rts

vdma_err        brk
                .endproc


;======================================
;
;======================================
InitIRQs        .proc
                pha

;   enable vertical blank interrupt
                .m8i8
                ldx #HandleIrq.HandleIrq_END-HandleIrq
_relocate       ;lda @l $024000,X       ; HandleIrq address
                ;sta @l $002000,X       ; new address within Bank 00
                ;dex
                ;bpl _relocate

                sei                     ; disable IRQ

                .m16
                ;lda @l vecIRQ
                ;sta IRQ_PRIOR

                lda #<>HandleIrq
                sta @l vecIRQ

                .m8
                lda #$07                ; reset consol
                sta CONSOL

                lda #$1F
                sta InputFlags
                stz InputType           ; joystick

                lda @l INT_MASK_REG0
                and #~FNX0_INT00_SOF    ; enable Start-of-Frame IRQ
                sta @l INT_MASK_REG0

                lda @l INT_MASK_REG1
                and #~FNX1_INT00_KBD    ; enable Keyboard IRQ
                sta @l INT_MASK_REG1

                cli                     ; enable IRQ

                pla
                rts
                .endproc


;======================================
;
;======================================
SetFont         .proc
                php
                pha
                phx
                phy

;   DEBUG: helpful if you need to see the trace
                ; bra _XIT

                .m8i8
                lda #<GameFont
                sta zpSource
                lda #>GameFont
                sta zpSource+1
                lda #`GameFont
                sta zpSource+2

                lda #<FONT_MEMORY_BANK0
                sta zpDest
                lda #>FONT_MEMORY_BANK0
                sta zpDest+1
                lda #`FONT_MEMORY_BANK0
                sta zpDest+2

                ldx #$07                ; 7 pages
_nextPage       ldy #$00
_next1          lda [zpSource],Y
                sta [zpDest],Y

                iny
                bne _next1

                inc zpSource+1
                inc zpDest+1

                dex
                bne _nextPage

_XIT            ply
                plx
                pla
                plp
                rts
                .endproc
