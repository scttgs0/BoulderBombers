frsGraphics     .macro
                pha

                lda #\1
                sta MASTER_CTRL_L
                lda #\2
                sta MASTER_CTRL_H

                pla
                .endmacro

frsBorder_off   .macro
                stz BORDER_CTRL
                stz BORDER_X_SIZE
                stz BORDER_Y_SIZE
                .endmacro

frsBorder_on    .macro color,xSize,ySize
                pha

                lda #$01
                sta BORDER_CTRL_REG

                lda \xSize
                sta BORDER_X_SIZE

                lda \ySize
                sta BORDER_Y_SIZE

                lda \color>>16&$FF
                sta BORDER_COLOR_R
                lda \color>>8&$FF
                sta BORDER_COLOR_G
                lda \color&$FF
                sta BORDER_COLOR_B

                pla
                .endmacro
