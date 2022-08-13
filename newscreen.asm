;--------------------------------------
;
;--------------------------------------
NewScreen       .proc
                jsr DrawScreen          ; set canyon

                lda #stBalloon          ; set type to Balloon
                sta zpShipType
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

                lda #FALSE              ; set players on screen=false
                sta onScreen
                ;sta AUDF4

                lda #1                  ; set start positions of players
                sta PlayerPosX
                lda #151
                sta PlayerPosX+1

                stz P2PF                ; clear collisions
                stz P3PF

                lda #8                  ; # of rocks per bomb
                sta RocksPerBomb        ; (max) = 8

                lda DELYVAL             ; speed up the game just a bit
                cmp #$AF
                beq BombLoop            ; (unless already at max speed)

                sec
                sbc #4
                sta DELYVAL

                jmp BombLoop

                .endproc
